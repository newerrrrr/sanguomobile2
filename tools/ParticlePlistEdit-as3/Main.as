package  
{
	import flash.display.Sprite;
	import flash.events.Event;
	import owen.utils.ParseXML;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.events.FileListEvent;
	import flash.events.IOErrorEvent;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import gs.TweenLite;
	/**
	 * ...
	 * @author WangYongchao
	 */
	public class Main extends Sprite 
	{
		private var _parseXml:ParseXML;
		private var _type:int = 2;
		private var filesPathList:Array = new Array();
		private var _idx:int = 0;
		
		private var _errorCnt:int = 0;
		private var _doneCnt:int = 0;
		private var filePath:String = null;
		private var m_xml:XML;
		private var tip:TipMc;
		public function Main() 
		{
			inputTxt.restrict = "0-9";
			btnSend.addEventListener(MouseEvent.CLICK, loadFileList);
		}
		
		private function loadFileList(e:MouseEvent):void
		{
			var mtype:int = int(inputTxt.text);
			if ( mtype > 2 )
			{
				mtype = 2;
			}
			_type = mtype;
			
			var directory:File = File.applicationDirectory.resolvePath("plists");
			directory.getDirectoryListingAsync();
			directory.addEventListener(FileListEvent.DIRECTORY_LISTING, plistDirectoryListingHandler);
		}
		
		private function plistDirectoryListingHandler(event:FileListEvent):void 
		{
			filesPathList = [];
			_idx = 0;
			_errorCnt = 0;
			_doneCnt = 0;
			var list:Array = event.files;
			for (var i:uint = 0; i < list.length; i++) 
			{
				trace(list[i].extension, list[i].name);
				var ext:String = list[i].extension;
				if (ext.toLowerCase() == "plist")
				{
					filesPathList.push("plists/" + list[i].name);
				}
			}
			
			if (filesPathList.length > 0)
			{
				_idx = 0;
				startModifily();
			}
			else
			{
				tips("安装目录 plists 文件夹下没有plist文件");
			}
		}
		private function tips(str)
		{
			if (!tip)
			{
				tip = new TipMc();
				addChild(tip)
				tip.x = 550 / 2;
				tip.y = 400 / 2;
			}
			tip.alpha = 0;
			tip.txt.text = str;
			TweenLite.to(tip, 0.5, { alpha:1 } );
		}
		
		private function startModifily()
		{
			if (_idx >= filesPathList.length)
			{
				trace("finish!  处理个数:" + _doneCnt);
				tips("success!  处理个数:" + _doneCnt);
				return;
			}
			
			//var file:File = File.applicationDirectory.resolvePath(filesPathList[_idx]);
			var file:File =new File(File.applicationDirectory.resolvePath(filesPathList[_idx]).nativePath);
			var fs:FileStream = new FileStream();          
			fs.open(file,FileMode.READ);  //以只读方式打开 
			m_xml = new XML(fs.readUTFBytes(fs.bytesAvailable));  //获取xml内容 
			
			var isParticlePlist:Boolean = false;
			
			
			var keys:XMLList = m_xml.dict.key;
			var matchCnt:int = 0;
		　　for (var key:String in keys)
			{
			　　trace(keys[key]);
				var keyName:String = keys[key];
				if (keyName == "startParticleSize" || keyName == "textureFileName" || keyName == "startParticleSizeVariance")
				{
					matchCnt++;
				}
		　　}
			
			if (matchCnt == 3)
			{
				
				if (m_xml.dict.key[0] == "lhsPositionType")
				{
					m_xml.dict.integer[0] = _type;
				}
				else
				{
					m_xml.dict.prependChild(<integer>{_type}</integer>);
					m_xml.dict.prependChild(<key>lhsPositionType</key>);
				}
				
				var str:String = '<?xml version="1.0" encoding="UTF-8"?> \n' +  '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"> \n'
				
				fs.open(file,FileMode.WRITE); 
				fs.writeUTFBytes(str + m_xml.toXMLString())   //写入修改过后的XML 
				
				
				trace("modify ok");
				_doneCnt ++;
			}
			
			fs.close();
			
			_idx ++;
			startModifily();
			
		}
	}

}