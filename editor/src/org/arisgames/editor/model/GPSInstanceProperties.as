package org.arisgames.editor.model
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	
	import org.arisgames.editor.view.GameObjectMarker;
	
	public class GPSInstanceProperties extends InstanceProperties
	{
		private var gpsMarker:GameObjectMarker;
		private var initiallyHidden:Boolean;
		private var forceView:Boolean;
		private var hiddenPicLoader:Loader;
		private var visiblePicLoader:Loader;
		private var visibilityIndicator:Sprite;
		private var forceViewPicLoader:Loader;
		private var optionalViewPicLoader:Loader;
		private var viewModeIndicator:Sprite;
		
		public function GPSInstanceProperties(sourceObject:InstantiatedObject, initiallyHidden:Boolean = false, forceView:Boolean = true, quantity:int = 1):void
		{
			super(sourceObject, InstanceProperties.GPS, quantity);
			hiddenPicLoader = new Loader()
			hiddenPicLoader.load(new URLRequest("assets/editor icons/hidden.png"));
			hiddenPicLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, updateContentDisplay);
			visiblePicLoader = new Loader();
			visiblePicLoader.load(new URLRequest("assets/editor icons/visible.png"));
			visiblePicLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, updateContentDisplay);
			visibilityIndicator = new Sprite();
			visibilityIndicator.addEventListener(MouseEvent.CLICK, updateVisibilityIndicator);
			forceViewPicLoader = new Loader();
			forceViewPicLoader.load(new URLRequest("assets/editor icons/exclamationPoint.png"));
			forceViewPicLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, updateContentDisplay);
			optionalViewPicLoader = new Loader();
			optionalViewPicLoader.load(new URLRequest("assets/editor icons/parentheses.png"));
			optionalViewPicLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, updateContentDisplay);
			viewModeIndicator = new Sprite();
			viewModeIndicator.addEventListener(MouseEvent.CLICK, updateViewModeIndicator);
			this.gpsMarker = null;
			this.initiallyHidden = initiallyHidden;
			this.forceView = forceView;
			updateVisibilityIndicator();
			visibilityIndicator.x = 0;
			contentDisplay.addChild(visibilityIndicator);
			updateViewModeIndicator();
			contentDisplay.addChild(viewModeIndicator);
			deleteBox.x = 0;
		}
								
		public function getGameMarker():GameObjectMarker
		{
			return gpsMarker;
		}
				
		public function setGameMarker(newMarker:GameObjectMarker):void
		{
			if(this.gpsMarker == null)
			{
				this.gpsMarker = newMarker;
			}
		}

		public function isInitiallyHidden():Boolean
		{
			return initiallyHidden;
		}
		
		public function setInitiallyHidden(newState:Boolean):void
		{
			initiallyHidden = newState;
		}
		
		public function isViewForced():Boolean
		{
			return forceView;
		}
		
		public function setForceView(newState:Boolean):void
		{
			forceView = newState;
		}
		
		override public function updateContentDisplay(event:Event = null):void
		{
			titleField.text = getSourceObject().getName();
			titleField.width = titleField.textWidth + 20;
			titleField.height = titleField.textHeight + 5;
			visibilityIndicator.y = titleField.height;
			viewModeIndicator.x = visibilityIndicator.width + 5;
			viewModeIndicator.y = visibilityIndicator.y;
			var nextY:Number = visibilityIndicator.y + visibilityIndicator.height + 5;
			if(getSourceObject().getType() == GameObject.ITEM)
			{
				quantityField.text = getQuantity().toString();
				quantityView.y = nextY;
				nextY += quantityView.height + 5;
			}
			deleteBox.y = nextY;
		}
		
		override protected function doDelete(event:CloseEvent):void
		{
			this.getGameMarker().setFocus();
			if(event.detail == Alert.OK)
			{
				visibilityIndicator.removeEventListener(MouseEvent.CLICK, updateVisibilityIndicator);
				viewModeIndicator.removeEventListener(MouseEvent.CLICK, updateViewModeIndicator);
				deleteBox.removeEventListener(MouseEvent.CLICK, deleteMe);
				gpsMarker.deleteMe();
				gpsMarker = null;
				this.getSourceObject().removeInstance(this);				
			}
		}
		
		private function updateVisibilityIndicator(event:MouseEvent = null):void
		{
			if(event != null)
			{
				this.setInitiallyHidden(!isInitiallyHidden());
			}
			var image1:Loader;
			if(isInitiallyHidden())
			{
				image1 = hiddenPicLoader;
			}
			else
			{
				image1 = visiblePicLoader;
			}
			if(!visibilityIndicator.contains(image1))
			{
				while(visibilityIndicator.numChildren > 0)
				{
					visibilityIndicator.removeChildAt(0);
				}
				visibilityIndicator.addChild(image1);				
			}
		}

		private function updateViewModeIndicator(event:MouseEvent = null):void
		{
			if(event != null)
			{
				this.setForceView(!isViewForced());
			}
			var image1:Loader;
			if(isViewForced())
			{
				image1 = forceViewPicLoader;
			}
			else
			{
				image1 = optionalViewPicLoader;
			}
			if(!viewModeIndicator.contains(image1))
			{
				while(viewModeIndicator.numChildren > 0)
				{
					viewModeIndicator.removeChildAt(0);
				}
				viewModeIndicator.addChild(image1);				
			}
		}

	}
}