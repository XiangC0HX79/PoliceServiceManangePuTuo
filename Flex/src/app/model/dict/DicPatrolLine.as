package app.model.dict
{
	import com.esri.ags.SpatialReference;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.geometry.Polyline;
	
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	public class DicPatrolLine
	{
		public static var defaultColor:Number = 0xFF0000;
		
		public static const ALL:DicPatrolLine = new DicPatrolLine({KEYID:'-1',DEPID:'-1',ZONENM:'所有巡区'});
		
		public var id:String;
		public var depid:String;
		public var label:String;
		public var callNo:String;
		public var color:Number = 0xFF0000;
		
		public var polyline:Polyline;
		
		public function DicPatrolLine(source:Object)
		{
			this.id = source.ID;
			this.depid = source.DEPID;
			this.label = source.NAME;			
			this.callNo = source.HH;
						
			var ring:Array = new Array;
			if(source.LINERANGE != undefined)
			{				
				var arr:Array = source.LINERANGE.split("|");
				var zonerange:String = arr[0];
				if(arr.length > 1)
				{
					this.color = Number(arr[1]);
				}
				else if(DicPatrolLine != null)
				{
					this.color = DicPatrolLine.defaultColor;
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
					this.polyline = new Polyline([ring],new SpatialReference(102100));
				}
			}
		}
		
		public static var dict:Dictionary = new Dictionary;
		public static function get listAll():ArrayCollection
		{
			var arr:Array = new Array;
			for each (var item:DicPatrolLine in dict)
			{
				arr.push(item);
			}			
			arr.sortOn("id",Array.NUMERIC);
			
			return new ArrayCollection(arr);
		}
		public static function get list():ArrayCollection
		{
			var arr:Array = new Array;
			for each (var item:DicPatrolLine in dict)
			{
				if(item.id != ALL.id)
				{
					arr.push(item);
				}
			}			
			arr.sortOn("id",Array.NUMERIC);
			
			return new ArrayCollection(arr);
		}
	}
}