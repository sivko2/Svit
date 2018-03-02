package
{
	import com.coltware.airxzip.ZipFileReader;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import qnx.dialog.AlertDialog;
	import qnx.dialog.DialogSize;
	import qnx.display.IowWindow;
	import qnx.ui.display.Image;
	
	public class BookManager
	{
		private var titles:Array;
		
		public function BookManager()
		{
		}

		public function moveFreeIncludedBooks():void
		{
			var freeBookDirs:Array = listFiles(File.applicationDirectory.resolvePath("ebooks/"));
			for (var i:int; i < freeBookDirs.length; i++)
			{
				copyFile(File.applicationDirectory, "ebooks/", freeBookDirs[i],
					File.userDirectory, "shared/books/", freeBookDirs[i]);
			}
			freeBookDirs  = null;
		}
		
		public function deleteTempFolder():void
		{
			if (!File.userDirectory.resolvePath("shared/misc/svit").exists)
			{
				File.userDirectory.resolvePath("shared/misc/svit").createDirectory();
			}
			var tempFiles:Array = File.userDirectory.resolvePath("shared/misc/svit/").getDirectoryListing();
			for (var i:int; i < tempFiles.length; i++)
			{
				var sourceFile:File = File.userDirectory.resolvePath("shared/misc/svit/" + (tempFiles[i] as File).name);
				if(!sourceFile.isDirectory && !sourceFile.isHidden)
				{
					sourceFile.deleteFile();
				}
				sourceFile = null;
			}
			tempFiles = null;
		}
		
		public function moveDownloadedBooks():void
		{
			var bookDirs:Array = listFiles(File.userDirectory.resolvePath("shared/downloads/"));
			for (var i:int; i < bookDirs.length; i++)
			{
				moveFile(File.userDirectory, "shared/downloads/", bookDirs[i],
					File.userDirectory, "shared/books/", bookDirs[i]);
			}
			bookDirs = null;
		}
		
		public function moveDocumentBooks():void
		{
			var bookDirs:Array = listFiles(File.userDirectory.resolvePath("shared/documents/"));
			for (var i:int; i < bookDirs.length; i++)
			{
				moveFile(File.userDirectory, "shared/documents/", bookDirs[i],
					File.userDirectory, "shared/books/", bookDirs[i]);
			}
			bookDirs = null;
		}
		
		public function getListOfBooks(dir:File):Array
		{
			var titles:Array = new Array();
			var dirs:Array = listFiles(dir);
			var delta:Number = 0;
			for (var i:int; i < dirs.length; i++)
			{
				var name:String = (dirs[i] as String);
				try
				{
					var data:ByteArray = readTextFileFromZip2(dir, name, ".opf");
					if (data != null)
					{
						var title:String = getBookTitle2(data, name);
						if (title == null)
						{
							title = name;
						}
						titles[titles.length] = new Ebook(title, name);
						title = null;
					}
					data = null;
				}
				catch (error:Error)
				{
					trace("Not EPUB file");
				}
				name = null;
			}
			dirs = null;
			return titles;
		}
		
		public function getDetails(dir:File, fileName:String):String
		{
			var data:ByteArray = readTextFileFromZip2(dir, fileName, ".opf");
			if (data != null)
			{
				return getBookDetails(data);
			}
			return null;
		}
		
		public function getBookDetails(data:ByteArray):String
		{
			var _package:XML = new XML(data);
			var xmlNamespace:Namespace = new Namespace("http://www.idpf.org/2007/opf");
			default xml namespace = xmlNamespace;
			var dc:Namespace = new Namespace("http://purl.org/dc/elements/1.1/");
			
			return "Creator: " + _package.metadata.dc::creator + "\n\nTitle: " + _package.metadata.dc::title;
			
		}
		
		public function deleteFile(dir:File, delFileName:String):void
		{
			try
			{
				var sourceFile:File = dir.resolvePath(delFileName);
				sourceFile.deleteFile();
				sourceFile = null;
			}
			catch (error:Error)
			{
				trace("DELETE FILE ERROR: " + error.message);
			}
		}
		
		public function deleteDir():void
		{
			var dirs:Array = listFiles(File.userDirectory);
			for (var i:int; i < dirs.length; i++)
			{
				try
				{
					var sourceFile:File = File.userDirectory.resolvePath("shared/books/" + (dirs[i] as String));
					sourceFile.deleteFile();
				}
				catch (error:Error)
				{
					trace("DELETE DIR ERROR: " + error.message);
				}
			}
			dirs = null;
		}
		
		public function getBookPieces(dir:File, fileName:String, titles:Array):void
		{
			var file:File = dir.resolvePath(fileName);
			Svit.bookCreator.pieces = null;
			Svit.bookCreator.pieces = new Array();
			try
			{
				for each(var xmlFilename:String in titles)
				{
					var data:ByteArray = readTextFileFromZip2(dir, file.name, xmlFilename);
					if (data != null)
					{
						getPieces(data, file.name);
					}
					data = null;
				}
			}
			catch (ex:Error)
			{
				Svit.bookCreator.pieces = null;
				var warningDialog:AlertDialog = new AlertDialog();
				warningDialog.title = "Error";
				warningDialog.message = "EPUB file corruption detected:\n\n" + ex.message;
				warningDialog.addButton("Close");
				warningDialog.dialogSize = DialogSize.SIZE_MEDIUM;
//				warningDialog.addEventListener(Event.SELECT, onWarningDialogClose);
				warningDialog.show(IowWindow.getAirWindow().group);
			}
		}
		
		private function onWarningDialogClose(event:Event):void
		{
		}

		public function getListOfImages(dir:File, fileName:String):Array
		{
			var imageFiles:Array = new Array();
			var file:File = dir.resolvePath(fileName);
			try
			{
				var reader:ZipFileReader = new ZipFileReader();
				reader.open(file);
				var list:Array = reader.getEntries();
				
				for each(var aEntry:com.coltware.airxzip.ZipEntry in list)
				{
					if(!aEntry.isDirectory())
					{
						var pos:int = aEntry.getFilename().lastIndexOf(".");
						var ext:String = aEntry.getFilename().substr(pos + 1).toUpperCase();
						if (ext == "JPG" || ext == "PNG" || ext == "GIF")
						{
							imageFiles[imageFiles.length] = aEntry.getFilename();
						}
						ext = null;
					}
				}
				reader = null;
			}
			catch(ex:Error)
			{
			}
			file = null;
			return imageFiles;
		}
		
		public function getListOfChapters2(dir:File, fileName:String):Array
		{
			var titles:Array;
			var file:File = dir.resolvePath(fileName);
			var data:ByteArray = readTextFileFromZip2(dir, file.name, ".opf");
			if (data != null)
			{
				titles = getBookChapters2(data);
			}
			data = null;
			file = null;
			return titles;
		}
	
		public function readTextFileFromZip2(dir:File, fileName:String, innerFileName:String):ByteArray
		{
			try
			{
				var reader:ZipFileReader = new ZipFileReader();
				var sourceFile:File = dir.resolvePath(fileName);
				reader.open(sourceFile);
				var list:Array = reader.getEntries();
				
				for each(var aEntry:com.coltware.airxzip.ZipEntry in list)
				{
					if(!aEntry.isDirectory())
					{
						if(aEntry.getFilename().toUpperCase().indexOf(innerFileName.toUpperCase()) > -1)
						{
							return reader.unzip(aEntry);
						}
					}
				}
			}
			catch(ex:Error)
			{
				trace(ex.getStackTrace());
			}
			return null;
		}
		
		public function getBookTitle2(data:ByteArray, name:String):String
		{
			try
			{
				var _package:XML = new XML(data);
				var xmlNamespace:Namespace = new Namespace("http://www.idpf.org/2007/opf");
				default xml namespace = xmlNamespace;
				var dc:Namespace = new Namespace("http://purl.org/dc/elements/1.1/");
				
				var retVal:String = _package.metadata.dc::title;
				if (_package.metadata.dc::creator[0] != null)
				{
					retVal += " by " + _package.metadata.dc::creator[0];
				}
				dc = null;
				xmlNamespace = null;
				_package = null;
				return retVal + " (" + name + ")";
			}
			catch(ex:Error)
			{
			}
			return null;
		}
		
		public function getBookChapters2(data:ByteArray):Array
		{
			titles = new Array();

			try
			{
				var _package:XML = new XML(data);
				var xmlNamespace:Namespace = new Namespace("http://www.idpf.org/2007/opf");
				default xml namespace = xmlNamespace;
				var dc:Namespace = new Namespace("http://purl.org/dc/elements/1.1/");
				
				var spineList:XMLList = _package.spine.elements();
				for each (var xmlTag:XML in spineList)
				{
					var idRef:String = xmlTag.@idref;
					if (idRef != null)
					{
						titles[titles.length] = (_package.manifest.item.(@id==idRef).@href);
					}
					idRef = null;
				}
				spineList = null;
				dc = null;
				xmlNamespace = null;
				_package = null;
			}
			catch(ex:Error)
			{
			}
			
			return titles;
		}
		
		public function getPieces(data:ByteArray, fileName:String):void
		{
			default xml namespace = new Namespace("http://www.w3.org/1999/xhtml");
			
			var str:String = new String(data);

//			trace(str);
			str = stripAll2(str);
//			trace(str);
			var html:XML = new XML(str);
//			trace("B");
			searchParagraphs(html.body.elements(), fileName);
			str = null;
			html = null;
		}
		
		private function stripAll2(xmlValue:String):String
		{
			var outValue:String = "";
			var command:String;
			var fullCommand:String;
			var size:int = xmlValue.length;
			var ok:Boolean = true;
			var commandOk:Boolean = false;
			var closedTagOk:Boolean = false;
			
			for (var pos:int = 0; pos < size; pos++)
			{
				var ch:String = xmlValue.charAt(pos);
				if (ok)
				{
				 	if (ch == "\n"){outValue += " ";}
					else if (ch == "\r"){outValue += " ";}
					else if (ch == "\t"){outValue += " ";}
					else if (ch == "<")
					{
						ok = false;
						commandOk = true;
						closedTagOk = false;
						command = "";
						fullCommand = "";
					}
					else
					{
						outValue += ch;
					}
				}
				else
				{
					var nextCh:String = xmlValue.charAt(pos + 1);
					if (command.length > 0 && ch == "/" && nextCh == ">")
					{
						if (command != "img")
						{
							closedTagOk = true;
						}
						if (commandOk)
						{
							command += ch;
						}
						fullCommand += ch;
					}
					else if (ch == " ")
					{
						command = command.toLowerCase();
						fullCommand += ch;
						if (command.indexOf("?xml") != 0 && command.indexOf("!doctype") != 0)
						{
							commandOk = false;
						}
						else
						{
							command += " ";
						}
					}
					else if (ch == "\n"){}
					else if (ch == "\r"){}
					else if (ch == "\t"){}
					else if (ch == ">")
					{
						ok = true;
						command = command.toLowerCase();
						fullCommand = fullCommand.toLowerCase();
						if (closedTagOk)
						{
//							trace("CLOSED: " + fullCommand);
							outValue += " ";
							closedTagOk = false;
						}
						else if (command == "p"){outValue += "<" + command + ">";}
						else if (command == "div"){outValue += "<" + command + ">";}
						else if (command == "table"){outValue += "<" + command + ">";}
						else if (command == "h1"){outValue += "<" + command + ">";}
						else if (command == "h2"){outValue += "<" + command + ">";}
						else if (command == "h3"){outValue += "<" + command + ">";}
						else if (command == "h4"){outValue += "<" + command + ">";}
						else if (command == "h5"){outValue += "<" + command + ">";}
						else if (command == "h6"){outValue += "<" + command + ">";}
						else if (command == "/p"){outValue += "<" + command + ">";}
						else if (command == "/div"){outValue += "<" + command + ">";}
						else if (command == "/table"){outValue += "<" + command + ">";}
						else if (command == "/h1"){outValue += "<" + command + ">";}
						else if (command == "/h2"){outValue += "<" + command + ">";}
						else if (command == "/h3"){outValue += "<" + command + ">";}
						else if (command == "/h4"){outValue += "<" + command + ">";}
						else if (command == "/h5"){outValue += "<" + command + ">";}
						else if (command == "/h6"){outValue += "<" + command + ">";}
						else if (command == "html"){outValue += "<" + command + ">";}
						else if (command == "/html"){outValue += "<" + command + ">";}
						else if (command == "head"){outValue += "<" + command + ">";}
						else if (command == "/head"){outValue += "<" + command + ">";}
						else if (command == "body"){outValue += "<" + command + ">";}
						else if (command == "/body"){outValue += "<" + command + ">";}
						else if (command == "br/"){outValue += " ###NEWLINE### ";}
						else if (command == "br"){outValue += " ###NEWLINE### ";}
						else if (command == "hr/"){outValue += " ###NEWLINE### ";}
						else if (command == "hr"){outValue += " ###NEWLINE### ";}
						else if (command == "img") 
						{
							var startPos:int = fullCommand.toUpperCase().indexOf("SRC=\"") + 5;
							var endPos:int = fullCommand.toUpperCase().indexOf("\"", startPos + 1);
							var url:String = fullCommand.substr(startPos, endPos - startPos);
							outValue += " <img>###IMAGE###" + url + "###</img> ";
						}
						else if (command == "!--") {}
//						else if (command == "div") {outValue += " ";}
//						else if (command == "/div") {outValue += " ";}
						else
						{
//							trace(command);
							outValue += " ";
						}
					}
					else
					{
						if (commandOk)
						{
							command += ch;
						}
						fullCommand += ch;
					}
				}
			}

			return outValue;
		}
		
		private function searchParagraphs(childrenList:XMLList, fileName:String):void
		{
			var type:int = 0;

			for each (var xmlTag:XML in childrenList)
			{
				var xmlValue:String = xmlTag.toXMLString();
				
//				xmlValue = xmlValue.replace("<p xmlns=\"http://www.w3.org/1999/xhtml\">", "<p>");						
//				xmlValue = xmlValue.replace("<div xmlns=\"http://www.w3.org/1999/xhtml\">", "<div>");						
				
//				trace(xmlValue);
				xmlTag = new XML(xmlValue);
//				trace("***");

				
	//			if ((xmlTag.localName() == "div" || xmlTag.localName() == "table") && xmlTag.hasComplexContent())
				if (xmlTag.hasComplexContent())
				{
					searchParagraphs(xmlTag.children(), fileName);
					continue;
				}
				else  if (xmlTag.localName() == "div" || xmlTag.localName() == "img" ||
					xmlTag.localName() == "p" || 
					xmlTag.localName() == "h1" ||  xmlTag.localName() == "h2" ||
					xmlTag.localName() == "h3" || xmlTag.localName() == "h4" ||
				    xmlTag.localName() == "h5" || xmlTag.localName() == "h6" ||
					xmlTag.localName() == "table")
				{
					if (xmlTag.localName() == "p")
					{
						type = Epiece.TYPE_P;
					}
					else if (xmlTag.localName() == "img")
					{
						type = Epiece.TYPE_IMAGE;
					}
					else if (xmlTag.localName() == "table")
					{
						type = Epiece.TYPE_P;
					}
					else if (xmlTag.localName() == "div")
					{
						type = Epiece.TYPE_P;
					}
					else if (xmlTag.localName() == "h1")
					{
						type = Epiece.TYPE_H1;
					}
					else if (xmlTag.localName() == "h2")
					{
						type = Epiece.TYPE_H2;
					}
					else if (xmlTag.localName() == "h3")
					{
						type = Epiece.TYPE_H3;
					}
					else if (xmlTag.localName() == "h4")
					{
						type = Epiece.TYPE_H4;
					}
					else if (xmlTag.localName() == "h5")
					{
						type = Epiece.TYPE_H5;
					}
					else if (xmlTag.localName() == "h6")
					{
						type = Epiece.TYPE_H6;
					}

					var paragraph:String;
					var isComplex:Boolean = xmlTag.hasComplexContent();
					if (isComplex)
					{
						paragraph = xmlValue;
					}
					else
					{
						paragraph = xmlTag;
					}
					paragraph = paragraph.split("\n").join("");
					paragraph = paragraph.split("\t").join("");
					paragraph = paragraph.split("\r").join("");
					var subPieces:Array = paragraph.split(" ");
					var firstOne:Boolean = true;
					for each(var piece:String in subPieces)
					{
						if (piece != null && piece.length > 0)
						{
							if (firstOne)
							{
//								piece = "      " + piece;
								firstOne = false;
							}
							if (piece == "###NEWLINE###")
							{
								if (Svit.bookCreator.pieces.length > 2 && 
									(Svit.bookCreator.pieces[Svit.bookCreator.pieces.length - 2] as Epiece).type == Epiece.TYPE_NEW_LINE &&
									(Svit.bookCreator.pieces[Svit.bookCreator.pieces.length - 1] as Epiece).type == Epiece.TYPE_NEW_LINE)
								{
								}
								else
								{
									Svit.bookCreator.pieces[Svit.bookCreator.pieces.length] = new Epiece("", Epiece.TYPE_NEW_LINE);
								}
							}
							else if (piece.indexOf("###IMAGE###") == 0)
							{
								type = Epiece.TYPE_IMAGE;
								var imageFilename:String = piece.substring(11, piece.length - 3);
								Svit.bookCreator.pieces[Svit.bookCreator.pieces.length] = new Epiece("IMAGE (TAP TO OPEN)", Epiece.TYPE_IMAGE);
								var prefix:String = imageFilename.substr(0, imageFilename.lastIndexOf("."));
								if (prefix.indexOf("/") > 0)
								{
									prefix = prefix.substring(prefix.lastIndexOf("/") + 1);
								}
								(Svit.bookCreator.pieces[Svit.bookCreator.pieces.length - 1] as Epiece).imagePath = prefix + ".html";
								var data:ByteArray = readTextFileFromZip2(Svit.currentDir, fileName, imageFilename);
								
//								Svit.bookCreator.pieces[Svit.bookCreator.pieces.length] = new Epiece("", Epiece.TYPE_NEW_LINE);
//								Svit.bookCreator.pieces[Svit.bookCreator.pieces.length] = new Epiece("", Epiece.TYPE_NEW_LINE);
								
								try
								{
									var outFile:File = File.userDirectory.resolvePath("shared/misc/svit/" + imageFilename);
									var out:FileStream = new FileStream();
									out.open(outFile, FileMode.WRITE);
									out.writeBytes(data, 0, data.length);
									out.close();
									
									outFile = File.userDirectory.resolvePath("shared/misc/svit/" + prefix + ".html");
									var htmlValue:String = "<html><body bgcolor=\"#999999\"><img src=\"" + imageFilename + "\"></img></body></html>";
									out = new FileStream();
									out.open(outFile, FileMode.WRITE);
									out.writeMultiByte(htmlValue,"utf-8");
									out.close();
									
								}
								catch(ex:Error)
								{
									trace("ERROR: " + ex.getStackTrace());
								}
							}
							else
							{
								Svit.bookCreator.pieces[Svit.bookCreator.pieces.length] = new Epiece(piece, type, firstOne);
							}
						}
					}
					Svit.bookCreator.pieces[Svit.bookCreator.pieces.length] = new Epiece(null, Epiece.TYPE_NEW_LINE);
				}
				else
				{
					continue;
				}
				searchNavPoints(xmlTag.elements());
			}
			
		}
		
		private function searchNavPoints(childrenList:XMLList):void
		{
			for each (var xmlTag:XML in childrenList)
			{
				if (xmlTag.localName() == "navPoint")
				{
				}
				else if (xmlTag.localName() == "content")
				{
					var attrList:XMLList = xmlTag.attributes();
					for each (var attrTag:XML in attrList)
					{
						var str:String = attrTag;
						var pos:int = str.indexOf("#");
						if (pos > -1)
						{
							str = str.substr(0, pos);
						}
						if (checkList(titles, str))
						{
							titles[titles.length] = str;
						}
					}
					continue;
				}
				else
				{
					continue;
				}
				searchNavPoints(xmlTag.elements());
			}
		}

		private function checkList(titles:Array, str:String):Boolean
		{
			for (var i:int = 0; i < titles.length; i++)
			{
				var tempStr:String = titles[i] as String;
				if (tempStr == str)
				{
					return false;
				}
			}
			return true;
		}
		
		public function listDirs(rootDir:File):Array
		{
			var retVal:Array = new Array();
			if (rootDir.nativePath != File.userDirectory.nativePath)
			{
				retVal[retVal.length] = "./..";
			}
			try
			{
				var dirs:Array = rootDir.getDirectoryListing();
				if (dirs != null)
				{
					for (var i:int = 0; i < dirs.length; i++)
					{
						if((dirs[i] as File).isDirectory && !(dirs[i] as File).isHidden)
						{
							var name:String = (dirs[i] as File).name;
							retVal[retVal.length] = "./" + name;
						}
					}
				}
			}
			catch (error:Error)
			{
				trace("LIST BOOKS ERROR: " + error.message);	
			}
			return retVal;
		}

		public function listFiles(rootDir:File):Array
		{
			var retVal:Array = new Array();
			try
			{
				var dirs:Array = rootDir.getDirectoryListing();
				if (dirs != null)
				{
					for (var i:int = 0; i < dirs.length; i++)
					{
						if(!(dirs[i] as File).isDirectory && !(dirs[i] as File).isHidden)
						{
							var name:String = (dirs[i] as File).name;
							var pos:int = name.lastIndexOf(".");
							var currExt:String = name.substr(pos + 1);
							if (currExt.toUpperCase() == "EPUB")
							{
								retVal[retVal.length] = name;
							}
						}
					}
				}
			}
			catch (error:Error)
			{
				trace("LIST BOOKS ERROR: " + error.message);	
			}
			return retVal;
		}
		
		public function readFile(rootDir:File, pathName:String, fileName:String):ByteArray
		{
			try
			{
				var file:File = rootDir.resolvePath(pathName + fileName);
				var fileStream:FileStream = new FileStream();
				fileStream.open(file, FileMode.READ);
				var data:ByteArray = new ByteArray();
				fileStream.readBytes(data, 0, file.size);
				fileStream.close();
				return data;
			}
			catch (error:Error)
			{
				trace("READ INTERNAL FILE ERROR " + error.message);
			}
			return null;
		}
		
		public function writeFile(rootDir:File, pathName:String, fileName:String, data:ByteArray):void
		{
			try
			{
				var file:File = rootDir.resolvePath(pathName + fileName);
				var fileStream:FileStream = new FileStream();
				fileStream.open(file, FileMode.WRITE);
				fileStream.writeBytes(data, 0, data.length);
				fileStream.close();
			}
			catch (error:Error)
			{
				trace("WRITE FILE INTO DOCS ERROR " + error.message);
			}
		}
		
		public function copyFile(srcRootDir:File, srcPathName:String, srcFileName:String,
								  destRootDir:File, destPathName:String, destFileName:String):void
		{
			var data:ByteArray = readFile(srcRootDir, srcPathName, srcFileName);
			if (data != null)
			{
				writeFile(destRootDir, destPathName, destFileName, data);
			}
		}
		
		public function moveFile(srcRootDir:File, srcPathName:String, srcFileName:String,
								  destRootDir:File, destPathName:String, destFileName:String):void
		{
			copyFile(srcRootDir, srcPathName, srcFileName, destRootDir, destPathName, destFileName);
			srcRootDir.resolvePath(srcPathName + srcFileName).deleteFile();
		}
		
		public function stripString(xmlValue:String, beginToken:String, endToken:String):String
		{
			var startPos:int = xmlValue.indexOf(beginToken);
			if (startPos == -1)
			{
				return xmlValue;
			}
			var endPos:int = xmlValue.indexOf(endToken, startPos + 1);
			if (endPos == -1)
			{
				return xmlValue;
			}
			return xmlValue.substr(0, startPos) +  " " + xmlValue.substr(endPos + 1);
		}
		
	}
}