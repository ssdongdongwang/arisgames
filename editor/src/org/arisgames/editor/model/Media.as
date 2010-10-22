package org.arisgames.editor.model
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	
	public class Media extends EventDispatcher
	{
		public static const IMAGE:String = "image";
		public static const SOUND:String = "sound";
		public static const VIDEO:String = "video";
		public static const MEDIA_UPLOAD_COMPLETE:String = "mediaUploadComplete";
		public static const MEDIA_UPLOAD_CANCELED:String = "mediaUploadCanceled";
		
		private var id:int;
		private var type:String;
		private var fileName:String;
		private var fileRef:FileReference;
		
		public function Media(id:int, type:String):void
		{
			this.id = id;
			this.type = type;
			this.fileName = null;
			this.fileRef = null;
			this.setFileName();
		}
		
		public function getID():int
		{
			return this.id;
		}
		
		public function getType():String
		{
			return this.type;
		}
		
		public function getFileName():String
		{
			return this.fileName;
		}
		
		//NOTE THAT THIS SETTER IS INTENTIONALLY PRIVATE - the filename should only be set by the constructor when the file is first uploaded
		private function setFileName():void
		{
			var fileType:String;
			var windowsFileExtensions:String;
			var macFileExtensions:String = null;
			if(this.type == IMAGE)
			{
				fileType = "Images (gif, png, jpg)";
				windowsFileExtensions = "*.gif;*.png;*.jpg";
			}
			else if(this.type == SOUND)
			{
				fileType = "Sound Files (mp3, aac)";
				windowsFileExtensions = "*.mp3;*.aac";
			}
			else if(this.type == VIDEO)
			{
				fileType = "Video (mp4, h.264)";
				windowsFileExtensions = "*.mp4";
			}
			else
			{
				return;
			}
			fileRef = new FileReference();
			fileRef.addEventListener(Event.SELECT, selectHandler);
			fileRef.addEventListener(Event.CANCEL, cancelHandler);
			fileRef.browse(new Array(new FileFilter(fileType, windowsFileExtensions, macFileExtensions)))
		}
		
		private function selectHandler(event:Event):void
		{
			this.fileName = fileRef.name;
			var event:Event = new Event(MEDIA_UPLOAD_COMPLETE, true, false);
			dispatchEvent(event);
		}
		
		private function cancelHandler(event:Event):void
		{
			var event:Event = new Event(MEDIA_UPLOAD_CANCELED, true, false);
			dispatchEvent(event);
		}

	}
}