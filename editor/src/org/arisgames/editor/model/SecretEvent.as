package org.arisgames.editor.model
{
	[Bindable]
	public class SecretEvent extends InstantiatedObject
	{
		public function SecretEvent(id:int):void
		{
			super(id, GameObject.SECRET_EVENT);
		}
		
		override public function setMedia(newMedia:Media):void
		{
			throw(new Error("SecretEvent objects cannot have media"));
		}
		
		override public function setDescription(newDescription:String):void
		{
			throw(new Error("SecretEvent objects cannot have descriptions"));
		}

	}
}