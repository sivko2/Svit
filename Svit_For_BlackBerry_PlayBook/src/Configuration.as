package
{
	import flash.net.SharedObject;
	import flash.text.Font;

	public class Configuration
	{
		public static var fontNames:Array = new Array();
		public static var fontNamePos:int = 6;
		
		public static var fontSizes:Array = [13, 16, 19, 22, 25];
		public static var fontSizePos:int = 2;
		
		public static var nightMode:Boolean = false;
		public static var fontName:Boolean = false;

		public static var backgroundColor:int = 0;

		public function Configuration()
		{
		}
		
		public static function load():void
		{
			var allFonts:Array = Font.enumerateFonts(true);
			for each (var font:Font in allFonts)
			{
				fontNames[fontNames.length] = font.fontName;
			}

			var so:SharedObject = SharedObject.getLocal("svit-config");
			
			if (so.data.fontNamePos == undefined)
			{
				store();
			}
			
			fontNamePos = so.data.fontNamePos;
			fontSizePos = so.data.fontSizePos;
			nightMode = so.data.nightMode;
			backgroundColor = so.data.backgroundColor;

			if (so.data.backgroundColor == undefined)
			{
				backgroundColor = 0;
				store();
			}
		}
		
		public static function store():void
		{
			var so:SharedObject = SharedObject.getLocal("svit-config");
			so.data.fontNamePos = fontNamePos;
			so.data.fontSizePos = fontSizePos;
			so.data.nightMode = nightMode;
			so.data.backgroundColor = backgroundColor;
			so.flush();
		}
	}
}