package app.view
{
	import app.AppNotification;
	import app.view.components.RightPanelAlarmStatis;
	
	import flash.events.Event;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class RightPanelAlarmStatisMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "RightPanelAlarmStatisMediator";
		
		public function RightPanelAlarmStatisMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			rightPanelAlarmStatis.addEventListener(RightPanelAlarmStatis.ALARMSTATIS,onStatis);
		}
		
		private function get rightPanelAlarmStatis():RightPanelAlarmStatis
		{
			return viewComponent as RightPanelAlarmStatis;
		}
		
		private function onStatis(event:Event):void
		{
			sendNotification(AppNotification.NOTIFY_ALARM_STATIS);
		}
	}
}