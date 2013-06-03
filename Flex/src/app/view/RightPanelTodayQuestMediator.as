package app.view
{
	import app.AppNotification;
	import app.model.GPSRealTimeInfoProxy;
	import app.model.vo.TaskPoliceVO;
	import app.model.vo.TaskVO;
	import app.view.components.MainMenu;
	import app.view.components.RightPanelTodayQuest;
	import app.view.components.subComponents.NaviPolice;
	import app.view.components.subComponents.NaviTask;
	
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.collections.Sort;
	
	public class RightPanelTodayQuestMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "RightPanelTodayQuestMediator";
		
		public function RightPanelTodayQuestMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			rightPanelTodayQuest.addEventListener(RightPanelTodayQuest.TABCHANGE,onTabChange);
		}
		
		private function get rightPanelTodayQuest():RightPanelTodayQuest
		{
			return viewComponent as RightPanelTodayQuest;
		}
		
		private function onTabChange(event:Event):void
		{
			var naviTask:NaviTask = rightPanelTodayQuest.tabNavi.selectedChild as NaviTask;
			if(naviTask != null)
			{
				initPolice(naviTask);
			}
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_MENUBAR
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch(notification.getName())
			{
				case AppNotification.NOTIFY_MENUBAR:
					if(notification.getType() == MainMenu.TODAYQUEST)
					{
						initTab();
					}
					break;
			}
		}
		
		private function initTab():void
		{			
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["getNewTask",onResult,[]]);	
			
			function onResult(result:ArrayCollection):void
			{		
				rightPanelTodayQuest.list.removeAll();
				
				rightPanelTodayQuest.tabNavi.removeAll();
				
				if(result.length == 0)
				{					
					var naviTask:NaviTask = new NaviTask;
					naviTask.label = "没有任务";
					rightPanelTodayQuest.tabNavi.addChild(naviTask);
				}
				else
				{
					for each(var item:Object in result)
					{
						var task:TaskVO = new TaskVO(item); 
						rightPanelTodayQuest.list.addItem(task);
						
						naviTask = new NaviTask;
						naviTask.task = task;
						
						rightPanelTodayQuest.tabNavi.addChild(naviTask);
						
						initPolice(naviTask);
					}
				}
			}
		}
		
		private function initPolice(naviTask:NaviTask):void
		{			
			var gpsProxy:GPSRealTimeInfoProxy = facade.retrieveProxy(GPSRealTimeInfoProxy.NAME) as GPSRealTimeInfoProxy;
			
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["getNewTaskPolice",onResult,[naviTask.task.taskID]]);	
			
			function onResult(result:ArrayCollection):void
			{		
				for(var i:Number = 0;i<naviTask.task.listPolice.length;i++)
					naviTask.task.listPolice.pop();
				
				naviTask.accordion.removeAllChildren();
				
				for each(var item:Object in result)
				{					
					if(item.USERID != undefined)
					{
						var taskPolice:TaskPoliceVO = new TaskPoliceVO(item);
						taskPolice.gps = gpsProxy.getPoliceByUserID(taskPolice.userID);
						
						naviTask.task.listPolice.push(taskPolice);
					}
				}
				
				naviTask.policeCount = naviTask.task.listPolice.length;
				
				naviTask.task.listPolice.sortOn("deptID",Array.NUMERIC);
				
				for(var key:String in naviTask.task.dictPolice)
				{
					var arr:ArrayCollection = naviTask.task.dictPolice[key] as ArrayCollection;
					
					var naviPolice:NaviPolice = new NaviPolice;
					naviPolice.list = arr;
					naviPolice.label = key + "(" + arr.length + ")";
					
					naviTask.accordion.addChild(naviPolice);
				}
			}
			
			function compareFunction(a:TaskPoliceVO, b:TaskPoliceVO, fields:Array = null):int
			{
				if(a.deptID < b.deptID)
					return 1;
				else
					return -1;
			}
		}
	}
}