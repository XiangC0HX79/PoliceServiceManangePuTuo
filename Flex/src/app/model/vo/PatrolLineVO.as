package app.model.vo
{
	import com.esri.ags.SpatialReference;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.geometry.Polyline;
	
	import app.model.dict.DicDepartment;
	import app.model.dict.DicPatrolLineType;

	[Bindable]
	public class PatrolLineVO
	{
		public static var defaultColor:Number = 0xFF0000;
				
		public var id:String;
		public var dept:DicDepartment;
		public var label:String;
		public var callNo:String;
		public var color:Number = 0xFF0000;
		
		public var type:DicPatrolLineType;
		
		public var polyline:Polyline;
		
		public function PatrolLineVO(source:Object)
		{
			this.id = source.ID;
			this.dept = DicDepartment.dict[source.DEPID];
			this.label = source.NAME;			
			this.callNo = source.HH;		
			this.type = DicPatrolLineType.dict[source.TYPE];
			
			var ring:Array = new Array;
			if(source.LINERANGE != undefined)
			{				
				var arr:Array = source.LINERANGE.split("|");
				var zonerange:String = arr[0];
				if(arr.length > 1)
				{
					this.color = Number(arr[1]);
				}
				else if(PatrolLineVO != null)
				{
					this.color = PatrolLineVO.defaultColor;
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
	}
}