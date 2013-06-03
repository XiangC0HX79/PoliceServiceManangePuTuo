package app.model.dict
{
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	import spark.components.Image;

	[Bindable]
	public class DicServiceType
	{
		public static const NOSERVICE:DicServiceType = new DicServiceType({QWTYPEID:"-1",QWTYPENAME:"未排班警力",ISGISSHOW:"0",ImageName:"2"});
		public static const NOGPS:DicServiceType = new DicServiceType({QWTYPEID:"0",QWTYPENAME:"无GPS信号",ISGISSHOW:"0",ImageName:"4"});
		
		public var id:String = "";
		public var label:String = "";
		public var isGisShow:Boolean;
		public var isMapShow:Boolean;
		public var imagelist:String = "";
				
		public function DicServiceType(source:Object)
		{
			this.id = source.QWTYPEID;
			this.label = source.QWTYPENAME;
			
			this.isGisShow = (source.ISGISSHOW == undefined)?true:(source.ISGISSHOW == "1");
			this.isMapShow = this.isGisShow;
						
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
			for each (var item:DicServiceType in dict)
			{
				arr.push(item);
			}			
			arr.push(DicServiceType.NOGPS);
			
			arr.sortOn("id",Array.NUMERIC);
			
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