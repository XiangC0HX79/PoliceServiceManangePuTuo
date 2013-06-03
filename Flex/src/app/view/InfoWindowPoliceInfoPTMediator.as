package app.view
{
	import app.AppNotification;
	import app.model.GPSRealTimeInfoProxy;
	import app.model.TrackHistoryProxy;
	import app.model.TrackRealtimeProxy;
	import app.model.dict.DicServiceStatus;
	import app.model.vo.AppConfigVO;
	import app.model.vo.GPSNewVO;
	import app.view.components.InfoWindowPoliceInfoPT;
	import app.view.components.MainMenu;
	
	import com.esri.ags.geometry.Geometry;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.tools.DrawTool;
	
	import flash.events.Event;
	
	import mx.core.IVisualElementContainer;
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.components.supportClasses.SkinnableComponent;
	
	public class InfoWindowPoliceInfoPTMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "InfoWindowPoliceInfoPTMediator";
		
		public function InfoWindowPoliceInfoPTMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
						
			infoWindowPoliceInfo.addEventListener(InfoWindowPoliceInfoPT.CHANGESTATE,onChangeState);			
			infoWindowPoliceInfo.addEventListener(InfoWindowPoliceInfoPT.TRACKREALTIME,onTrackRealtimeButtonDown);	
			infoWindowPoliceInfo.addEventListener(InfoWindowPoliceInfoPT.TRACKHISTORY,onTrackHistoryButtonDown);
			infoWindowPoliceInfo.addEventListener(InfoWindowPoliceInfoPT.CORRECTPOS,onCorrectPosition);
			
			infoWindowPoliceInfo.addEventListener(InfoWindowPoliceInfoPT.ANSWER,onAnswer);
			infoWindowPoliceInfo.addEventListener(InfoWindowPoliceInfoPT.NOANSWER,onNoAnswer);
		}
		
		private function get infoWindowPoliceInfo():InfoWindowPoliceInfoPT
		{
			return viewComponent as InfoWindowPoliceInfoPT;
		}
					
		private function onTrackRealtimeButtonDown(event:Event):void
		{
			var trackRealtimeProxy:TrackRealtimeProxy = facade.retrieveProxy(TrackRealtimeProxy.NAME) as TrackRealtimeProxy;
			if(trackRealtimeProxy.listTrackRealtimeArr.contains(infoWindowPoliceInfo.police))
			{
				sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,infoWindowPoliceInfo.police.gpsName + "正在执勤跟踪。");
			}
			else
			{
				if(trackRealtimeProxy.listTrackRealtimeArr.length >=4 )
				{
					sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"最多只能同时选择4名人员进行执勤跟踪。");
				}
				else
				{
					trackRealtimeProxy.add(infoWindowPoliceInfo.police);
				}
			}
		}
		
		private function onTrackHistoryButtonDown(event:Event):void
		{
			if((AppConfigVO.Auth == "0") 
				&& (infoWindowPoliceInfo.police.department != AppConfigVO.user.department))
			{
				sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"不能查看其他单位人员的历史轨迹。");
			}
			else
			{
				sendNotification(AppNotification.NOTIFY_MENUBAR,null,MainMenu.SERVICETRACKHISTORY);
				
				sendNotification(AppNotification.NOTIFY_INFOWINDOW_TRACKHISTORY,infoWindowPoliceInfo.police);
			}
		}
				
		private function onAnswer(event:Event):void
		{
			sendNotification(AppNotification.NOTIFY_INFOPOLICE_CALL,
				[
					infoWindowPoliceInfo.police
					,"是"
					,String(infoWindowPoliceInfo.radioButtonGroupCorrect.selectedValue)
					,infoWindowPoliceInfo.txtCall.text
					,infoWindowPoliceInfo.inputName.text
					,infoWindowPoliceInfo.inputKind.text
					,infoWindowPoliceInfo.textPos
				]);
		}
		
		private function onNoAnswer(event:Event):void
		{
			sendNotification(AppNotification.NOTIFY_INFOPOLICE_CALL,
				[
					infoWindowPoliceInfo.police
					,"否"
					,String(infoWindowPoliceInfo.radioButtonGroupCorrect.selectedValue)
					,infoWindowPoliceInfo.txtCall.text
					,infoWindowPoliceInfo.inputName.text
					,infoWindowPoliceInfo.inputKind.text
					,infoWindowPoliceInfo.textPos
				]);
		}
		
		private function onChangeState(event:Event):void
		{
			var selectedStatus:DicServiceStatus = infoWindowPoliceInfo.dropListServiceStatus.selectedItem as DicServiceStatus;
			
			if(selectedStatus.id != infoWindowPoliceInfo.police.serviceStatusID)
			{
				var gpsRealTimeInfoProxy:GPSRealTimeInfoProxy = facade.retrieveProxy(GPSRealTimeInfoProxy.NAME) as GPSRealTimeInfoProxy;
				gpsRealTimeInfoProxy.setServiceState(
					selectedStatus.id
					,selectedStatus.label
					,infoWindowPoliceInfo.police.userId
					,AppConfigVO.user.gpsName
					,infoWindowPoliceInfo.police.gpsDateFormat
				);
			}
		}
		
		
		private function onCorrectPosition(event:Event):void
		{			
			sendNotification(AppNotification.NOTIFY_SEARCH_GRAPHICSTART,[0,DrawTool.MAPPOINT,drawResultHandle]);
			
			function drawResultHandle(geometry:Geometry):void
			{
				sendNotification(AppNotification.NOTIFY_SEARCH_GRAPHICSTOP);
				
				infoWindowPoliceInfo.textPos = (geometry as MapPoint).x + " " + (geometry as MapPoint).y;
				
				sendNotification(AppNotification.NOTIFY_APP_ALERTINFO,"实为GPS位置修正完毕。");
				//alarmInfoProxy.correct(rightPanelAlarmInfo.listAlarmItem,geometry as MapPoint);
			}
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_APP_INIT,
				AppNotification.NOTIFY_LAYERGPS_POLICECLICK,
				AppNotification.NOTIFY_MAP_INFOPOLICEHIDE
				];
		}
		
		override public function handleNotification(notification:INotification):void
		{			
			switch(notification.getName())
			{
				case AppNotification.NOTIFY_APP_INIT:
					infoWindowPoliceInfo.listServiceStatus = DicServiceStatus.list;
					break;
				
				case AppNotification.NOTIFY_LAYERGPS_POLICECLICK:
					infoWindowPoliceInfo.police = notification.getBody() as GPSNewVO;
					
					infoWindowPoliceInfo.listServiceStatusItem = infoWindowPoliceInfo.police.serviceStatus;
					
					infoWindowPoliceInfo.textCall = "";
					
					infoWindowPoliceInfo.textKind = infoWindowPoliceInfo.police.policeKind;
					infoWindowPoliceInfo.textName = infoWindowPoliceInfo.police.gpsName;
					infoWindowPoliceInfo.textPos = infoWindowPoliceInfo.police.mapPoint.x + " " + infoWindowPoliceInfo.police.mapPoint.y;
					
					infoWindowPoliceInfo.currentState = "min";					
					break;
								
				case AppNotification.NOTIFY_MAP_INFOPOLICEHIDE:
					infoWindowPoliceInfo.dropListServiceStatus.closeDropDown(false);
					break;
			}
		}
	}
}