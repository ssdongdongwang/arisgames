package org.arisgames.editor.model
{
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	
	//IMPORTANT: This class is effectively ABSTRACT. Not intended for instantiation.
	//Use one the of following subclasses instead: Item, Character, Page, Quest, SecretEvent
	[Bindable]
	public class GameObject
	{
		public static const ITEM:String = "item";
		public static const CHARACTER:String = "character";
		public static const PAGE:String = "page";
		public static const QUEST:String = "quest";
		public static const SECRET_EVENT:String = "secretEvent";
		public static const EXIT_CHOICE:String = "exitChoice";
		
		protected var id:int;
		protected var name:String;
		protected var notes:String;
		protected var description:String;
		protected var type:String;
		protected var media:Media;
		
		protected var exitChoice:Object;
		protected var exitChoiceShown:Boolean;
		protected var choicesArray:Array;
		public var choicesDataProvider:ArrayCollection;

		public function GameObject(id:int, type:String):void
		{
			this.id = id;
			this.type = type;
			this.name = (type + id);
			this.notes = "";
			this.media = null;
			this.choicesArray = new Array();
			this.choicesDataProvider = new ArrayCollection(choicesArray);
			this.exitChoice = {label:"Exit", choiceText:"I'm done here", type:EXIT_CHOICE};
			this.exitChoiceShown = false;
		}
		
		public function getXML():XML
		{
			var result:XML = <object/>;
			result.@label = this.name;
			result.@id = this.id;
			result.@type = this.type;
			return result;
		}
		
		public function getID():int
		{
			return this.id;
		}
		
		public function getName():String
		{
			return this.name;
		}
		
		public function setName(newName:String):void
		{
			this.name = newName;
		}
		
		public function getType():String
		{
			return this.type;
		}
		
		public function hasMedia():Boolean
		{
			return (this.media != null);
		}
		
		public function getMedia():Media
		{
			return this.media;
		}
		
		public function setMedia(newMedia:Media):void
		{
			this.media = newMedia;
		}
		
		public function getNotes():String
		{
			return this.notes;
		}
		
		public function setNotes(newNotes:String):void
		{
			this.notes = newNotes;
		}
		
		public function getDescription():String
		{
			return this.description;
		}
		
		public function setDescription(newDescription:String):void
		{
			this.description = newDescription;
		}
		
		public function addChoice(newChoice:Object):void
		{
			choicesArray.push(newChoice);
		}
		
		private function displayDataProvider():void
		{
			var result:String = "DataProvider contents.... ";
			for(var i:int = 0; i < choicesArray.length; i++)
			{
				result += choicesArray[i].label;
				result += ": ";
				result += choicesArray[i].choiceText;
				result += "... ";
			}
			Alert.show(result);
		}
		
		public function removeChoice(choice:Object):void
		{
			choicesArray.splice(choicesArray.indexOf(choice), 1);
		}
		
		public function toggleExitChoice():void
		{
			exitChoiceShown = !exitChoiceShown;
			if(exitChoiceShown)
			{
				addChoice(this.exitChoice);
			}
			else
			{
				removeChoice(this.exitChoice);
			}
		}
		
	}
}