package org.arisgames.editor.model
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	
	import mx.controls.Alert;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	
	// IMPORTANT: this class is intended to be functionally ABSTRACT.
	// Do not implement directly.  Instead use one of GPSInstanceProperties or QRCodeInstanceProperites
	public class InstanceProperties
	{
		public static const GPS:String = "gps";
		public static const QR_CODE:String = "qrCode";
		
		protected var sourceObject:InstantiatedObject;
		protected var type:String;
		protected var quantity:uint;
		protected var titleField:TextField;
		protected var deleteBox:Sprite;
		protected var contentDisplay:Sprite;
		protected var quantityView:Sprite;
		protected var quantityField:TextField;

		public function InstanceProperties(sourceObject:InstantiatedObject, type:String, quantity:int = 1):void
		{
			this.sourceObject = sourceObject;
			this.type = type;
			this.setQuantity(quantity);

			titleField = new TextField();
			titleField.text = getSourceObject().getName();
			titleField.x = 0;
			titleField.y = 0;

			var deleteField:TextField = new TextField();
			deleteField.text = "Delete this copy";
			deleteField.x = deleteField.textHeight;
			deleteField.height = deleteField.textHeight + 5;
			deleteField.width = deleteField.textWidth + 5;
			deleteField.selectable = false;

			deleteBox = new Sprite();
			deleteBox.graphics.lineStyle(3, 0xFF0000);
			deleteBox.graphics.moveTo(2, 2);
			deleteBox.graphics.lineTo(deleteField.textHeight - 2, deleteField.textHeight - 2);
			deleteBox.graphics.moveTo(deleteField.textHeight - 2, 2);
			deleteBox.graphics.lineTo(2, deleteField.textHeight - 2);			
			deleteBox.addChild(deleteField);
			deleteBox.addEventListener(MouseEvent.CLICK, deleteMe);
			
			this.contentDisplay = new Sprite();
			contentDisplay.addChild(titleField);
			contentDisplay.addChild(deleteBox);

			if(sourceObject.getType() == GameObject.ITEM)
			{
				var quantityLabel:TextField = new TextField();
				quantityLabel.text = "Quantity Here: ";
				quantityLabel.width = quantityLabel.textWidth;
				quantityLabel.height = quantityLabel.textHeight + 5;
				quantityLabel.x = 0;
				quantityLabel.y = 0;
				quantityLabel.selectable = false;
				
				quantityField = new TextField();
				quantityField.text = "99"; // for setting size only
				quantityField.height = quantityField.textHeight + 2;
				quantityField.width = quantityField.textWidth + 5;
				quantityField.text = this.getQuantity().toString(); //actual value to display
				quantityField.maxChars = 2;
				quantityField.restrict = "0-9";
				quantityField.selectable = true;
				quantityField.type = TextFieldType.INPUT;
				quantityField.x = quantityLabel.width;
				quantityField.y = 0;
				quantityField.addEventListener(Event.CHANGE, updateQuantity);

				quantityView = new Sprite();
				quantityView.addChild(quantityLabel);
				quantityView.addChild(quantityField);
				contentDisplay.addChild(quantityView);
			}
		}	
							
		public function getSourceObject():InstantiatedObject
		{
			return this.sourceObject;
		}
		
		public function getType():String
		{
			return this.type;
		}

		public function getQuantity():uint
		{
			return this.quantity;
		}
		
		public function setQuantity(newQuantity:uint):void
		{
			if(sourceObject.getType() == GameObject.ITEM)
			{
				this.quantity = newQuantity;			
			}
			else
			{
				this.quantity = 1;
			}
		}
		
		public function updateQuantity(event:Event):void
		{
			setQuantity(uint(quantityField.text));
			if(quantityField.text != getQuantity().toString())
			{
				quantityField.text = getQuantity().toString();
				quantityField.setSelection(0,quantityField.length);
			}			
		}
		
		protected function deleteMe(event:MouseEvent = null):void
		{
			Alert.show("Are you sure you want to delete this copy of " + getSourceObject().getName() + "?  (other copies will remain in place)",
					   "Confirm Delete", (Alert.OK | Alert.CANCEL), null, doDelete, null, Alert.CANCEL);
		}
		
		public function getContentDisplay():Sprite
		{
			return this.contentDisplay;
		}
		
		// ABSTRACT FUNCTION
		public function updateContentDisplay(event:Event = null):void
		{
			Alert.show("Error: updateContentDisplay function from InstanceProperties class must be overriden");
		}

		// ABSTRACT FUNCTION
		protected function doDelete(event:CloseEvent):void
		{
			Alert.show("Error: doDelete function from InstanceProperties class must be overridden");
		}
		
	}
}