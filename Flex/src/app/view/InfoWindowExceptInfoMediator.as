package app.view
{
	import app.AppNotification;
	import app.model.vo.ServiceExceptVO;
	import app.view.components.InfoWindowExceptInfo;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class InfoWindowExceptInfoMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "InfoWindowExceptInfoMediator";
		
		public function InfoWindowExceptInfoMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
		}
				
		private function get infoWindowExceptInfo():InfoWindowExceptInfo
		{
			return viewComponent as InfoWindowExceptInfo;
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_LAYEREXCEPT_GRAPHICCLICK			
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{			
			switch(notification.getName())
			{
				case AppNotification.NOTIFY_LAYEREXCEPT_GRAPHICCLICK:
					infoWindowExceptInfo.info = notification.getBody() as ServiceExceptVO;
					break;
			}
		}	
	}
}