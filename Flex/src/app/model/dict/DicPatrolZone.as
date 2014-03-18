package app.model.dict
{
	import com.esri.ags.SpatialReference;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.geometry.Polygon;
	import com.esri.ags.geometry.Polyline;
	
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	public class DicPatrolZone
	{
		public static var defaultColor:Number = 0xFF0000;
		
		public static const ALL:DicPatrolZone = new DicPatrolZone({KEYID:'-1',DEPID:'-1',ZONENM:'所有巡区'});
		
		public var id:String;
		public var depid:String;
		public var label:String;
		public var range:String;
		public var color:Number = 0xFF0000;
		
		public var polygon:Polygon;
		
		public function DicPatrolZone(source:Object)
		{
			this.id = source.KEYID;
			this.depid = source.DEPID;
			this.label = source.ZONENM;			
			this.range = source.RANGE;
						
			var ring:Array = new Array;
			if(source.ZONEGPSRANGE != undefined)
			{				
				var arr:Array = source.ZONEGPSRANGE.split("|");
				var zonerange:String = arr[0];
				if(arr.length > 1)
				{
					this.color = Number(arr[1]);
				}
				else if(DicPatrolZone != null)
				{
					this.color = DicPatrolZone.defaultColor;
				}
				
				var arrPoint:Array = zonerange.split(";");
				for each(var xy:String in arrPoint)
				{
					var arrXY:Array;
					if(xy.indexOf(",") >= 0)
					{
						arrXY = xy.split(",");
					}
					else
					{
						arrXY =  xy.split(" ");
					}
					
					if(arrXY.length == 2)
					{
						ring.push(new MapPoint(Number(arrXY[0]),Number(arrXY[1])));
					}
				}
				
				if(ring.length >= 3)
				{
					this.polygon = new Polygon([ring],new SpatialReference(102100));
				}
			}
		}
		
		public static var dict:Dictionary = new Dictionary;
		public static function get listAll():ArrayCollection
		{
			var arr:Array = new Array;
			for each (var item:DicPatrolZone in dict)
			{
				arr.push(item);
			}			
			arr.sortOn("id",Array.NUMERIC);
			
			return new ArrayCollection(arr);
		}
		public static function get list():ArrayCollection
		{
			var arr:Array = new Array;
			for each (var item:DicPatrolZone in dict)
			{
				if(item.id != ALL.id)
				{
					arr.push(item);
				}
			}			
			arr.sortOn("id",Array.NUMERIC);
			
			return new ArrayCollection(arr);
		}
		
		/*protected var source:Object = null;
		
		public function get id():String{return source.KEYID;}
		public function get depid():String{return source.DEPID;}
		public function get label():String{return source.ZONENM;}
		public function get range():String{return source.RANGE;}
		
		public function get polygon():Polygon
		{			
			var ring:Array = new Array;
			if(source.ZONEGPSRANGE != undefined)
			{				
				var arrPoint:Array = source.ZONEGPSRANGE.split(";");
				for each(var xy:String in arrPoint)
				{
					var arrXY:Array;
					if(xy.indexOf(",") >= 0)
					{
						arrXY = xy.split(",");
					}
					else
					{
						arrXY =  xy.split(" ");
					}
					
					if(arrXY.length == 2)
					{
						ring.push(new MapPoint(Number(arrXY[0]),Number(arrXY[1])));
					}
				}
			}
			
			return new Polygon([ring],new SpatialReference(102100));
		}*/
		/*public function set polygon(polygon:Polygon):void
		{
			var sPolygon:String = "";
			for each(var ring:Array in polygon.rings)
			{
				for each(var point:MapPoint in ring)
				{
					sPolygon += point.x.toString() + " " + point.y.toString() + ";";
				}
			}
			if(sPolygon != "")sPolygon = sPolygon.slice(0,sPolygon.length - 1);
			
			source.polygon= sPolygon;
		}*/
	}
}