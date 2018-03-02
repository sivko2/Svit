package
{
	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.events.TouchEvent;
	import flash.events.TransformGestureEvent;
	import flash.filesystem.File;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.system.System;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import qnx.dialog.AlertDialog;
	import qnx.dialog.DialogSize;
	import qnx.dialog.PopupList;
	import qnx.dialog.PromptDialog;
	import qnx.display.IowWindow;
	import qnx.events.QNXApplicationEvent;
	import qnx.events.WebViewEvent;
	import qnx.media.QNXStageWebView;
	import qnx.system.QNXApplication;
	import qnx.ui.buttons.Button;
	import qnx.ui.buttons.IconButton;
	import qnx.ui.buttons.LabelButton;
	import qnx.ui.buttons.SegmentedControl;
	import qnx.ui.buttons.ToggleSwitch;
	import qnx.ui.core.Container;
	import qnx.ui.data.DataProvider;
	import qnx.ui.display.Image;
	import qnx.ui.events.SliderEvent;
	import qnx.ui.slider.Slider;
	import qnx.ui.text.Label;
	
	public class Reader extends Sprite
	{
		private var searchPositions:Array = new Array()
		private var currField:TextField;
		private var posX:int;
		private var posY:int;
		private var posWidth:int;
		private var posHeight:int;
		
		private var percLabel:Label;
		private var wcLabel:Label;
		private var pageLabel:Label;
		private var titleLabel:Label;
		private var dummyLabel:Label;

		private var fieldArray:Array;
		private var bookTitle:String;
		private var bookFilename:String;
		
		private var currPage:int = 0;
		private var displayStage:Stage;
		
		private var touching:Boolean = false;
		private var dualTouching:Boolean = false;
		private var touchCounter:int = 0;
		private var touchX:int = 0;
		private var touchY:int = 0;
		
		public var menuContainer:Container;
		private var fontNameSegment:SegmentedControl;
		private var fontSizeSegment:SegmentedControl;
		private var nightToggle:ToggleSwitch;
		private var backgroundSegment:SegmentedControl;
		private var slider:Slider;
		private var bookmarksButton:LabelButton;
		private var fontNameButton:LabelButton;
		private var searchButton:LabelButton;
		private var resetButton:LabelButton;
		
		private var imgView:QNXStageWebView;
		
		private var timer:Timer;
		private var revTimer:Timer;
		private var pressTimer:Timer;

		private var origFontNamePos:int;
		private var origFontSizePos:int;
		private var origNightMode:Boolean;
		private var origBackgroundColor:int;
		
		private var oldFontName:String;

		private var menuShown:Boolean = false;
		private var pressed:Boolean = false;
		
		private var closeButton:IconButton;
		
		private var image:Image;

		public const DELTA_MOVE:int = 70;

		public function Reader(title:String, filename:String, stage:Stage)
		{
			oldFontName = Configuration.fontNames[Configuration.fontNamePos];
			imgView = new QNXStageWebView("Image");
//			imgView.addEventListener(MouseEvent.MOUSE_UP, onImgClick);
			
			currPage = 0;
			bookTitle = title;
			bookFilename = filename;
			displayStage = stage;
//			BookInfo.reset(bookFilename);
			
			timer = new Timer(30, 8);
			revTimer = new Timer(30, 8);
			pressTimer = new Timer(1000, 1);
			
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			revTimer.addEventListener(TimerEvent.TIMER, onRevTimer);
			pressTimer.addEventListener(TimerEvent.TIMER, onPressTimer);

			var leftFormat:TextFormat = new TextFormat();
			leftFormat.font = "Sans";
			leftFormat.size = 12;
			leftFormat.color = 0x777777;
			leftFormat.align = "left";

			var centerFormat:TextFormat = new TextFormat();
			centerFormat.font = "Sans";
			centerFormat.size = 12;
			centerFormat.color = 0x777777;
			centerFormat.align = "center";

			var rightFormat:TextFormat = new TextFormat();
			rightFormat.font = "Sans";
			rightFormat.size = 12;
			rightFormat.color = 0x777777;
			rightFormat.align = "right";

			dummyLabel = new Label();
			addChild(dummyLabel);
			
			titleLabel = new Label();
			titleLabel.format = centerFormat;
			titleLabel.text = bookTitle;
			addChild(titleLabel);
			
			percLabel = new Label();
			percLabel.format = leftFormat;
			addChild(percLabel);
			
			wcLabel = new Label();
			wcLabel.format = centerFormat;
			addChild(wcLabel);
			
			pageLabel = new Label();
			pageLabel.format = rightFormat; 
			addChild(pageLabel);
			
			slider = new Slider();
			slider.visible = false;
			slider.addEventListener(SliderEvent.MOVE, sliderMoved);
			slider.addEventListener(SliderEvent.END, sliderEnd);
			addChild(slider);
			
			Svit.svit.prevImage.addEventListener(MouseEvent.MOUSE_UP, onPrevClick);
			addChild(Svit.svit.prevImage);
			
			Svit.svit.nextImage.addEventListener(MouseEvent.MOUSE_UP, onNextClick);
			addChild(Svit.svit.nextImage);

			menuContainer = new Container();
			menuContainer.x = 0;
			menuContainer.y = -280;
			menuContainer.width = 600;
			menuContainer.height = 280;
			Svit.svit.addChild(menuContainer);

			closeButton = new IconButton();
			closeButton.setIcon("img/close.png");
			closeButton.addEventListener(MouseEvent.CLICK, onCloseClick);
			closeButton.x = 20;
			closeButton.y = 20;
			closeButton.width = 80;
			closeButton.height = 80;
			menuContainer.addChild(closeButton);
			
			var fontNameLabel:Label = new Label();
			fontNameLabel.text = "Font name";
			fontNameLabel.x = 130;
			fontNameLabel.y = 15;
			fontNameLabel.width = 100;
			fontNameLabel.height = 35;
			menuContainer.addChild(fontNameLabel);

			fontNameButton = new LabelButton();
			fontNameButton.label = Configuration.fontNames[Configuration.fontNamePos];
			fontNameButton.x = 240;
			fontNameButton.y = 10;
			fontNameButton.width = 350;
			fontNameButton.height = 40;
			fontNameButton.addEventListener(MouseEvent.CLICK, onFontNameClick);
			menuContainer.addChild(fontNameButton);

/*			var fontNameArray:Array=[]; 
			fontNameArray.push({label: Configuration.fontNames[0]}); 
			fontNameArray.push({label: Configuration.fontNames[1]}); 
			fontNameArray.push({label: Configuration.fontNames[2]}); 
			fontNameSegment = new SegmentedControl(); 
			fontNameSegment.x = 240; 
			fontNameSegment.y = 10; 
			fontNameSegment.width = 350; 
			fontNameSegment.height = 40;
			fontNameSegment.dataProvider = new DataProvider(fontNameArray); 
			fontNameSegment.selectedIndex = Configuration.fontNamePos; 
			menuContainer.addChild(fontNameSegment);*/
			
			var fontSizeLabel:Label = new Label();
			fontSizeLabel.text = "Font size";
			fontSizeLabel.x = 130;
			fontSizeLabel.y = 65;
			fontSizeLabel.width = 100;
			fontSizeLabel.height = 35;
			menuContainer.addChild(fontSizeLabel);
			
			var fontSizeArray:Array=[]; 
			fontSizeArray.push({label: "XS"}); 
			fontSizeArray.push({label: "S"}); 
			fontSizeArray.push({label: "M"}); 
			fontSizeArray.push({label: "L"}); 
			fontSizeArray.push({label: "XL"}); 
			fontSizeSegment = new SegmentedControl(); 
			fontSizeSegment.x = 240; 
			fontSizeSegment.y = 60; 
			fontSizeSegment.width = 350; 
			fontSizeSegment.height = 40;
			fontSizeSegment.dataProvider = new DataProvider(fontSizeArray); 
			fontSizeSegment.selectedIndex = Configuration.fontSizePos; 
			menuContainer.addChild(fontSizeSegment);
			
			var nightLabel:Label = new Label();
			nightLabel.text = "Night mode:";
			nightLabel.x = 20;
			nightLabel.y = 125;
			nightLabel.width = 140;
			nightLabel.height = 35;
			menuContainer.addChild(nightLabel);
			
			nightToggle = new ToggleSwitch();
			nightToggle.defaultLabel = "Off"; 
			nightToggle.selectedLabel = "On"; 
			nightToggle.selected = Configuration.nightMode;
			nightToggle.x = 170;
			nightToggle.y = 120;
			nightToggle.width = 200;
			nightToggle.height = 40;
			menuContainer.addChild(nightToggle);
			
			var backgroundLabel:Label = new Label();
			backgroundLabel.text = "Background:";
			backgroundLabel.x = 20;
			backgroundLabel.y = 175;
			backgroundLabel.width = 140;
			backgroundLabel.height = 35;
			menuContainer.addChild(backgroundLabel);
			
			var backgroundArray:Array=[]; 
			backgroundArray.push({label: "White"}); 
			backgroundArray.push({label: "Sepia"}); 
			backgroundArray.push({label: "Blue"}); 
			backgroundArray.push({label: "Green"}); 
			backgroundSegment = new SegmentedControl(); 
			backgroundSegment.x = 170; 
			backgroundSegment.y = 170; 
			backgroundSegment.width = 420; 
			backgroundSegment.height = 40;
			backgroundSegment.dataProvider = new DataProvider(backgroundArray); 
			backgroundSegment.selectedIndex = Configuration.backgroundColor; 
			menuContainer.addChild(backgroundSegment);
			
			bookmarksButton = new LabelButton();
			bookmarksButton.label = "Bookmarks";
			bookmarksButton.x = 450;
			bookmarksButton.y = 120;
			bookmarksButton.width = 140;
			bookmarksButton.height = 40;
			bookmarksButton.addEventListener(MouseEvent.CLICK, onBookmarksClick);
			menuContainer.addChild(bookmarksButton);

			searchButton = new LabelButton();
			searchButton.label = "Search";
			searchButton.x = 20;
			searchButton.y = 220;
			searchButton.width = 140;
			searchButton.height = 40;
			searchButton.addEventListener(MouseEvent.CLICK, onSearchClick);
			menuContainer.addChild(searchButton);
			
			resetButton = new LabelButton();
			resetButton.label = "Reset";
			resetButton.x = 180;
			resetButton.y = 220;
			resetButton.width = 140;
			resetButton.height = 40;
			resetButton.addEventListener(MouseEvent.CLICK, onResetClick);
			menuContainer.addChild(resetButton);
			
			Svit.svit.bookmarkImage.x = Svit.screenWidth - Svit.svit.bookmarkImage.width;
			Svit.svit.bookmarkImage.y = 0;
			addChild(Svit.svit.bookmarkImage);

			Svit.svit.fingerImage.x = 0;
			Svit.svit.fingerImage.y = 0;
			Svit.svit.fingerImage.visible = false;
			Svit.svit.fingerImage.alpha= 0.5;
			addChild(Svit.svit.fingerImage);

			addEventListener(MouseEvent.MOUSE_DOWN, touchBegin);
			addEventListener(MouseEvent.MOUSE_UP, touchEnd);
			addEventListener(MouseEvent.MOUSE_MOVE, touchMove);
			QNXApplication.qnxApplication.addEventListener(QNXApplicationEvent.SWIPE_DOWN, onSwipe)
		}
		
		private function onResetClick(event:MouseEvent):void
		{
			var alert:AlertDialog = new AlertDialog();
			alert.title = "Warning";
			alert.message = "Do you really want to reset all bookmarks and highlights in the book?";
			alert.addButton("Yes");
			alert.addButton("No");
			alert.dialogSize= DialogSize.SIZE_SMALL;
			alert.addEventListener(Event.SELECT, alertResetClicked); 
			alert.show(IowWindow.getAirWindow().group);
			
			revTimer.reset();
			revTimer.start();
			menuShown = false;
		}
		
		private function alertResetClicked(event:Event):void
		{
			if (event.target.selectedIndex == 0)
			{
				BookInfo.bookmarks = undefined;
				BookInfo.highlights = undefined;
				BookInfo.store(bookFilename);
				BookInfo.load(bookFilename);
				for each(var piece:Epiece in Svit.bookCreator.pieces)
				{
					if (piece.bookmarked == true)
					{
						piece.bookmarked = false;
					}
					if (piece.highlighted == true)
					{
						piece.highlighted = false;
					}
				}
				showCurrPage(false);
			}
		}
		
		private function onSearchClick(event:MouseEvent):void
		{
			var prompt:PromptDialog = new PromptDialog();
			prompt.title = "Search";
			prompt.message = "Please enter a word to be searched:";
			prompt.prompt = "";
			prompt.addButton("Search");
			prompt.addButton("Cancel");
			prompt.dialogSize= DialogSize.SIZE_SMALL;
			prompt.addEventListener(Event.SELECT, alertSearchClicked);
			prompt.show(IowWindow.getAirWindow().group);
			
			revTimer.reset();
			revTimer.start();
			menuShown = false;
		}
		
		private function alertSearchClicked(e:Event):void
		{
			var dialog:PromptDialog = e.target as PromptDialog;
			if (dialog.selectedIndex > 0)
			{
				return;
			}
			if (dialog.text == null || dialog.text.length == 0)
			{
				return;
			}
			
			searchPositions = new Array();
			var searchTitles:Array = new Array();
			var counter:int = 0;
			var foundCounter:int = 0;
			for each(var piece:Epiece in Svit.bookCreator.pieces)
			{
				if (piece.value != null && piece.value.toUpperCase().indexOf(dialog.text.toUpperCase()) > -1)
				{
					searchPositions[searchPositions.length] = counter;
					var text:String = "WORD POSITION " + counter + ": '";
					if (Svit.bookCreator.pieces[counter].type != Epiece.TYPE_NEW_LINE)
					{
						text += Svit.bookCreator.pieces[counter].value;
					}
					for (var i:int = 1; i < 30; i++)
					{
						if (Svit.bookCreator.pieces[counter + i].type != Epiece.TYPE_NEW_LINE)
						{
							text += " " + Svit.bookCreator.pieces[counter + i].value;
						}
					}
					text += "'";

					searchTitles[searchTitles.length] = text;
					foundCounter++;
					if (foundCounter >= 20)
					{
						break;
					}
				}
				counter++;	
			}
			var popUp:PopupList = new PopupList();
			popUp.title = "Result";
			popUp.items = searchTitles;
			popUp.multiSelect = false;
			popUp.addButton("Go");
			popUp.addButton("Cancel");
			popUp.dialogSize = DialogSize.SIZE_FULL;
			popUp.addEventListener(Event.SELECT, onResultSelect);
			popUp.show(IowWindow.getAirWindow().group);
		}
		
		private function onResultSelect(event:Event):void 
		{
			var popUp:PopupList = event.target as PopupList;
			if (popUp.selectedIndex == 0)
			{
				if (popUp.selectedIndices.length == 1)
				{
					var pos:int = popUp.selectedIndices[0];
					setCurrPage(searchPositions[pos]);
					showCurrPage(false);
				}
			}
		}

		private function onCloseClick(event:MouseEvent):void
		{
			currPage = 0;
			BookInfo.currWord = 0;
			BookInfo.reset(bookFilename);
			Svit.svit.backToMenu(true);
			flash.system.System.gc();
			flash.system.System.gc();
		}
		
		public function removeListeners():void
		{
			removeEventListener(MouseEvent.MOUSE_DOWN, touchBegin);
			removeEventListener(MouseEvent.MOUSE_UP, touchEnd);
			QNXApplication.qnxApplication.removeEventListener(QNXApplicationEvent.SWIPE_DOWN, onSwipe);
		}
		
		private function onSwipe(event:QNXApplicationEvent):void
		{
			if (!menuShown)
			{
				menuContainer.y = - menuContainer.height;
				this.y = 0;
				menuShown = true;
				origFontNamePos = Configuration.fontNamePos;
				origFontSizePos = Configuration.fontSizePos;
				origNightMode = Configuration.nightMode;
				origBackgroundColor = Configuration.backgroundColor;
				timer.reset();
				timer.start();
			}
		}

		private function onFontNameClick(event:MouseEvent):void
		{
			var popUp:PopupList = new PopupList();
			popUp.title = "Select font:";
			popUp.items = Configuration.fontNames;
			popUp.multiSelect = false;
			popUp.addButton("OK");
			popUp.addButton("Cancel");
			popUp.dialogSize = DialogSize.SIZE_MEDIUM;
			popUp.addEventListener(Event.SELECT, onFontNameSelect);
			popUp.show(IowWindow.getAirWindow().group);
		}
		
		private function onFontNameSelect(event:Event):void 
		{
			var popUp:PopupList = event.target as PopupList;
			if (popUp.selectedIndex == 0)
			{
				if (popUp.selectedIndices.length == 1)
				{
					var pos:int = popUp.selectedIndices[0];
					Configuration.fontNamePos = pos;
					Configuration.store();
					fontNameButton.label = Configuration.fontNames[pos];
				}
			}
		}

		private function onBookmarksClick(event:MouseEvent):void
		{
			var popUp:PopupList = new PopupList();
			popUp.title = "Select bookmark:";
			var items:Array = new Array();
			try
			{
				for (var j:int = 0; j < BookInfo.bookmarks.length; j++)
				{
					var text:String = "";
					if (Svit.bookCreator.pieces[BookInfo.bookmarks[j].wordPos].type != Epiece.TYPE_NEW_LINE)
					{
						text += Svit.bookCreator.pieces[BookInfo.bookmarks[j].wordPos].value;
					}
					for (var i:int = 1; i < 30; i++)
					{
						if (Svit.bookCreator.pieces[BookInfo.bookmarks[j].wordPos + i].type != Epiece.TYPE_NEW_LINE)
						{
							text += " " + Svit.bookCreator.pieces[BookInfo.bookmarks[j].wordPos + i].value;
						}
					}
					text += "'";
	//				Svit.bookCreator.pieces[bookmark.wordPos];
					items[items.length] = text;
				}
			}
			catch (ex:Error)
			{
				trace("ERROR: " + ex.getStackTrace());
//				BookInfo.remove(bookFilename);
//				BookInfo.(bookFilename);
			}
			popUp.items = items;
			popUp.multiSelect = false;
			popUp.addButton("OK");
			popUp.addButton("Cancel");
			popUp.dialogSize = DialogSize.SIZE_FULL;
			popUp.addEventListener(Event.SELECT, onBookmarkSelect);
			popUp.show(IowWindow.getAirWindow().group);

			revTimer.reset();
			revTimer.start();
			menuShown = false;
		}
		
		private function onBookmarkSelect(event:Event):void 
		{
			var popUp:PopupList = event.target as PopupList;
			if (popUp.selectedIndex == 0)
			{
				if (popUp.selectedIndices.length == 1)
				{
					var pos:int = popUp.selectedIndices[0];
					setCurrPage(BookInfo.bookmarks[pos].wordPos);
					showCurrPage(false);
				}
			}
		}
		
		private function onPressTimer(event:TimerEvent):void
		{
			onWordTap();
		}
		
		private function onWordTap():void
		{
/*			if (!pressed)
			{
				return;
			}*/

			var startWordPos:int = -1;
			var endWordPos:int = -1;
			if (Svit.orientation == Svit.LANDSCAPE)
			{
				startWordPos = Svit.bookCreator.pageIndexLandscape[currPage]; 
				if (currPage < Svit.bookCreator.pageIndexLandscape.length - 1)
				{
					endWordPos = Svit.bookCreator.pageIndexLandscape[currPage + 1];
				}
				else
				{
					endWordPos = Svit.bookCreator.pieces.length;
				}
			}
			else
			{
				startWordPos = Svit.bookCreator.pageIndexPortrait[currPage];
				if (currPage < Svit.bookCreator.pageIndexPortrait.length - 1)
				{
					endWordPos = Svit.bookCreator.pageIndexPortrait[currPage + 1];
				}
				else
				{
					endWordPos = Svit.bookCreator.pieces.length;
				}
			}
			for (var i:int = startWordPos; i < endWordPos; i++)
			{
				var piece:Epiece = Svit.bookCreator.pieces[i];
				if (Svit.orientation == Svit.LANDSCAPE)
				{
					if (touchX >= piece.xLandscape && touchX <= piece.xLandscape + piece.widthLandscape &&
						touchY >= piece.yLandscape && touchY <= piece.yLandscape + piece.heightLandscape)
					{
						if ((Svit.bookCreator.pieces[i] as Epiece).type != Epiece.TYPE_IMAGE)
						{
							if (!Svit.bookCreator.pieces[i].highlighted)
							{
								BookInfo.highlights[BookInfo.highlights.length] = i;
								Svit.bookCreator.pieces[i].highlighted = true;
							}
							else
							{
								for (var j:int = 0; j < BookInfo.highlights.length; j++)
								{
									var pos:int = BookInfo.highlights[j];
									if (i == pos)
									{
										BookInfo.highlights.splice(j, 1);
										j--;
										Svit.bookCreator.pieces[i].highlighted = false;
										break;
									}
								}
							}
							BookInfo.store(bookFilename);
						}
						else
						{
							showImage((Svit.bookCreator.pieces[i] as Epiece).imagePath);
						}
						break;
					}
				}
				else
				{
					if (touchX >= piece.xPortrait && touchX <= piece.xPortrait + piece.widthPortrait &&
						touchY >= piece.yPortrait && touchY <= piece.yPortrait + piece.heightPortrait)
					{
						if ((Svit.bookCreator.pieces[i] as Epiece).type != Epiece.TYPE_IMAGE)
						{
//							Svit.bookCreator.pieces[i].highlighed = !Svit.bookCreator.pieces[i].highlighed; 
							if (!Svit.bookCreator.pieces[i].highlighted)
							{
								BookInfo.highlights[BookInfo.highlights.length] = i;
								Svit.bookCreator.pieces[i].highlighted = true;
							}
							else
							{
								for (var j:int = 0; j < BookInfo.highlights.length; j++)
								{
									var pos:int = BookInfo.highlights[j];
									if (i == pos)
									{
										BookInfo.highlights.splice(j, 1);
										j--;
										Svit.bookCreator.pieces[i].highlighted = false;
										break;
									}
								}
							}
							BookInfo.store(bookFilename);
						}
						else
						{
							showImage((Svit.bookCreator.pieces[i] as Epiece).imagePath);
						}
						break;
					}
				}
			}
			showCurrPage(false);
		}
		
		private function showImage(filename:String):void
		{
			try
			{
				trace(filename);
				var path:File = File.userDirectory.resolvePath("shared/misc/svit/" + filename);
				var url:String = "file:/" + "/" + path.nativePath;
				imgView.stage = this.stage;
				imgView.loadURL(url);
				imgView.addEventListener(WebViewEvent.DOCUMENT_LOAD_FAILED, onImgFail);
				imgView.zoomToFitWidthOnLoad = true;
				imgView.visible = true;
			}
			catch (ex:Error)
			{
				trace("ERROR: " + ex.message);
			}
		}
		
		private function onImgFail(e:WebViewEvent):void
		{
		}
		
		private function onTimer(event:TimerEvent):void
		{
			imgView.visible = false;
			menuContainer.y += 35;
			this.y += 35;
		}
		
		private function onRevTimer(event:TimerEvent):void
		{
			imgView.visible = false;
			menuContainer.y -= 35;
			this.y -= 35;
		}
		
		private function touchBegin(event:MouseEvent):void
		{
			if (menuShown)
			{
				imgView.visible = false;
				menuShown = false;
				var idx:int = -1;
				for each (var fontName:String in Configuration.fontNames)
				{
					idx++;
					if (fontName == fontNameButton.label)
					{
						Configuration.fontNamePos = idx;
					}
				}
				Configuration.fontSizePos = fontSizeSegment.selectedIndex;
				Configuration.nightMode = nightToggle.selected;
				Configuration.backgroundColor = backgroundSegment.selectedIndex;
				Configuration.store();
				if (fontNameButton.label != oldFontName || origFontSizePos != fontSizeSegment.selectedIndex)
				{
					slider.visible = false;
					if (Svit.orientation == Svit.LANDSCAPE)
					{
						Svit.svit.reloadReader(Svit.bookCreator.pageIndexLandscape[currPage]);
					}
					else
					{
						Svit.svit.reloadReader(Svit.bookCreator.pageIndexPortrait[currPage]);
					}
				}
				else
				{
					slider.visible = false;
					if (origNightMode != nightToggle.selected || (nightToggle.selected == false &&
						origBackgroundColor != backgroundSegment.selectedIndex))
					{
						showCurrPage(false);
					}					
					revTimer.reset();
					revTimer.start();
				}
			}
			else if (!touching)
			{
				if (event.stageX > Svit.screenWidth - Svit.bookCreator.DELTA_X &&
					event.stageY < Svit.bookCreator.DELTA_Y)
				{
					if (!imgView.visible)
					{
						bookmark();
					}
					slider.visible = false;
				}
				else if (event.stageX < Svit.screenWidth - Svit.bookCreator.DELTA_X &&
					event.stageX > Svit.bookCreator.DELTA_X &&
					event.stageY < Svit.screenHeight - Svit.bookCreator.DELTA_Y &&
					event.stageY > Svit.bookCreator.DELTA_Y)
				{
					slider.visible = false;
					touching = true;
					touchX = event.stageX;
					touchY = event.stageY;
					pressed = true;
//					pressTimer.reset();
//					pressTimer.start();
				}
				else if ((event.stageX > Svit.screenWidth - Svit.bookCreator.DELTA_X ||
					event.stageX < Svit.bookCreator.DELTA_X) &&
					event.stageY < Svit.screenHeight - Svit.bookCreator.DELTA_Y &&
					event.stageY > Svit.bookCreator.DELTA_Y)
				{
					if (!imgView.visible)
					{
						slider.visible = false;
						Svit.svit.fingerImage.visible = true;
						Svit.svit.fingerImage.y = event.stageY - Svit.svit.fingerImage.height / 2;
					}
					imgView.visible = false;
				}
				else if (event.stageY > Svit.screenHeight - Svit.bookCreator.DELTA_Y &&
					event.stageX > 50 && event.stageX < Svit.screenWidth - 50)
				{
					if (!imgView.visible)
					{
						slider.visible = true;
					}
					imgView.visible = false;
				}
				else
				{
					imgView.visible = false;
				}
			}
		}
		
		private function touchMove(event:MouseEvent):void
		{
//			pressed = false;
//			pressTimer.stop();
			
			if (Svit.svit.fingerImage.visible)
			{
				Svit.svit.fingerImage.y = event.stageY - Svit.svit.fingerImage.height / 2;
			}
		}

		
		private function onNextClick(event:MouseEvent):void
		{
			if (Svit.orientation == Svit.LANDSCAPE)
			{
				if (currPage < Svit.bookCreator.pageIndexLandscape.length - 1)
				{
					currPage++;
					BookInfo.currWord = Svit.bookCreator.pageIndexLandscape[currPage];
					BookInfo.store(bookFilename);
					showCurrPage(false);
				}
			}
			else
			{
				if (currPage < Svit.bookCreator.pageIndexPortrait.length - 1)
				{
					currPage++;
					BookInfo.currWord = Svit.bookCreator.pageIndexPortrait[currPage];
					BookInfo.store(bookFilename);
					showCurrPage(false);
				}
			}
		}
		
/*		private function onImgClick(event:MouseEvent):void
		{
			imgView.visible = false;
		}*/
		
		private function onPrevClick(event:MouseEvent):void
		{
			if (currPage > 0)
			{
				currPage--;
				if (Svit.orientation == Svit.LANDSCAPE)
				{
					BookInfo.currWord = Svit.bookCreator.pageIndexLandscape[currPage];
					BookInfo.store(bookFilename);
					showCurrPage(false);
				}
				else
				{
					BookInfo.currWord = Svit.bookCreator.pageIndexPortrait[currPage];
					BookInfo.store(bookFilename);
					showCurrPage(false);
				}
				showPage(currPage);
			}
		}
		
		private function touchEnd(event:MouseEvent):void
		{
//			pressTimer.stop();
			pressed = false;
			
			if (Svit.svit.fingerImage.visible)
			{
				Svit.svit.fingerImage.visible = false;
			}

			if (touching)
			{
				if (event.stageX == touchX && event.stageY == touchY)
				{
					onWordTap();
				}
				else if (event.stageX > touchX + DELTA_MOVE)
				{
					onPrevClick(null);
				}
				else if (event.stageX < touchX - DELTA_MOVE)
				{
					onNextClick(null);
				}
			}
			touching = false;
		}
		
		public function sliderMoved(event:SliderEvent):void
		{
			pageLabel.text = "page " + Math.round(event.value);
		}
		
		public function sliderEnd(event:SliderEvent):void
		{
			pageLabel.text = "page " + Math.round(event.value);
			currPage = Math.round(event.value) - 1;
			if (Svit.orientation == Svit.LANDSCAPE)
			{
				BookInfo.currWord = Svit.bookCreator.pageIndexLandscape[currPage];
				BookInfo.store(bookFilename);
				showPage(currPage);
			}
			else
			{
				BookInfo.currWord = Svit.bookCreator.pageIndexPortrait[currPage];
				BookInfo.store(bookFilename);
				showPage(currPage);
			}
		}
		
		public function setCurrPage(wordPos:int):void
		{
			if (Svit.orientation == Svit.LANDSCAPE)
			{
				var i:int;
				for (i = 0; i < Svit.bookCreator.pageIndexLandscape.length; i++)
				{
					var posL:int = Svit.bookCreator.pageIndexLandscape[i];
					if (wordPos < posL)
					{
						currPage = i - 1;
						break;
					}
				}
				if (i == Svit.bookCreator.pageIndexLandscape.length - 1)
				{
					currPage = Svit.bookCreator.pageIndexLandscape.length - 1;
				}
			}
			else
			{
				var j:int;
				for (j = 0; j < Svit.bookCreator.pageIndexPortrait.length; j++)
				{
					var posP:int = Svit.bookCreator.pageIndexPortrait[j];
					if (wordPos < posP)
					{
						currPage = j - 1;
						break;
					}
				}
				if (j == Svit.bookCreator.pageIndexPortrait.length - 1)
				{
					currPage = Svit.bookCreator.pageIndexPortrait.length - 1;
				}
			}
		}
		
		public function showCurrPage(orientationChanged:Boolean):void
		{
			var wordPos:int = -1;
			slider.minimum = 1;
			if (Svit.orientation == Svit.LANDSCAPE)
			{
				slider.maximum = Svit.bookCreator.pageIndexLandscape.length;
			}	
			else
			{
				slider.maximum = Svit.bookCreator.pageIndexPortrait.length;
			}
			
			if (orientationChanged)
			{
				if (Svit.orientation == Svit.LANDSCAPE)
				{
				   	wordPos = Svit.bookCreator.pageIndexPortrait[currPage];
					var i:int;
					for (i = 0; i < Svit.bookCreator.pageIndexLandscape.length; i++)
					{
						var posL:int = Svit.bookCreator.pageIndexLandscape[i];
						if (wordPos < posL)
						{
							currPage = i - 1;
							break;
						}
					}
					if (i == Svit.bookCreator.pageIndexLandscape.length - 1)
					{
					   currPage = Svit.bookCreator.pageIndexLandscape.length - 1;
					}
				}
				else
				{
					wordPos = Svit.bookCreator.pageIndexLandscape[currPage];
					var j:int;
					for (j = 0; j < Svit.bookCreator.pageIndexPortrait.length; j++)
					{
						var posP:int = Svit.bookCreator.pageIndexPortrait[j];
						if (wordPos < posP)
						{
							currPage = j - 1;
							break;
						}
					}
					if (j == Svit.bookCreator.pageIndexPortrait.length - 1)
					{
						currPage = Svit.bookCreator.pageIndexPortrait.length - 1;
					}
				}
			}

			if (Svit.orientation == Svit.LANDSCAPE)
			{
				titleLabel.x = 0;
				titleLabel.y = 5;
				titleLabel.width = 1024;
				titleLabel.height = 25;
				
				percLabel.x = 60;
				percLabel.y = 575;
				percLabel.width = 180;
				percLabel.height = 25;
				
				wcLabel.x = 422;
				wcLabel.y = 575;
				wcLabel.width = 180;
				wcLabel.height = 25;
				
				pageLabel.x = 784;
				pageLabel.y = 575;
				pageLabel.width = 180;
				pageLabel.height = 25;
				
				slider.x = 272;
				slider.y = 550;
				slider.width = 480;
				slider.height = 30;
				
				Svit.svit.prevImage.x = 0;
				Svit.svit.prevImage.y = 550;
				Svit.svit.prevImage.width = 50;
				Svit.svit.prevImage.height = 50;
				Svit.svit.prevImage.alpha = 1;
				
				Svit.svit.nextImage.x = 974;
				Svit.svit.nextImage.y = 550;
				Svit.svit.nextImage.width = 50;
				Svit.svit.nextImage.height = 50;
				Svit.svit.nextImage.alpha = 1;
			}
			else
			{
				titleLabel.x = 0;
				titleLabel.y = 5;
				titleLabel.width = 600;
				titleLabel.height = 25;
				
				percLabel.x = 60;
				percLabel.y = 999;
				percLabel.width = 180;
				percLabel.height = 25;
				
				wcLabel.x = 210;
				wcLabel.y = 999;
				wcLabel.width = 180;
				wcLabel.height = 25;
				
				pageLabel.x = 360;
				pageLabel.y = 999;
				pageLabel.width = 180;
				pageLabel.height = 25;
				
				slider.x = 60;
				slider.y = 974;
				slider.width = 480;
				slider.height = 30;
				
				Svit.svit.prevImage.x = 0;
				Svit.svit.prevImage.y = 974;
				Svit.svit.prevImage.width = 50;
				Svit.svit.prevImage.height = 50;
				Svit.svit.prevImage.alpha = 1;
				
				Svit.svit.nextImage.x = 550;
				Svit.svit.nextImage.y = 974;
				Svit.svit.nextImage.width = 50;
				Svit.svit.nextImage.height = 50;
				Svit.svit.nextImage.alpha = 1;
			}

			dummyLabel.x = 0;
			dummyLabel.y = 0;
			dummyLabel.width = Svit.screenWidth;
			dummyLabel.height= Svit.screenHeight;
			if (Configuration.nightMode)
			{
				dummyLabel.graphics.beginFill(0x000000);
			}
			else
			{
				if (Configuration.backgroundColor == 0)
				{
					dummyLabel.graphics.beginFill(0xFFFFFF);
				}
				else if (Configuration.backgroundColor == 1)
				{
					dummyLabel.graphics.beginFill(0xFFFFDA);
				}
				else if (Configuration.backgroundColor == 2)
				{
					dummyLabel.graphics.beginFill(0xCFF0FF);
				}
				else if (Configuration.backgroundColor == 3)
				{
					dummyLabel.graphics.beginFill(0xDAFCDA);
				}
			}
			dummyLabel.graphics.drawRect(0, 0, Svit.screenWidth, Svit.screenHeight);
			dummyLabel.graphics.endFill();
			
			imgView.viewPort = new Rectangle(50, 50, Svit.screenWidth - 100, Svit.screenHeight - 100);
			
			showPage(currPage);

		}
			
//		private function bookmark(e:Event):void
		private function bookmark():void
		{
/*			var dialog:PromptDialog = e.target as PromptDialog;
			if (dialog.selectedIndex > 0)
			{
				return;
			}
			if (dialog.text == null || dialog.text.length == 0)
			{
				return;
			}*/

			var startWordPos:int = -1;
			var endWordPos:int = -1;
			if (Svit.orientation == Svit.LANDSCAPE)
			{
				startWordPos = Svit.bookCreator.pageIndexLandscape[currPage]; 
				if (currPage < Svit.bookCreator.pageIndexLandscape.length - 1)
				{
					endWordPos = Svit.bookCreator.pageIndexLandscape[currPage + 1];
				}
				else
				{
					endWordPos = Svit.bookCreator.pieces.length;
				}
			}
			else
			{
				startWordPos = Svit.bookCreator.pageIndexPortrait[currPage];
				if (currPage < Svit.bookCreator.pageIndexPortrait.length - 1)
				{
					endWordPos = Svit.bookCreator.pageIndexPortrait[currPage + 1];
				}
				else
				{
					endWordPos = Svit.bookCreator.pieces.length;
				}
			}
			
			var bookmarked:Boolean = false;
			for (var i:int = startWordPos; i < endWordPos; i++)
			{
				var piece:Epiece = Svit.bookCreator.pieces[i];
				if (piece.bookmarked)
				{
					bookmarked = true;
				}
			}

			if (bookmarked)
			{
				for (var i:int = startWordPos; i < endWordPos; i++)
				{
					var piece:Epiece = Svit.bookCreator.pieces[i];
					if (piece.bookmarked)
					{
						piece.bookmarked = false;
					}
					for (var j:int = 0; j < BookInfo.bookmarks.length; j++)
					{
						var pos:int = BookInfo.bookmarks[j].wordPos;
						if (i == pos)
						{
							BookInfo.bookmarks.splice(j, 1);
							j--;
							break;
						}
					}
				}
				BookInfo.store(bookFilename);
				BookInfo.load(bookFilename);
				showCurrPage(false);
			}
			else
			{
				if (Svit.orientation == Svit.LANDSCAPE)
				{
					Svit.bookCreator.pieces[Svit.bookCreator.pageIndexLandscape[currPage]].bookmarked = true;
					var xArray:Array = BookInfo.bookmarks;
					xArray[xArray.length] = new Bookmark(Svit.bookCreator.pageIndexLandscape[currPage], new Date());
					BookInfo.bookmarks = xArray;
					BookInfo.store(bookFilename);
					BookInfo.load(bookFilename);
				}
				else
				{
					Svit.bookCreator.pieces[Svit.bookCreator.pageIndexPortrait[currPage]].bookmarked = true;
					BookInfo.bookmarks[BookInfo.bookmarks.length] = 
						new Bookmark(Svit.bookCreator.pageIndexPortrait[currPage], new Date());
					BookInfo.store(bookFilename);
				}
				showCurrPage(false);
			}
		}
		
		public function showPage(page:int):void
		{

			currPage = page;
			pageLabel.text = "page " + (currPage + 1);
			slider.value = (currPage + 1);
			var startWordPos:int = -1;
			var endWordPos:int = -1;
			if (image != null)
			{
				removeChild(image);
				image = null;
			}
			if (fieldArray != null)
			{
				for (var j:int = 0; j < fieldArray.length; j++)
				{
					removeChild(fieldArray[j]);
				}
			}
			
			fieldArray = new Array();
			
			if (Svit.orientation == Svit.LANDSCAPE)
			{
				percLabel.text = int(currPage * 100 / Svit.bookCreator.pageIndexLandscape.length) + " %";
				startWordPos = Svit.bookCreator.pageIndexLandscape[page]; 
				wcLabel.text = "word " + startWordPos;
				if (page < Svit.bookCreator.pageIndexLandscape.length - 1)
				{
					endWordPos = Svit.bookCreator.pageIndexLandscape[page + 1];
				}
				else
				{
					endWordPos = Svit.bookCreator.pieces.length;
				}
			}
			else
			{
				percLabel.text = int(currPage * 100 / Svit.bookCreator.pageIndexPortrait.length) + " %";
				startWordPos = Svit.bookCreator.pageIndexPortrait[page];
				wcLabel.text = "word " + startWordPos;
				if (page < Svit.bookCreator.pageIndexPortrait.length - 1)
				{
					endWordPos = Svit.bookCreator.pageIndexPortrait[page + 1];
				}
				else
				{
					endWordPos = Svit.bookCreator.pieces.length;
				}
			}
			
			var bookmarkedPage:Boolean = false;
			for (var i:int = startWordPos; i < endWordPos; i++)
			{
				var piece:Epiece = Svit.bookCreator.pieces[i];
				
				if (piece.bookmarked)
				{
					bookmarkedPage = true;
				}
				
				if (Svit.orientation == Svit.LANDSCAPE)
				{
					posX = piece.xLandscape;
					posY = piece.yLandscape;
					posWidth = piece.widthLandscape;
					posHeight = piece.heightLandscape;
				}
				else
				{
					posX = piece.xPortrait;
					posY = piece.yPortrait;
					posWidth = piece.widthPortrait;
					posHeight = piece.heightPortrait;
				}
			
				var field:Label = new Label();

				if (piece.type == Epiece.TYPE_P || piece.type == Epiece.TYPE_IMAGE)
				{
					if (piece.highlighted)
					{
//						trace ("A++");
						dummyLabel.graphics.beginFill(0xFDB15E);
						if (Svit.orientation == Svit.LANDSCAPE)
						{
							dummyLabel.graphics.drawRect(piece.xLandscape, piece.yLandscape, 
								piece.widthLandscape + Svit.bookCreator.spaceWidth, piece.heightLandscape);
						}
						else
						{
							dummyLabel.graphics.drawRect(piece.xPortrait, piece.yPortrait, 
								piece.widthPortrait + Svit.bookCreator.spaceWidth, piece.heightPortrait);
						}
						dummyLabel.graphics.endFill();
					}
					if (Configuration.nightMode)
					{
						field.format = Svit.bookCreator.pNightFormat;
					}
					else
					{
						field.format = Svit.bookCreator.pFormat;
					}
				}
				else if (piece.type == Epiece.TYPE_H1)
				{
					if (Configuration.nightMode)
					{
						field.format = Svit.bookCreator.h1NightFormat;
					}
					else
					{
						field.format = Svit.bookCreator.h1Format;
					}
				}
				else if (piece.type == Epiece.TYPE_H2)
				{
					if (Configuration.nightMode)
					{
						field.format = Svit.bookCreator.h3NightFormat;
					}
					else
					{
						field.format = Svit.bookCreator.h2Format;
					}
				}
				else if (piece.type == Epiece.TYPE_H3)
				{
					if (Configuration.nightMode)
					{
						field.format = Svit.bookCreator.h3NightFormat;
					}
					else
					{
						field.format = Svit.bookCreator.h3Format;
					}
				}
				else if (piece.type == Epiece.TYPE_H4)
				{
					if (Configuration.nightMode)
					{
						field.format = Svit.bookCreator.h4NightFormat;
					}
					else
					{
						field.format = Svit.bookCreator.h4Format;
					}
				}
				else if (piece.type == Epiece.TYPE_H5)
				{
					if (Configuration.nightMode)
					{
						field.format = Svit.bookCreator.h5NightFormat;
					}
					else
					{
						field.format = Svit.bookCreator.h5Format;
					}
				}
				else if (piece.type == Epiece.TYPE_H6)
				{
					if (Configuration.nightMode)
					{
						field.format = Svit.bookCreator.h6NightFormat;
					}
					else
					{
						field.format = Svit.bookCreator.h6Format;
					}
				}
				field.text = piece.value;
				field.x = posX;
				field.y = posY;
				field.width = posWidth;
				field.height = posHeight;
				addChild(field);
				fieldArray[fieldArray.length] = field;
			}
			
			if (bookmarkedPage)
			{
				Svit.svit.bookmarkImage.x = Svit.screenWidth - Svit.svit.bookmarkImage.width;
				Svit.svit.bookmarkImage.y = 0;
				Svit.svit.bookmarkImage.visible = true;
			}
			else
			{
				Svit.svit.bookmarkImage.visible = false;
			}
		}
	}
}