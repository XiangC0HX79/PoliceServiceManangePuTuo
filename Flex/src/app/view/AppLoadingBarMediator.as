package app.view
{
	import app.AppNotification;
	import app.model.GPSRealTimeInfoProxy;
	import app.view.components.AppLoadingBar;
	
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class AppLoadingBarMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "AppLoadingBarMediator";
				
		private var _loadingCount:Number = 0;
		
		public function AppLoadingBarMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			var contextMenu:ContextMenu=new ContextMenu();
			contextMenu.hideBuiltInItems(); 
			
			var contextMenuItem:ContextMenuItem= new ContextMenuItem("地图版本：2.4.3");			
			contextMenu.customItems.push(contextMenuItem);
			
			appLoadingBar.contextMenu=contextMenu;
		}
		
		private function get appLoadingBar():AppLoadingBar
		{
			return viewComponent as AppLoadingBar;
		}		
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_APP_LOADINGHIDE,
				AppNotification.NOTIFY_APP_LOADINGSHOW
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch(notification.getName())
			{
				case AppNotification.NOTIFY_APP_LOADINGHIDE:
					if(notification.getBody() != null)
						appLoadingBar.loadingInfo = notification.getBody() as String;	
										
					this._loadingCount--;
					
					if(this._loadingCount == 0)
					{
						appLoadingBar.visible = false;
					}
					break;
				
				case AppNotification.NOTIFY_APP_LOADINGSHOW:
					if(notification.getBody() != null)
						appLoadingBar.loadingInfo = notification.getBody() as String;	
										
					this._loadingCount++;
					
					if(this._loadingCount == 1)
					{					
						appLoadingBar.visible = true;
					}
					break;
			}
		}
	}
}