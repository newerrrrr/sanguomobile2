package classes 
{
	/**
	 * ...
	 * @author WangYongchao
	 */
	public class TypeDefine 
	{
		public static const INT:String = "int";
		public static const STRING:String = "string";
		public static const ARRAY:String = "array";
		public static const GROUP:String = "group";
		public function TypeDefine() 
		{
			
		}
		
		public static function isVaildType(type:String):Boolean
		{
			var isVaild:Boolean = false;
			if (type == INT ||type == STRING ||type == ARRAY ||type == GROUP)
			{
				isVaild = true;
			}
			return isVaild;
		} 
		
		public static function getDefaultValueByType(type:String):String
		{
			var ret:String = "";
			if (type == INT)
			{
				ret = "0";
			}
			else if (type == ARRAY)
			{
				ret = '"{}"';
			}
			else if (type == GROUP )
			{
				ret = '"{}"';
			}
			return ret;
		} 
		
	}

}