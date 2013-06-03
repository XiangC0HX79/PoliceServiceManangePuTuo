package app.view
{
	import app.AppNotification;
	import app.model.dict.DicDepartment;
	import app.model.dict.DicPatrolZone;
	import app.view.components.InfoWindowAlarmStatis;
	
	import flash.events.Event;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class InfoWindowAlarmStatisMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "";
		
		public function InfoWindowAlarmStatisMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			infoWindowAlarmStatis.addEventListener(InfoWindowAlarmStatis.DIS,onDis);
		}
		
		private function get infoWindowAlarmStatis():InfoWindowAlarmStatis
		{
			return viewComponent as InfoWindowAlarmStatis;
		}
		
		private function onDis(event:Event):void
		{
			sendNotification(AppNotification.NOTIFY_ALARM_STATISDIS,infoWindowAlarmStatis.alarmStatis);
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_ALARM_STATISCLICK
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{			
			switch(notification.getName())
			{				
				case AppNotification.NOTIFY_ALARM_STATISCLICK:
					var alarmStatis:DicPatrolZone = notification.getBody() as DicPatrolZone;
					
					infoWindowAlarmStatis.alarmStatis = alarmStatis;
					
					infoWindowAlarmStatis.deptName = alarmStatis.depid;
					infoWindowAlarmStatis.statisName = alarmStatis.label;
										
					var index:Number = Number(alarmStatis.id);					
					switch(index % 4)
					{
						case 0:
							infoWindowAlarmStatis.level = "本色预警";
							break;
						case 1:
							infoWindowAlarmStatis.level = "橙色预警";
							break;
						case 2:
							infoWindowAlarmStatis.level = "红色预警";
							break;
						case 3:
							infoWindowAlarmStatis.level = "黑色预警";
							break;
					}
					
					break;
			}
		}
	}
}