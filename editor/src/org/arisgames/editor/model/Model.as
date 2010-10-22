package org.arisgames.editor.model
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.XMLListCollection;
	
	[Bindable]
	public class Model extends EventDispatcher
	{
		private var gameList:Array;
		private var currentGame:String;
		private var items:Array;
		private var characters:Array;
		private var pages:Array;
		private var quests:Array;
		private var secretEvents:Array;
		private var images:Array;
		private var sounds:Array;
		private var videos:Array;
		private var nextItemID:int;
		private var nextCharacterID:int;
		private var nextPageID:int;
		private var nextQuestID:int;
		private var nextSecretEventID:int;
		private var nextImageID:int;		
		private var nextSoundID:int;
		private var nextVideoID:int;
		private var XMLData:XML;
		private var pendingMedia:Media;
		private var claimedQRCodes:Array;
				
		public var XMLDataProvider:XMLListCollection;
		
		
		public function Model():void
		{	
			gameList = new Array();
			createNewGame("MyNewGame");
		}
		
		public function populateGameList():void
		{
			
		}
		
		public function loadGame(newGame:String):void
		{
			currentGame = newGame;
		}
		
		public function createNewGame(newGame:String):void
		{
			currentGame = newGame;
			gameList.push(currentGame);
			nextItemID = 0;
			nextCharacterID = 0;
			nextPageID = 0;
			nextQuestID = 0;
			nextSecretEventID = 0;
			nextImageID = 0;
			items = new Array();
			characters = new Array();
			pages = new Array();
			quests = new Array();
			secretEvents = new Array();
			images = new Array();
			sounds = new Array();
			videos = new Array();
			claimedQRCodes = new Array();
			XMLData = <data>
						<folder label="Items">
							<object label="Create New Item" generator="true" type="item" id="-1"/>
						</folder>
						<folder label="Characters">
							<object label="Create New Character" generator="true" type="character" id="-1"/>
						</folder>
						<folder label="Pages">
							<object label="Create New Page" generator="true" type="page" id="-1"/>
						</folder>
						<folder label="Quests">
							<object label="Create New Quest" generator="true" type="quest" id="-1"/>
						</folder>
						<folder label="Secret Events">
							<object label="Create New Secret Event" generator="true" type="secretEvent" id="-1"/>
						</folder>
						<folder label="Media">
							<folder label="Images">
								<media label="Upload New Image" uploader="true" type="image" id="-1"/>
							</folder>
							<folder label="Sounds">
								<media label="Upload New Sound" uploader="true" type="sound" id="-1"/>
							</folder>
							<folder label="Video">
								<media label="Upload New Video" uploader="true" type="video" id="-1"/>
							</folder>
						</folder>									
					</data>;
			XMLDataProvider = new XMLListCollection(XMLData.folder);
		}

		public function getGameList():Array
		{
			return gameList;
		}
				
		public function getCurrentGame():String
		{
			return currentGame;
		}
		
		public function createNewGameObject(type:String):XML
		{
			var newGameObject:GameObject;
			var newID:int;
			if(type == GameObject.ITEM)
			{
				newID = nextItemID;
				newGameObject = new Item(newID);
			}
			else if(type == GameObject.CHARACTER)
			{
				newID = nextCharacterID;
				newGameObject = new Character(newID);
			}
			else if(type == GameObject.PAGE)
			{
				newID = nextPageID;
				newGameObject = new Page(newID);
			}
			else if(type == GameObject.QUEST)
			{
				newID = nextQuestID;
				newGameObject = new Quest(newID);
			}
			else if(type == GameObject.SECRET_EVENT)
			{
				newID = nextSecretEventID;
				newGameObject = new SecretEvent(newID);
			}
			else
			{
				return null;
			}
			newGameObject.setName(type + newID);
			return addGameObject(newGameObject);
		}
		
		public function uploadNewMedia(type:String):void
		{
			var newID:int;
			if(type == Media.IMAGE)
			{
				newID = nextImageID;
			}
			else if(type == Media.SOUND)
			{
				newID = nextSoundID;
			}
			else if(type == Media.VIDEO)
			{
				newID = nextVideoID;
			}
			else
			{
				return;
			}
			pendingMedia = new Media(newID, type);
			pendingMedia.addEventListener(Media.MEDIA_UPLOAD_COMPLETE, addMedia);
			pendingMedia.addEventListener(Media.MEDIA_UPLOAD_CANCELED, cancelMedia);
		}
		
		private function addGameObject(newGameObject:GameObject):XML
		{
			var type:String = newGameObject.getType();
			var newXML:XML = <object/>;
			newXML.@label = newGameObject.getName();
			newXML.@type = type;
			newXML.@id = newGameObject.getID();
			var creatorLabel:String;
			if(type == GameObject.ITEM)
			{
				this.items.push(newGameObject);
				creatorLabel = "Create New Item";
				nextItemID = Math.max(nextItemID, 1 + newGameObject.getID());
			}
			else if(type == GameObject.CHARACTER)
			{
				this.characters.push(newGameObject);
				creatorLabel = "Create New Character";
				nextCharacterID = Math.max(nextCharacterID, 1 + newGameObject.getID());
			}
			else if(type == GameObject.PAGE)
			{
				this.pages.push(newGameObject);
				creatorLabel = "Create New Page";
				nextPageID = Math.max(nextPageID, 1 + newGameObject.getID());
			}
			else if(type == GameObject.QUEST)
			{
				this.quests.push(newGameObject);
				creatorLabel = "Create New Quest";
				nextQuestID = Math.max(nextQuestID, 1 + newGameObject.getID());
			}
			else if(type == GameObject.SECRET_EVENT)
			{
				this.secretEvents.push(newGameObject);
				creatorLabel = "Create New Secret Event";
				nextSecretEventID = Math.max(nextSecretEventID, 1 + newGameObject.getID());
			}
			else
			{
				return null;
			}
			XMLData.folder.(@label==getFolderName(type)).insertChildBefore(XMLData.folder.object.(@label==creatorLabel), newXML);
			return newXML;
		}
		
		public function addMedia(event:Event):XML
		{
			pendingMedia.removeEventListener(Media.MEDIA_UPLOAD_COMPLETE, addMedia);
			pendingMedia.removeEventListener(Media.MEDIA_UPLOAD_CANCELED, cancelMedia);
			var type:String = pendingMedia.getType();
			var creatorLabel:String;
			var newXML:XML = <media/>;
			newXML.@label = pendingMedia.getFileName();
			newXML.@type = type;
			newXML.@id = pendingMedia.getID();
			if(type == Media.IMAGE)
			{
				this.images.push(pendingMedia);
				creatorLabel = "Upload New Image";
				nextImageID = Math.max(nextImageID, 1 + pendingMedia.getID());
			}
			else if(type == Media.SOUND)
			{
				this.sounds.push(pendingMedia);
				creatorLabel = "Upload New Sound";
				nextSoundID = Math.max(nextSoundID, 1 + pendingMedia.getID());
			}
			else if(type == Media.VIDEO)
			{
				this.videos.push(pendingMedia);
				creatorLabel = "Upload New Video";
				nextVideoID = Math.max(nextVideoID, 1 + pendingMedia.getID());
			}
			else
			{
				return null;
			}
			XMLData.folder.(@label=="Media").folder.(@label==getFolderName(type)).insertChildBefore(XMLData.folder.folder.media.(@label==creatorLabel), newXML);
			return newXML;			
		}
		
		public function cancelMedia(event:Event):void
		{
			pendingMedia.removeEventListener(Media.MEDIA_UPLOAD_COMPLETE, addMedia);
			pendingMedia.removeEventListener(Media.MEDIA_UPLOAD_CANCELED, cancelMedia);
			pendingMedia = null;
		}
		
		public function getGameObject(objectNode:XML):GameObject
		{
			var type:String = objectNode.attribute("type");
			var objArray:Array;
			if(type == GameObject.ITEM)
			{
				objArray = items;
			}
			else if(type == GameObject.CHARACTER)
			{
				objArray = characters;
			}
			else if(type == GameObject.PAGE)
			{
				objArray = pages;
			}
			else if(type == GameObject.QUEST)
			{
				objArray = quests;
			}
			else if(type == GameObject.SECRET_EVENT)
			{
				objArray = secretEvents;
			}
			else
			{
				return null;
			}
			var idNum:int = objectNode.attribute("id");
			for(var i:int = 0; i < objArray.length; i++)
			{
				if((objArray[i] as GameObject).getID() == idNum)
				{
					return objArray[i];
				}
			}
			return null;			
		}

		public function getMedia(objectNode:XML):Media
		{
			var type:String = objectNode.attribute("type");
			var objArray:Array;
			if(type == Media.IMAGE)
			{
				objArray = images;
			}
			else if(type == Media.SOUND)
			{
				objArray = sounds;
			}
			else if(type == Media.VIDEO)
			{
				objArray = videos;
			}
			else
			{
				return null;
			}
			var idNum:int = objectNode.attribute("id");
			for(var i:int = 0; i < objArray.length; i++)
			{
				if((objArray[i] as Media).getID() == idNum)
				{
					return objArray[i];
				}
			}
			return null;			
		}
		
		public function changeName(type:String, idNum:int, newName:String):void
		{
			getGameObject(XMLData.folder.(@label == getFolderName(type)).object.(@id == idNum)[0]).setName(newName);
			XMLData.folder.(@label == getFolderName(type)).object.(@id == idNum).@label = newName;
		}
		
		public function getFolderName(type:String):String
		{
			var folderLabel:String = type;
			if(type == GameObject.ITEM)
			{
				folderLabel = "Items";
			}
			else if(type == GameObject.CHARACTER)
			{
				folderLabel = "Characters";
			}
			else if(type == GameObject.PAGE)
			{
				folderLabel = "Pages";
			}
			else if(type == GameObject.QUEST)
			{
				folderLabel = "Quests";
			}
			else if(type == GameObject.SECRET_EVENT)
			{
				folderLabel = "Secret Events";
			}
			else if(type == Media.IMAGE)
			{
				folderLabel = "Images";
			}
			else if(type == Media.SOUND)
			{
				folderLabel = "Sounds";
			}
			else if(type == Media.VIDEO)
			{
				folderLabel = "Videos";
			}
			return folderLabel;
		}
		
		
	}

}