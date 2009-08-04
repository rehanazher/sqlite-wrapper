/**
 * This is the Logger class - provides simple logging to enable an SQL log to be 
 * built up of statements passed through the wrapper. Forms an initial basis
 * for the addition of synchronisation/replication. 
 * 
 * @author	R.Turrall
 * @version 0.1
 */
package org.sqlitewrapper {
	import flash.data.*;
	import flash.events.*;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	[Event(name="error", type="flash.events.IOErrorEvent")] 
	
	public class Logger extends EventDispatcher {
		
		private var _statement:String;
		private var _fullStatement:String;
		private var _data:String;
		private var _file:File;
		private var _fileStream:FileStream;
		private var _parameters:Array;
		
		private var _logSelects:Boolean;
		
		public function Logger(logSelects:Boolean = false):void {
			
			_logSelects = logSelects;
			
			_file = File.applicationStorageDirectory.resolvePath("applog.sql");
			_fileStream = new FileStream();
			_fileStream.addEventListener(IOErrorEvent.IO_ERROR, onLogError);
			purgeLog(); // truncate the log ready for reuse
		}
		
		//[Bindable]
		public function get log():String {
			var logData:String;
			_fileStream.open(_file, FileMode.APPEND);
			logData = _fileStream.readUTFBytes(_fileStream.bytesAvailable);
			_fileStream.close();
			return logData;
		}
		
		// consider using openAsync() to avoid performance issues or impacting SQL performance

		public function writeLog(statement:SQLStatement):void {
			var i:uint;
			var len:uint;
			
			_parameters = new Array();
			_statement = statement.text;
			
			// strip out SELECT statements if not logging them - but cater for subselects!
			var ind:int = statement.text.indexOf("SELECT");
			
			if (ind > -1 && ind < 8 ) {
				if (!_logSelects) {
					return;
				} 
			}
			
			for(var prop:Object in statement.parameters) { 
				_parameters.push(statement.parameters[prop]);
			} 
			
			// now need to add in the parameter values to the sql statement before writing to the log!
			// work through occurrences of "?" and replace with values from the _parameters array
			len = _parameters.length;
			
			var matchPattern:RegExp = /\?/;  
			_fullStatement = _statement;
			
			for(i = 0; i < len; i++) {
				_fullStatement = _fullStatement.replace(matchPattern, _parameters[i]);
			}
			
			_data = _fullStatement + "\n";
			_fileStream.open(_file, FileMode.APPEND);
			_fileStream.writeUTFBytes(_data);
			_fileStream.close();
		}
		
		public function purgeLog():void {
			_fileStream.open(_file, FileMode.WRITE);
			_fileStream.writeUTFBytes("");
			_fileStream.close();
		}

		private function onLogError(evt:IOErrorEvent):void {
			dispatchEvent(evt);
		} 
		
	}
	
}