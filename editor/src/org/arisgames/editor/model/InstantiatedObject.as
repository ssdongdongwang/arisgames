package org.arisgames.editor.model
{
	import mx.controls.Alert;
	
	[Bindable]
	public class InstantiatedObject extends GameObject
	{
		private var instances:Array;
		private var currentInstanceIndex:int;
		
		public function InstantiatedObject(id:int, type:String):void
		{
			super(id, type);
			this.instances = new Array();
			this.currentInstanceIndex = -1;
		}

		public function addInstance(instanceProperties:InstanceProperties):void
		{
			this.instances.push(instanceProperties);
		}
		
		public function removeInstance(instanceToRemove:InstanceProperties):void
		{
			removeInstanceByIndex(this.instances.indexOf(instanceToRemove));
		}
		
		public function removeInstanceByIndex(instanceIndex:int):void
		{
			var removedInstance:InstanceProperties = this.instances.splice(instanceIndex, 1)[0];
			removedInstance = null;
		}
		
		public function getInstanceByIndex(instanceIndex:int):InstanceProperties
		{
			return instances[instanceIndex];
		}
		
		public function getNextInstance():InstanceProperties
		{
			this.currentInstanceIndex++;
			if(this.currentInstanceIndex >= getNumInstances())
			{
				this.currentInstanceIndex = 0;
			}
			return getInstanceByIndex(currentInstanceIndex);
		}
		
		public function getPreviousInstance():InstanceProperties
		{
			this.currentInstanceIndex--;
			if(this.currentInstanceIndex < 0)
			{
				this.currentInstanceIndex = getNumInstances() - 1;
			}
			return getInstanceByIndex(currentInstanceIndex);
		}
		
		public function getCurrentInstance():InstanceProperties
		{
			if(getNumInstances() > 0)
			{
				currentInstanceIndex = Math.max(currentInstanceIndex, 0);
				return getInstanceByIndex(currentInstanceIndex);
			}
			return null;
		}
		
		public function getNumInstances():int
		{
			return instances.length;
		}
		
		public function updateAllInstances():void
		{
			for(var i:int = 0; i < instances.length; i++)
			{
				(instances[i] as InstanceProperties).updateContentDisplay();
			}
		}
		

	}
}