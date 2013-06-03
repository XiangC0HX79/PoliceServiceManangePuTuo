package app.model.vo
{
	import com.esri.ags.geometry.Polyline;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	public class TrackHistoryVO
	{
		public function TrackHistoryVO()
		{
			//this.gps = gps;
		}
		
		//public var gps:GPSVO = null;
			
		public var listPath:ArrayCollection = new ArrayCollection;
				
		public function get listGPS():ArrayCollection
		{
			var arr:ArrayCollection = new ArrayCollection;
			
			for each(var path:PathVO in listPath)
			{
				for each(var gps:GPSVO in path.listGPS)
					arr.addItem(gps);
			}
			
			return arr;
		}
		
		/*public function get trackPath():Array
		{			
			if(listGPS.length == 0)
				return null;
						
			var pathArr:Array = new Array;
			for each(var item:ArrayCollection in listGPS)
			{
				var path:Array = new Array;
				for each(var gps:GPSVO in item)
				{
					path.push(gps.mapPoint);
				}
				
				var polyline:Polyline = new Polyline([path]);
				pathArr.push(polyline);
			}
			return pathArr;
		}*/
		
		public function get line():Polyline
		{
			var arr:Array = new Array;
			for each(var path:PathVO in listPath)
			{
				arr.push(path.line.paths[0]);
			}
			
			if(arr.length > 0)
			{
				return new Polyline(arr);	
			}
			else 
			{
				return null;
			}
		}
		
		public function get firstGPS():GPSVO
		{
			if(listPath.length > 0)
			{
				return (listPath[0] as PathVO).firstGPS;
			}
			else
			{
				return null;
			}			
		}
		
		public function get lastGPS():GPSVO
		{
			if(listPath.length > 0)
			{
				return (listPath[listPath.length - 1] as PathVO).lastGPS;
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