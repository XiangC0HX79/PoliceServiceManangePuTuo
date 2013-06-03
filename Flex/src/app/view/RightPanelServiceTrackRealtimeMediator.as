package app.view
{
	import app.AppNotification;
	import app.event.AppEvent;
	import app.model.GPSRealTimeInfoProxy;
	import app.model.TrackRealtimeProxy;
	import app.model.dict.DicDepartment;
	import app.model.dict.DicPatrolZone;
	import app.model.dict.DicPoliceType;
	import app.model.vo.AppConfigVO;
	import app.model.vo.GPSNewVO;
	import app.view.components.MainMenu;
	import app.view.components.RightPanelServiceTrackRealtime;
	import app.view.components.subComponents.HeadRendererCheck;
	import app.view.components.subComponents.ItemRendererCheck;
	import app.view.components.subComponents.ItemRendererTrackRealtime;
	
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.events.GridEvent;
	import spark.events.IndexChangeEvent;
	import spark.events.TextOperationEvent;
	
	public class RightPanelServiceTrackRealtimeMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "RightPanelServiceTrackRealtimeMediator";
		
		private var trackRealtimeProxy:TrackRealtimeProxy = null;
						
		public function RightPanelServiceTrackRealtimeMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			rightPanelServcieTrack.addEventListener(RightPanelServiceTrackRealtime.SEARCH,onSearchPolice);
			
			rightPanelServcieTrack.addEventListener(AppEvent.ITEMCLICK,onGridPoliceItemCheck);
			
			trackRealtimeProxy = facade.retrieveProxy(TrackRealtimeProxy.NAME) as TrackRealtimeProxy;
		}
		
		private function get rightPanelServcieTrack():RightPanelServiceTrackRealtime
		{
			return viewComponent as RightPanelServiceTrackRealtime;
		}
		
		public function patrolZoneFilterFunction(item:DicPatrolZone):Boolean
		{
			if(item == DicPatrolZone.ALL)
				return true;
			else 
				return (item.depid == rightPanelServcieTrack.listDeptItem.id);
		}			
							
		private function onSearchPolice(event:Event = null):void
		{
			rightPanelServcieTrack.listPolice.removeAll();
						
			var gpsRealTimeInfoProxy:GPSRealTimeInfoProxy = facade.retrieveProxy(GPSRealTimeInfoProxy.NAME) as GPSRealTimeInfoProxy;
			
			for each(var gps:GPSNewVO in gpsRealTimeInfoProxy.listGPS)
			{
				if(
					(
						(gps.policeNo.indexOf(rightPanelServcieTrack.textPoliceNo) != -1) 
						|| (gps.gpsName.indexOf(rightPanelServcieTrack.textPoliceNo) != -1)
						|| (gps.radioNo.indexOf(rightPanelServcieTrack.textPoliceNo) != -1)
						|| (gps.callNo.indexOf(rightPanelServcieTrack.textPoliceNo) != -1)
					)
					&& 
					(
						(rightPanelServcieTrack.listDeptItem == DicDepartment.ALL) 
						|| ((rightPanelServcieTrack.listDeptItem == DicDepartment.TRAFFIC) && (gps.department != null) && (gps.department.ZB == 125))
						|| (gps.department == rightPanelServcieTrack.listDeptItem)
					)
					&& 
					(gps.patrolZoneName.indexOf(rightPanelServcieTrack.patrolZoneName) != -1)
				)
				{
					rightPanelServcieTrack.listPolice.addItem(gps);
				}
			}
		}
				
		private function onGridPoliceItemCheck(event:Event):void
		{
			var itemRenderer:ItemRendererCheck = event.target as ItemRendererCheck;
			var gps:GPSNewVO = itemRenderer.data as GPSNewVO;		
			
			if(itemRenderer.valueDisplay.selected)
			{
				trackRealtimeProxy.remove(gps);
			}
			else
			{							
				if(trackRealtimeProxy.listTrackRealtimeArr.length >=4 )
				{
					sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"最多只能同时选择4名人员进行执勤跟踪。");
				}
				else
				{
					trackRealtimeProxy.add(gps);
				}
			}
		}
		
		override public function listNotificationInterests():Array
		{
			return [				
				AppNotification.NOTIFY_APP_INIT,
				AppNotification.NOTIFY_MENUBAR,
				AppNotification.NOTIFY_TRACKREALTIME_REFRESH
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch(notification.getName())
			{				
				case AppNotification.NOTIFY_APP_INIT:
					rightPanelServcieTrack.listDept = DicDepartment.listOverview;
					if(AppConfigVO.Auth == "0")
					{
						rightPanelServcieTrack.listDeptItem = DicDepartment.dict[AppConfigVO.user.departmentID];
					}
					else
					{
						rightPanelServcieTrack.listDeptItem = DicDepartment.ALL;
					}
										
					rightPanelServcieTrack.listPatrolZone = DicPatrolZone.listAll;
					rightPanelServcieTrack.listPatrolZone.filterFunction = patrolZoneFilterFunction;
					rightPanelServcieTrack.listPatrolZone.refresh();
					break;
						
				case AppNotification.NOTIFY_MENUBAR:
					if(notification.getType() == MainMenu.SERVICETRACKREALTIME)
					{
						onSearchPolice();
					}
					break;
				
				case AppNotification.NOTIFY_TRACKREALTIME_REFRESH:
					for each(var gps:GPSNewVO in rightPanelServcieTrack.listPolice)
					{
						gps.selected = trackRealtimeProxy.listTrackRealtimeArr.contains(gps);
					}
					
					rightPanelServcieTrack.listTrack.removeAll();
					rightPanelServcieTrack.listTrack.addAll(trackRealtimeProxy.listTrackRealtimeArr);
					break;
			}
		}
	}
}