package app.view
{
	import app.AppNotification;
	
	import mx.controls.Alert;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class AppAlertMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "AppAlertMediator";
		
		[Embed(source="assets/image/icon_error.png")]
		private const ICON_ERROR:Class;
		
		[Embed(source="assets/image/icon_alarm.png")]
		private const ICON_ALARM:Class;
		
		[Embed(source="assets/image/icon_info.png")]
		private const ICON_INFO:Class;
		
		public function AppAlertMediator()
		{
			super(NAME, null);
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_APP_ALERTERROR,
				AppNotification.NOTIFY_APP_ALERTALARM,
				AppNotification.NOTIFY_APP_ALERTINFO
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			var info:String = "";
			
			switch(notification.getName())
			{
				case AppNotification.NOTIFY_APP_ALERTERROR:
					info = notification.getBody() as String;
					Alert.show(info,"公安勤务",4,null,null,ICON_ERROR);
					break;
				
				case AppNotification.NOTIFY_APP_ALERTALARM:
					info = notification.getBody() as String;
					Alert.show(info,"公安勤务",4,null,null,ICON_ALARM);
					break;
				
				case AppNotification.NOTIFY_APP_ALERTINFO:
					info = notification.getBody() as String;
					Alert.show(info,"公安勤务",4,null,null,ICON_INFO);
					break;
			}
		}
	}
}