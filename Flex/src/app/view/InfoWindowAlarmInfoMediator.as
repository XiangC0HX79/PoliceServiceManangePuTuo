package app.view
{
	import app.AppNotification;
	import app.model.AlarmInfoProxy;
	import app.model.vo.AlarmInfoVO;
	import app.view.components.InfoWindowAlarmInfo;
	
	import com.esri.ags.geometry.Geometry;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.tools.DrawTool;
	
	import flash.events.Event;
	
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class InfoWindowAlarmInfoMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "InfoWindowAlarmInfoMediator";
		
		private var alarmInfoProxy:AlarmInfoProxy;
		
		public function InfoWindowAlarmInfoMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			infoWindowAlarmInfo.addEventListener(InfoWindowAlarmInfo.CORRECT,onBtnAlarmCorrectButtonDown);
			infoWindowAlarmInfo.addEventListener(InfoWindowAlarmInfo.UNDO,onBtnAlarmUndoButtonDown);
			infoWindowAlarmInfo.addEventListener(InfoWindowAlarmInfo.FOCUS,onBtnAlarmFocusButtonDown);
			infoWindowAlarmInfo.addEventListener(InfoWindowAlarmInfo.HIDE,onBtnAlarmHideButtonDown);
			
			alarmInfoProxy = facade.retrieveProxy(AlarmInfoProxy.NAME) as AlarmInfoProxy;				
		}
		
		private function get infoWindowAlarmInfo():InfoWindowAlarmInfo
		{
			return viewComponent as InfoWindowAlarmInfo;
		}
		
		private function onBtnAlarmCorrectButtonDown(event:Event):void
		{			
			sendNotification(AppNotification.NOTIFY_SEARCH_GRAPHICSTART,[0,DrawTool.MAPPOINT,drawResultHandle]);
			
			function drawResultHandle(geometry:Geometry):void
			{
				sendNotification(AppNotification.NOTIFY_SEARCH_GRAPHICSTOP);
								
				alarmInfoProxy.correct(infoWindowAlarmInfo.alarm,geometry as MapPoint);
			}
		}
		
		private function onBtnAlarmUndoButtonDown(event:Event):void
		{						
			alarmInfoProxy.correct(infoWindowAlarmInfo.alarm,infoWindowAlarmInfo.alarm.srcPoint);
		}
		
		private function onBtnAlarmFocusButtonDown(event:Event):void
		{
			if(infoWindowAlarmInfo.alarm != null)
			{
				infoWindowAlarmInfo.alarm.isFocus = !infoWindowAlarmInfo.alarm.isFocus;
				
				alarmInfoProxy.updateFocus(infoWindowAlarmInfo.alarm);
								
				infoWindowAlarmInfo.labelFocus = infoWindowAlarmInfo.alarm.isFocus?"取消关注":"关注警情";
				
				sendNotification(AppNotification.NOTIFY_ALARM_FOCUS,infoWindowAlarmInfo.alarm);
			}
		}
		
		private function onBtnAlarmHideButtonDown(event:Event):void
		{
			if(infoWindowAlarmInfo.alarm != null)
			{
				infoWindowAlarmInfo.alarm.isMapShow = !infoWindowAlarmInfo.alarm.isMapShow;
				
				infoWindowAlarmInfo.labelHide = infoWindowAlarmInfo.alarm.isMapShow?"隐藏警情":"显示警情";
				
				sendNotification(AppNotification.NOTIFY_ALARM_HIDE,infoWindowAlarmInfo.alarm);
			}
		}			
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_LAYERALARM_GRAPHICCLICK
				//AppNotification.NOTIFY_LAYERALARM_GRAPHICMOUSEOVER				
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{			
			switch(notification.getName())
			{
				case AppNotification.NOTIFY_LAYERALARM_GRAPHICCLICK:
					infoWindowAlarmInfo.alarm = notification.getBody() as AlarmInfoVO;
										
					infoWindowAlarmInfo.labelFocus = infoWindowAlarmInfo.alarm.isFocus?"取消关注":"关注警情";
					infoWindowAlarmInfo.labelHide = infoWindowAlarmInfo.alarm.isMapShow?"隐藏警情":"显示警情";
					break;
				
			/*	case AppNotification.NOTIFY_LAYERALARM_GRAPHICMOUSEOVER:
					infoWindowAlarmInfo.minGroup();
					break;*/
			}
		}	
	}
}