package app.view
{
	import app.AppNotification;
	import app.event.AppEvent;
	import app.view.components.MainTool;
	import app.view.components.subComponents.ImageButton;
	
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class MainToolMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "ToolBarMediator";
				
		public function MainToolMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			toolBar.addEventListener(FlexEvent.BUTTON_DOWN,onToolButtonDown);
		}
		
		private function get toolBar():MainTool
		{
			return viewComponent as MainTool;
		}
			
		private function onToolButtonDown(event:FlexEvent):void
		{
			sendNotification(AppNotification.NOTIFY_TOOLBAR,null,toolBar.tool);
		}
	}
}