package org.arisgames.editor.components
{
	import com.ninem.controls.TreeBrowser;
	import com.ninem.events.TreeBrowserEvent;
	
	import flash.events.MouseEvent;
	
	import mx.containers.Panel;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.DataGrid;
	import mx.core.ClassFactory;
	import mx.events.DynamicEvent;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	import mx.rpc.Responder;
	
	import org.arisgames.editor.data.arisserver.Media;
	import org.arisgames.editor.models.GameModel;
	import org.arisgames.editor.services.AppServices;
	import org.arisgames.editor.util.AppConstants;
	import org.arisgames.editor.util.AppDynamicEventManager;
	import org.arisgames.editor.util.AppUtils;
	
	public class GameEditorMediaPickerView extends Panel
	{
		// Data Object
		public var delegate:Object;
		//private var objectPaletteItem:ObjectPaletteItemBO;
		private var isIconPicker:Boolean = false;
		private var uploadFormVisable:Boolean = false;
		
		// Media Data
		[Bindable] public var xmlData:XML;
		
		// GUI
		[Bindable] public var treeBrowser:TreeBrowser;
		[Bindable] public var closeButton:Button;
		[Bindable] public var selectButton:Button;
		
		// Tree Icons
		[Bindable]
		[Embed(source="assets/img/separator.png")]
		public var separatorIcon:Class; //If these names are changed, make sure it is also changed in AppConstants (MEDIATREEICON_*)
		
		[Bindable]
		[Embed(source="assets/img/upload.png")]
		public var uploadIcon:Class; //If these names are changed, make sure it is also changed in AppConstants (MEDIATREEICON_*)
		
		private var mediaUploader:GameEditorMediaPickerUploadFormMX;
		
		/**
		 * Constructor
		 */
		public function GameEditorMediaPickerView()
		{
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, handleInit);
		}
		
		private function handleInit(event:FlexEvent):void
		{
			trace("in GameEditorMediaPickerView's handleInit");
			var cf:ClassFactory = new ClassFactory(GameEditorMediaPickerCustomEditorMX);
			//cf.properties = {objectPaletteItem: this.objectPaletteItem};
			treeBrowser.detailRenderer = cf;
			treeBrowser.addEventListener(TreeBrowserEvent.NODE_SELECTED, onNodeSelected);
			closeButton.addEventListener(MouseEvent.CLICK, handleCloseButton);
			selectButton.addEventListener(MouseEvent.CLICK, handleSelectButton);
			// Load Game's Media Into XML
			AppServices.getInstance().getMediaForGame(GameModel.getInstance().game.gameId, new Responder(handleLoadingOfMediaIntoXML, handleFault));
		}
		
		private function printXMLData():void
		{
			trace("XML Data = '" + xmlData.toXMLString() + "'");
		}
		
		public function isInIconPickerMode():Boolean
		{
			return isIconPicker;
		}
		
		public function setIsIconPicker(isIconPickerMode:Boolean):void
		{
			trace("setting isIconPicker mode to: " + isIconPickerMode);
			this.isIconPicker = isIconPickerMode;
			this.updateTitleBasedOnMode();
		}
		
		private function updateTitleBasedOnMode():void
		{
			if (isIconPicker)
			{
				title = "Icon Picker";
			}
			else
			{
				title = "Media Picker";
			}
		}
		
		private function handleCloseButton(evt:MouseEvent):void
		{
			trace("GameEditorMediaPickerView: handleCloseButton()");
			PopUpManager.removePopUp(this);
		}
		
		
		private function handleSelectButton(evt:MouseEvent):void
		{
			trace("Select Button clicked...");
			
			var m:Media = new Media();
			m.mediaId = treeBrowser.selectedItem.@mediaId;
			m.name = treeBrowser.selectedItem.@name;
			m.type = treeBrowser.selectedItem.@type;
			m.urlPath = treeBrowser.selectedItem.@urlPath;
			m.fileName = treeBrowser.selectedItem.@fileName;
			m.isDefault = treeBrowser.selectedItem.@isDefault;
			
			if (delegate.hasOwnProperty("didSelectMediaItem")){
				delegate.didSelectMediaItem(this, m);
			}		
			
			PopUpManager.removePopUp(this);
		}
		
		
		private function handleLoadingOfMediaIntoXML(obj:Object):void
		{	
			trace("In handleLoadingOfMediaIntoXML() Result called with obj = " + obj + "; Result = " + obj.result);
			if (obj.result.returnCode != 0)
			{
				trace("Bad loading of media attempt... let's see what happened.  Error = '" + obj.result.returnCodeDescription + "'");
				var msg:String = obj.result.returnCodeDescription;
				Alert.show("Error Was: " + msg, "Error While Loading Media");
				return;
			}
			
			//Init the XML Data
			xmlData = new XML('<nodes label="' + AppConstants.MEDIATYPE + '"/>');
			
			this.printXMLData();
			
			var media:Array = obj.result.data as Array;
			trace("Number of Media Objects returned from server = '" + media.length + "'");
			
			//Puts media items in xml readable format
			var numImageDefaults:Number = 0;
			var numAudioDefaults:Number = 0;
			var numVideoDefaults:Number = 0;
			var numIconDefaults:Number = 0;
			for (var k:Number = 0; k <= 1; k++) //Iterates over list twice; once for uploaded items, again for default
			{
				if(k == 0){
					xmlData.appendChild('<node label="' + AppConstants.MEDIATYPE_UPLOADNEW + '" icon="'+ AppConstants.MEDIATREEICON_UPLOAD +'"/>');
				}
				for (var j:Number = 0; j < media.length; j++)
				{
					var o:Object = media[j];
					
					if((k==0 && !o.is_default) || (k==1 && o.is_default)){
						var m:Media = new Media();
						
						m.mediaId = o.media_id;
						m.name = o.name;
						m.type = o.type;
						m.urlPath = o.url_path;
						m.fileName = o.file_name;
						m.isDefault = o.is_default; //for both default files and uploaded files
						
						var node:String = "<node label='" + AppUtils.filterStringToXMLEscapeCharacters(m.name) + "' mediaId='" + m.mediaId + "' type='" + m.type + "' urlPath='" + m.urlPath + "' fileName='" + m.fileName + "' isDefault='" + m.isDefault + "'/>";
						
						switch (m.type)
						{
							case AppConstants.MEDIATYPE_IMAGE:
								if (!this.isIconPicker) {
									if(k > numIconDefaults) xmlData.appendChild('<node label="' + AppConstants.MEDIATYPE_SEPARATOR + '" icon="'+ AppConstants.MEDIATREEICON_SEPARATOR +'"/>');
									xmlData.appendChild(node);
									numIconDefaults+=k;
								}
								break;
							case AppConstants.MEDIATYPE_AUDIO:
								break;
							case AppConstants.MEDIATYPE_VIDEO:
								break;
							case AppConstants.MEDIATYPE_ICON:
								if (this.isIconPicker) {
									trace("Node :"+node);
									if(k > numIconDefaults) xmlData.appendChild('<node label="' + AppConstants.MEDIATYPE_SEPARATOR + '" icon="'+ AppConstants.MEDIATREEICON_SEPARATOR +'"/>');
									xmlData.appendChild(node);
									numIconDefaults+=k;
								}
								break;
							default:
								trace("Default statement reached in load media.  This SHOULD NOT HAPPEN.  The offending mediaId = '" + m.mediaId + "' and type = '" + m.type + "'");
								break;
						}
					}
				}
			}
			trace("GameEditorMediaPickerView: handleLoadingOfMediaIntoXML: Just finished loading Media Objects into XML.  Here's what the new XML looks like:");
			this.printXMLData();
			
			trace("Finished with handleLoadingOfMediaIntoXML().");
		}
		
		public function handleFault(obj:Object):void
		{
			trace("Fault called: " + obj.message);
			Alert.show("Error occurred: " + obj.message, "Problems Loading Media");
		}
		
		private function onNodeSelected(event:TreeBrowserEvent):void
		{
			if (!event.isBranch)
			{
				if (event.item.@label == AppConstants.MEDIATYPE_UPLOADNEW)
				{
					if (uploadFormVisable == false) {
						trace("GameEditorMediaPickerView: onNodeSelected label == MEDIATYPE_UPLOADNEW, display form");
						selectButton.enabled = false;
						uploadFormVisable = true;
						this.displayMediaUploader();
						PopUpManager.removePopUp(this);
					}
					else trace("GameEditorMediaPickerView: ignored second TreeBrowserEvent == MEDIATYPE_UPLOADNEW");
					
				}
				else if(event.item.@label == AppConstants.MEDIATYPE_SEPARATOR){
					//Do Nothing
					trace("Separator Selected");
					selectButton.enabled = false;
				}
				else
				{
					trace("GameEditorMediaPickerView: onNodeSelected is a media item");
					selectButton.enabled = true;
				}
			}
			else {
				selectButton.enabled = false;	
			}
		}
		
		private function displayMediaUploader():void
		{
			trace("GameEditorMediaPickerPickerView: displayMediaUploader");
			mediaUploader = new GameEditorMediaPickerUploadFormMX();
			mediaUploader.isIconPicker = this.isIconPicker;
			mediaUploader.delegate = this;
			PopUpManager.addPopUp(mediaUploader, AppUtils.getInstance().getMainView(), true);
			PopUpManager.centerPopUp(mediaUploader);
		}
		
		public function didUploadMedia(uploader:GameEditorMediaPickerUploadFormMX, m:Media):void{
			trace("GameEditorMediaPicker: didUploadMedia");
			
			uploadFormVisable = false;
			
			if (delegate.hasOwnProperty("didSelectMediaItem")){
				delegate.didSelectMediaItem(this, m);
			}		
			
			PopUpManager.removePopUp(uploader);
		}
		
	}
}