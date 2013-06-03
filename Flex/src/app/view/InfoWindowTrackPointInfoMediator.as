package app.view
{
	import app.AppNotification;
	import app.model.vo.GPSVO;
	import app.view.components.InfoWindowTrackPointInfo;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class InfoWindowTrackPointInfoMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "InfoWindowTrackPointInfoMediator";
			
		public function InfoWindowTrackPointInfoMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
		}
		
		private function get infoWindowTrackPointInfo():InfoWindowTrackPointInfo
		{
			return viewComponent as InfoWindowTrackPointInfo;
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_LAYERTRACK_POINTMOUSEOVER
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch(notification.getName())
			{
				case AppNotification.NOTIFY_LAYERTRACK_POINTMOUSEOVER:
					infoWindowTrackPointInfo.gps = notification.getBody()[0];
					break;
			}
		}
	}
}