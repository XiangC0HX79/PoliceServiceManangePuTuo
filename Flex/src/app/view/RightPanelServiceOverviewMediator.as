package app.view
{
	import app.AppNotification;
	import app.event.AppEvent;
	import app.model.dict.DicDepartment;
	import app.model.dict.DicLayer;
	import app.model.dict.DicPoliceType;
	import app.model.dict.DicServiceStatus;
	import app.model.dict.DicServiceType;
	import app.model.vo.AppConfigVO;
	import app.view.components.RightPanelServiceOverview;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class RightPanelServiceOverviewMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "RightPanelServiceOverviewMediator";
		
		public function RightPanelServiceOverviewMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			rightPanelServiceOverview.addEventListener(RightPanelServiceOverview.UPDATE,onUpdate);
		}
		
		protected function get rightPanelServiceOverview():RightPanelServiceOverview
		{
			return viewComponent as RightPanelServiceOverview;
		}
				
		private function onUpdate(event:Event):void
		{
			sendNotification(AppNotification.NOTIFY_OVERVIEW_SET);
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_APP_INIT
				];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch(notification.getName())
			{
				case AppNotification.NOTIFY_APP_INIT:
					rightPanelServiceOverview.listPoliceType = DicPoliceType.list;					
					rightPanelServiceOverview.listServiceType = DicServiceType.listOverview;
					rightPanelServiceOverview.listServiceStatus = DicServiceStatus.listAll;
					rightPanelServiceOverview.listDept = DicDepartment.listOverview;
					
					rightPanelServiceOverview.listLayer = DicLayer.listPatrol;
					break;
			}
		}
	}
}