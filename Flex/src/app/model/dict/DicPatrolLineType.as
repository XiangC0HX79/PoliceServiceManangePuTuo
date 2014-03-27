package app.model.dict
{
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	public class DicPatrolLineType
	{				
		public static const ALL:DicPatrolLineType = new DicPatrolLineType({DICID:'-1',DICVALUE:"所有",ORDERNUM:'-1'});
		
		public var id:int;
		public var label:String = "";
		public var isMapShow:Boolean = true;
		
		public var orderNum:String = "";
		
		public function DicPatrolLineType(source:Object)
		{
			this.id = int(source.DICID);
			this.label = source.DICVALUE;
			this.orderNum = source.ORDERNUM;
		}
		
		public static var dict:Dictionary = new Dictionary;
		public static function get listAll():ArrayCollection
		{
			var arr:Array = new Array;
			for each (var item:DicPatrolLineType in dict)
			{
				arr.push(item);
			}			
			arr.sortOn("orderNum",Array.NUMERIC);
			
			return new ArrayCollection(arr);
		}
		
		public static function get list():ArrayCollection
		{
			var arr:Array = new Array;
			for each (var item:DicPatrolLineType in dict)
			{
				if(item != ALL)
				{
					arr.push(item);
				}
			}			
			arr.sortOn("orderNum",Array.NUMERIC);
			
			return new ArrayCollection(arr);
		}
	}
}