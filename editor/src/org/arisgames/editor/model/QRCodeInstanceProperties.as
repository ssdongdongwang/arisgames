package org.arisgames.editor.model
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	
	import mx.controls.Alert;
	import mx.core.DragSource;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.events.DragEvent;
	import mx.managers.DragManager;
	
	public class QRCodeInstanceProperties extends InstanceProperties
	{
		public static const MAX_CODE_LENGTH:int = 4;
		
		private var qrCode:uint;
		private var qrCodeField:TextField;
		private var qrCodeView:Sprite;
		private var contentDisplayWrapper:UIComponent; // we use a wrapper to allow adding this as a child to a flex container
		private var dragOffsetX:Number;
		private var dragOffsetY:Number;
		
		public function QRCodeInstanceProperties(sourceObject:InstantiatedObject, qrCode:int = -1, quantity:int = 1):void
		{
			super(sourceObject, InstanceProperties.QR_CODE, quantity);
			this.randomizeQRCode();

			var qrCodeLabel:TextField = new TextField();
			qrCodeLabel.text = "QR Code: ";
			qrCodeLabel.width = qrCodeLabel.textWidth;
			qrCodeLabel.height = qrCodeLabel.textHeight + 5;
			qrCodeLabel.x = 0;
			qrCodeLabel.y = 0;
			qrCodeLabel.selectable = false;
			
			qrCodeField = new TextField();
			qrCodeField.text = "9"; // for width setting only
			qrCodeField.height = qrCodeField.textHeight + 2;
			qrCodeField.width = (MAX_CODE_LENGTH * qrCodeField.textWidth * 1.5);
			qrCodeField.text = getQRCode().toString(); // put text back to actual code value
			qrCodeField.maxChars = MAX_CODE_LENGTH;
			qrCodeField.restrict = "0-9";
			qrCodeField.selectable = true;
			qrCodeField.type = TextFieldType.INPUT;
			qrCodeField.x = qrCodeLabel.width;
			qrCodeField.y = 0;
			qrCodeField.addEventListener(Event.CHANGE, updateQRCode);
			updateQRCode();
			
			qrCodeView = new Sprite();
			qrCodeView.addChild(qrCodeLabel);
			qrCodeView.addChild(qrCodeField);
			contentDisplay.addChild(qrCodeView);
			
			updateContentDisplay();
			contentDisplayWrapper = null;
		}
		
		public function getQRCode():uint
		{
			return qrCode;
		}
		
		public function setQRCode(newCode:uint):void
		{
			this.qrCode = newCode;
		}
		
		public function randomizeQRCode():void
		{
			var newCode:uint;
			var searching:Boolean = true;
			while(searching)
			{
				newCode = Math.random() * getMaxCodeNumber();
				searching = false;			
			}
			this.setQRCode(newCode);
		}
		
		public function getMaxCodeNumber():uint
		{
			return uint(Math.pow(10, MAX_CODE_LENGTH) - 1);
		}
		
		public function updateQRCode(event:Event = null):void
		{
			setQRCode(uint(qrCodeField.text));
			var codeString:String = getQRCode().toString()
			if(codeString.length > MAX_CODE_LENGTH) //make sure code isn't too long
			{
				codeString = codeString.substring(0, MAX_CODE_LENGTH);
				Alert.show("Error: requested QR Code exceeds maximum length of " + MAX_CODE_LENGTH.toString() + " characters.  Code has been truncated.");
			}
			if(qrCodeField.text != codeString)
			{
				qrCodeField.text = codeString;
				qrCodeField.setSelection(0,qrCodeField.length);
			}			
		}

		public function setContentDisplayWrapper(wrapper:UIComponent):void
		{
			this.contentDisplayWrapper = wrapper;
			wrapper.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			wrapper.addEventListener(DragEvent.DRAG_COMPLETE, dragCompleteHandler);
			wrapper.addChild(getContentDisplay());
			updateContentDisplay();
		}
		
		public function getContentDisplayWrapper():UIComponent
		{
			return this.contentDisplayWrapper;
		}
		
		private function dragCompleteHandler(event:DragEvent):void
		{
			if(event.action == DragManager.MOVE)
			{
				contentDisplayWrapper.x -= dragOffsetX;
				contentDisplayWrapper.y -= dragOffsetY;				
			}
		}
		
		private function mouseMoveHandler(event:MouseEvent):void
		{
            var ds:DragSource = new DragSource();
            ds.addData(this.contentDisplayWrapper, InstanceProperties.QR_CODE);
            dragOffsetX = this.contentDisplayWrapper.mouseX;
            dragOffsetY = this.contentDisplayWrapper.mouseY;
            DragManager.doDrag(this.contentDisplayWrapper, ds, event);           
 		}
		
		override public function updateContentDisplay(event:Event = null):void
		{
			titleField.text = getSourceObject().getName();
			titleField.width = titleField.textWidth + 20;
			titleField.height = titleField.textHeight + 5;
			qrCodeView.y = titleField.height;
			var nextY:Number = qrCodeView.y + qrCodeView.height + 5;
			if(getSourceObject().getType() == GameObject.ITEM)
			{
				quantityField.text = getQuantity().toString();
				quantityView.y = nextY;
				nextY += quantityView.height + 5;
			}
			deleteBox.y = nextY;
			if(contentDisplayWrapper != null)
			{
				contentDisplayWrapper.width = contentDisplay.width;
				contentDisplayWrapper.height = contentDisplay.height;
				contentDisplayWrapper.graphics.clear();
				contentDisplayWrapper.graphics.beginFill(0xFFFFFF);
				contentDisplayWrapper.graphics.lineStyle(2, 0x000000);
				contentDisplayWrapper.graphics.drawRect(-2, -2, contentDisplayWrapper.width + 4, contentDisplayWrapper.height + 4);
				contentDisplayWrapper.graphics.endFill();
			}
		}
		
		override protected function doDelete(event:CloseEvent):void
		{
//			this.getGameMarker().setFocus();
			if(event.detail == Alert.OK)
			{
				deleteBox.removeEventListener(MouseEvent.CLICK, deleteMe);
				qrCodeField.removeEventListener(Event.CHANGE, updateQRCode);
				this.contentDisplay = null;
				if(contentDisplayWrapper != null)
				{
					this.contentDisplayWrapper.parent.removeChild(this.contentDisplayWrapper);
					this.contentDisplayWrapper = null;
				}
				this.getSourceObject().removeInstance(this);				
			}
		}
		
	}
}