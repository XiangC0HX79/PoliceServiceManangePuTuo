package app.view
{
	import app.AppNotification;
	import app.event.AppEvent;
	import app.view.components.MainMenu;
	import app.view.components.subComponents.ImageButton;
	
	import flash.events.Event;
	
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.components.Button;
	import spark.components.ButtonBar;
	import spark.events.IndexChangeEvent;
	
	public class MainMenuMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "MenuBarMediator";
		
		public function MainMenuMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			menuBar.addEventListener(MainMenu.MENUCLICK,onMenuClick);
		}
		
		protected function get menuBar():MainMenu
		{
			return viewComponent as MainMenu;
		}
		
		private function onMenuClick(event:Event):void
		{
			sendNotification(AppNotification.NOTIFY_MENUBAR,null,menuBar.menu);
		}
		
		override public function listNotificationInterests():Array
		{
			return [
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{			
			switch(notification.getName())
			{			
			}
		}
	}
}