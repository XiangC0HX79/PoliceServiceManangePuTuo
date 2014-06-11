package app.view
{
	import app.AppNotification;
	import app.event.AppEvent;
	import app.model.GPSRealTimeInfoProxy;
	import app.model.dict.DicDepartment;
	import app.model.dict.DicKind;
	import app.model.dict.DicLayer;
	import app.model.dict.DicPoliceType;
	import app.model.dict.DicServiceStatus;
	import app.model.dict.DicServiceType;
	import app.model.vo.AppConfigVO;
	import app.model.vo.GPSNewVO;
	import app.view.components.MainMenu;
	import app.view.components.RightPanelServiceOverviewPT;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class RightPanelServiceOverviewPTMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "RightPanelServiceOverviewPTMediator";
		
		public function RightPanelServiceOverviewPTMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			rightPanelServiceOverview.addEventListener(RightPanelServiceOverviewPT.UPDATE,onUpdate);
		}
		
		protected function get rightPanelServiceOverview():RightPanelServiceOverviewPT
		{
			return viewComponent as RightPanelServiceOverviewPT;
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
					rightPanelServiceOverview.listServiceType = DicServiceType.listOverview;
					rightPanelServiceOverview.listServiceStatus = DicServiceStatus.listAll;
					rightPanelServiceOverview.listDept = DicDepartment.listOverview;
					
					rightPanelServiceOverview.listLayer = DicLayer.listPatrol;
										
					rightPanelServiceOverview.listKind = DicKind.listOverview;
					break;
			}
		}
	}
}