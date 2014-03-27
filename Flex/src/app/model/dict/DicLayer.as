package app.model.dict
{
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	import spark.components.Image;

	[Bindable]
	public class DicLayer
	{
		public static const PATROLZONE:DicLayer = new DicLayer({NAME:"巡区"});
		public static const PATROLLINE:DicLayer = new DicLayer({NAME:"巡线"});
		public static const PATROLPOINT:DicLayer = new DicLayer({NAME:"必到点"});
		public static const GPSNAME:DicLayer = new DicLayer({NAME:"名称"});
		
		public static const ELEPOLICE:DicLayer = new DicLayer({NAME:"电子警察"});
		public static const GATEWAY:DicLayer = new DicLayer({NAME:"卡口"});
		public static const VIDEO:DicLayer = new DicLayer({NAME:"摄像头"});
		
		public var layerName:String = "";
		public var selected:Boolean = false;
				
		public function DicLayer(source:Object)
		{
			this.layerName = source.NAME;
		}
		
		public static function get listPatrol():ArrayCollection
		{
			var arr:ArrayCollection = new ArrayCollection;
			arr.addItem(PATROLZONE);
			//arr.addItem(PATROLLINE);
			arr.addItem(PATROLPOINT);
			arr.addItem(GPSNAME);
			return arr;
		}
		
		public static function get listElePolice():ArrayCollection
		{
			var arr:ArrayCollection = new ArrayCollection;
			arr.addItem(ELEPOLICE);
			arr.addItem(GATEWAY);
			arr.addItem(VIDEO);
			return arr;
		}
	}
}