package app.model.dict
{
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	public class DicPatrolType
	{
		public var id:String;
		public var label:String;
		
		public function DicPatrolType(source:Object)
		{
			this.id = source.DICID;
			this.label = source.DICVALUE;
		}
		
		public static var dict:Dictionary = new Dictionary;
		public static function get list():ArrayCollection
		{
			var arr:Array = new Array;
			for each (var item:DicPatrolType in dict)
			{
				arr.push(item);
			}			
			arr.sortOn("id",Array.NUMERIC);
			
			return new ArrayCollection(arr);
		}
	}
}