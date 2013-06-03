package app.model
{
	import app.AppNotification;
	import app.model.dict.DicGPSImage;
	import app.model.dict.DicPatrolType;
	import app.model.dict.DicPoliceType;
	import app.model.dict.DicServiceStatus;
	import app.model.dict.DicServiceType;
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
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	import spark.collections.Sort;
	import spark.effects.Move;
	import spark.formatters.DateTimeFormatter;
	
	public class TrackHistoryProxy extends Proxy implements IProxy
	{
		public static const NAME:String= "TrackHistoryProxy";
							
		//public var arrSelected:ArrayCollection = new ArrayCollection;
		
		//public var endTime:Date = new Date;
		//public var beginTime:Date =new Date(endTime.time - 60*60*1000);
				
		public var listSelected:ArrayCollection = new ArrayCollection;
		
		public function TrackHistoryProxy()
		{
			super(NAME,new ArrayCollection);
		}
				
		private function get list():ArrayCollection
		{
			return data as ArrayCollection;
		}
		
		public function get listTrackHistory():ArrayCollection
		{
			var result:ArrayCollection = new ArrayCollection;
			for each(var gps:GPSVO in listSelected)
			{
				var track:TrackHistoryVO = getTrackHistory(gps);
				if(track != null)
				{
					result.addItem(track);
				}
			}
			return result;
		}
			
		public function get trackBeginTime():Date
		{
			var result:Date = null;
			for each(var item:TrackHistoryVO in listTrackHistory)
			{
				if((item.beginTime != null)
					&& ((result == null) || (result.time > item.beginTime.time)))
				{
					result = item.beginTime;
				}				
			}
			
			return result;
		}
		
		public function get trackEndTime():Date
		{
			var result:Date = null;
			for each(var item:TrackHistoryVO in listTrackHistory)
			{
				if((item.endTime != null)
					&& ((result == null) || (result.time < item.endTime.time)))
				{
					result = item.endTime;
				}				
			}
			
			return result;
		}
		
		public function get trackExtent():Extent
		{
			var result:Extent = null;
			for each(var item:TrackHistoryVO in listTrackHistory)
			{
				if(item.line != null)
				{
					if(result == null)
					{
						result = item.line.extent;
					}
					else
					{
						result = result.union(item.line.extent);
					}
				}
			}
			
			return result;
		}
		
		public function get listTrackPoint():ArrayCollection
		{
			var result:ArrayCollection = new ArrayCollection;
			for each(var item:TrackHistoryVO in listTrackHistory)
			{
				result.addAll(item.listGPS);	
			}
			
			var sort:Sort = new Sort;
			sort.compareFunction = compareFunction;
			result.sort = sort;
			result.refresh();
			
			return result;
			
			function compareFunction(a:GPSVO, b:GPSVO, fields:Array = null):int
			{
				if(a.gpsDate.time > b.gpsDate.time)
				{
					return 1;
				}
				else
				{
					return -1;
				}
			}
		}
		
		public function getGPSByDate(gps:GPSVO,date:Date):GPSVO
		{
			//var result:GPSVO = new GPSVO;
			
			var trackHistory:TrackHistoryVO = this.getTrackHistory(gps);
			
			if(date.time <= trackHistory.beginTime.time)
			{
				//result.copy(trackHistory.firstGPS);
				return trackHistory.firstGPS;
			}
			
			var path:PathVO = trackHistory.listPath[0];
			for(var i:Number = 0;i<path.listGPS.length - 1;i++)
			{
				var preGPS:GPSVO = path.listGPS[i];
				var nextGPS:GPSVO = path.listGPS[i+1];
				
				if(preGPS.gpsDate.time == date.time)
				{
					//result.copy(preGPS);
					return preGPS;
				}
				
				if(nextGPS.gpsDate.time == date.time)
				{
					//result.copy(nextGPS);
					return nextGPS;
				}
				
				if((preGPS.gpsDate.time < date.time)
					&& (date.time < nextGPS.gpsDate.time))
				{
					var scale:Number = (date.time - preGPS.gpsDate.time) / (nextGPS.gpsDate.time - preGPS.gpsDate.time);
					var x:Number = (nextGPS.mapPoint.x - preGPS.mapPoint.x) * scale + preGPS.mapPoint.x;
					var y:Number = (nextGPS.mapPoint.y - preGPS.mapPoint.y) * scale + preGPS.mapPoint.y;
					
					var newGPS:GPSVO = new GPSVO({});
					newGPS.copy(preGPS);
					
					var dateF:DateTimeFormatter = new DateTimeFormatter;
					dateF.dateTimePattern = "yyyy-MM-dd HH:mm:ss";					
					newGPS.gpsDate = date;
					newGPS.gpsDateFormat = dateF.format(date);
										
					newGPS.mapPoint = new MapPoint(x,y);
					return newGPS;
				}
			}
			
			//result.copy(trackHistory.lastGPS);
			return trackHistory.lastGPS;			 
		}
				
		public function clear():void
		{
			list.removeAll();
			
			listSelected.removeAll();
			
			//listPolice.removeAll();
			
			sendNotification(AppNotification.NOTIFY_TRACKHISTORY_CLEAR);
		}
					
		public function getTrackHistory(gps:GPSVO):TrackHistoryVO
		{
			for each(var item:TrackHistoryVO in list)
			{
				if(item.firstGPS.gpsSimCard == gps.gpsSimCard)
					return item;
			}
			
			return null;
		}
					
		public function add(gps:GPSVO,beginTime:Date,endTime:Date):void
		{			
			listSelected.addItem(gps);
			
			if(getTrackHistory(gps) == null)
			{
				getGPSTrackHistory(gps, beginTime,endTime);
			}
			else
			{
				sendNotification(AppNotification.NOTIFY_TRACKHISTORY_CHANGE);
			}
		}
		
		public function remove(gps:GPSVO):void
		{
			listSelected.removeItemAt(listSelected.getItemIndex(gps));
			
			sendNotification(AppNotification.NOTIFY_TRACKHISTORY_CHANGE);
		}
				
		/*public function getGPSTrackHistoryListByInfoWindow(gps:GPSVO,beginTime:Date,endTime:Date):void
		{			
			var dateF:DateTimeFormatter = new DateTimeFormatter();
			dateF.dateTimePattern = "yyyy-MM-dd HH:mm:ss";
			
			//this.endTime = new Date;
			//this.beginTime = new Date((new Date).time - 60*60*1000);
			
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["getGPSListTrackHis",onResult,[gps.department.id,gps.gpsName,dateF.format(beginTime),dateF.format(endTime)]]);	
			
			function onResult(result:ArrayCollection):void
			{	
				if(result.length > 0)
				{
					clear();
					
					for each(var item:Object in result)
					{
						listPolice.addItem(new GPSVO(item));
					}			
										
					sendNotification(AppNotification.NOTIFY_TRACKHISTORY_INFOWINDOWGETLIST);
					
					add(gps,beginTime,endTime);
				}
				else
				{
					sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"当前查询没有返回轨迹，请更改查询条件后重新查询历史轨迹。");
				}
			}
		}*/
		
		public function getGPSTrackHistoryList(deptID:String,name:String,beginTime:Date,endTime:Date):void
		{					
			var dateF:DateTimeFormatter = new DateTimeFormatter();
			dateF.dateTimePattern = "yyyy-MM-dd HH:mm:ss";
			
			//this.beginTime = beginTime;
			//this.endTime = endTime;
						
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["getGPSListTrackHis",onResult,[deptID,name,dateF.format(beginTime),dateF.format(endTime)]]);	
		
			function onResult(result:ArrayCollection):void
			{	
				if(result.length > 0)
				{
					clear();
					
					/*var arr:ArrayCollection = new ArrayCollection;
					for each(var item:Object in result)
					{
						arr.addItem(new GPSVO(item));
					}				
					
					sendNotification(AppNotification.NOTIFY_TRACKHISTORY_GETLIST,arr);*/
					
					sendNotification(AppNotification.NOTIFY_TRACKHISTORY_GETLIST,result);
				}
				else
				{
					sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"当前查询没有返回轨迹，请更改查询条件后重新查询历史轨迹。");
				}
			}
		}
		
		private function getGPSTrackHistory(gps:GPSVO,beginTime:Date,endTime:Date):void
		{			
			var dateF:DateTimeFormatter = new DateTimeFormatter();
			dateF.dateTimePattern = "yyyy-MM-dd HH:mm:ss";
			
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["getGPSTrackHis",onResult,[gps.gpsSimCard, dateF.format(beginTime),dateF.format(endTime)]]);
				
			function onResult(result:ArrayCollection):void
			{					
				if(result.length > 0) 
				{
					var trackHistory:TrackHistoryVO = new TrackHistoryVO;	
					
					var path:PathVO = new PathVO;
					for each(var row:Object in result)
					{
						var item:GPSVO = new GPSVO(row);
						//refreshGPSImage(item);
						path.listGPS.addItem(item);
					}										
					trackHistory.listPath.addItem(path);
					
					list.addItem(trackHistory);
				}
				
				sendNotification(AppNotification.NOTIFY_TRACKHISTORY_CHANGE);
			}
		}
	}
}