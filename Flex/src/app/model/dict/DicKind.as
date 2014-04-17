package app.model.dict
{
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	public class DicKind
	{	
		public static const ALL:DicKind = new DicKind({DICID:'0',DICVALUE:"所有"});
		public static const OTHER:DicKind = new DicKind({DICID:'-1',DICVALUE:"其他"});
		public static const NONE:DicKind = new DicKind({DICID:'-2',DICVALUE:"无警种"});
		
		public var id:int;
		public var label:String = "";
		private var _isMapShow:Boolean = true;
	
		public static var dict:Dictionary = new Dictionary;
		
		public function DicKind(source:Object)
		{
			this.id = int(source.DICID);
			this.label = source.DICVALUE;
		}
		
		public function get isMapShow():Boolean
		{
			if(this == ALL)
			{				
				if(!NONE._isMapShow)
					return false;
				
				for each(var item:DicKind in DicKind.dict)
				{
					if(!item._isMapShow)
						return false;
				}
				
				return true;
			}
			else if(this == OTHER)
			{				
				if(!NONE._isMapShow)
					return false;
				
				for each(item in DicKind.dict)
				{
					if((item.label != "巡警")
						&& (item.label != "社区管理")
						&& (item.label != "交通")
						&& (item.label != "特警"))
					{
						if(!item._isMapShow)
							return false;
					}
				}
				
				return true;
			}
			else 
				return this._isMapShow;			
		}
		
		public function set isMapShow(value:Boolean):void
		{
			if(this == ALL)
			{				
				NONE._isMapShow = value;
				
				for each(var item:DicKind in DicKind.dict)
				{
					item._isMapShow = value;
				}
			}
			else if(this == OTHER)
			{				
				NONE._isMapShow = value;
								
				for each(item in DicKind.dict)
				{
					if((item.label != "巡警")
						&& (item.label != "社区管理")
						&& (item.label != "交通")
						&& (item.label != "特警"))
					{
						item._isMapShow = value;
					}
				}
			}
			else 
				this._isMapShow = value;			
		}
		
		public static function get listOverview():ArrayCollection
		{			
			var arr:Array = new Array;
			arr.push(ALL);
			for each (var item:DicKind in dict)
			{
				if((item.label == "巡警")
					|| (item.label == "社区管理")
					|| (item.label == "交通")
					|| (item.label == "特警"))
				arr.push(item);
			}		
			arr.push(OTHER);	
			
			return new ArrayCollection(arr);
		}
	}
}