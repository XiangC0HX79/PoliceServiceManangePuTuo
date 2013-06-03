package app.model
{
	import app.AppNotification;
	import app.model.vo.GPSNewVO;
	
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public class TrackRealtimeProxy extends Proxy implements IProxy
	{
		public static const NAME:String = "TrackRealtimeProxy";
				
		public const MAXCOUNT:Number = 4;
		
		public function TrackRealtimeProxy()
		{
			super(NAME, new Array(MAXCOUNT));
		}
		
		public function get listTrackRealtime():Array
		{
			return data as Array;
		}
		
		public function get listTrackRealtimeArr():ArrayCollection
		{
			var arr:ArrayCollection = new ArrayCollection;
			
			for(var i:Number = 0;i<MAXCOUNT;i++)
			{
				var curgps:GPSNewVO = listTrackRealtime[i] as GPSNewVO;
				if(curgps != null)
					arr.addItem(curgps);
			}
			
			return arr;
		}
		
		public function get nullIndex():Number
		{
			for(var i:Number = 0;i<MAXCOUNT;i++)
			{
				var curgps:GPSNewVO = listTrackRealtime[i] as GPSNewVO;
				if(curgps == null)
					return i;
			}
			
			return -1;
		}
		
		public function getGpsIndex(gps:GPSNewVO):Number
		{			
			for(var i:Number = 0;i<MAXCOUNT;i++)
			{
				var curgps:GPSNewVO = listTrackRealtime[i] as GPSNewVO;
				if((curgps != null) && (curgps.gpsSimCard == gps.gpsSimCard))
					return i;
			}
			
			return -1;
		}
		
		public function clear():void
		{
			for(var i:Number = 0;i<MAXCOUNT;i++)
			{
				listTrackRealtime[i] = null;
			}
			
			sendNotification(AppNotification.NOTIFY_TRACKREALTIME_REFRESH);
		}
		
		public function add(gps:GPSNewVO):void
		{
			if(getGpsIndex(gps) == -1)
			{
				listTrackRealtime[nullIndex] = gps;
			}
			
			sendNotification(AppNotification.NOTIFY_TRACKREALTIME_REFRESH);
		}
		
		public function reset(arr:Array):void
		{
			for(var i:Number = 0;i<MAXCOUNT;i++)
			{
				listTrackRealtime[i] = null;
			}
			
			for each(var item:GPSNewVO in arr)
			{
				if(getGpsIndex(item) == -1)
				{
					listTrackRealtime[nullIndex] = item;
				}
			}
			
			sendNotification(AppNotification.NOTIFY_TRACKREALTIME_REFRESH);
		}
		
		public function remove(gps:GPSNewVO):void
		{
			var index:Number = getGpsIndex(gps);
			if(index != -1)
				listTrackRealtime[index] = null;
			
			sendNotification(AppNotification.NOTIFY_TRACKREALTIME_REFRESH);
		}
	}
}