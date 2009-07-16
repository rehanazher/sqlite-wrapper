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
		private var _data:String;
		private var _file:File;
		private var _fileStream:FileStream;
		private var _parameters:String;
		
		public function Logger():void {
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
			var len:uint = statement.parameters.length;
			trace("len="+len);
			
			_statement = statement.text;
			trace("statement "+_statement);
			if(statement.parameters) {
				for(i = 0; i < len; i++) {
					_parameters += statement.parameters[i];
					trace("parameters "+_parameters);
				}
			}
			
			
			_data = _statement + "\n";
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