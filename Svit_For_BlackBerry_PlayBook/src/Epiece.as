package
{
	import qnx.ui.display.Image;

	public class Epiece
	{
		public static const TYPE_P:int = 0; 
		public static const TYPE_H1:int = 1; 
		public static const TYPE_H2:int = 2; 
		public static const TYPE_H3:int = 3; 
		public static const TYPE_H4:int = 4; 
		public static const TYPE_H5:int = 5; 
		public static const TYPE_H6:int = 6; 
		public static const TYPE_NEW_LINE:int = 7; 
		public static const TYPE_IMAGE:int = 8; 
		
		public var value:String; 
		public var type:int; 
		public var firstInParagraph:Boolean;
		public var bookmarked:Boolean;
		public var highlighted:Boolean;
		
		public var xLandscape:int; 
		public var yLandscape:int;
		public var widthLandscape:int; 
		public var heightLandscape:int;
		
		public var xPortrait:int; 
		public var yPortrait:int; 
		public var widthPortrait:int; 
		public var heightPortrait:int;
		
		public var image:Image;
		public var imagePath:String;
		public var width:int; 
		public var height:int;
		
		public function Epiece(value:String, type:int, firstInParagraph:Boolean = false, bookmarked:Boolean = false,
			highlighted:Boolean = false):void
		{
			this.value = value;
			this.type = type;
			this.firstInParagraph = firstInParagraph;
			this.bookmarked = bookmarked;
			this.highlighted = highlighted;
			reset();
		}
		
		public function reset():void
		{
			this.xLandscape = 0; 
			this.yLandscape = 0; 
			this.widthLandscape = 0; 
			this.heightLandscape = 0;
			
			this.xPortrait = 0; 
			this.yPortrait = 0; 
			this.widthPortrait = 0; 
			this.heightPortrait = 0;
		}
	}
}