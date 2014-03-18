package app.view
{
	import app.AppFunction;
	import app.AppNotification;
	import app.event.AppEvent;
	import app.model.GPSRealTimeInfoProxy;
	import app.model.TrackHistoryProxy;
	import app.model.TrackRealtimeProxy;
	import app.model.dict.DicDepartment;
	import app.model.dict.DicPatrolZone;
	import app.model.dict.DicPoliceType;
	import app.model.vo.AppConfigVO;
	import app.model.vo.GPSVO;
	import app.model.vo.TrackHistoryVO;
	import app.view.components.MainMenu;
	import app.view.components.RightPanelServiceTrackHistory;
	import app.view.components.subComponents.ItemRendererCheck;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.components.Button;
	import spark.events.GridEvent;
	import spark.events.IndexChangeEvent;
	import spark.events.TextOperationEvent;
	import spark.formatters.DateTimeFormatter;
	
	public class RightPanelServiceTrackHistoryMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "RightPanelServiceTrackHistoryMediator";
		
		private var trackHistoryProxy:TrackHistoryProxy;
						
		public function RightPanelServiceTrackHistoryMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			rightPanelServiceTrackHistory.addEventListener(RightPanelServiceTrackHistory.SEARCH,onSearch);
			
			rightPanelServiceTrackHistory.addEventListener(AppEvent.ITEMCLICK,onGridPoliceItemCheck);
			
			rightPanelServiceTrackHistory.addEventListener(RightPanelServiceTrackHistory.FLASHTRACK,onFlashTrack);
			rightPanelServiceTrackHistory.addEventListener(RightPanelServiceTrackHistory.LOCATETRACK,onLocateTrack);
			
			rightPanelServiceTrackHistory.addEventListener(RightPanelServiceTrackHistory.SPEED,onBarSpeedChange);
			
			rightPanelServiceTrackHistory.addEventListener(RightPanelServiceTrackHistory.PLAY,onPlay);
			rightPanelServiceTrackHistory.addEventListener(RightPanelServiceTrackHistory.PAUSE,onPause);
			rightPanelServiceTrackHistory.addEventListener(RightPanelServiceTrackHistory.STOP,onStop);
			
			rightPanelServiceTrackHistory.addEventListener(RightPanelServiceTrackHistory.SLIDE,onSlide);
						
			trackHistoryProxy = facade.retrieveProxy(TrackHistoryProxy.NAME) as TrackHistoryProxy;
		}
		
		public function get rightPanelServiceTrackHistory():RightPanelServiceTrackHistory
		{
			return viewComponent as RightPanelServiceTrackHistory;
		}	
											
		private function onSearch(event:Event):void
		{								
			var tempBeginTime:Date = rightPanelServiceTrackHistory.beginTime;
			var tempEndTime:Date = rightPanelServiceTrackHistory.endTime;			
			var tempTimeSpan:Date = new Date(24*60*60*1000);
			var error:String = "";
			
			if(tempBeginTime.time > tempEndTime.time)
			{				
				sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"开始时间不能晚于结束时间！");
			}
			else if((tempEndTime.time - tempBeginTime.time) > tempTimeSpan.time)
			{			
				if(tempTimeSpan.date > 1)
				{
					error = (tempTimeSpan.dateUTC - 1) + "天";
				}
				else if(tempTimeSpan.hours > 0)
				{
					error = tempTimeSpan.hoursUTC + "小时";
				}
				else
				{
					error = tempTimeSpan.minutesUTC + "分钟";
				}
				sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"所选时间段不能超过" + error +"！");
			}
			else
			{
				trackHistoryProxy.getGPSTrackHistoryList(
					rightPanelServiceTrackHistory.listDeptItem.id
					,rightPanelServiceTrackHistory.textPoliceNo
					,rightPanelServiceTrackHistory.beginTime
					,rightPanelServiceTrackHistory.endTime
				);
			}
		}		
				
		private function onGridPoliceItemCheck(event:Event):void
		{
			var itemRenderer:ItemRendererCheck = event.target as ItemRendererCheck;
			var gps:GPSVO = itemRenderer.data as GPSVO;		
			
			if(itemRenderer.valueDisplay.selected)
			{
				itemRenderer.valueDisplay.selected = false;
				
				trackHistoryProxy.remove(gps);		
			}
			else
			{								
				if(trackHistoryProxy.listTrackHistory.length >=4 )
				{
					sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"最多只能同时选择4名人员进行轨迹回放。");
				}
				else
				{
					itemRenderer.valueDisplay.selected = true;
					
					trackHistoryProxy.add(gps
						,rightPanelServiceTrackHistory.beginTime
						,rightPanelServiceTrackHistory.endTime);
				}
			}
		}
			
		private function onFlashTrack(event:AppEvent):void
		{
			sendNotification(AppNotification.NOTIFY_TRACKHISTORY_FLASH,event.data);
		}
		
		private function onLocateTrack(event:AppEvent):void
		{			
			sendNotification(AppNotification.NOTIFY_TRACKHISTORY_LOCATE,event.data);
		}
		
		private function onBarSpeedChange(event:Event):void
		{			
			if(trackHistoryProxy.listTrackHistory.length > 0)
			{				
				sendNotification(AppNotification.NOTIFY_TRACKHISTORY_SPEED,rightPanelServiceTrackHistory.speed);
			}
		}
								
		private function onPlay(event:Event):void
		{			
			if(trackHistoryProxy.listTrackHistory.length > 0)
			{
				if(trackHistoryProxy.listTrackHistory.length > 0)
				{				
					if(rightPanelServiceTrackHistory.slider.value == rightPanelServiceTrackHistory.slider.maximum)
					{
						rightPanelServiceTrackHistory.slider.value = rightPanelServiceTrackHistory.slider.minimum;
					}
					
					var beginTime:Date = new Date(rightPanelServiceTrackHistory.slider.value);
					sendNotification(AppNotification.NOTIFY_TRACKHISTORY_PLAY,[beginTime,rightPanelServiceTrackHistory.speed]);
				}
				else
				{
					sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"没有可播放的历史轨迹，请重新进行查询。");
				}
			}
			else
			{
				sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"请选择轨迹回放人员。");
			}
		}
		
		private function onPause(event:Event):void
		{			
			if(trackHistoryProxy.listTrackHistory.length > 0)
			{
				sendNotification(AppNotification.NOTIFY_TRACKHISTORY_PAUSE);
			}
		}
		
		private function onStop(event:Event):void
		{
			if(trackHistoryProxy.listTrackHistory.length > 0)
			{
				sendNotification(AppNotification.NOTIFY_TRACKHISTORY_STOP);
			}
		}
		
		private function onSlide(event:Event):void
		{
			if(trackHistoryProxy.listTrackHistory.length > 0)
			{
				sendNotification(AppNotification.NOTIFY_TRACKHISTORY_SLIDE,new Date(rightPanelServiceTrackHistory.slider.value));
			}
		}	
				
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_APP_INIT,
				
				AppNotification.NOTIFY_MENUBAR,
				
				AppNotification.NOTIFY_INFOWINDOW_TRACKHISTORY,
				
				AppNotification.NOTIFY_TRACKHISTORY_GETLIST,
				
				AppNotification.NOTIFY_TRACKHISTORY_CHANGE,
								
				AppNotification.NOTIFY_LAYERTRACK_MOVEUPDATE
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch(notification.getName())
			{				
				case AppNotification.NOTIFY_APP_INIT:
					rightPanelServiceTrackHistory.listDept = DicDepartment.listOverview;
					if(AppConfigVO.Auth == "0")
					{
						rightPanelServiceTrackHistory.listDeptItem = DicDepartment.dict[AppConfigVO.user.departmentID];
					}
					else
					{
						rightPanelServiceTrackHistory.listDeptItem = DicDepartment.ALL;
					}
					break;
				
				case AppNotification.NOTIFY_MENUBAR:
					if(notification.getType() == MainMenu.SERVICETRACKHISTORY)
					{						
						rightPanelServiceTrackHistory.listPolice.removeAll();
						
						rightPanelServiceTrackHistory.endTime = new Date;
						rightPanelServiceTrackHistory.beginTime =  new Date(rightPanelServiceTrackHistory.endTime.time - 60*60*1000);
																		
						trackHistoryProxy.clear();
					}
					break;
				
				case AppNotification.NOTIFY_INFOWINDOW_TRACKHISTORY:											
					rightPanelServiceTrackHistory.listPolice.removeAll();
					
					rightPanelServiceTrackHistory.endTime = new Date;
					rightPanelServiceTrackHistory.beginTime =  new Date(rightPanelServiceTrackHistory.endTime.time - 60*60*1000);
					
					trackHistoryProxy.clear();
					
					var gps:GPSVO = new GPSVO(null);
					gps.copy(notification.getBody() as GPSVO);
					gps.selected = true;
					
					if(AppConfigVO.Auth == "1")
					{
						rightPanelServiceTrackHistory.listDeptItem = gps.department;
					}
					
					rightPanelServiceTrackHistory.textPoliceNo = gps.gpsName;
					rightPanelServiceTrackHistory.listPolice.addItem(gps);
					
					trackHistoryProxy.add(gps
						,rightPanelServiceTrackHistory.beginTime
						,rightPanelServiceTrackHistory.endTime);
					break;
				
				case AppNotification.NOTIFY_TRACKHISTORY_GETLIST:
					rightPanelServiceTrackHistory.listPolice.removeAll();
					
					var gpsProxy:GPSRealTimeInfoProxy = facade.retrieveProxy(GPSRealTimeInfoProxy.NAME) as GPSRealTimeInfoProxy;
								
					var arr:Array = new Array;
					for each(var item:Object in notification.getBody() as ArrayCollection)
					{
						var curGPS:GPSVO =  gpsProxy.dicGPS[item.GPSSIMCARD] as GPSVO;
						
						if(curGPS != null)
						{
							gps = new GPSVO(null);
							gps.copy(curGPS);
							gps.selected = false;
							
							arr.push(gps);
						}
					}		
					arr.sort(AppFunction.compareFunction);
					
					rightPanelServiceTrackHistory.listPolice.addAll(new ArrayCollection(arr));
					
					rightPanelServiceTrackHistory.slider.minimum = (new Date).time;
					rightPanelServiceTrackHistory.slider.maximum = rightPanelServiceTrackHistory.slider.minimum;
					rightPanelServiceTrackHistory.slider.value = rightPanelServiceTrackHistory.slider.minimum;
					break;
				
				case AppNotification.NOTIFY_TRACKHISTORY_CHANGE:
					for each(gps in rightPanelServiceTrackHistory.listPolice)
					{
						gps.selected = trackHistoryProxy.listSelected.contains(gps);
					}
					
					if((trackHistoryProxy.trackBeginTime == null)
						|| (trackHistoryProxy.trackEndTime == null))
					{
						rightPanelServiceTrackHistory.slider.minimum = (new Date).time;
						rightPanelServiceTrackHistory.slider.maximum = rightPanelServiceTrackHistory.slider.minimum;
						rightPanelServiceTrackHistory.slider.value = rightPanelServiceTrackHistory.slider.minimum;
					}
					else
					{
						rightPanelServiceTrackHistory.slider.minimum = trackHistoryProxy.trackBeginTime.time;
						rightPanelServiceTrackHistory.slider.maximum = trackHistoryProxy.trackEndTime.time;
						rightPanelServiceTrackHistory.slider.value = rightPanelServiceTrackHistory.slider.minimum;
					}
					
					rightPanelServiceTrackHistory.listPath = trackHistoryProxy.listTrackPoint;
					
					break;
					
				case AppNotification.NOTIFY_LAYERTRACK_MOVEUPDATE:
					rightPanelServiceTrackHistory.slider.value = (notification.getBody() as Date).time;
					break;
			}
		}
	}
}