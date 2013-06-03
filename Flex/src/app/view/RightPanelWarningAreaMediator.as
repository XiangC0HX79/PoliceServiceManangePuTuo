package app.view
{
	import app.AppNotification;
	import app.model.dict.DicDepartment;
	import app.model.vo.AppConfigVO;
	import app.model.vo.WarningAreaVO;
	import app.view.components.MainMenu;
	import app.view.components.RightPanelWarningArea;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class RightPanelWarningAreaMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "RightPanelWarningAreaMediator";
		
		public function RightPanelWarningAreaMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			
			rightPanelWarningArea.addEventListener(RightPanelWarningArea.SEARCH,onSearch);
			
			rightPanelWarningArea.addEventListener(RightPanelWarningArea.GRIDCLICK,onGridExceptClick);
			rightPanelWarningArea.addEventListener(RightPanelWarningArea.GRIDDOUBLECLICK,onGridExceptDoubleClick);
		}
		
		protected function get rightPanelWarningArea():RightPanelWarningArea
		{
			return viewComponent as RightPanelWarningArea;
		}
		
		private function onSearch(event:Event = null):void
		{
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				[
					"getWarningArea",onResult,[rightPanelWarningArea.listDeptItem.id]
				]);
			
			function onResult(table:ArrayCollection):void
			{				
				rightPanelWarningArea.listExcept.removeAll();
				
				for(var i:Number = 0;i<table.length;i++)
				{
					rightPanelWarningArea.listExcept.addItem(new WarningAreaVO(table[i]));
				}
				
				sendNotification(AppNotification.NOTIFY_WARNINGAREA_REFRESH,rightPanelWarningArea.listExcept);
			}
		}
		
		private function onGridExceptClick(event:Event):void
		{
			var warning:WarningAreaVO = rightPanelWarningArea.listExceptItem as WarningAreaVO;
			if(warning != null)
				sendNotification(AppNotification.NOTIFY_WARNINGAREA_FLASH,warning);
		}
		
		private function onGridExceptDoubleClick(event:Event):void
		{			
			var warning:WarningAreaVO = rightPanelWarningArea.listExceptItem as WarningAreaVO;
			if(warning != null)
				sendNotification(AppNotification.NOTIFY_MAP_LOCATE,warning.polygon);
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
					rightPanelWarningArea.listDept = DicDepartment.listOverview;
					
					if(AppConfigVO.Auth == "1")
					{
						rightPanelWarningArea.listDeptItem = DicDepartment.ALL;
					}
					else
					{
						rightPanelWarningArea.listDeptItem = AppConfigVO.user.department;
					}
					break;
				
				case AppNotification.NOTIFY_MENUBAR:	
					if(notification.getType() == MainMenu.WARNING)
					{						
						onSearch();
					}
					break;
			}
		}
	}
}