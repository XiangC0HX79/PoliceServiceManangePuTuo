package app.view
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	import app.AppNotification;
	import app.model.QWPointProxy;
	import app.model.dict.DicDepartment;
	import app.model.dict.DicPointLevel;
	import app.model.dict.DicPointType;
	import app.model.vo.AppConfigVO;
	import app.model.vo.QwPointVO;
	import app.view.components.MainMenu;
	import app.view.components.RightPanelQwPoint;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class RightPanelQwPointMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "RightPanelQwPointMediator";
		
		private var qwPointProxy:QWPointProxy;
		
		public function RightPanelQwPointMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
						
			rightPanelQwPoint.addEventListener(RightPanelQwPoint.POINT_LEVEL_UPDATE,onUpdate);
			rightPanelQwPoint.addEventListener(RightPanelQwPoint.POINT_TYPE_UPDATE,onUpdate);
			
			rightPanelQwPoint.addEventListener(RightPanelQwPoint.GRIDCLICK,onGridExceptClick);
			rightPanelQwPoint.addEventListener(RightPanelQwPoint.GRIDDOUBLECLICK,onGridExceptDoubleClick);
			
			qwPointProxy = facade.retrieveProxy(QWPointProxy.NAME) as QWPointProxy;
			rightPanelQwPoint.listExcept = qwPointProxy.col;
		}
		
		protected function get rightPanelQwPoint():RightPanelQwPoint
		{
			return viewComponent as RightPanelQwPoint;
		}
		
		private function onUpdate(event:Event = null):void
		{
			qwPointProxy.update();
		}
		
		private function onGridExceptClick(event:Event):void
		{
			var qwPoint:QwPointVO = rightPanelQwPoint.listExceptItem as QwPointVO;
			if(qwPoint != null)
				sendNotification(AppNotification.NOTIFY_QWPOINT_FLASH,qwPoint);
		}
		
		private function onGridExceptDoubleClick(event:Event):void
		{			
			var qwPoint:QwPointVO = rightPanelQwPoint.listExceptItem as QwPointVO;
			if(qwPoint != null)
				sendNotification(AppNotification.NOTIFY_MAP_LOCATE,qwPoint.pt);
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_APP_INIT,
				AppNotification.NOTIFY_MENUBAR
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{			
			switch(notification.getName())
			{
				case AppNotification.NOTIFY_APP_INIT:
					rightPanelQwPoint.listPointLevel = DicPointLevel.listAll;
					rightPanelQwPoint.listPointType = DicPointType.listAll;
					break;
				
				case AppNotification.NOTIFY_MENUBAR:	
					if(notification.getType() == MainMenu.QW_POINT)
					{						
						qwPointProxy.load();
					}
					break;
			}
		}
	}
}