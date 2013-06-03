package app.view
{	
	import app.AppNotification;
	import app.event.AppEvent;
	
	import flash.events.Event;
	import flash.utils.Timer;
	
	import mx.events.ResizeEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.patterns.mediator.Mediator;
		
	public class ApplicationMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "ApplicationMediator";
		
		public function ApplicationMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
						
			facade.registerMediator(new AppLoadingBarMediator(application.appLoadingBar));
			
			facade.registerMediator(new MainMapMediator(application.mainMap));
			facade.registerMediator(new RightPanelMediator(application.rightPanel));
			
			facade.registerMediator(new SubPanelMapManagerMediator(application.subPanelMapMananger));
			
			application.addEventListener(ResizeEvent.RESIZE,onApplicationResize);
			
			application.addEventListener(AppEvent.FLASHGPS,onFlashGPS);
			application.addEventListener(AppEvent.LOCATEGPS,onLocateGPS);
		}
		
		protected function get application():Main
		{
			return viewComponent as Main;
		}
		
		private function onFlashGPS(event:AppEvent):void
		{
			sendNotification(AppNotification.NOTIFY_LAYERGPS_FLASH,event.data);
		}
		
		private function onLocateGPS(event:AppEvent):void
		{
			sendNotification(AppNotification.NOTIFY_LAYERGPS_LOCATE,event.data);
		}
		
		private function onApplicationResize(event:ResizeEvent):void
		{
			sendNotification(AppNotification.NOTIFY_APP_RESIZE,[application.width,application.height]);
		}
	}
}