package app.view
{
	import app.AppNotification;
	import app.model.dict.DicDepartment;
	import app.model.dict.DicPatrolPoint;
	import app.view.components.InfoWindowPatrolPoint;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class InfoWindowPatrolPointMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "InfoWindowPatrolPointMediator";
		
		public function InfoWindowPatrolPointMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
		}
		
		protected function get infoWindowPatrolPoint():InfoWindowPatrolPoint
		{
			return viewComponent as InfoWindowPatrolPoint;
		}		
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_LAYERPATROPOINT_GRAPHICCLICK			
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{	
			switch(notification.getName())
			{
				case AppNotification.NOTIFY_LAYERPATROPOINT_GRAPHICCLICK:
					infoWindowPatrolPoint.patrolPoint = notification.getBody() as DicPatrolPoint;
					infoWindowPatrolPoint.dept = DicDepartment.dict[infoWindowPatrolPoint.patrolPoint.depId];
					break;
			}
		}	
	}
}