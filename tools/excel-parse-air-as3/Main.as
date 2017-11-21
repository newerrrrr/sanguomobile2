package  {
	
	/**
	 * ...
	 * @author WangYongchao
	 */
	
	import flash.display.MovieClip;
	import com.childoftv.XLSXLoader;
	import com.childoftv.Worksheet;
	import flash.events.Event;
	import classes.TypeDefine;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.events.FileListEvent;
	import flash.events.IOErrorEvent;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	public class Main extends MovieClip 
	{
		
		private var loader:XLSXLoader;
		private var dataLength:int = 0;
		private const TAB:String = "	";
		private var _list:Array;
		private var _exportIndex:int = 0;
		private var _floderPath:String = "";
		private var directory:File = File.applicationDirectory.resolvePath("Data");
		private var _allSheetNames:Vector.<String>;
		public function Main() 
		{
			btnStart.addEventListener(MouseEvent.CLICK, startHandler);
			btnSet.addEventListener(MouseEvent.CLICK, selectFloder);
			logTxt.text = "";

			loadPathConfig();
		}
		
		//加载已经选择保存的路径
		private function loadPathConfig():void
		{
			var file:File = new File(File.documentsDirectory.resolvePath("path_cache").nativePath);
			if (file.exists)
			{
				var fs:FileStream = new FileStream();          
				fs.open(file,FileMode.READ);  //以只读方式打开 
				var str:String = fs.readUTFBytes(fs.bytesAvailable);
				
				if (str == "")//如果没选择过，直接弹出选择框
				{
					selectFloder();
				}
				else
				{
					directory = new File(str);
				}
				fs.close();
			}
			else
			{
				selectFloder();
			}
			
		}
		
		//弹出选择文件夹窗口
		private function selectFloder(e:MouseEvent = null):void
		{
			try
			{
				directory.browseForDirectory("Select Directory");
				directory.addEventListener(Event.SELECT, directorySelected);
			}
			catch (error:Error)
			{
				trace("Failed:", error.message);
				logTxt.text = "Failed:" +error.message;
			}

			function directorySelected(event:Event):void 
			{
				
				directory = event.target as File;
				
				//把选择的路径保存
				var file:File = new File(File.documentsDirectory.resolvePath("path_cache").nativePath);
				var fs:FileStream = new FileStream();    
				fs.open(file,FileMode.WRITE); 
				fs.writeUTFBytes(directory.url);
				fs.close();
				
				logTxt.text = "设置Excel文件目录成功";
				//trace(directory.url);
				//var files:Array = directory.getDirectoryListing();
				//for(var i:uint = 0; i < files.length; i++)
				//{
					//trace(files[i].name);
				//}
			}
		}
		
		private function startHandler(e:MouseEvent):void
		{
			loadFloder();
		}
		
		private function loadFloder():void
		{
			logTxt.text = "读取文件列表...";
			//var directory:File = File.desktopDirectory.resolvePath(_fPath);
			//var directory:File = new File("file:///C:/workspace/sanguo_mobile_2/sanguo_mobile_2_client/trunk/sanguo_mobile_2/tools/Data");
			_floderPath = directory.url + "/";
			trace(directory.url);
			directory.getDirectoryListingAsync();
			directory.addEventListener(FileListEvent.DIRECTORY_LISTING, imageDirectoryListingHandler);
		}
		
		private function imageDirectoryListingHandler(event:FileListEvent):void 
		{
			logTxt.text = "读取文件列表成功,正在准备生成Lua文件...";
			var listAll:Array = event.files;
			var list:Array = new Array();
			for (var i:uint = 0; i < listAll.length; i++) 
			{
				var mext:String = listAll[i].extension;
				trace(listAll[i].name);
				var startStr:String = listAll[i].name.substr(0, 1);
				if (mext && startStr != "." && startStr != "~")
				{
					if (mext.toLowerCase() == "xlsx")
					{
						list.push(listAll[i]);
					}
				}
			}
			_list = list;
			startExport();
		}
		
		private function startExport():void
		{
			_exportIndex = 0;
			_allSheetNames = new Vector.<String>();
			if (_list.length <= 0)
			{
				logTxt.text = "指定文件夹没有*.xlsx文件，请检查文件夹或者重新设置文件目录";
			}
			
			var file:File=new File(); 
			file.nativePath = File.applicationDirectory.nativePath + '/lua';
			if (file.exists)
			{
				file.deleteDirectory(true);
			}
			

			var fileName:String = _list[_exportIndex].name;
			logTxt.text = "加载" + fileName + "...";
			trace("language.xlsx:",fileName.toLowerCase() == "language.xlsx");
			load(_floderPath + fileName,fileName.toLowerCase() == "language.xlsx");
			
		}
		
		private function load(fileName:String,exportColorFlag:Boolean = false):void
		{
			if (loader)
			{
				loader.removeEventListener("complete",loadCompleteHandler);
				loader.close();
				loader = null;
			}
			dataLength = 0;
			loader = new XLSXLoader();
			loader.addEventListener("complete", loadCompleteHandler);
			loader.load(fileName,exportColorFlag);
		}
		
		private function loadCompleteHandler(e:Event):void
		{
			
			//trace("file loaded");
			var sheetNames:Vector.<String> = loader.getSheetNames();
			logTxt.text = "正在导出 " + sheetNames + "，请耐心等待...";
			trace("sheetNames:",sheetNames);
			for each ( var sheetName:String in sheetNames)
			{
				_allSheetNames.push(sheetName);
				
				var vaildTypeColumnNames:Array = [];
				dataLength = 0;
				
				var sheet:Worksheet = loader.worksheet(sheetName);
				
				var strToWrite:String = "local " + sheetName+"Config = {\n";
				
				var columnInfos:Vector.<Object> = getVaildColumnNames(sheet);
				
				for (var i:int = 0; i < dataLength;i ++ )
				{
					
					if (i >= 2)
					{
						strToWrite += TAB + "{\n";
						for each ( var columnInfo:Object in columnInfos)
						{
							var contentXmlList:XMLList = columnInfo.values_list
							var keyName:String = columnInfo.key_name;
							var type:String = columnInfo.type;
							var value:String = "";
							if (contentXmlList[columnInfo.cloumn_idx])
							{
								
								var pattern:RegExp = /([0-9]+)/;
								var columnIdx:int = int(contentXmlList[columnInfo.cloumn_idx].@r.match(pattern)[0]);
								//trace("cidx:",columnIdx,"i + 1:",i + 1);
								if (columnIdx == (i+1))
								{
									//trace(columnInfo.c_name + " columnIdx:",columnIdx,"real xml idx:",columnInfo.cloumn_idx);
									value = contentXmlList[columnInfo.cloumn_idx].toString();
									columnInfo.cloumn_idx ++;
									
								}
								
							}
							
							
							if (value == "")
							{
								//value = TypeDefine:getDefaultValueByType(type);
								if (type == TypeDefine.INT)
								{
									value = "0";
								}
								else if (type == TypeDefine.ARRAY)
								{
									value = '{}';
								}
								else if (type == TypeDefine.GROUP )
								{
									value = '{}';
								}
								else if (type == TypeDefine.STRING )
								{
									value = '""';
								}
							}
							else
							{
								if (type == TypeDefine.ARRAY)
								{
									value = "{" + value + "}";
									//trace(value);
								}
								else if (type == TypeDefine.STRING )
								{
									value = '"' + value + '"';
								}
								else if (type == TypeDefine.GROUP )
								{
									var newValue:String = "{";
									//  drop_data = {{1,10600,2000,10,},} ,
									var my_array:Array = value.split(";"); 
									for (var k = 0; k < my_array.length; k++) 
									{ 
										newValue += "{" + my_array[k] +"},";
									} 
									
									newValue += "}";
									value = newValue;
								}
							}
							
							strToWrite += TAB + TAB + keyName + " = " + value + ",\n";
						}
						strToWrite += TAB + "},\n";
					}
					
				}
				
				strToWrite += "\n}\nreturn " + sheetName+"Config";
				//trace(strToWrite);
				
				var file:File = new File(File.applicationDirectory.resolvePath("lua/" +sheetName+".lua").nativePath);
				var fs:FileStream = new FileStream();         
				
				fs.open(file,FileMode.WRITE); 
				fs.writeUTFBytes(strToWrite);
				fs.close();
				
				//for test
				//trace(sheetXml);
				//trace(sheet.getRowAsValues(2, 2));
				//trace(sheet.getRow(2, 2));
				//trace(sheet.getRowAsValues());
				//trace(sheet.getRowAsValues(3,3));
				//for each(var row in sheetXml.sheetData.row.(@r == "2"))
				//{
					//trace(row);
				//}
				//trace("Cell A3="+sheet.getCellValue("A1")) //outputs: Cell A3=Hello World;
				//trace(sheet.toXMLString)
			}
			
			
			//继续下一个文件
			trace("list length:", _list.length);
			_exportIndex++;
			if (_exportIndex > _list.length - 1)
			{
				
		
				var fileTablelist:File = new File(File.applicationDirectory.resolvePath("lua/_GGobalDefine.lua").nativePath);
				var fsTableList:FileStream = new FileStream();     
				
				var strTb:String = "local gobalDefine = {\n" + TAB + "TableList={\n";
				for each ( var msheetName:String in _allSheetNames)
				{
					strTb += TAB + '"' + msheetName + '",\n'
				}
				strTb += TAB + "}\n}\nreturn gobalDefine"
				
				
				fsTableList.open(fileTablelist,FileMode.WRITE); 
				fsTableList.writeUTFBytes(strTb);
				fsTableList.close();
		
				
				logTxt.text = "全部数据导出完成！";
				return;
			}
			var fileName:String = _list[_exportIndex].name;
			load(_floderPath + fileName);
		
		}
		
		private function getVaildColumnNames(sheet:Worksheet):Vector.<Object>
		{
			var rowIdx:int = 2;//类型所在的行号
			
			var xmlList:XMLList = sheet.getRowAsValues(rowIdx, rowIdx);
			var names:Vector.<Object> = new Vector.<Object>();
			var length:int = xmlList.length();
			
			//trace(xmlList);
			
			for (var i:int = 0; i < length; i++ )
			{
				var mtype:String = xmlList[i].toString();
				mtype = mtype.toLowerCase();
				
				
				if (TypeDefine.isVaildType(mtype))
				{
					
					var cName:String = xmlList.@r[i].match(/^[A-Z]+/)[0];
					var valuesList:XMLList = sheet.getRowsAsValues(cName);
					var keyName:String = sheet.getCellValue(cName + "1");
					trace("cname:",cName,"type:",mtype);
					if (cName == "A")
					{
						//trace(valuesList);
						//dataLength = valuesList.length();
						var cnt:int = 0;
						for each(var val:String in valuesList)
						{
							if (val != "")
							{
								cnt++;
							}
						}
						dataLength = cnt;
					}
					
					names.push({c_name:cName,type:mtype,values_list:valuesList,key_name:keyName,cloumn_idx:2});
				}
			}
			return names;
		}
	}
	
}
