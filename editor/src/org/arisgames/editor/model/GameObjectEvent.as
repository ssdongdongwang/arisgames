package org.arisgames.editor.model
{
	import flash.events.Event;

	public class GameObjectEvent extends Event
	{
		public static const CHANGE:String = "gameObjectChange";
		
		public function GameObjectEvent(type:String):void
		{
			super(type, true, false);
		}
		
	}
}