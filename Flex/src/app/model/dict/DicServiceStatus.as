package app.model.dict
{
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	public class DicServiceStatus
	{				
		public static const ALL:DicServiceStatus = new DicServiceStatus({DICID:'-1',DICVALUE:"所有",ORDERNUM:'-1'});
		
		public var id:String = "";
		public var label:String = "";
		public var isMapShow:Boolean = true;
		
		public var orderNum:String = "";
		
		//public var color:uint;
		public var imageSource:Object;
		
		public function DicServiceStatus(source:Object)
		{
			this.id = source.DICID;
			this.label = source.DICVALUE;
			this.orderNum = source.ORDERNUM;
			
			this.imageSource = DicGPSImage.getImageClass(DicGPSImage.STATUS,0,orderNum);
			/*switch(this.label)
			{
				case "待勤":
					this.color = 0x00FF00;
					break;
				
				case "设卡":
				case "处警":
				case "任务":
					this.color = 0xFF0000;
					break;
				
				case "休息":
				case "就餐":
					this.color = 0xFF8400;
					break;
				
				default:
					this.color = 0xFFFFFF;
					break;
			}*/
		}
		
		public static var dict:Dictionary = new Dictionary;
		public static function get listAll():ArrayCollection
		{
			var arr:Array = new Array;
			for each (var item:DicServiceStatus in dict)
			{
				arr.push(item);
			}			
			arr.sortOn("orderNum",Array.NUMERIC);
			
			return new ArrayCollection(arr);
		}
		
		public static function get list():ArrayCollection
		{
			var arr:Array = new Array;
			for each (var item:DicServiceStatus in dict)
			{
				if(item != ALL)
				{
					arr.push(item);
				}
			}			
			arr.sortOn("orderNum",Array.NUMERIC);
			
			return new ArrayCollection(arr);
		}
		
		//处警勤务状态
		public static function get chujin():DicServiceStatus
		{
			for each (var item:DicServiceStatus in dict)
			{
				if(item.id == "141")
				{
					return item;
				}
			}			
			
			return null;
		}
		
		//待勤勤务状态
		public static function get idle():DicServiceStatus
		{
			for each (var item:DicServiceStatus in dict)
			{
				if(item.id == "126")
				{
					return item;
				}
			}			
			
			return null;
		}
				
		//异常勤务状态
		public static function get except():DicServiceStatus
		{
			for each (var item:DicServiceStatus in dict)
			{
				if(item.label == "异常")
				{
					return item;
				}
			}			
			
			return null;
		}
	}
}