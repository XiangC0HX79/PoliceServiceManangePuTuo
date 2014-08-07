package app.model.dict
{
	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	import spark.components.Image;

	[Bindable]
	public class DicServiceType
	{
		public static const ALL:DicServiceType = new DicServiceType({QWTYPEID:"-2",QWTYPENAME:"所有",ISGISSHOW:"0",ImageName:"2"});
		public static const NOSERVICE:DicServiceType = new DicServiceType({QWTYPEID:"-1",QWTYPENAME:"未排班警力",ISGISSHOW:"1",ImageName:"2"});
		
		public static const OTHER:DicServiceType = new DicServiceType({QWTYPEID:"98",QWTYPENAME:"其他勤务",ISGISSHOW:"0",ImageName:"17"});
		public static const WEAPON:DicServiceType = new DicServiceType({QWTYPEID:"99",QWTYPENAME:"武装巡逻",ISGISSHOW:"1",ImageName:"98"});
		public static const NOGPS:DicServiceType = new DicServiceType({QWTYPEID:"100",QWTYPENAME:"无GPS信号",ISGISSHOW:"0",ImageName:"1"});
		
		public var id:String = "";
		public var label:String = "";
		public var isGisShow:Boolean;
		
		private var _isMapShow:Boolean;
		public function get isMapShow():Boolean
		{
			return _isMapShow;
		}

		public function set isMapShow(value:Boolean):void
		{			
			_isMapShow = value;
		}

		public var imagelist:String = "";
				
		public function DicServiceType(source:Object)
		{
			this.id = source.QWTYPEID;
			this.label = source.QWTYPENAME;
			
			this.isGisShow = (source.ISGISSHOW == undefined)?true:(source.ISGISSHOW == "1");
			this._isMapShow = this.isGisShow;
									
			this.imagelist = (source.ImageName != undefined)?source.ImageName:"";
		}
		
		public static function get duty():DicServiceType
		{
			for each(var item:DicServiceType in dict)
			{
				if(item.label == "值班警力")
				{
					return item;
				}
			}
			
			return null;
		}
		
		public static var dict:Dictionary = new Dictionary;
		public static function get list():ArrayCollection
		{
			var arr:Array = new Array;
			for each (var item:DicServiceType in dict)
			{
				arr.push(item);
			}			
			arr.sortOn("id",Array.NUMERIC);
			
			return new ArrayCollection(arr);
		}
		
		public static function get listOverview():ArrayCollection
		{
			var arr:Array = new Array;
			
			arr.push(DicServiceType.ALL);			
			for each (var item:DicServiceType in dict)
			{
				if((item.label == "巡逻")
					|| (item.label == "社区"))
				{
					arr.push(item);
				}
			}			
			arr.push(DicServiceType.OTHER);			
			arr.push(DicServiceType.WEAPON);
			arr.push(DicServiceType.NOGPS);
			
			//arr.sortOn("id",Array.NUMERIC);
			
			return new ArrayCollection(arr);
		}
		
		public static function get listService():ArrayCollection
		{
			var arr:Array = new Array;
			for each (var item:DicServiceType in dict)
			{
				if(item != NOSERVICE)
				{
					arr.push(item);
				}
			}			
			arr.sortOn("id",Array.NUMERIC);
			
			return new ArrayCollection(arr);
		}
	}
}