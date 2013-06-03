package app.model.dict
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Image;
	import mx.core.BitmapAsset;

	/**
	 *字段说明 
	 */	
	[Bindable]
	public class DicPoliceType
	{
		public static const VEHICLE:DicPoliceType = new DicPoliceType({ID:"1",LABEL:"车辆"});
		public static const PEOPLE:DicPoliceType = new DicPoliceType({ID:"2",LABEL:"民警"});
		public static const TRAFFIC:DicPoliceType = new DicPoliceType({ID:"3",LABEL:"交警"});
		
		public static const BASEDMG:DicPoliceType = new DicPoliceType({ID:"5",LABEL:"基地台"});
		
		public var id:String = "";
		public var label:String = "";		
		public var isMapShow:Boolean = true;;
				
		public function DicPoliceType(source:Object)
		{
			this.id = source.ID;
			this.label = source.LABEL;
		}
		
		public static var dict:Dictionary = new Dictionary;
		public static function get list():ArrayCollection
		{
			var arr:Array = new Array;
			for each (var item:DicPoliceType in dict)
			{
				arr.push(item);
			}			
			arr.sortOn("id",Array.NUMERIC);
			
			return new ArrayCollection(arr);
		}
	}
}