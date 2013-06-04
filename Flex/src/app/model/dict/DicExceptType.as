package app.model.dict
{
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	import spark.components.Image;

	[Bindable]
	public class DicExceptType
	{
		public static const UNKNOWN:DicExceptType = new DicExceptType({ID:"-1",NAME:"未知异常"});
		public static const ALL:DicExceptType = 	new DicExceptType({ID:"0",NAME:"所有异常"});
		public static const CROSSING:DicExceptType = new DicExceptType({ID:"1",NAME:"巡逻越界"});
		public static const STOPPING:DicExceptType = new DicExceptType({ID:"2",NAME:"车辆滞留"});
		public static const LONGTIME:DicExceptType = new DicExceptType({ID:"3",NAME:"处警过长"});
		public static const NOPATROL:DicExceptType = new DicExceptType({ID:"4",NAME:"无人巡逻"});
		public static const EMERGENCY:DicExceptType = new DicExceptType({ID:"5",NAME:"警员告警"});
		public static const MANUAL:DicExceptType = 	new DicExceptType({ID:"6",NAME:"手动修改"});
				
		public var exceptID:String = "";
		public var exceptName:String = "";
		public var isMonitoring:Boolean = false;
				
		public function DicExceptType(source:Object)
		{
			this.exceptID = source.ID;
			this.exceptName = source.NAME;
		}
		
		public static function get list():ArrayCollection
		{
			var arr:ArrayCollection = new ArrayCollection;
			arr.addItem(ALL);
			arr.addItem(CROSSING);
			arr.addItem(STOPPING);
			//arr.addItem(LONGTIME);
			arr.addItem(NOPATROL);
			arr.addItem(EMERGENCY);
			arr.addItem(MANUAL);
			return arr;
		}
	}
}