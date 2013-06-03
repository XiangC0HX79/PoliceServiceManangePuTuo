package app.model.vo
{
	import com.esri.ags.geometry.Polyline;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	public class PathVO
	{
		public function PathVO()
		{
		}
		
		public var listGPS:ArrayCollection = new ArrayCollection;
		
		public function get line():Polyline
		{
			var arr:Array = new Array;
			for each(var gps:GPSVO in listGPS)
			{
				arr.push(gps.mapPoint);
			}
			
			if(arr.length > 0)
			{
				return new Polyline([arr]);	
			}
			else
			{
				return null;
			}
		}
		
		public function get firstGPS():GPSVO
		{
			if(listGPS.length > 0)
			{
				return listGPS[0];
			}
			else
			{
				return null;
			}			
		}
		
		public function get lastGPS():GPSVO
		{
			if(listGPS.length > 0)
			{
				return listGPS[listGPS.length - 1];
			}
			else
			{
				return null;
			}			
		}
		
		public function get beginTime():Date
		{
			if(firstGPS != null)
			{
				return firstGPS.gpsDate;
			}
			else
			{
				return null;
			}
		}
		
		public function get endTime():Date
		{			
			if(lastGPS != null)
			{
				return lastGPS.gpsDate;
			}
			else
			{
				return null;
			}
		}
	}
}