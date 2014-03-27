package app.model.dict
{
	import com.esri.ags.SpatialReference;
	import com.esri.ags.geometry.MapPoint;
	
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	import spark.formatters.DateTimeFormatter;

	[Bindable]
	public class DicPatrolPoint
	{		
		public var id:String;
		public var label:String;
		public var address:String;
		public var patrolZoneID:String;
		public var type:String;
		
		public var startTime:Date;
		public var endTime:Date;
		
		public var depId:Number;
		public var time:String;
		
		public var mapPoint:MapPoint;
		
		public function DicPatrolPoint(source:Object)
		{
			this.id = source.ID;
			this.label = source.MUSTNAME;
			this.address = source.Address;
			this.patrolZoneID = source.ZONEID;
			this.type = source.DICVALUE;
			
			this.startTime = new Date(Date.parse(source.StartTime));
			this.endTime = new Date(Date.parse(source.endTime));
			
			this.depId =  source.DEPID;
			this.time =  source.TIME;
			
			var long:Number = Number(source.X);
			var lat:Number = Number(source.Y);
			this.mapPoint =  new MapPoint(
				isNaN(long)?0:long,
				isNaN(lat)?0:lat,
				new SpatialReference(102100)
			);
		}
		
		//protected var source:Object = null;
		
		public static var dict:Dictionary = new Dictionary;
		public static function get list():ArrayCollection
		{
			var arr:Array = new Array;
			for each (var item:DicPatrolPoint in dict)
			{
				arr.push(item);
			}			
			arr.sortOn("id",Array.NUMERIC);
			
			return new ArrayCollection(arr);
		}
		/*public function get id():String{return source.ID;}
		public function get label():String{return source.MUSTNAME;}
		public function get address():String{return source.Address;}
		public function get patrolZoneID():String{return source.ZONEID;}
		
		public function get startTime():Date {return new Date(Date.parse(source.StartTime));}		
		public function get endTime():Date {return new Date(Date.parse(source.endTime));}
		
		//点
		public function get mapPoint():MapPoint
		{
			
		}*/
		/*public function set mapPoint(point:MapPoint):void
		{
			source.X = String(point.x);
			source.Y = String(point.y);
		}*/
	}
}