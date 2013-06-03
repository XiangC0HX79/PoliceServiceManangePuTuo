package app.model
{
	import app.AppNotification;
	import app.model.vo.AppConfigVO;
	import app.model.vo.GPSVO;
	import app.model.vo.PathVO;
	import app.model.vo.TrackHistoryVO;
	
	import com.esri.ags.geometry.Extent;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.geometry.Polygon;
	import com.esri.ags.geometry.Polyline;
	
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.collections.XMLListCollection;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	import spark.collections.Sort;
	import spark.effects.Move;
	import spark.formatters.DateTimeFormatter;
	
	public class TrackLinebackProxy extends Proxy implements IProxy
	{
		public static const NAME:String= "TrackLinebackProxy";
		
		public function TrackLinebackProxy()
		{
			super(NAME,new Dictionary);
		}
		
		public function get dict():Dictionary
		{
			return data as Dictionary;
		}
		
		public function get list():ArrayCollection
		{
			var result:ArrayCollection = new ArrayCollection;
			for each(var item:TrackHistoryVO in dict)
			{
				result.addItem(item);
			}
			return result;
		}
		
		public function get listGPS():ArrayCollection
		{
			var result:ArrayCollection = new ArrayCollection;
			for each(var item:TrackHistoryVO in dict)
			{
				result.addItem(item.lastGPS);
			}
			return result;
		}
						
		public function getGPSTrackHistory(deptID:String,beginTime:Date,endTime:Date,polygon:Polygon):void
		{			
			var dateF:DateTimeFormatter = new DateTimeFormatter();
			dateF.dateTimePattern = "yyyy-MM-dd HH:mm:ss";
												
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["getGPSTrackLineBack",onResult,[deptID,dateF.format(beginTime), dateF.format(endTime)]]);	
			
			function onResult(result:ArrayCollection):void
			{						
				if(result.length > 0)
				{			
					setData(new Dictionary);
					
					var dictTemp:Dictionary = new Dictionary;
					
					for each(var item:Object in result)
					{
						var gps:GPSVO = new GPSVO(item);
						if(dict[gps.gpsSimCard] == undefined)
						{							
							dict[gps.gpsSimCard] = new TrackHistoryVO();
							dictTemp[gps.gpsSimCard] = new ArrayCollection;
						}
						
						(dictTemp[gps.gpsSimCard] as ArrayCollection).addItem(gps);
					}
					
					for(var key:* in dictTemp)
					{
						var trackHistory:TrackHistoryVO = dict[key];
						
						var path:PathVO = null;;
						for each(var subGPS:GPSVO in dictTemp[key])
						{
							if(polygon.contains(subGPS.mapPoint))
							{
								if(path == null)
								{
									path = new PathVO;
								}
								
								path.listGPS.addItem(subGPS);
							}
							else
							{
								if(path != null)
									trackHistory.listPath.addItem(path);
								
								path = null;
							}
						}
						
						if(path != null)
						{
							trackHistory.listPath.addItem(path);
						}
						
						if(trackHistory.listPath.length == 0)
						{
							delete dict[key];
						}
					}
					
					sendNotification(AppNotification.NOTIFY_TRACKLINEBACK_GET);
				}					
				else
				{
					sendNotification(AppNotification.NOTIFY_APP_ALERTALARM ,"当前范围内未查询到轨迹，请更改查询条件后重新查询。");
				}
			}
		}
	}
}