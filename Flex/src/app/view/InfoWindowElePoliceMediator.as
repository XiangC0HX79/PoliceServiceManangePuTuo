package app.view
{
	import app.AppNotification;
	import app.model.dict.DicElePolice;
	import app.view.components.InfoWindowElePolice;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class InfoWindowElePoliceMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "InfoWindowElePoliceMediator";
		
		public function InfoWindowElePoliceMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
		}
		
		protected function get infoWindowElePolice():InfoWindowElePolice
		{
			return viewComponent as InfoWindowElePolice;
		}		
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_LAYERELEPOLICE_GRAPHICCLICK			
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{			
			switch(notification.getName())
			{
				case AppNotification.NOTIFY_LAYERELEPOLICE_GRAPHICCLICK:
					infoWindowElePolice.elePolice = notification.getBody() as DicElePolice;
					break;
			}
		}	
	}
}