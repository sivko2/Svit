package
{
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextLineMetrics;
	
	import org.osmf.containers.MediaContainer;
	
	import qnx.ui.display.Image;

	public class BookCreator
	{
		public const SCREEN_WIDTH_LANDSCAPE:int = 1024;
		public const SCREEN_HEIGHT_LANDSCAPE:int = 600;
		public const SCREEN_WIDTH_PORTRAIT:int = 600;
		public const SCREEN_HEIGHT_PORTRAIT:int = 1024;

		public const DELTA_X:int = 50;
		public const DELTA_Y:int = 50;
		
		public var pageIndexLandscape:Array; 
		public var pageIndexPortrait:Array; 

		public var pieces:Array;
		
		public var pFormat:TextFormat;
		public var h1Format:TextFormat;
		public var h2Format:TextFormat;
		public var h3Format:TextFormat;
		public var h4Format:TextFormat;
		public var h5Format:TextFormat;
		public var h6Format:TextFormat;
		
		public var upFormat:TextFormat;
		public var uh1Format:TextFormat;
		public var uh2Format:TextFormat;
		public var uh3Format:TextFormat;
		public var uh4Format:TextFormat;
		public var uh5Format:TextFormat;
		public var uh6Format:TextFormat;

		public var pNightFormat:TextFormat;
		public var h1NightFormat:TextFormat;
		public var h2NightFormat:TextFormat;
		public var h3NightFormat:TextFormat;
		public var h4NightFormat:TextFormat;
		public var h5NightFormat:TextFormat;
		public var h6NightFormat:TextFormat;

		public var upNightFormat:TextFormat;
		public var uh1NightFormat:TextFormat;
		public var uh2NightFormat:TextFormat;
		public var uh3NightFormat:TextFormat;
		public var uh4NightFormat:TextFormat;
		public var uh5NightFormat:TextFormat;
		public var uh6NightFormat:TextFormat;
		
		public var pField:TextField;
		public var h1Field:TextField;
		public var h2Field:TextField;
		public var h3Field:TextField;
		public var h4Field:TextField;
		public var h5Field:TextField;
		public var h6Field:TextField;
		
		private var metrics:TextLineMetrics;
		
		public var charWidths:Array;
		
		public var spaceWidth:int; 
		public var spaceHeight:int; 
		public var spaceH1Width:int; 
		public var spaceH1Height:int; 
		public var spaceH2Width:int; 
		public var spaceH2Height:int; 
		public var spaceH3Width:int; 
		public var spaceH3Height:int; 
		public var spaceH4Width:int; 
		public var spaceH4Height:int; 
		public var spaceH5Width:int; 
		public var spaceH5Height:int; 
		public var spaceH6Width:int; 
		public var spaceH6Height:int; 

		public function BookCreator()
		{
			pFormat = new TextFormat();
			h1Format = new TextFormat();
			h2Format = new TextFormat();
			h3Format = new TextFormat();
			h4Format = new TextFormat();
			h5Format = new TextFormat();
			h6Format = new TextFormat();
			
			pNightFormat = new TextFormat();
			h1NightFormat = new TextFormat();
			h2NightFormat = new TextFormat();
			h3NightFormat = new TextFormat();
			h4NightFormat = new TextFormat();
			h5NightFormat = new TextFormat();
			h6NightFormat = new TextFormat();
			
			upFormat = new TextFormat();
			uh1Format = new TextFormat();
			uh2Format = new TextFormat();
			uh3Format = new TextFormat();
			uh4Format = new TextFormat();
			uh5Format = new TextFormat();
			uh6Format = new TextFormat();
			
			upNightFormat = new TextFormat();
			uh1NightFormat = new TextFormat();
			uh2NightFormat = new TextFormat();
			uh3NightFormat = new TextFormat();
			uh4NightFormat = new TextFormat();
			uh5NightFormat = new TextFormat();
			uh6NightFormat = new TextFormat();
			
			pField = new TextField();
			h1Field = new TextField();
			h2Field = new TextField();
			h3Field = new TextField();
			h4Field = new TextField();
			h5Field = new TextField();
			h6Field = new TextField();
			
		}
		
		public function setToCurrentFontValues():void
		{
			pFormat.font = Configuration.fontNames[Configuration.fontNamePos];
			pFormat.size = Configuration.fontSizes[Configuration.fontSizePos];
			pFormat.color = 0x000000;
			
			h1Format.font = Configuration.fontNames[Configuration.fontNamePos];
			h1Format.size = Configuration.fontSizes[Configuration.fontSizePos] + 1;
			h1Format.italic = true;
			h1Format.color = 0x000000;
			
			h2Format.font = Configuration.fontNames[Configuration.fontNamePos];
			h2Format.size = Configuration.fontSizes[Configuration.fontSizePos] + 1;
			h2Format.bold = true;
			h2Format.color = 0x000000;
			
			h3Format.font = Configuration.fontNames[Configuration.fontNamePos];
			h3Format.size = Configuration.fontSizes[Configuration.fontSizePos] + 2;
			h3Format.bold = true;
			h3Format.color = 0x000000;
			
			h4Format.font = Configuration.fontNames[Configuration.fontNamePos];
			h4Format.size = Configuration.fontSizes[Configuration.fontSizePos] + 3;
			h4Format.bold = true;
			h4Format.color = 0x000000;
			
			h5Format.font = Configuration.fontNames[Configuration.fontNamePos];
			h5Format.size = Configuration.fontSizes[Configuration.fontSizePos] + 4;
			h5Format.bold = true;
			h5Format.color = 0x000000;
			
			h6Format.font = Configuration.fontNames[Configuration.fontNamePos];
			h6Format.size = Configuration.fontSizes[Configuration.fontSizePos] + 4;
			h6Format.bold = true;
			h6Format.underline = true;
			h6Format.color = 0x000000;
			
			pNightFormat.font = Configuration.fontNames[Configuration.fontNamePos];
			pNightFormat.size = Configuration.fontSizes[Configuration.fontSizePos];
			pNightFormat.color = 0xFFFFFF;
			
			h1NightFormat.font = Configuration.fontNames[Configuration.fontNamePos];
			h1NightFormat.size = Configuration.fontSizes[Configuration.fontSizePos] + 1;
			h1NightFormat.italic = true;
			h1NightFormat.color = 0xFFFFFF;
			
			h2NightFormat.font = Configuration.fontNames[Configuration.fontNamePos];
			h2NightFormat.size = Configuration.fontSizes[Configuration.fontSizePos] + 1;
			h2NightFormat.bold = true;
			h2NightFormat.color = 0xFFFFFF;
			
			h3NightFormat.font = Configuration.fontNames[Configuration.fontNamePos];
			h3NightFormat.size = Configuration.fontSizes[Configuration.fontSizePos] + 2;
			h3NightFormat.bold = true;
			h3NightFormat.color = 0xFFFFFF;
			
			h4NightFormat.font = Configuration.fontNames[Configuration.fontNamePos];
			h4NightFormat.size = Configuration.fontSizes[Configuration.fontSizePos] + 3;
			h4NightFormat.bold = true;
			h4NightFormat.color = 0xFFFFFF;
			
			h5NightFormat.font = Configuration.fontNames[Configuration.fontNamePos];
			h5NightFormat.size = Configuration.fontSizes[Configuration.fontSizePos] + 4;
			h5NightFormat.bold = true;
			h5NightFormat.color = 0xFFFFFF;
			
			h6NightFormat.font = Configuration.fontNames[Configuration.fontNamePos];
			h6NightFormat.size = Configuration.fontSizes[Configuration.fontSizePos] + 4;
			h6NightFormat.bold = true;
			h6NightFormat.underline = true;
			h6NightFormat.color = 0xFFFFFF;
			
			upFormat.font = Configuration.fontNames[Configuration.fontNamePos];
			upFormat.size = Configuration.fontSizes[Configuration.fontSizePos];
			upFormat.underline = true;
			upFormat.color = 0x0000ff;
			
			uh1Format.font = Configuration.fontNames[Configuration.fontNamePos];
			uh1Format.size = Configuration.fontSizes[Configuration.fontSizePos];
			uh1Format.bold = true;
			uh1Format.underline = true;
			uh1Format.color = 0x000000;
			
			uh2Format.font = Configuration.fontNames[Configuration.fontNamePos];
			uh2Format.size = Configuration.fontSizes[Configuration.fontSizePos];
			uh2Format.bold = true;
			uh2Format.underline = true;
			uh2Format.color = 0x000000;
			
			uh3Format.font = Configuration.fontNames[Configuration.fontNamePos];
			uh3Format.size = Configuration.fontSizes[Configuration.fontSizePos];
			uh3Format.bold = true;
			uh3Format.underline = true;
			uh3Format.color = 0x000000;
			
			uh4Format.font = Configuration.fontNames[Configuration.fontNamePos];
			uh4Format.size = Configuration.fontSizes[Configuration.fontSizePos];
			uh4Format.bold = true;
			uh4Format.underline = true;
			uh4Format.color = 0x000000;
			
			uh5Format.font = Configuration.fontNames[Configuration.fontNamePos];
			uh5Format.size = Configuration.fontSizes[Configuration.fontSizePos];
			uh5Format.bold = true;
			uh5Format.underline = true;
			uh5Format.color = 0x000000;
			
			uh6Format.font = Configuration.fontNames[Configuration.fontNamePos];
			uh6Format.size = Configuration.fontSizes[Configuration.fontSizePos];
			uh6Format.bold = true;
			uh6Format.underline = true;
			uh6Format.color = 0x000000;
			
			upNightFormat.font = Configuration.fontNames[Configuration.fontNamePos];
			upNightFormat.size = Configuration.fontSizes[Configuration.fontSizePos];
			upNightFormat.underline = true;
			upNightFormat.color = 0xFFFFFF;
			
			uh1NightFormat.font = Configuration.fontNames[Configuration.fontNamePos];
			uh1NightFormat.size = Configuration.fontSizes[Configuration.fontSizePos];
			uh1NightFormat.bold = true;
			uh1NightFormat.underline = true;
			uh1NightFormat.color = 0xFFFFFF;
			
			uh2NightFormat.font = Configuration.fontNames[Configuration.fontNamePos];
			uh2NightFormat.size = Configuration.fontSizes[Configuration.fontSizePos];
			uh2NightFormat.bold = true;
			uh2NightFormat.underline = true;
			uh2NightFormat.color = 0xFFFFFF;
			
			uh3NightFormat.font = Configuration.fontNames[Configuration.fontNamePos];
			uh3NightFormat.size = Configuration.fontSizes[Configuration.fontSizePos];
			uh3NightFormat.bold = true;
			uh3NightFormat.underline = true;
			uh3NightFormat.color = 0xFFFFFF;
			
			uh4NightFormat.font = Configuration.fontNames[Configuration.fontNamePos];
			uh4NightFormat.size = Configuration.fontSizes[Configuration.fontSizePos];
			uh4NightFormat.bold = true;
			uh4NightFormat.underline = true;
			uh4NightFormat.color = 0xFFFFFF;
			
			uh5NightFormat.font = Configuration.fontNames[Configuration.fontNamePos];
			uh5NightFormat.size = Configuration.fontSizes[Configuration.fontSizePos];
			uh5NightFormat.bold = true;
			uh5NightFormat.underline = true;
			uh5NightFormat.color = 0xFFFFFF;
			
			uh6NightFormat.font = Configuration.fontNames[Configuration.fontNamePos];
			uh6NightFormat.size = Configuration.fontSizes[Configuration.fontSizePos];
			uh6NightFormat.bold = true;
			uh6NightFormat.underline = true;
			uh6NightFormat.color = 0xFFFFFF;
			
			if (Configuration.nightMode)
			{
				pField.defaultTextFormat = pNightFormat;
				h1Field.defaultTextFormat = h1NightFormat;
				h2Field.defaultTextFormat = h2NightFormat;
				h3Field.defaultTextFormat = h3NightFormat;
				h4Field.defaultTextFormat = h4NightFormat;
				h5Field.defaultTextFormat = h5NightFormat;
				h6Field.defaultTextFormat = h6NightFormat;
			}
			else
			{
				pField.defaultTextFormat = pFormat;
				h1Field.defaultTextFormat = h1Format;
				h2Field.defaultTextFormat = h2Format;
				h3Field.defaultTextFormat = h3Format;
				h4Field.defaultTextFormat = h4Format;
				h5Field.defaultTextFormat = h5Format;
				h6Field.defaultTextFormat = h6Format;
			}
			
			pField.text = " ";
			metrics = pField.getLineMetrics(0);
			spaceWidth = Math.ceil(metrics.width * 0.4);
			spaceHeight = Math.ceil(metrics.descent + metrics.ascent) + 4;
			Svit.svit.fingerImage.height = spaceHeight;
			
			h1Field.text = " ";
			metrics = h1Field.getLineMetrics(0);
			spaceH1Width = Math.ceil(metrics.width * 0.6);
			spaceH1Height = Math.ceil(metrics.descent + metrics.ascent) + 4;
			
			h2Field.text = " ";
			metrics = h2Field.getLineMetrics(0);
			spaceH2Width = Math.ceil(metrics.width * 0.6);
			spaceH2Height = Math.ceil(metrics.descent + metrics.ascent) + 4;
			
			h3Field.text = " ";
			metrics = h3Field.getLineMetrics(0);
			spaceH3Width = Math.ceil(metrics.width * 0.6);
			spaceH3Height = Math.ceil(metrics.descent + metrics.ascent) + 4;
			
			h4Field.text = " ";
			metrics = h4Field.getLineMetrics(0);
			spaceH4Width = Math.ceil(metrics.width * 0.6);
			spaceH4Height = Math.ceil(metrics.descent + metrics.ascent);
			
			h5Field.text = " ";
			metrics = h5Field.getLineMetrics(0);
			spaceH5Width = Math.ceil(metrics.width * 0.6);
			spaceH5Height = Math.ceil(metrics.descent + metrics.ascent);
			
			h6Field.text = " ";
			metrics = h6Field.getLineMetrics(0);
			spaceH6Width = Math.ceil(metrics.width * 0.6);
			spaceH6Height = Math.ceil(metrics.descent + metrics.ascent);

			charWidths = new Array();
			var field:TextField = new TextField();
			field.defaultTextFormat = pFormat;
			for (var i:int = 0; i < 224; i++)
			{
				field.text = String.fromCharCode(32 + i);
				var metrics:TextLineMetrics = field.getLineMetrics(0);
				charWidths[i] = Math.ceil(metrics.width);
			}
		}
		
		public function prepareIndex():void
		{
			pageIndexLandscape = new Array();
			pageIndexPortrait = new Array();
		}
		
		public function setCoords():void
		{
			setToCurrentFontValues();

			var pagePosLandscape:int = 0;
			var pagePosPortrait:int = 0;
			
			pageIndexLandscape[pagePosLandscape] = 0;
			pageIndexPortrait[pagePosPortrait] = 0;
			
			var posXLandscape:int = DELTA_X;
			var posYLandscape:int = DELTA_Y;
			var posXPortrait:int = DELTA_X;
			var posYPortrait:int = DELTA_Y;
			
			var width:int;
			var charValue:int;
			var piece:Epiece;
			var length:int;

			var startLinePos:int;
			var endLinePos:int;
			var counter:int = -1;
			
			posXLandscape = DELTA_X;
			posYLandscape = DELTA_Y;
			for each(piece in pieces)
			{
				counter++;
				if (piece.type == Epiece.TYPE_NEW_LINE)
				{
					posXLandscape = DELTA_X;
					posYLandscape += int(1.5 * spaceHeight);
					if (posYLandscape > SCREEN_HEIGHT_LANDSCAPE - DELTA_Y - spaceHeight)
					{
						posYLandscape = DELTA_Y;
						pagePosLandscape++;
						pageIndexLandscape[pagePosLandscape] = counter;
					}
				}
				else if (piece.type == Epiece.TYPE_P || piece.type == Epiece.TYPE_IMAGE)
				{
					length = piece.value.length;
					width = 0;
					
					for (var i:int = 0; i < length; i++)
					{
						charValue = piece.value.charCodeAt(i);
						if (charValue < 256)
						{
							width += charWidths[charValue - 32];
						}
						else
						{
							pField.text = piece.value.charAt(i);
							metrics = pField.getLineMetrics(0);
							width += Math.ceil(metrics.width);
						}
					}
					width += 4;
					
					if (posXLandscape > DELTA_X && posXLandscape + width > SCREEN_WIDTH_LANDSCAPE - DELTA_X)
					{
						posXLandscape = DELTA_X;
						posYLandscape += spaceHeight;
						if (posYLandscape > SCREEN_HEIGHT_LANDSCAPE - DELTA_Y - spaceHeight)
						{
							posYLandscape = DELTA_Y;
							pagePosLandscape++;
							pageIndexLandscape[pagePosLandscape] = counter;
						}
					}
					piece.xLandscape = posXLandscape;
					piece.yLandscape = posYLandscape;
					piece.widthLandscape = width;
					piece.heightLandscape = spaceHeight;
					posXLandscape += width + spaceWidth;
				}
				else if (piece.type == Epiece.TYPE_H1)
				{
					h1Field.text = piece.value;
					metrics = h1Field.getLineMetrics(0);
					width = Math.ceil(metrics.width) + 4;
					if (posXLandscape > DELTA_X && posXLandscape + width > SCREEN_WIDTH_LANDSCAPE - DELTA_X)
					{
						posXLandscape = DELTA_X;
						posYLandscape += spaceH1Height;
						if (posYLandscape > SCREEN_HEIGHT_LANDSCAPE - DELTA_Y - spaceHeight)
						{
							posYLandscape = DELTA_Y;
							pagePosLandscape++;
							pageIndexLandscape[pagePosLandscape] = counter;
						}
					}
					piece.xLandscape = posXLandscape;
					piece.yLandscape = posYLandscape;
					piece.widthLandscape = width;
					piece.heightLandscape = spaceH1Height;
					posXLandscape += width + spaceH1Width;
				}
				else if (piece.type ==Epiece.TYPE_H2)
				{
					h2Field.text = piece.value;
					metrics = h2Field.getLineMetrics(0);
					width = Math.ceil(metrics.width) + 4;
					if (posXLandscape > DELTA_X && posXLandscape + width > SCREEN_WIDTH_LANDSCAPE - DELTA_X)
					{
						posXLandscape = DELTA_X;
						posYLandscape += spaceH2Height;
						if (posYLandscape > SCREEN_HEIGHT_LANDSCAPE - DELTA_Y - spaceHeight)
						{
							posYLandscape = DELTA_Y;
							pagePosLandscape++;
							pageIndexLandscape[pagePosLandscape] = counter;
						}
					}
					piece.xLandscape = posXLandscape;
					piece.yLandscape = posYLandscape;
					piece.widthLandscape = width;
					piece.heightLandscape = spaceH2Height;
					posXLandscape += width + spaceH2Width;
				}
				else if (piece.type == Epiece.TYPE_H3)
				{
					h3Field.text = piece.value;
					metrics = h3Field.getLineMetrics(0);
					width = Math.ceil(metrics.width) + 4;
					if (posXLandscape > DELTA_X && posXLandscape + width > SCREEN_WIDTH_LANDSCAPE - DELTA_X)
					{
						posXLandscape = DELTA_X;
						posYLandscape += spaceH3Height;
						if (posYLandscape > SCREEN_HEIGHT_LANDSCAPE - DELTA_Y - spaceHeight)
						{
							posYLandscape = DELTA_Y;
							pagePosLandscape++;
							pageIndexLandscape[pagePosLandscape] = counter;
						}
					}
					piece.xLandscape = posXLandscape;
					piece.yLandscape = posYLandscape;
					piece.widthLandscape = width;
					piece.heightLandscape = spaceH3Height;
					posXLandscape += width + spaceH3Width;
				}
				else if (piece.type == Epiece.TYPE_H4)
				{
					h4Field.text = piece.value;
					metrics = h4Field.getLineMetrics(0);
					width = Math.ceil(metrics.width) + 4;
					if (posXLandscape > DELTA_X && posXLandscape + width > SCREEN_WIDTH_LANDSCAPE - DELTA_X)
					{
						posXLandscape = DELTA_X;
						posYLandscape += spaceH4Height;
						if (posYLandscape > SCREEN_HEIGHT_LANDSCAPE - DELTA_Y - spaceHeight)
						{
							posYLandscape = DELTA_Y;
							pagePosLandscape++;
							pageIndexLandscape[pagePosLandscape] = counter;
						}
					}
					piece.xLandscape = posXLandscape;
					piece.yLandscape = posYLandscape;
					piece.widthLandscape = width;
					piece.heightLandscape = spaceH4Height;
					posXLandscape += width + spaceH4Width;
				}
				else if (piece.type == Epiece.TYPE_H5)
				{
					h5Field.text = piece.value;
					metrics = h5Field.getLineMetrics(0);
					width = Math.ceil(metrics.width) + 4;
					if (posXLandscape > DELTA_X && posXLandscape + width > SCREEN_WIDTH_LANDSCAPE - DELTA_X)
					{
						posXLandscape = DELTA_X;
						posYLandscape += spaceH5Height;
						if (posYLandscape > SCREEN_HEIGHT_LANDSCAPE - DELTA_Y - spaceHeight)
						{
							posYLandscape = DELTA_Y;
							pagePosLandscape++;
							pageIndexLandscape[pagePosLandscape] = counter;
						}
					}
					piece.xLandscape = posXLandscape;
					piece.yLandscape = posYLandscape;
					piece.widthLandscape = width;
					piece.heightLandscape = spaceH5Height;
					posXLandscape += width + spaceH5Width;
				}
				else if (piece.type == Epiece.TYPE_H6)
				{
					h6Field.text = piece.value;
					metrics = h6Field.getLineMetrics(0);
					width = Math.ceil(metrics.width) + 4;
					if (posXLandscape > DELTA_X && posXLandscape + width > SCREEN_WIDTH_LANDSCAPE - DELTA_X)
					{
						posXLandscape = DELTA_X;
						posYLandscape += spaceH6Height;
						if (posYLandscape > SCREEN_HEIGHT_LANDSCAPE - DELTA_Y - spaceHeight)
						{
							posYLandscape = DELTA_Y;
							pagePosLandscape++;
							pageIndexLandscape[pagePosLandscape] = counter;
						}
					}
					piece.xLandscape = posXLandscape;
					piece.yLandscape = posYLandscape;
					piece.widthLandscape = width;
					piece.heightLandscape = spaceH6Height;
					posXLandscape += width + spaceH6Width;
				}
			}

			counter = -1;
			posXPortrait = DELTA_X;
			posYPortrait = DELTA_Y;
			for each(piece in pieces)
			{
				counter++;
				if (piece.type == Epiece.TYPE_NEW_LINE)
				{
					posXPortrait = DELTA_X;
					posYPortrait += int(1.5 * spaceHeight);
					if (posYPortrait > SCREEN_HEIGHT_PORTRAIT - DELTA_Y - spaceHeight)
					{
						posYPortrait = DELTA_Y;
						pagePosPortrait++;
						pageIndexPortrait[pagePosPortrait] = counter;
					}
				}
				else if (piece.type == Epiece.TYPE_P || piece.type == Epiece.TYPE_IMAGE)
				{
					length = piece.value.length;
					width = 0;
					for (var i:int = 0; i < length; i++)
					{
						charValue = piece.value.charCodeAt(i);
						if (charValue < 256)
						{
							width += charWidths[charValue - 32];
						}
						else
						{
							pField.text = piece.value.charAt(i);
							metrics = pField.getLineMetrics(0);
							width += Math.ceil(metrics.width);
						}
					}
					width += 4;

					if (posXPortrait > DELTA_X && posXPortrait + width > SCREEN_WIDTH_PORTRAIT - DELTA_X)
					{
						posXPortrait = DELTA_X;
						posYPortrait += spaceHeight;
						if (posYPortrait > SCREEN_HEIGHT_PORTRAIT - DELTA_Y - spaceHeight)
						{
							posYPortrait = DELTA_Y;
							pagePosPortrait++;
							pageIndexPortrait[pagePosPortrait] = counter;
						}
					}
					piece.xPortrait = posXPortrait;
					piece.yPortrait = posYPortrait;
					piece.widthPortrait = width;
					piece.heightPortrait = spaceHeight;
					posXPortrait += width + spaceWidth;
				}
				else if (piece.type == Epiece.TYPE_H1)
				{
					h1Field.text = piece.value;
					metrics = h1Field.getLineMetrics(0);
					width = Math.ceil(metrics.width) + 4;
					if (posXPortrait > DELTA_X && posXPortrait + width > SCREEN_WIDTH_PORTRAIT - DELTA_X)
					{
						posXPortrait = DELTA_X;
						posYPortrait += spaceH1Height;
						if (posYPortrait > SCREEN_HEIGHT_PORTRAIT - DELTA_Y - spaceHeight)
						{
							posYPortrait = DELTA_Y;
							pagePosPortrait++;
							pageIndexPortrait[pagePosPortrait] = counter;
						}
					}
					piece.xPortrait = posXPortrait;
					piece.yPortrait = posYPortrait;
					piece.widthPortrait = width;
					piece.heightPortrait = spaceH1Height;
					posXPortrait += width + spaceH1Width;
				}
				else if (piece.type ==Epiece.TYPE_H2)
				{
					h2Field.text = piece.value;
					metrics = h2Field.getLineMetrics(0);
					width = Math.ceil(metrics.width) + 4;
					if (posXPortrait > DELTA_X && posXPortrait + width > SCREEN_WIDTH_PORTRAIT - DELTA_X)
					{
						posXPortrait = DELTA_X;
						posYPortrait += spaceH2Height;
						if (posYPortrait > SCREEN_HEIGHT_PORTRAIT - DELTA_Y - spaceHeight)
						{
							posYPortrait = DELTA_Y;
							pagePosPortrait++;
							pageIndexPortrait[pagePosPortrait] = counter;
						}
					}
					piece.xPortrait = posXPortrait;
					piece.yPortrait = posYPortrait;
					piece.widthPortrait = width;
					piece.heightPortrait = spaceH2Height;
					posXPortrait += width + spaceH2Width;
				}
				else if (piece.type == Epiece.TYPE_H3)
				{
					h3Field.text = piece.value;
					metrics = h3Field.getLineMetrics(0);
					width = Math.ceil(metrics.width) + 4;
					if (posXPortrait > DELTA_X && posXPortrait + width > SCREEN_WIDTH_PORTRAIT - DELTA_X)
					{
						posXPortrait = DELTA_X;
						posYPortrait += spaceH3Height;
						if (posYPortrait > SCREEN_HEIGHT_PORTRAIT - DELTA_Y - spaceHeight)
						{
							posYPortrait = DELTA_Y;
							pagePosPortrait++;
							pageIndexPortrait[pagePosPortrait] = counter;
						}
					}
					piece.xPortrait = posXPortrait;
					piece.yPortrait = posYPortrait;
					piece.widthPortrait = width;
					piece.heightPortrait = spaceH3Height;
					posXPortrait += width + spaceH3Width;
				}
				else if (piece.type == Epiece.TYPE_H4)
				{
					h4Field.text = piece.value;
					metrics = h4Field.getLineMetrics(0);
					width = Math.ceil(metrics.width) + 4;
					if (posXPortrait > DELTA_X && posXPortrait + width > SCREEN_WIDTH_PORTRAIT - DELTA_X)
					{
						posXPortrait = DELTA_X;
						posYPortrait += spaceH4Height;
						if (posYPortrait > SCREEN_HEIGHT_PORTRAIT - DELTA_Y - spaceHeight)
						{
							posYPortrait = DELTA_Y;
							pagePosPortrait++;
							pageIndexPortrait[pagePosPortrait] = counter;
						}
					}
					piece.xPortrait = posXPortrait;
					piece.yPortrait = posYPortrait;
					piece.widthPortrait = width;
					piece.heightPortrait = spaceH4Height;
					posXPortrait += width + spaceH4Width;
				}
				else if (piece.type == Epiece.TYPE_H5)
				{
					h5Field.text = piece.value;
					metrics = h5Field.getLineMetrics(0);
					width = Math.ceil(metrics.width) + 4;
					if (posXPortrait > DELTA_X && posXPortrait + width > SCREEN_WIDTH_PORTRAIT - DELTA_X)
					{
						posXPortrait = DELTA_X;
						posYPortrait += spaceH5Height;
						if (posYPortrait > SCREEN_HEIGHT_PORTRAIT - DELTA_Y - spaceHeight)
						{
							posYPortrait = DELTA_Y;
							pagePosPortrait++;
							pageIndexPortrait[pagePosPortrait] = counter;
						}
					}
					piece.xPortrait = posXPortrait;
					piece.yPortrait = posYPortrait;
					piece.widthPortrait = width;
					piece.heightPortrait = spaceH5Height;
					posXPortrait += width + spaceH5Width;
				}
				else if (piece.type == Epiece.TYPE_H6)
				{
					h6Field.text = piece.value;
					metrics = h6Field.getLineMetrics(0);
					width = Math.ceil(metrics.width) + 4;
					if (posXPortrait > DELTA_X && posXPortrait + width > SCREEN_WIDTH_PORTRAIT - DELTA_X)
					{
						posXPortrait = DELTA_X;
						posYPortrait += spaceH6Height;
						if (posYPortrait > SCREEN_HEIGHT_PORTRAIT - DELTA_Y - spaceHeight)
						{
							posYPortrait = DELTA_Y;
							pagePosPortrait++;
							pageIndexPortrait[pagePosPortrait] = counter;
						}
					}
					piece.xPortrait = posXPortrait;
					piece.yPortrait = posYPortrait;
					piece.widthPortrait = width;
					piece.heightPortrait = spaceH6Height;
					posXPortrait += width + spaceH6Width;
				}
			}
			
			for (var h:int = 0; h < BookInfo.bookmarks.length; h++)
			{
				var wordPos:int = BookInfo.bookmarks[h].wordPos;
				Epiece(pieces[wordPos]).bookmarked = true;
			}

			for (var k:int = 0; k < BookInfo.highlights.length; k++)
			{
				var wordPos:int = BookInfo.highlights[k];
				if (pieces.length >= wordPos)
				{
					Epiece(pieces[wordPos]).highlighted = true;
				}
			}
		}
	}
}