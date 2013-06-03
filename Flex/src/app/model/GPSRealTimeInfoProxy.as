package app.model
{	
	import app.AppNotification;
	import app.model.dict.DicGPSImage;
	import app.model.dict.DicPatrolType;
	import app.model.dict.DicPoliceType;
	import app.model.dict.DicServiceStatus;
	import app.model.dict.DicServiceType;
	import app.model.vo.AppConfigVO;
	import app.model.vo.GPSNewVO;
	import app.view.MainMapMediator;
	
	import com.esri.ags.geometry.Extent;
	import com.esri.ags.geometry.Geometry;
	import com.esri.ags.geometry.Polygon;
	
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	import spark.formatters.DateTimeFormatter;
	
	public class GPSRealTimeInfoProxy extends Proxy implements IProxy
	{
		public static const NAME:String = "GPSRealTimeProxy";
		
		//private var _gpsValidDiff:Number = 40;
				
		public function GPSRealTimeInfoProxy()
		{
			super(NAME, new Array(2));
			
			list[0] = new Dictionary;
			list[1] = new Dictionary;
			//list[2] = new Dictionary;
		}
		
		private function get list():Array
		{
			return data as Array;
		}
		
		public function get dicGPS():Dictionary
		{
			return list[0] as Dictionary;
		}
		
		public function get dicDuty():Dictionary
		{
			return list[1] as Dictionary;
		}
		
		/*public function get dicCall():Dictionary
		{
			return list[2] as Dictionary;
		}*/
		
		public function get listGPS():ArrayCollection
		{
			var result:ArrayCollection = new ArrayCollection;
			
			for each(var item:GPSNewVO in dicGPS)
			{
				if(item.inService || item.gpsValid)
				{
					result.addItem(item);
				}
			}
			
			return result;
		}
		
		public function get listPolice():ArrayCollection
		{
			var result:ArrayCollection = new ArrayCollection;
			
			for each(var item:GPSNewVO in dicGPS)
			{
				if(item.policeTypeID != DicPoliceType.VEHICLE.id)
				{
					result.addItem(item);
				}
			}
			
			return result;
		}
		
		public function get listService():ArrayCollection
		{
			var result:ArrayCollection = new ArrayCollection;
			
			for each(var item:GPSNewVO in dicGPS)
			{
				if(item.inService)
				{
					result.addItem(item);
				}
			}
			
			return result;
		}
		
		public function get maxID():Number
		{
			var result:Number = 0;
			
			for each(var item:GPSNewVO in dicGPS)
			{
				if(item.gpsID > result)
				{
					result = item.gpsID;
				}
			}
			
			return result;
		}
		
		public function getPoliceByUserID(userID:String):GPSNewVO
		{
			for each(var item:GPSNewVO in dicGPS)
			{
				if(item.userId == userID)
				{
					return item;
				}
			}
			
			return null;
		}

		public function refresh(gps:GPSNewVO):GPSNewVO
		{
			var oldGPS:GPSNewVO = dicGPS[gps.gpsSimCard] as GPSNewVO;
			if(oldGPS != null)
			{				
				if(oldGPS.gpsID < gps.gpsID)
				{
					oldGPS.copy(gps);
				}
				else if(oldGPS.gpsID == gps.gpsID)
				{
					if((oldGPS.stateChangeTime != null) && (gps.stateChangeTime != null)
						 && (oldGPS.stateChangeTime.time < gps.stateChangeTime.time))
					{
						oldGPS.copy(gps);
					}
					//过滤值班勤务
					else if(oldGPS.inService && (oldGPS.serviceTypeID == "1"))
					{
						oldGPS.copy(gps);
					}
				}
				
				oldGPS.refresh();
			}
			else
			{
				dicGPS[gps.gpsSimCard] = gps;
			}
			
			return dicGPS[gps.gpsSimCard];
		}
						
		public function GetGPSRealTimeInfo():void
		{
			/*var dateF:DateTimeFormatter = new DateTimeFormatter();
			dateF.dateTimePattern = "yyyy-MM-dd HH:mm:ss";*/
						
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["getGPSRealTimeInfo",onResult,[this.maxID],
					false]);	
			
			function onResult(result:ArrayCollection):void
			{			
				GPSNewVO.CurrentTime = new Date(Date.parse(result[0].DATARECORDTIME));
				
				this.dicDuty = new Dictionary;
				
				for(var i:Number = 1;i<result.length;i++)
				{
					var gps:GPSNewVO = new GPSNewVO(result[i]);
					
					/*if(gps.gpsDate.time > GPSNewVO.LastUpdateTime.time)
					{
						GPSNewVO.LastUpdateTime = gps.gpsDate;
					}*/
					
					if((gps.inService) && (gps.serviceType.label == "值班警力"))
					{
						this.dicDuty[gps.gpsSimCard] = gps;
					}
					
					refresh(gps);
				}
				
				sendNotification(AppNotification.NOTIFY_GPS_RECEIVE);
			}
		}
		
		public function RefreshAll():void
		{
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["getGPSRealTimeInfo",onResult,[""],true]);	
			
			function onResult(result:ArrayCollection):void
			{			
				GPSNewVO.CurrentTime = new Date(Date.parse(result[0].DATARECORDTIME));
				
				this.dicDuty = new Dictionary;
				
				for(var i:Number = 1;i<result.length;i++)
				{
					var gps:GPSNewVO = new GPSNewVO(result[i]);
					
					/*if(gps.gpsDate.time > GPSNewVO.LastUpdateTime.time)
					{
						GPSNewVO.LastUpdateTime = gps.gpsDate;
					}*/
					
					if((gps.inService) && (gps.serviceType.label == "值班警力"))
					{
						this.dicDuty[gps.gpsSimCard] = gps;
					}
					
					refresh(gps);
				}
				
				sendNotification(AppNotification.NOTIFY_GPS_RECEIVE);
			}
		}
		
		public function setServiceState(stateid:String,statenm:String,jyid:String,username:String,gpsTime:String):void
		{			
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["setServiceState",onResult,[stateid,statenm,jyid,"地图调整",username,gpsTime]]);	
			
			function onResult(result:ArrayCollection):void
			{				
				if(result.length > 0)
				{
					var  gps:GPSNewVO = refresh(new GPSNewVO(result[0]));				
					sendNotification(AppNotification.NOTIFY_GPS_CHANGESTATE,gps);
				}
			}
		}
	}
}