package classes 
{
	/**
	 * ...
	 * @author WangYongchao
	 */
	
	 //16进制颜色和RGB颜色值的相互转换
	public class ColorTransition
	{
		public static function extractRed(c:uint):uint {
			
			return (( c >> 16 ) & 0xFF);
			
		}

		public static function extractGreen(c:uint):uint {
			
			return ( (c >> 8) & 0xFF );
			
		}

		public static function extractBlue(c:uint):uint {
			
			return ( c & 0xFF );
			
		}


		public static function extractAlpha(c:uint):uint {
			return (( c >> 24 ) & 0xFF);
		}

		/*
		The very useful function below takes RGB components (each must be between 0 and 255)
		and returns the numerical representation of the resulting color.
		*/

		///// Function that combines red, green and blue components in to a color value. /////

		public static function combineRGB(r:uint,g:uint,b:uint):uint {
			
			return ( ( r<< 16 ) | ( g << 8 ) | b );
			
		}

		public static function combineARGB(a:uint,r:uint,g:uint,b:uint):uint {
			return ( (a << 24) | ( r << 16 ) | ( g << 8 ) | b );
		}

	}

}