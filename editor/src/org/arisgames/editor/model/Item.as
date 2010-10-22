package org.arisgames.editor.model
{
	[Bindable]
	public class Item extends InstantiatedObject
	{
		private var droppable:Boolean;
		private var destroyable:Boolean;
		
		public function Item(id:int, droppable:Boolean = false, destroyable:Boolean = false):void
		{
			super(id, GameObject.ITEM);
			this.droppable = droppable;
			this.destroyable = destroyable;
		}
		
		public function isDroppable():Boolean
		{
			return droppable;
		}
		
		public function setDroppable(newValue:Boolean):void
		{
			droppable = newValue;
		}
		
		public function isDestroyable():Boolean
		{
			return destroyable;
		}
		
		public function setDestroyable(newValue:Boolean):void
		{
			destroyable = newValue;
		}
		
	}
}