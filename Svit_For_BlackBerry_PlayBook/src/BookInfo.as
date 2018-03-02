package
{
	import flash.net.SharedObject;
	import flash.net.registerClassAlias;

	public class BookInfo
	{
		public static var currWord:int = 0;
		public static var bookmarks:Array = new Array();
		public static var highlights:Array = new Array();
		
		public function BookInfo()
		{
		}
		
		public static function reset(title:String):void
		{
			currWord = 0;
			bookmarks = new Array();
			highlights = new Array();
		}

		public static function load(title:String):void
		{
			var so:SharedObject = SharedObject.getLocal(normalizeName("svit-" + title));
			
			if (so.data.currWord == undefined)
			{
				currWord = 0;
				store(title);
			}
			if (so.data.bookmarks == undefined)
			{
				bookmarks = new Array();
				store(title);
			}
			if (so.data.highlights == undefined)
			{
				highlights = new Array();
				store(title);
			}
			
			currWord = so.data.currWord;
			bookmarks = so.data.bookmarks;
			highlights = so.data.highlights;
			so.close();
		}
		
		public static function store(title:String):void
		{
			var so:SharedObject = SharedObject.getLocal(normalizeName("svit-" + title));
			so.data.currWord = currWord;
			so.data.bookmarks = bookmarks;
			so.data.highlights = highlights;
			so.flush();
			so.close();
		}

		public static function remove(title:String):void
		{
			var so:SharedObject = SharedObject.getLocal(normalizeName("svit-" + title));
			so.data.currWord = undefined;
			so.data.bookmarks = undefined;
			so.data.highlights = undefined;
			so.flush();
			so.close();
		}
		
		private static function normalizeName(str:String):String
		{
			while (str.indexOf(" ") > -1)
			{
				str = str.replace(" ", "");						
			}
			while (str.indexOf("~") > -1)
			{
				str = str.replace("~", "");						
			}
			while (str.indexOf("%") > -1)
			{
				str = str.replace("%", "");						
			}
			while (str.indexOf("&") > -1)
			{
				str = str.replace("&", "");						
			}
			while (str.indexOf("\\") > -1)
			{
				str = str.replace("\\", "");						
			}
			while (str.indexOf(";") > -1)
			{
				str = str.replace(";>", "");						
			}
			while (str.indexOf(":") > -1)
			{
				str = str.replace(":", "");						
			}
			while (str.indexOf("'") > -1)
			{
				str = str.replace("'", "");						
			}
			while (str.indexOf(",") > -1)
			{
				str = str.replace(",", "");						
			}
			while (str.indexOf("<") > -1)
			{
				str = str.replace("<", "");						
			}
			while (str.indexOf(">") > -1)
			{
				str = str.replace(">", "");						
			}
			while (str.indexOf("?") > -1)
			{
				str = str.replace("?", "");						
			}
			while (str.indexOf("#") > -1)
			{
				str = str.replace("#", "");						
			}
			return str;
		}
	}
}