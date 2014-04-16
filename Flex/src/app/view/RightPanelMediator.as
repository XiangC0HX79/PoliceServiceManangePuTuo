package app.view
{
	import app.AppNotification;
	import app.model.vo.AppConfigVO;
	import app.view.components.*;
	
	import flash.events.Event;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.components.NavigatorContent;
	
	public class RightPanelMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "RightPanelMediator";
		
		public function RightPanelMediator( viewComponent:Object=null)
		{
			super(NAME, viewComponent);
						
			rightPanel.addEventListener(RightPanel.CLOSE,onClose);
		}
		
		protected function get rightPanel():RightPanel
		{
			return viewComponent as RightPanel;
		}
		
		private function onClose(event:Event):void
		{
			sendNotification(AppNotification.NOTIFY_MENUBAR,null,MainMenu.NONE);
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_MENUBAR,
				AppNotification.NOTIFY_APP_RESIZE
						];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			var navi:NavigatorContent;
			
			switch(notification.getName())
			{				
				case AppNotification.NOTIFY_MENUBAR:
					if(notification.getType() != MainMenu.NONE)
					{
						rightPanel.panelTitle = notification.getType();
						
						rightPanel.width = (rightPanel.height < RightPanel.MINH)?340:320;
						
						switch(rightPanel.panelTitle)
						{
							case MainMenu.SERVICEOVERVIEW:			
								if(AppConfigVO.district.indexOf('普陀') >= 0)
								{
									navi = facade.retrieveMediator(RightPanelServiceOverviewPTMediator.NAME).getViewComponent() as NavigatorContent;
								}
								else
								{
									navi = facade.retrieveMediator(RightPanelServiceOverviewMediator.NAME).getViewComponent() as NavigatorContent;
								}
								break;
							case MainMenu.SERVICESEARCH:								
								if(AppConfigVO.district.indexOf('奉贤') >= 0)
								{
									navi = facade.retrieveMediator(RightPanelServiceSearchFXMediator.NAME).getViewComponent() as NavigatorContent;
								}
								else if(AppConfigVO.district.indexOf('普陀') >= 0)
								{
									navi = facade.retrieveMediator(RightPanelServiceSearchPTMediator.NAME).getViewComponent() as NavigatorContent;
								}
								else
								{
									navi = facade.retrieveMediator(RightPanelServiceSearchMediator.NAME).getViewComponent() as NavigatorContent;
								}
								break;
							case MainMenu.ALARMINFO:
								if(AppConfigVO.district.indexOf('奉贤') >= 0)
								{
									navi = facade.retrieveMediator(RightPanelAlarmInfoFXMediator.NAME).getViewComponent() as NavigatorContent;
								}
								else
								{
									navi = facade.retrieveMediator(RightPanelAlarmInfoMediator.NAME).getViewComponent() as NavigatorContent;			
								}
								break;
							case MainMenu.TODAYSERVICE:
								navi = facade.retrieveMediator(RightPanelTodayServiceMediator.NAME).getViewComponent() as NavigatorContent;	
								break;
							case MainMenu.SERVICETRACKREALTIME:
								navi = facade.retrieveMediator(RightPanelServiceTrackRealtimeMediator.NAME).getViewComponent() as NavigatorContent;	
								break;
							case MainMenu.SERVICETRACKHISTORY:
								navi = facade.retrieveMediator(RightPanelServiceTrackHistoryMediator.NAME).getViewComponent() as NavigatorContent;	
								break;
							case MainMenu.SERVICECALL:
								navi = facade.retrieveMediator(RightPanelServiceCallPTMediator.NAME).getViewComponent() as NavigatorContent;
								break;
							case MainMenu.SERVICEEXCEPT:
								navi = facade.retrieveMediator(RightPanelServiceExceptMediator.NAME).getViewComponent() as NavigatorContent;	
								break;
							case MainMenu.SERVICELINEBACK:
								navi = facade.retrieveMediator(RightPanelServiceLinebackMediator.NAME).getViewComponent() as NavigatorContent;	
								break;
							
							case MainMenu.TODAYQUEST:
								navi = facade.retrieveMediator(RightPanelTodayQuestMediator.NAME).getViewComponent() as NavigatorContent;	
								break;
							case MainMenu.ALARMSTATIS:
								navi = facade.retrieveMediator(RightPanelAlarmStatisMediator.NAME).getViewComponent() as NavigatorContent;	
								break;
							case MainMenu.WARNING:
								navi = facade.retrieveMediator(RightPanelWarningAreaMediator.NAME).getViewComponent() as NavigatorContent;	
								break;
							case MainMenu.QW_POINT:
								navi = facade.retrieveMediator(RightPanelQwPointMediator.NAME).getViewComponent() as NavigatorContent;	
								break;
							case MainMenu.PATROL_LINE:
								navi = facade.retrieveMediator(RightPanelPatrolLineMediator.NAME).getViewComponent() as NavigatorContent;	
								break;
						}
												
						if(!rightPanel.viewstack1.contains(navi))
						{
							rightPanel.viewstack1.addChild(navi);									
						}
						
						rightPanel.viewstack1.selectedChild = navi;
					}					
					break;
				
				case AppNotification.NOTIFY_APP_RESIZE:
					var height:Number = notification.getBody()[1];
					
					if(rightPanel.width > 0)
					{
						rightPanel.width = (height < RightPanel.MINH)?340:320;
					}
					break;
			}
		}
	}
}