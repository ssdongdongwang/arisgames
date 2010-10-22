package org.arisgames.editor.view
{
	import com.google.maps.InfoWindowOptions;
	import com.google.maps.Map;
	import com.google.maps.overlays.Marker;
	
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.net.URLRequest;
	
	import mx.controls.Alert;
	
	import org.arisgames.editor.model.GameObject;
	import org.arisgames.editor.model.GameObjectEvent;
	import org.arisgames.editor.model.InstanceProperties;
	import org.arisgames.editor.model.InstantiatedObject;

	public class GameObjectMarker extends Sprite
	{
		private var sourceInstance:InstanceProperties;
		private var loader:Loader;
		private var url:String;
		private var xOffset:Number;
		private var marker:Marker;
		private var map:Map;
		
		public function GameObjectMarker(sourceInstance:InstanceProperties, map:Map)
		{
			this.sourceInstance = sourceInstance;
			this.map = map;
			this.loader = new Loader();
			url = "assets/editor icons/";
			var type:String = getSourceObject().getType();
			if(type == GameObject.ITEM)
			{
				url += "item2.png";
				xOffset = 0;
			}
			else if(type == GameObject.CHARACTER)
			{
				url += "character.png";
				xOffset = 2;			
			}
			else if(type == GameObject.PAGE)
			{
				url += "page2.png";
				xOffset = 0;			
			}
			else if(type == GameObject.SECRET_EVENT)
			{
				url += "question.png";
				xOffset = 2;			
			}
			else
			{
				return;
			}
            loader.load(new URLRequest(url));
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, drawImage);
            loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			this.marker = null;
		}
		
		public function deleteMe():void
		{
			this.marker.closeInfoWindow();
			this.map.removeOverlay(this.marker);
			this.marker = null;
		}
		
		public function getGoogleMapsMarker():Marker
		{
			return this.marker;
		}
		
		public function setGoogleMapsMarker(newMarker:Marker):void
		{
			if(this.marker == null)
			{
				this.marker = newMarker;
			}
		}
		
		public function setFocus():void
		{
			this.map.setFocus();
		}
		
		public function getSourceInstance():InstanceProperties
		{
			return this.sourceInstance;
		}
		
		public function getSourceObject():InstantiatedObject
		{
			return this.sourceInstance.getSourceObject();
		}
		
        private function drawImage(event:Event):void
        {
        	var myBitmap:BitmapData = new BitmapData(loader.width, loader.height, false);
        	var transform:Matrix = new Matrix();
        	transform.tx = xOffset - 12;
        	transform.ty = -35;
            myBitmap.draw(loader);
            
            var shadowAlpha:Number = 0.25;
            for(var i:int = 1; i < 4; i++)
            {
	            graphics.lineStyle(1 + i, 0x000000, shadowAlpha);
	            graphics.moveTo(0,0);
	            graphics.lineTo(2.3, -4.5);
	            graphics.lineStyle(0, 0, 0);
	            graphics.beginFill(0x000000, shadowAlpha);
	            graphics.drawCircle(7.5, -13, 7 + i);
	            graphics.endFill();
	        }

			graphics.lineStyle(1, 0x000000);
			graphics.beginBitmapFill(myBitmap, transform, false, false);
			graphics.drawCircle(0, -25, 12);
			graphics.endFill();
			graphics.beginFill(0x000000);
			graphics.drawRect(-0.5, -13, 1, 13);
			graphics.endFill();
			
 			this.addEventListener(MouseEvent.CLICK, showInfoWindow);
        }
 
        private function ioErrorHandler(event:IOErrorEvent):void
        {
        	Alert.show("Unable to load image: " + url);
        }
        
        public function showInfoWindow(event:Event = null):void
        {
			var contentDisplay:Sprite = sourceInstance.getContentDisplay();
			var options:InfoWindowOptions = new InfoWindowOptions({customContent: contentDisplay, 
																   drawDefaultFrame: true, 
																   pointOffset: new Point(0, -38),
																   height: contentDisplay.height,
																   width: contentDisplay.width});
			marker.openInfoWindow(options);
			dispatchEvent(new GameObjectEvent(GameObjectEvent.CHANGE));        	
        }
		
	}
}