package app.model.vo
{
	import app.model.dict.DicDepartment;
	
	import com.esri.ags.SpatialReference;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.geometry.Polygon;

	[Bindable]
	public class WarningAreaVO
	{
		public var ID:String;
		public var LEVEL:String;
		public var DEPID:String;
		public var NAME:String;
		public var GPSRANGE:String;
		public var LEVEL_NAME:String;
		
		public var dept:DicDepartment;
		
		public var color:Number = 0xFF0000;
		
		public var polygon:Polygon;
		
		public function WarningAreaVO(source:Object)
		{
			this.ID = source.ID;
			this.LEVEL = source.LEVEL;
			this.DEPID = source.DEPID;
			
			if(DicDepartment.dict[this.DEPID] != undefined)
			{
				this.dept = DicDepartment.dict[this.DEPID];
			}
			
			this.NAME = source.NAME;
			this.LEVEL_NAME = source.DICVALUE;
			
			var ring:Array = new Array;
			if(source.GPSRANGE != undefined)
			{				
				var arr:Array = source.GPSRANGE.split("|");
				var zonerange:String = arr[0];
				if(arr.length > 1)
				{
					this.color = Number(arr[1]);
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
	}
}