/**
 *  Copyright (c)  2009 coltware@gmail.com
 *  http://www.coltware.com 
 *
 *  License: LGPL v3 ( http://www.gnu.org/licenses/lgpl-3.0-standalone.html )
 *
 * @author coltware@gmail.com
 */
package com.coltware.airxzip {
	
	import flash.events.*;
	import flash.utils.*;
	
	use namespace zip_internal;
	/**
	*  Zipファイル情� �
	*/
	public class ZipEntry extends EventDispatcher{
		
		public static var METHOD_NONE:int    = 0;
		public static var METHOD_DEFLATE:int = 8;
		
		zip_internal var _header:ZipHeader;
		zip_internal var _headerLocal:ZipHeader;
		private var _content:ByteArray;
		
		private var _stream:IDataInput;
		
		public function ZipEntry(stream:IDataInput) {
			_stream = stream;
		}
		
		/**
		*  @private
		*/
		public function setHeader(h:ZipHeader):void{
			_header = h;
		}
		
		/**
		*  圧縮方式を返す
		*
		*/
		public function getCompressMethod():int{
			return _header.getCompressMethod();
		}
		
		/**
		*  ファイル名を取得する.
		*
		*  文字コードを指定しない� �合には、自動的に判断する。
		*  た� し、あくまでZipファイルの日本的な慣習にのっとり自動判別します。
		*  なので、utf-8 もしくは shift_jis のどちらかが自動的には判断されます。
		*
		*/
		public function getFilename(charset:String = null):String{
			return _header.getFilename(charset);
		}
		
		/**
		*  
		*  ディレクトリか?
		*/
		public function isDirectory():Boolean{
			return _header.isDirectory();
		}
		/**
		*  圧縮率を返す.
		*
		*/
		public function getCompressRate():Number{
			return _header.getCompressRate();
		}
		
		public function getUncompressSize():int{
			return _header.getUncompressSize();
		}
		
		public function getCompressSize():int{
			return _header.getCompressSize();
		}
		
		/**
		*  日付情� �を返す
		*
		*/
		public function getDate():Date{
			return _header.getDate();
		}
		
		/**
		 *  圧縮バージョンを取得する.
		 * 
		 * unzipコマンドでは"minimum software version required to extract:"と記述されている。
		 * 
		 */
		public function getVersion():int{
			return _header._version;
		}  
		
		/**
		 *  圧縮ホストのバージョンを取得する
		 * 
		 * unzipコマンドでは"version of encoding software:"と記述されている
		 * 
		 */
		public function getHostVersion():int{
			return _header.getVersion();
		}
		/**
		 *  CRC32 の値を取得する
		 */
		public function getCrc32():String{
			return _header._crc32.toString(16);
		}
		
		public function isEncrypted():Boolean{
			if(_header._bitFlag & 1){
				return true;
			}
			else{
				return false;
			}
		}
		
		/**
		*
		*  LOCAL HEADERのオフセット位置を取得する
		*
		* @private
		*/
		public function getLocalHeaderOffset():int{
			return _header.getLocalHeaderOffset();
		}
		
		
		
		/**
		 * @private
		 */
		public function getLocalHeaderSize():int{
			return _header.getLocalHeaderSize();
		}
		
		
		
		zip_internal function dumpLogInfo():void{
			_header.dumpLogInfo();
		}

	}

}