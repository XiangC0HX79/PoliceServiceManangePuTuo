package app.view
{
	import app.AppNotification;
	import app.model.TrackHistoryProxy;
	import app.model.TrackRealtimeProxy;
	import app.model.vo.AppConfigVO;
	import app.model.vo.GPSNewVO;
	import app.view.components.InfoWindowCarInfo;
	import app.view.components.MainMenu;
	
	import flash.events.Event;
	
	import mx.core.IVisualElementContainer;
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class InfoWindowCarInfoMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "InfoWindowCarInfoMediator";
		
		public function InfoWindowCarInfoMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			infoWindowCarInfo.btnTrackRealtime.addEventListener(FlexEvent.BUTTON_DOWN,onTrackRealtimeButtonDown);
			infoWindowCarInfo.btnTrackHistory.addEventListener(FlexEvent.BUTTON_DOWN,onTrackHistoryButtonDown);
			
			infoWindowCarInfo.addEventListener(InfoWindowCarInfo.ANSWER,onAnswer);
			infoWindowCarInfo.addEventListener(InfoWindowCarInfo.NOANSWER,onNoAnswer);
		}
		
		private function get infoWindowCarInfo():InfoWindowCarInfo
		{
			return viewComponent as InfoWindowCarInfo;
		}
		
		private function onTrackRealtimeButtonDown(event:FlexEvent):void
		{			
			var trackRealtimeProxy:TrackRealtimeProxy = facade.retrieveProxy(TrackRealtimeProxy.NAME) as TrackRealtimeProxy;
			if(trackRealtimeProxy.listTrackRealtimeArr.contains(infoWindowCarInfo.carInfo))
			{
				sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,infoWindowCarInfo.carInfo.gpsName + "正在执勤跟踪。");
			}
			else
			{
				if(trackRealtimeProxy.listTrackRealtimeArr.length >=4 )
				{
					sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"最多只能同时选择4名人员进行执勤跟踪。");
				}
				else
				{
					trackRealtimeProxy.add(infoWindowCarInfo.carInfo);
				}
			}
		}
		
		private function onTrackHistoryButtonDown(event:FlexEvent):void
		{			
			if((AppConfigVO.Auth == "0") 
				&& (infoWindowCarInfo.carInfo.department != AppConfigVO.user.department))
			{
				sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"不能查看其他单位人员的历史轨迹。");
			}
			else
			{
				sendNotification(AppNotification.NOTIFY_MENUBAR,null,MainMenu.SERVICETRACKHISTORY);
				
				sendNotification(AppNotification.NOTIFY_INFOWINDOW_TRACKHISTORY,infoWindowCarInfo.carInfo);
			}
		}
				
		private function onAnswer(event:Event):void
		{
			
			sendNotification(AppNotification.NOTIFY_INFOPOLICE_CALL,
				[infoWindowCarInfo.carInfo,"是",String(infoWindowCarInfo.radioButtonGroupCorrect.selectedValue),infoWindowCarInfo.txtCall.text]);
		}
		
		private function onNoAnswer(event:Event):void
		{
			sendNotification(AppNotification.NOTIFY_INFOPOLICE_CALL,
				[infoWindowCarInfo.carInfo,"否",String(infoWindowCarInfo.radioButtonGroupCorrect.selectedValue),infoWindowCarInfo.txtCall.text]);
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_APP_INIT,
				AppNotification.NOTIFY_LAYERGPS_VEHICLECLICK
				];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch(notification.getName())
			{
				case AppNotification.NOTIFY_APP_INIT:	
					break;
				
				case AppNotification.NOTIFY_LAYERGPS_VEHICLECLICK:
					infoWindowCarInfo.carInfo = notification.getBody() as GPSNewVO;
					
					infoWindowCarInfo.textCall = "";
					
					infoWindowCarInfo.currentState = "min";
					break;
			}
		}
	}
}