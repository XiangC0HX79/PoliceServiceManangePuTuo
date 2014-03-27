package app.view
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	import app.AppNotification;
	import app.model.dict.DicDepartment;
	import app.model.dict.DicPatrolLineType;
	import app.model.vo.AppConfigVO;
	import app.model.vo.PatrolLineVO;
	import app.view.components.MainMenu;
	import app.view.components.RightPanelPatrolLine;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class RightPanelPatrolLineMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "RightPanelPatrolLineMediator";
		
		public function RightPanelPatrolLineMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
						
			rightPanelPatrolLine.addEventListener(RightPanelPatrolLine.UPDATE,onUpdate);
			
			rightPanelPatrolLine.addEventListener(RightPanelPatrolLine.GRIDCLICK,onGridExceptClick);
			rightPanelPatrolLine.addEventListener(RightPanelPatrolLine.GRIDDOUBLECLICK,onGridExceptDoubleClick);
		}
		
		protected function get rightPanelPatrolLine():RightPanelPatrolLine
		{
			return viewComponent as RightPanelPatrolLine;
		}
		
		private function onUpdate(event:Event = null):void
		{
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
					["getPatrolLine",onPatrolLineResult,[],true]);		
		}
		
		
		private function onPatrolLineResult(result:ArrayCollection):void
		{	
			rightPanelPatrolLine.listPatrolLine.removeAll();
			
			for each(var row:Object in result)
			{
				var patrolLine:PatrolLineVO = new PatrolLineVO(row);	
				
				if(patrolLine.type && patrolLine.type.isMapShow && patrolLine.dept)
				{
					for each(var dept:DicDepartment in rightPanelPatrolLine.listDept)
					{
						if((dept.id == patrolLine.dept.id) && (dept.isMapShow))
						{
							rightPanelPatrolLine.listPatrolLine.addItem(patrolLine);
							break;							
						}
					}
				}
			}
			
			sendNotification(AppNotification.NOTIFY_PATROL_LINE_UPDATE,rightPanelPatrolLine.listPatrolLine);
		}
		
		private function onGridExceptClick(event:Event):void
		{
			var patrolLine:PatrolLineVO = rightPanelPatrolLine.listPatrolLineItem as PatrolLineVO;
			if(patrolLine != null)
				sendNotification(AppNotification.NOTIFY_PATROL_LINE_FLASH,patrolLine);
		}
		
		private function onGridExceptDoubleClick(event:Event):void
		{			
			var patrolLine:PatrolLineVO = rightPanelPatrolLine.listPatrolLineItem as PatrolLineVO;
			if(patrolLine != null)
				sendNotification(AppNotification.NOTIFY_MAP_LOCATE,patrolLine.polyline);
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
					rightPanelPatrolLine.listDept = new ArrayCollection;
															
					if(AppConfigVO.Auth == "1")
					{
						for each(var dept:DicDepartment in DicDepartment.listPolice)
						{
							rightPanelPatrolLine.listDept.addItem(dept.copy());							
						}
					}
					else
					{
						rightPanelPatrolLine.listDept.addItem(AppConfigVO.user.department.copy());
					}
					
					rightPanelPatrolLine.listPointType = DicPatrolLineType.listAll;
					break;
				
				case AppNotification.NOTIFY_MENUBAR:	
					if(notification.getType() == MainMenu.PATROL_LINE)
					{						
						onUpdate(null);
					}
					break;
			}
		}
	}
}