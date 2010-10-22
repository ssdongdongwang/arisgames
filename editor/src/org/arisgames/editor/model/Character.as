package org.arisgames.editor.model
{
	[Bindable]
	public class Character extends InstantiatedObject
	{
		public function Character(id:int):void
		{
			super(id, GameObject.CHARACTER);
		}
		
	}
}