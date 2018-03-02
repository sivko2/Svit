package
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.StageOrientationEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.*;
	import flash.geom.Rectangle;
	import flash.net.FileFilter;
	import flash.net.SharedObject;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.net.registerClassAlias;
	import flash.text.Font;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import net.rim.blackberry.bbid.UserProperty;
	
	import qnx.dialog.AlertDialog;
	import qnx.dialog.DialogSize;
	import qnx.dialog.PopupList;
	import qnx.display.IowWindow;
	import qnx.events.WebViewEvent;
	import qnx.media.QNXStageWebView;
	import qnx.pps.Message;
	import qnx.ui.buttons.Button;
	import qnx.ui.buttons.IconButton;
	import qnx.ui.buttons.LabelButton;
	import qnx.ui.core.Container;
	import qnx.ui.core.ContainerAlign;
	import qnx.ui.core.ContainerFlow;
	import qnx.ui.core.SizeMode;
	import qnx.ui.core.SizeUnit;
	import qnx.ui.data.DataProvider;
	import qnx.ui.display.Image;
	import qnx.ui.listClasses.DropDown;
	import qnx.ui.listClasses.List;
	import qnx.ui.listClasses.ListSelectionMode;
	import qnx.ui.listClasses.RoundList;
	import qnx.ui.listClasses.ScrollDirection;
	import qnx.ui.text.Label;

	
	[SWF(height="600", width="1024", frameRate="30", backgroundColor="#dddddd")]
	public class Svit extends Sprite
	{
		
		public static const HELP:String =
			"Svit - Project Gutenberg Ebook Reader with EPUB Support\n" +
			"Copyright © 2011, Pronic, Meselina Ponikvar Verhovsek s.p.\n\n" +
			"For any help contact info@pronic.si\n\n" + 
			"This application reads digital ebooks in the EPUB format and comes with preloaded ebooks.\n\n" +
			"The SVIT Ebook Reader with EPUB Support connects to the PROJECT GUTENBERG site where you can " +
			"search among 36,000 FREE high quality ebooks, download them, and read them offline. You can " + 
			"also read your own collections of digital non-DRM EPUB ebooks.\n\n" +
			"No fee or registration is required to use the books, but if you find Project Gutenberg useful, " +
			"please donate a small amount to the organization by tapping on Donate button " +
			"(more information at http://www.gutenberg.org).\n"
		
		public const NUMBER_OF_MENU_IMAGES:int = 9;

		public static const LANDSCAPE:int = 0;
		public static const PORTRAIT:int = 1;
		
		public static var dirPos:int = File.userDirectory.resolvePath("./.").nativePath.length;
		public static var currentDir:File = File.userDirectory.resolvePath("shared/books");
		
		private var counterMenu:int = 0;
		private var reloadState:Boolean = false;
		private var currWord:int = 0;

		public static var orientation:int;
		public static var screenWidth:int;
		public static var screenHeight:int;
		private var tempOrientation:int;
		
		public static var bookManager:BookManager = new BookManager();
		public static var bookCreator:BookCreator = new BookCreator();
		
		private var mainContainer:Container;
		private var titleContainer:Container;
		private var listContainer:Container;
		
		private var helpDialog:AlertDialog;
		private var warningDialog:AlertDialog;
		
		private var helpView:QNXStageWebView;
		
		private var logoButton:IconButton;
		private var helpButton:IconButton;
		private var syncButton:IconButton;
		private var searchButton:IconButton;
		private var openButton:IconButton;
		private var deleteButton:IconButton;
		private var moveDownloadButton:IconButton;
		
		private var urlTitles:Array = ["Project Gutenberg", 
									   "Project Gutenberg Australia", 
									   "Project Gutenberg Canada", 
									   "Project Gutenberg Consortia Center", 
									   "Project Gutenberg Germany", 
									   "Project Gutenberg Europe",
									   "Runeberg", 
									   "Manybooks", 
									   "Feedbooks"
									  ];
		private var urlLinks:Array = ["http://www.gutenberg.org/ebooks/", 
			                          "http://gutenberg.net.au/searchresults.html",
									  "http://www.gutenberg.ca/",
									  "http://www.gutenberg.cc/",
									  "http://gutenberg.spiegel.de/",
									  "http://pge.rastko.net/",
									  "http://runeberg.org/",
									  "http://www.manybooks.net/",
									  "http://www.feedbooks.com/publicdomain"
									 ];

		private var emptyLabel:Label;
		private var listLabel:Label;
		private var dirLabel:Label;

		private var titleList:List;

		public var waitLImage:Image;
		public var waitPImage:Image;
		public var wait2Image:Image;
		public var bookmarkImage:Image;
		public var fingerImage:Image;
		public var helpLImage:Image;
		public var helpPImage:Image;
		public var prevImage:Image;
		public var nextImage:Image;

		public static var svit:Svit;
		private static var reader:Reader;
		
		private var timer:Timer;
		private var timer2:Timer;
		private var timer3:Timer;
		
		private var so:SharedObject;
		
		public function Svit()
		{
			so = SharedObject.getLocal("svit-eula");

			svit = this;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			stage.nativeWindow.visible = true;
			Multitouch.inputMode = MultitouchInputMode.GESTURE; 
			
			timer = new Timer(1000, 1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimer);
			timer2 = new Timer(1000, 1);
			timer2.addEventListener(TimerEvent.TIMER_COMPLETE, onTimer2);
			timer3 = new Timer(50, 1);
			timer3.addEventListener(TimerEvent.TIMER_COMPLETE, onTimer3);
			
			Configuration.load();
			try
			{
				bookManager.deleteTempFolder();
			}
			catch (error:Error)
			{
				warningDialog = new AlertDialog();
				warningDialog.title = "WARNING";
				warningDialog.message = "You haven't allowed Svit to access the file system. That is why ebooks can not be opened.\n\n" +
					"Open 'Options' on your PlayBook's home screen, tap on the 'Security' tab, tap on 'Application Permissions', " +
					"tap on 'Svit' and change 'Files' from DENIED to ALLOWED.\n\n" +
					"You can find more information on the 'Help' screen (tap on the '?' button) under Chapter 3.";
				warningDialog.addButton("Close");
				warningDialog.addButton("Go to Pronic Apps");
				warningDialog.dialogSize = DialogSize.SIZE_MEDIUM;
				warningDialog.addEventListener(Event.SELECT, onWarningDialogClose);
				warningDialog.show(IowWindow.getAirWindow().group);
			}
		}

		private function onWarningDialogClose(event:Event):void
		{
			if (warningDialog.selectedIndex == 1)
			{
				var request:URLRequest = new URLRequest("http://www.pronicapps.wordpress.com");
				navigateToURL(request, "_blank");
			}
		}

		private function onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			if (stage.stageWidth == 1024)
			{
				orientation = LANDSCAPE;
			}
			else
			{
				orientation = PORTRAIT;
			}
			screenWidth = stage.stageWidth;
			screenHeight = stage.stageHeight;
			
			﻿stage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGE, onOrientationChange);
			
			loadImages();
		}
		
		private function loadImages(): void
		{
			waitLImage = new Image();
			waitLImage.addEventListener(Event.COMPLETE, onImageLoaded);
			waitLImage.setImage("file://" + File.applicationDirectory.
				nativePath + "/img/wait_landscape.png");
			
			waitPImage = new Image();
			waitPImage.addEventListener(Event.COMPLETE, onImageLoaded);
			waitPImage.setImage("file://" + File.applicationDirectory.
				nativePath + "/img/wait_portrait.png");
			
			helpLImage = new Image();
			helpLImage.addEventListener(Event.COMPLETE, onImageLoaded);
			helpLImage.setImage("file://" + File.applicationDirectory.
				nativePath + "/img/help_landscape.png");
			
			helpPImage = new Image();
			helpPImage.addEventListener(Event.COMPLETE, onImageLoaded);
			helpPImage.setImage("file://" + File.applicationDirectory.
				nativePath + "/img/help_portrait.png");
			
			wait2Image = new Image();
			wait2Image.addEventListener(Event.COMPLETE, onImageLoaded);
			wait2Image.setImage("file://" + File.applicationDirectory.
				nativePath + "/img/wait2.png");
			
			bookmarkImage = new Image();
			bookmarkImage.addEventListener(Event.COMPLETE, onImageLoaded);
			bookmarkImage.setImage("file://" + File.applicationDirectory.
				nativePath + "/img/bookmark.png");
			
			fingerImage = new Image();
			fingerImage.addEventListener(Event.COMPLETE, onImageLoaded);
			fingerImage.setImage("file://" + File.applicationDirectory.
				nativePath + "/img/finger.png");
			
			prevImage = new Image();
			prevImage.addEventListener(Event.COMPLETE, onImageLoaded);
			prevImage.setImage("file://" + File.applicationDirectory.
				nativePath + "/img/prev.png");
			
			nextImage = new Image();
			nextImage.addEventListener(Event.COMPLETE, onImageLoaded);
			nextImage.setImage("file://" + File.applicationDirectory.
				nativePath + "/img/next.png");
		}
		
		private function onImageLoaded(event:Event):void
		{
			counterMenu++;
			if (counterMenu >= NUMBER_OF_MENU_IMAGES)
			{
				createUI();
				positionUI();
				wait2Image.x = int((Svit.screenWidth - wait2Image.width) / 2);  
				wait2Image.y = int((Svit.screenHeight - wait2Image.height) / 2);  
				mainContainer.addChild(wait2Image);
				timer3.reset();
				timer3.start();
			}
		}
		
		private function onTimer3(event:TimerEvent):void
		{
			showEula();
		}
		
		private function onOrientationChange(event:StageOrientationEvent):void
		{
			if (stage.stageWidth == 1024)
			{
				orientation = LANDSCAPE;
			}
			else
			{
				orientation = PORTRAIT;
			}
			screenWidth = stage.stageWidth;
			screenHeight = stage.stageHeight;
			positionUI();
		}
		
		private function positionUI():void
		{
			if (orientation == LANDSCAPE)
			{
				if (helpPImage.visible)
				{
					helpPImage.visible = false;
					helpLImage.visible = true;
				}
				
				helpView.viewPort = new Rectangle(0, 65, screenWidth, screenHeight - 65);

				mainContainer.x = 0;
				mainContainer.y = 0;
				mainContainer.width = 1024;
				mainContainer.height = 600;
				
				logoButton.x = 5;
				logoButton.y = 5;
				logoButton.width = 130;
				logoButton.height = 100;
				
				titleContainer.x = 0;
				titleContainer.y = 0;
				titleContainer.width = 1024;
				titleContainer.height = 60;

				helpButton.x = 899;
				helpButton.y = 3;
				helpButton.width = 120;
				helpButton.height = 57;

				syncButton.x = 774;
				syncButton.y = 3;
				syncButton.width = 120;
				syncButton.height = 57;

				searchButton.x = 649;
				searchButton.y = 3;
				searchButton.width = 120;
				searchButton.height = 57;

				emptyLabel.x = 0;
				emptyLabel.y = 0;
				emptyLabel.width = 1024;
				emptyLabel.height = 10;

				listContainer.x = 0;
				listContainer.y = 60;
				listContainer.width = 1024;
				listContainer.height = 480;

				listLabel.x = 140;
				listLabel.y = 10;
				listLabel.width = 744;
				listLabel.height = 40;
				
				dirLabel.x = 10;
				dirLabel.y = 50;
				dirLabel.width = 1004;
				dirLabel.height = 40;
				
				titleList.x = 0; 
				titleList.y = 90; 
				titleList.width = 1024; 
				titleList.height = 380; 
				
				openButton.x = 327;
				openButton.y = 483;
				openButton.width = 120;
				openButton.height = 57;

				deleteButton.x = 452;
				deleteButton.y = 483;
				deleteButton.width = 120;
				deleteButton.height = 57;

				moveDownloadButton.x = 577;
				moveDownloadButton.y = 483;
				moveDownloadButton.width = 120;
				moveDownloadButton.height = 57;
				
				if (reader != null)
				{
					reader.showCurrPage(true);
				}
			}
			else
			{
				if (helpLImage.visible)
				{
					helpLImage.visible = false;
					helpPImage.visible = true;
				}
				
				helpView.viewPort = new Rectangle(0, 65, screenWidth, screenHeight - 65);
				
				mainContainer.x = 0;
				mainContainer.y = 0;
				mainContainer.width = 600;
				mainContainer.height = 1024;
				
				logoButton.x = 5;
				logoButton.y = 5;
				logoButton.width = 130;
				logoButton.height = 100;
				
				titleContainer.x = 0;
				titleContainer.y = 0;
				titleContainer.width = 600;
				titleContainer.height = 60;
				
				helpButton.x = 475;
				helpButton.y = 3;
				helpButton.width = 120;
				helpButton.height = 57;
				
				syncButton.x = 350;
				syncButton.y = 3;
				syncButton.width = 120;
				syncButton.height = 57;
				
				searchButton.x = 225;
				searchButton.y = 3;
				searchButton.width = 120;
				searchButton.height = 57;
				
				emptyLabel.x = 0;
				emptyLabel.y = 0;
				emptyLabel.width = 600;
				emptyLabel.height = 10;
				
				listContainer.x = 0;
				listContainer.y = 60;
				listContainer.width = 600;
				listContainer.height = 904;
				
				listLabel.x = 140;
				listLabel.y = 10;
				listLabel.width = 320;
				listLabel.height = 40;
				
/*				listLabel.x = 10;
				listLabel.y = 50;
				listLabel.width = 580;
				listLabel.height = 40;*/
				
				titleList.x = 0; 
				titleList.y = 90; 
				titleList.width = 600; 
				titleList.height = 804; 
				
				dirLabel.x = 10;
				dirLabel.y = 50;
				dirLabel.width = 580;
				dirLabel.height = 40;
				
				openButton.x = 115;
				openButton.y = 907;
				openButton.width = 120;
				openButton.height = 57;
				
				deleteButton.x = 240;
				deleteButton.y = 907;
				deleteButton.width = 120;
				deleteButton.height = 57;
				
				moveDownloadButton.x = 365;
				moveDownloadButton.y = 907;
				moveDownloadButton.width = 120;
				moveDownloadButton.height = 57;

				if (reader != null)
				{
					reader.showCurrPage(true);
				}
			}
		}
		
		private function createUI():void
		{
			mainContainer = new Container();
			addChild(mainContainer);
			
			titleContainer = new Container();
			mainContainer.addChild(titleContainer);
			
			logoButton = new IconButton();
			logoButton.setIcon("img/logo.png");
			logoButton.addEventListener(MouseEvent.CLICK, onLogoClick);
			mainContainer.addChild(logoButton);

			helpButton = new IconButton();
			helpButton.setIcon("img/help.png");
			helpButton.addEventListener(MouseEvent.CLICK, onHelpClick);
			titleContainer.addChild(helpButton);
			
			syncButton = new IconButton();
			syncButton.setIcon("img/sync.png");
			syncButton.addEventListener(MouseEvent.CLICK, onSyncClick);
			titleContainer.addChild(syncButton);
			
			searchButton = new IconButton();
			searchButton.setIcon("img/go.png");
			searchButton.addEventListener(MouseEvent.CLICK, onSearchClick);
			titleContainer.addChild(searchButton);
			
			listContainer = new Container();
			mainContainer.addChild(listContainer);
			
			emptyLabel = new Label();
			emptyLabel.text = " ";
			listContainer.addChild(emptyLabel);
			
			var textFormat:TextFormat = new TextFormat();
			textFormat.bold = true;
			textFormat.italic = false;
			textFormat.align = TextFormatAlign.CENTER;
			
			var dirTextFormat:TextFormat = new TextFormat();
			dirTextFormat.bold = false;
			dirTextFormat.italic = true;
			dirTextFormat.align = TextFormatAlign.LEFT;
			
			listLabel = new Label();
			listLabel.format = textFormat;
			listLabel.text = "List of Titles";
			listContainer.addChild(listLabel);

			dirLabel = new Label();
			dirLabel.format = dirTextFormat;
			var dirName:String = currentDir.nativePath.substring(dirPos);
			if (dirName.length == 0)
			{
				dirName = "/";
			}
			dirLabel.text = "Current folder: " + dirName;
			listContainer.addChild(dirLabel);
			
			titleList = new List(); 
			titleList.selectionMode = ListSelectionMode.SINGLE; 
			titleList.scrollDirection = ScrollDirection.VERTICAL; 
			listContainer.addChild(titleList);
			
			openButton = new IconButton();
			openButton.setIcon("img/open.png");
			openButton.addEventListener(MouseEvent.CLICK, onOpenClick);
			listContainer.addChild(openButton);

			deleteButton = new IconButton();
			deleteButton.setIcon("img/delete.png");
			deleteButton.addEventListener(MouseEvent.CLICK, onDeleteClick);
			listContainer.addChild(deleteButton);
			
			moveDownloadButton = new IconButton();
			moveDownloadButton.setIcon("img/info.png");
			moveDownloadButton.addEventListener(MouseEvent.CLICK, onMoveDownloadClick);
			listContainer.addChild(moveDownloadButton);

			helpPImage.visible = false;
			helpPImage.x = 0;
			helpPImage.y = 0;
			helpPImage.addEventListener(MouseEvent.MOUSE_DOWN, onImageTap);
			mainContainer.addChild(helpPImage);

			helpLImage.visible = false;
			helpLImage.x = 0;
			helpLImage.y = 0;
			helpLImage.addEventListener(MouseEvent.MOUSE_DOWN, onImageTap);
			mainContainer.addChild(helpLImage);
			
			setTitleList(titleList);
			
			try
			{
				var path:File = File.applicationDirectory.resolvePath("help/help.html");
				var url:String = "file:/" + "/" + path.nativePath;
				helpView = new QNXStageWebView("Help");
				helpView.stage = this.stage;
				helpView.loadURL(url);
				helpView.addEventListener(WebViewEvent.DOCUMENT_LOAD_FAILED, onHelpFail);
				helpView.zoomToFitWidthOnLoad = true;
				helpView.visible = false;
			}
			catch (ex:Error)
			{
				trace("ERROR: " + ex.message);
			}
		}
		
		private function onHelpFail(e:WebViewEvent):void
		{
		}
		
		private function onImageTap(event:MouseEvent):void
		{
			helpPImage.visible = false;
			helpLImage.visible = false;
		}
		
		private function onOpenClick(event:MouseEvent):void
		{
			var pos:int = titleList.selectedIndex;
			if (pos == -1)
			{
				return;
			}

			if (reloadState)
			{
				timer2.reset();
				timer2.start();
			}
			else
			{
				var titleFile:String = titleList.getItemAt(pos)["filename"];
				if (titleFile.indexOf("./") == 0)
				{
					if (titleFile == "./..")
					{
						currentDir = currentDir.parent;
						var dirName:String = currentDir.nativePath.substring(dirPos);
						if (dirName.length == 0)
						{
							dirName = "/";
						}
						dirLabel.text = "Current folder: " + dirName;
					}
					else
					{
						currentDir = currentDir.resolvePath(titleFile.substr(2));
						var dirName:String = currentDir.nativePath.substring(dirPos);
						if (dirName.length == 0)
						{
							dirName = "/";
						}
						dirLabel.text = "Current folder: " + dirName;
					}
					onSyncClick(null);
					return;
				}
				bookManager.deleteTempFolder();
				timer.reset();
				timer.start();
			}

			tempOrientation = orientation;
			if (orientation == LANDSCAPE)
			{
				waitLImage.x = 0;  
				waitLImage.y = 0;  
				mainContainer.addChild(waitLImage);
			}
			else
			{
				waitPImage.x = 0;  
				waitPImage.y = 0;  
				mainContainer.addChild(waitPImage);
			}
		}
		
		private function onTimer2(event:TimerEvent):void
		{
			var pos:int = titleList.selectedIndex;
			bookCreator.setCoords();
			
			reader = new Reader(titleList.getItemAt(pos)["label"], titleList.getItemAt(pos)["filename"], stage);
			removeChild(mainContainer);
			addChild(reader);
			reader.setCurrPage(currWord);
			reader.showCurrPage(false);
			
			if (tempOrientation == LANDSCAPE)
			{
				mainContainer.removeChild(waitLImage);
			}
			else
			{
				mainContainer.removeChild(waitPImage);
			}
		}
		
		private function onTimer(event:TimerEvent):void
		{
			var pos:int = titleList.selectedIndex;
			var titleFile:String = titleList.getItemAt(pos)["filename"];
			try
			{
				BookInfo.reset(titleFile);
				BookInfo.load(titleFile);
			}
			catch (ex:Error)
			{
				trace(ex.getStackTrace());
				BookInfo.remove(titleFile);
				BookInfo.load(titleFile);
			}
			currWord = BookInfo.currWord;
			bookCreator.prepareIndex();
/*			try
			{*/
				var listOfChapters:Array = bookManager.getListOfChapters2(currentDir, titleList.getItemAt(pos)["filename"]);

				bookManager.getBookPieces(currentDir, titleList.getItemAt(pos)["filename"], listOfChapters);
				if (Svit.bookCreator.pieces == null)
				{
					if (tempOrientation == LANDSCAPE)
					{
						mainContainer.removeChild(waitLImage);
					}
					else
					{
						mainContainer.removeChild(waitPImage);
					}
					return;
				}
				bookCreator.setCoords();
				
				reader = new Reader(titleList.getItemAt(pos)["label"], titleFile, stage);
				removeChild(mainContainer);
				addChild(reader);
				reader.setCurrPage(currWord);
				reader.showCurrPage(false);
				
				if (tempOrientation == LANDSCAPE)
				{
					mainContainer.removeChild(waitLImage);
				}
				else
				{
					mainContainer.removeChild(waitPImage);
				}
/*			}
			catch (ex:Error)
			{
+				if (orientation == LANDSCAPE)
				{
					mainContainer.removeChild(waitLImage);
				}
				else
				{
					mainContainer.removeChild(waitLImage);
				}
				var warningDialog:AlertDialog = new AlertDialog();
				warningDialog.title = "Error";
				warningDialog.message = "EPUB file corruption detected:\n\n" + ex.message;
				warningDialog.addButton("Close");
				warningDialog.dialogSize = DialogSize.SIZE_MEDIUM;
				warningDialog.addEventListener(Event.SELECT, onWarningDialogClose);
				warningDialog.show(IowWindow.getAirWindow().group);
			}*/
		}
		
		public function reloadReader(wordPos:int):void
		{
			reloadState = true;
			backToMenu(false);
			currWord = wordPos;
			onOpenClick(null);
			reloadState = false;
		}
		
		public function backToMenu(unsetList:Boolean):void
		{
			reader.removeListeners();
			removeChild(reader.menuContainer);
			removeChild(reader);
			addChild(mainContainer);
			if (unsetList)
			{
				titleList.selectedIndex = -1;
				reader = null;
			}
		}
		
		private function onLogoClick(event:MouseEvent):void
		{
			helpDialog = new AlertDialog();
			helpDialog.title = "Help";
			helpDialog.message = HELP;
			helpDialog.addButton("Close");
			helpDialog.addButton("Extract books");
			helpDialog.addButton("Donate");
			helpDialog.addButton("Visit Pronic Apps");
			helpDialog.dialogSize = DialogSize.SIZE_LARGE;
			helpDialog.addEventListener(Event.SELECT, onLogoDialogClose);
			helpDialog.show(IowWindow.getAirWindow().group);
		}

		private function onHelpClick(event:MouseEvent):void
		{
/*			if (orientation == LANDSCAPE)
			{
				helpLImage.visible = true;
			}
			else
			{
				helpPImage.visible = true;
			}*/
			if (helpView.visible)
			{
				helpView.visible = false;
				helpButton.selected = false;
				logoButton.visible = true;
				searchButton.visible = true;
				syncButton.visible = true;
				listLabel.visible = true;
			}
			else
			{
				helpView.visible = true;
				helpButton.selected = true;
				logoButton.visible = false;
				searchButton.visible = false;
				syncButton.visible = false;
				listLabel.visible = false;
			}
		}
		
		private function onLogoDialogClose(event:Event):void
		{
			if (helpDialog.selectedIndex == 1)
			{
				bookManager.moveFreeIncludedBooks();
				titleList.removeAll();
				setTitleList(titleList);
			}
			else if (helpDialog.selectedIndex == 2)
			{
				var request:URLRequest = new URLRequest("https://www.paypal.com/xclick/business=ZZDA8JQF5YTGQ&item_name=Donation+to+Project+Gutenberg");
				navigateToURL(request, "_blank");
			}
			else if (helpDialog.selectedIndex == 3)
			{
				var request:URLRequest = new URLRequest("http://www.pronicapps.wordpress.com");
				navigateToURL(request, "_blank");
			}
		}
		
		private function onSyncClick(event:MouseEvent):void
		{
//			bookManager.moveDownloadedBooks();
			titleList.removeAll();
			setTitleList(titleList);
		}
		
		private function onSearchClick(event:MouseEvent):void
		{
			var popUp:PopupList = new PopupList();
			popUp.title = "Select site:";
			popUp.items = urlTitles;
			popUp.multiSelect = false;
			popUp.addButton("Go!");
			popUp.addButton("Cancel");
			popUp.dialogSize = DialogSize.SIZE_MEDIUM;
			popUp.addEventListener(Event.SELECT, onUrlSelect);
			popUp.show(IowWindow.getAirWindow().group);
		}
		
		private function onUrlSelect(event:Event):void 
		{
			var popUp:PopupList = event.target as PopupList;
			if (popUp.selectedIndex == 0)
			{
				if (popUp.selectedIndices.length == 1)
				{
					var pos:int = popUp.selectedIndices[0];
					var request:URLRequest = new URLRequest(urlLinks[pos]);
					navigateToURL(request, "_blank");
				}
			}
		}

		private function onDeleteClick(event:MouseEvent):void
		{
			var pos:int = titleList.selectedIndex;
			if (pos == -1)
			{
				return;
			}
			var alert:AlertDialog = new AlertDialog();
			alert.title = "Warning";
			alert.message = "Do you really want to delete '" + 
				titleList.getItemAt(pos)["label"] + "'?";
			alert.addButton("Yes");
			alert.addButton("No");
			alert.dialogSize= DialogSize.SIZE_SMALL;
			alert.addEventListener(Event.SELECT, alertDeleteClicked); 
			alert.show(IowWindow.getAirWindow().group);
		}

		private function onMoveDownloadClick(event:MouseEvent):void
		{
			bookManager.moveDownloadedBooks();
			titleList.removeAll();
			setTitleList(titleList);
		}
		
		private function onDetailsDialogClose(event:Event):void
		{
		}
		
		private function alertDeleteClicked(event:Event):void
		{
			var pos:int = titleList.selectedIndex;
			if (pos == -1)
			{
				return;
			}
			if (event.target.selectedIndex == 0)
			{
				var fileName:String = titleList.getItemAt(pos)["filename"];
				try
				{
					var sourceFile:File = currentDir.resolvePath(fileName);
					sourceFile.deleteFile();
					BookInfo.remove(fileName);
				}
				catch (error:Error)
				{
					trace("DELETE FILE ERROR: " + error.message);
				}
				titleList.removeItemAt(pos);;
			}
		}

		private function setTitleList(titleList:List):void
		{
			var bookArray:Array = []; 
			var dirList:Array = bookManager.listDirs(currentDir);
			for (var j:int; j < dirList.length; j++)
			{
				var dir:String = (dirList[j] as String); 
				var name:String = "[" + dir.substr(2) + "]";
				bookArray.push({label: name, filename: dir, title: dir}); 
			}
			var bookList:Array = bookManager.getListOfBooks(currentDir);
			for (var i:int; i < bookList.length; i++)
			{
				var book:Ebook = (bookList[i] as Ebook); 
				bookArray.push({label: book.title, filename: book.fileName, title: book.title}); 
			}
			bookArray.sortOn('title');

			titleList.dataProvider = new DataProvider(bookArray);
		}
		
		private function showEula():void
		{
			if (so.data.eula == undefined || so.data.eula == 0)
			{
				var eulaDialog:AlertDialog = new AlertDialog();
				eulaDialog.title = "END USER AGREEMENT AND LICENSE";
				eulaDialog.message = EULA;
				eulaDialog.addButton("I agree");
				eulaDialog.dialogSize = DialogSize.SIZE_FULL;
				eulaDialog.addEventListener(Event.SELECT, onEulaClose);
				eulaDialog.show(IowWindow.getAirWindow().group);
			}
			else
			{
				mainContainer.removeChild(wait2Image);
			}
		}
		
		private function onEulaClose(event:Event):void
		{
			var so:SharedObject = SharedObject.getLocal("svit-eula");
			so.data.eula = 1;
			so.flush();
			bookManager.moveFreeIncludedBooks();
			onSyncClick(null);
			mainContainer.removeChild(wait2Image);
		}
		
		private function deleteEulaInfo():void
		{
			var so:SharedObject = SharedObject.getLocal("svit-eula");
			so.clear();
			so.flush();
		}
		
		public static const EULA:String =
			"SVIT EBOOK READER - END USER AGREEMENT AND LICENSE\n\n" +
			"You may use this software product only on the condition that you agree to abide by the following terms.\n\n" +
			"BY INSTALLING OR USING THIS SOFTWARE, YOU ARE AGREEING ELECTRONICALLY TO THE TERMS OF THIS SOFTWARE END USER AGREEMENT (THE 'AGREEMENT' or 'LICENSE'). If you do not agree to the terms of this License, do not install, copy or use the Software. Also, you agree that any claim or dispute that you may have regarding this Agreement or the Software resides in the Courts of the Republic of Slovenia.\n\n" +
			"1.  SOFTWARE.  This Agreement and the supplemental terms below apply to the software product and any updates for SVIT EBOOK READER (hereinafter referred to as the 'Software').  In this Agreement, the term 'you' or 'your' means you as an individual or such entity in whose behalf you act, if any.\n\n" +
			"2.  OWNERSHIP.  This is a license of the Software and not a sale. The Software is protected by copyright and other intellectual property laws and by international treaties. The Author of the Software and suppliers own all rights in the Software. Your rights to use the Software are specified in this Agreement and we retain and reserve all rights not expressly granted to you.\n\n" +
			"3.  LICENSE.  Provided that you comply with the terms of this Agreement, we grant you a personal, limited, non-exclusive and non-transferable license to install and use the Software on a single, authorized BlackBerry® PlayBook™ device for personal and internal business purposes. This license does not entitle you to receive from us hard-copy documentation, support, telephone assistance, or enhancements or updates to the Software.\n\n" +
			"4.  RESTRICTIONS.  You may not: (i) make any copies of the Software other than an archival copy, (ii) modify or create any derivative works of the Software or documentation; (iii) decompile, disassemble, reverse engineer, or otherwise attempt to derive the source code, underlying ideas, or algorithms of the Software, or in any way ascertain, decipher, or obtain the communications protocols for accessing our networks; (iv) copy, reproduce, reuse in another product or service, modify, alter, or display in any manner any files, or parts thereof, included in the Software;\n\n" +
			"The Software is offered in the United States. You understand and agree that (a) the Software is not designed or customized for distribution for any specific country or jurisdiction ('Territory') and (b) the Software is not intended for distribution to, or use by, any person or entity in any Territory where such distribution or use would be contrary to local law or regulation. You are solely responsible for compliance with local laws as applicable when you use the Software.\n\n" +
			"5. CONTENT.  Content, information ('Content') that may be accessed through the use of the Software is the property of its respective owner. You may only use such Content for personal, noncommercial purposes and subject to the terms and conditions that accompany such Content. We make no representations or warranties regarding the accuracy or reliability of the information included in such Content.\n\n" +
			"6. CONTENT DISCLAIMER. All of the content and information within LUX CONVERT, (the 'Content') is provided 'AS IS' and for your convenience only.  RIM, ITS AFFILIATES, ITS INFORMATION PROVIDERS, AIRTIME SERVICE PROVIDERS/TELECOMMUNICATIONS CARRIERS, AND ANY MoR MAKING THE SOFTWARE AVAILABLE THROUGH ITS KIOSK MAKE NO EXPRESS OR IMPLIED WARRANTIES (INCLUDING, WITHOUT LIMITATION, ANY WARRANTY OF MERCHANTABLILITY, ACCURACY OR FITNESS FOR A PARTICULAR PURPOSE OR USE) REGARDING ANY CONTENT.\n\n" +
			"RIM, any telecommunications carriers, its information providers, and any MoR shall not be liable for any decisions you make based upon use of the Content. In addition, RIM, including its affiliates and information or content providers, any telecommunications carriers, and any MoR, will not be liable to anyone for any interruption, inaccuracy, error or omission, regardless of cause, or for any resulting damages (whether direct or indirect, consequential, punitive or exemplary).\n\n" +
			"7.  DISCLAIMER OF WARRANTY.\n\n" +
			"WE LICENSE THE SOFTWARE 'AS IS' AND WITH ALL FAULTS. WE DO NOT WARRANT THAT THIS SOFTWARE WILL MEET YOUR REQUIREMENTS OR THAT ITS OPERATION WILL BE UNINTERRUPTED OR ERROR-FREE. THE ENTIRE RISK AS TO SATISFACTORY QUALITY, PERFORMANCE, ACCURACY, EFFORT AND COST OF ANY SERVICE AND REPAIR IS WITH YOU.\n\n" +
			"WE, OUR SUPPLIERS AND DISTRIBUTORS DISCLAIM ALL EXPRESS WARRANTIES AND ALL IMPLIED WARRANTIES, INCLUDING ANY IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, NON-INTERFERENCE, NON-INFRINGEMENT OR ACCURACY, UNLESS SUCH IMPLIED WARRANTIES ARE LEGALLY INCAPABLE OF EXCLUSION.\n\n" +
			"NO ORAL OR WRITTEN INFORMATION OR ADVICE GIVEN BY US SHALL CREATE A WARRANTY OR IN ANY WAY INCREASE THE SCOPE OF ANY WARRANTY THAT CANNOT BE DISCLAIMED UNDER APPLICABLE LAW. WE, OUR SUPPLIERS AND DISTRIBUTORS HAVE NO LIABILITY WITH RESPECT TO YOUR USE OF THE SOFTWARE.\n\n" +
			"IF ANY IMPLIED WARRANTY MAY NOT BE DISCLAIMED UNDER APPLICABLE LAW, THEN SUCH IMPLIED WARRANTY IS LIMITED TO 30 DAYS FROM THE DATE YOU ACQUIRED THE SOFTWARE FROM US OR OUR AUTHORIZED DISTRIBUTOR.\n\n" +
			"8.  LIMITATION OF LIABILITY.\n\n" +
			"TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, IN NO EVENT WILL WE, OUR DISTRIBUTORS, CHANNEL PARTNERS, AND ASSOCIATED SERVICE PROVIDERS, BE LIABLE FOR ANY INDIRECT, SPECIAL, INCIDENTAL, CONSEQUENTIAL, OR EXEMPLARY DAMAGES ARISING OUT OF OR IN ANY WAY RELATING TO THIS AGREEMENT OR THE USE OF OR INABILITY TO USE THE SOFTWARE, INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF GOODWILL, WORK STOPPAGE, LOST PROFITS, LOSS OF DATA, COMPUTER OR DEVICE FAILURE OR MALFUNCTION, OR ANY AND ALL OTHER COMMERCIAL DAMAGES OR LOSSES, EVEN IF ADVISED OF THE POSSIBILITY THEREOF, AND REGARDLESS OF THE LEGAL OR EQUITABLE THEORY (CONTRACT, TORT OR OTHERWISE) UPON WHICH THE CLAIM IS BASED.\n\n" +
			"9.  NO SUPPORT OR UPGRADE OBLIGATIONS.  We, our suppliers and distributors are not obligated to create or provide any support, corrections, updates, upgrades, bug fixes and/or enhancements of the Software.\n\n" +
			"10.  IMPORT/EXPORT CONTROL.  The Software is subject to export and import laws, regulations, rules and orders of the United States and foreign nations. You must comply with these laws that apply to the Software. You may not directly or indirectly export, re-export, transfer, or release the Software, any other commodities, software or technology received from us, or any direct product thereof, for any proscribed end-use, or to any proscribed country, entity or person (wherever located), without proper authorization from the U.S. and/or foreign government.\n\n" +
			"11.  U.S. GOVERNMENT END-USERS.  The Software is a 'commercial item,' as that term is defined in 48 C.F.R. 2.101, consisting of 'commercial computer software' and 'commercial computer software documentation,' as such terms are used in 48 C.F.R. 12.212 (Sept. 1995) and 48 C.F.R. 227.7202 (June 1995). Consistent with 48 C.F.R. 12.212, 48 C.F.R. 27.405(b) (2) (June 1998) and 48 C.F.R. 227.7202, all U.S. Government End Users acquire the Software with only those rights as described in this License.\n\n" +
			"12.  ELECTRONIC NOTICES.  YOU AGREE TO THIS LICENSE ELECTRONICALLY. YOU AUTHORIZE US TO PROVIDE YOU ANY INFORMATION AND NOTICES REGARDING THE SOFTWARE ('NOTICES') IN ELECTRONIC FORM. WE MAY PROVIDE NOTICES TO YOU (1) VIA E-MAIL IF YOU HAVE PROVIDED US WITH A VALID EMAIL ADDRESS OR (2) BY POSTING THE NOTICE ON A WEB OR MOBILE PAGE DESIGNATED BY US FOR THIS PURPOSE. The delivery of any Notice is effective when sent or posted by us, regardless of whether you read the Notice or actually receive the delivery. You can withdraw your consent to receive Notices electronically by discontinuing your use of the Software.\n\n" +
			"13.  INDEMNIFICATION.  Upon a request by us, you agree to defend, indemnify, and hold harmless us and other affiliated companies, and our respective employees, contractors, officers, directors, suppliers and agents and distributors from all liabilities, claims, and expenses, including attorney's fees that arise from your use or misuse of the Software. We reserve the right, at our own expense, to assume the exclusive defense and control of any matter otherwise subject to indemnification by you, in which event you will cooperate with us in asserting any available defenses.\n\n" +
			"14. CHOICE OF LAW AND LOCATION FOR RESOLVING DISPUTES. YOU EXPRESSLY AGREE THAT EXCLUSIVE JURISDICTION FOR ANY CLAIM OR DISPUTE RELATING IN ANY WAY TO YOUR USE OF THE SOFTWARE RESIDES IN THE FEDERAL OR STATE COURTS LOCATED IN THE COMMONWEALTH OF CALIFORNIA AND YOU FURTHER AGREE AND EXPRESSLY CONSENT TO THE EXERCISE OF PERSONAL JURISDICTION IN SUCH COURTS IN CONNECTION WITH ANY SUCH DISPUTE INCLUDING ANY CLAIM INVOLVING the software. PLEASE NOTE THAT BY AGREEING TO THESE TERMS OF USE, YOU ARE WAIVING CLAIMS THAT YOU MIGHT OTHERWISE HAVE AGAINST US BASED ON THE LAWS OF OTHER JURISDICTIONS, INCLUDING YOUR OWN.\n\n" +
			"15.  ENTIRE AGREEMENT.  This Agreement and any supplemental terms constitute the entire agreement between you and us concerning the subject matter of this Agreement, which may only be modified by us.\n\n" +
			"16.  GENERAL TERMS.  (a) This Agreement shall not be governed by the United Nations Convention on Contracts for the International Sale of Goods. (b) If any part of this Agreement is held invalid or unenforceable, that part shall be construed to reflect the parties' original intent, and the remaining portions remain in full force and effect, or we may at our option terminate this Agreement. (c) The controlling language of this Agreement is English. If you have received a translation into another language, it has been provided for your convenience only. (d) A waiver by either party of any term or condition of this Agreement or any breach thereof, in any one instance, shall not waive such term or condition or any subsequent breach thereof. (e) You may not assign or otherwise transfer by operation of law or otherwise this Agreement or any rights or obligations herein. We may assign this Agreement to any entity at its sole discretion and without notice to you. (f) This Agreement shall be binding upon and shall inure to the benefit of the parties, their successors and permitted assigns. (g) Neither party shall be in default or be liable for any delay, failure in performance or interruption of service resulting directly or indirectly from any cause beyond its reasonable control.\n\n" +
			"17.  USER OUTSIDE THE U.S.  If you are using the Software outside the U.S., then the provisions of this Section shall apply: (i) Les parties aux prA©sentA©s confirment leur volontA© que cette convention de mAame que tous les documents y compris tout avis qui s'y rattachA©, soient redigA©s en langue anglaise. (translation: 'The parties confirm that this Agreement and all related documentation is and will be in the English language.'); (ii) you are responsible for complying with any local laws in your jurisdiction which might impact your right to import, export or use the Software, and you represent that you have complied with any regulations or registration procedures required by applicable law to make this license enforceable; and (iii) if the laws applicable to your use of the Software would prohibit the enforceability of this Agreement, or confer any rights to you that are materially different from the terms and conditions of this Agreement, then you are not authorized to use the Software and you agree to remove it from your device.\n\n" +
			"Supplemental Terms for BLACKBERRY®, airtime service providers, and MoRs.\n\n" +
			"These terms supplement and are in addition to the terms of the Agreement for users who install the Software on hardware products provided by Research In Motion, Limited ('RIM'), airtime service providers, and any MoRs.\n\n" +
			"a. You understand and agree that RIM, airtime service providers, and any MoRs have no obligation whatsoever to furnish any maintenance and support services regarding the Software.\n\n" +
			"b. RIM, airtime service providers, and any MoRs shall not be responsible for any claims by you or any third relating to your possession and/or use of the Software, including but not limited to (i) product liability claims, (ii) any claim that the Software fails to conform to any applicable legal or regulatory requirement, (iii) claims arising under consumer protection laws or similar legislation, and (iv) claims by any third party that the Software or your possession and use of the Software infringes the intellectual property rights of the third party.\n\n" +
			"c. You agree that RIM, RIM's subsidiaries, airtime service providers, and any MoRs are third party beneficiaries of this Agreement, and that upon your acceptance of the terms and conditions of this License, RIM will have the right (and will be deemed to have accepted the right) to enforce this Agreement against you as a third party beneficiary thereof.";
	}
}