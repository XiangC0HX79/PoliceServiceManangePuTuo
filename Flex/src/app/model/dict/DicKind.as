package app.model.dict
{
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	public class DicKind
	{	
		public static const ALL:DicKind = new DicKind({DICID:'0',DICVALUE:"所有"});
		
		public static const PEOPLE_TRAFFIC:DicKind = new DicKind({DICID:'-1',DICVALUE:"交通",IMAGEID:"3"});
		public static const PEOPLE_SPECIAL:DicKind = new DicKind({DICID:'-2',DICVALUE:"特警",IMAGEID:"4"});
		public static const NONE:DicKind = new DicKind({DICID:'-3',DICVALUE:"无警种"});
		
		public static const OTHER:DicKind = new DicKind({DICID:'200',DICVALUE:"其他"});
		
		public static const VEHICLE_NORMAL:DicKind = new DicKind({DICID:'201',DICVALUE:"普通车辆",IMAGEID:"1"});
		public static const VEHICLE_SPECIAL:DicKind = new DicKind({DICID:'202',DICVALUE:"特警车辆",IMAGEID:"6"});
		public static const VEHICLE_WEAPON:DicKind = new DicKind({DICID:'203',DICVALUE:"武装车辆",IMAGEID:"7"});
		
		public var id:int;
		public var label:String = "";
		private var _isMapShow:Boolean = true;
		
		public var imageId:String = "";
	
		public static var dict:Dictionary = new Dictionary;
		
		public function DicKind(source:Object)
		{
			this.id = int(source.DICID);
			this.label = source.DICVALUE;
			this.imageId = source.IMAGEID;
		}
		
		public function get isMapShow():Boolean
		{
			if(this == ALL)
			{				
				if(!NONE._isMapShow)
					return false;
				
				if(!VEHICLE_NORMAL._isMapShow)
					return false;
				
				if(!VEHICLE_SPECIAL._isMapShow)
					return false;
				
				if(!VEHICLE_WEAPON._isMapShow)
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
				
				VEHICLE_NORMAL.isMapShow = value;
				VEHICLE_SPECIAL.isMapShow = value;
				VEHICLE_WEAPON.isMapShow = value;
				
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
			
			arr.push(VEHICLE_NORMAL);	
			arr.push(VEHICLE_SPECIAL);	
			arr.push(VEHICLE_WEAPON);	
			
			arr.sortOn("id",Array.NUMERIC);
			
			return new ArrayCollection(arr);
		}
	}
}