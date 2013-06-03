package app.view
{
	import app.AppNotification;
	import app.event.AppEvent;
	import app.model.GPSRealTimeInfoProxy;
	import app.model.TrackHistoryProxy;
	import app.model.TrackLinebackProxy;
	import app.model.dict.DicDepartment;
	import app.model.dict.DicPatrolPoint;
	import app.model.dict.DicPatrolZone;
	import app.model.vo.AppConfigVO;
	import app.model.vo.GPSVO;
	import app.model.vo.PathVO;
	import app.model.vo.TrackHistoryVO;
	import app.view.components.MainMenu;
	import app.view.components.RightPanelServiceLineback;
	
	import com.esri.ags.SpatialReference;
	import com.esri.ags.geometry.Polygon;
	import com.esri.ags.geometry.Polyline;
	import com.esri.ags.tasks.supportClasses.BufferParameters;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.events.GridEvent;
	import spark.events.GridSelectionEvent;
	import spark.events.IndexChangeEvent;
	
	public class RightPanelServiceLinebackMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "RightPanelServiceLinebackMediator";
		
		private var trackLinebackProxy:TrackLinebackProxy;
		
		public function RightPanelServiceLinebackMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			rightPanelServiceLineback.addEventListener(RightPanelServiceLineback.PATROLZONE,onPatrolZone);
			rightPanelServiceLineback.addEventListener(RightPanelServiceLineback.PATROLPOINT,onPatrolPoint);
			
			//rightPanelServiceLineback.addEventListener(RightPanelServiceLineback.POLICECHANGE,onGridPoliceChange);
			rightPanelServiceLineback.addEventListener(RightPanelServiceLineback.POLICECLICK,onGridPoliceClick);
			rightPanelServiceLineback.addEventListener(RightPanelServiceLineback.POLICEDOUBLECLICK,onGridPoliceDoubleClick);
			
			rightPanelServiceLineback.addEventListener(RightPanelServiceLineback.PATHCLICK,onGridPatrolInfoClick);
			rightPanelServiceLineback.addEventListener(RightPanelServiceLineback.PATHDOUBLECLICK,onGridPatrolInfoDoubleClick);
			
			trackLinebackProxy = facade.retrieveProxy(TrackLinebackProxy.NAME) as TrackLinebackProxy;
		}
		
		private function get rightPanelServiceLineback():RightPanelServiceLineback
		{
			return viewComponent as RightPanelServiceLineback;
		}
				
		public function patrolZoneFilterFunction(item:DicPatrolZone):Boolean
		{
			if(rightPanelServiceLineback.listDeptItem.id != "-2")
			{
				return (item.depid == rightPanelServiceLineback.listDeptItem.id);
			}
			else
			{
				for each(var dept:DicDepartment in DicDepartment.listTraffic)
				{
					if(dept.id == item.depid)
					{
						return true;
					}
				}
			}
			
			return false;
		}	
		
		public function patrolPointFilterFunction(item:DicPatrolPoint):Boolean
		{
			if(rightPanelServiceLineback.listPatrolZoneItem == null)
				return false;
			else 
				return (item.patrolZoneID == rightPanelServiceLineback.listPatrolZoneItem.id);
		}	
										
		private function onPatrolZone(event:Event):void
		{
			if((rightPanelServiceLineback.listDeptItem != null) 
				&& (rightPanelServiceLineback.listPatrolZoneItem != null))
			{
				if(rightPanelServiceLineback.listPatrolZoneItem.polygon == null)
				{
					sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"所选巡区范围未定义！");
				}
				else 
				{		
					var tempBeginTime:Date = rightPanelServiceLineback.beginTime;
					var tempEndTime:Date = rightPanelServiceLineback.endTime;			
					var tempTimeSpan:Date = new Date(8*60*60*1000);
					var error:String = "";
					
					if(tempBeginTime.time > tempEndTime.time)
					{				
						sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"开始时间不能晚于结束时间！");
					}
					else if((tempEndTime.time - tempBeginTime.time) > tempTimeSpan.time)
					{			
						if(tempTimeSpan.date > 1)
						{
							error = (tempTimeSpan.dateUTC - 1) + "天";
						}
						else if(tempTimeSpan.hours > 0)
						{
							error = tempTimeSpan.hoursUTC + "小时";
						}
						else
						{
							error = tempTimeSpan.minutesUTC + "分钟";
						}
						sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"所选时间段不能超过" + error +"！");
					}
					else
					{
						trackLinebackProxy.getGPSTrackHistory(rightPanelServiceLineback.listDeptItem.id
							,rightPanelServiceLineback.beginTime
							,rightPanelServiceLineback.endTime
							,rightPanelServiceLineback.listPatrolZoneItem.polygon);
						
						sendNotification(AppNotification.NOTIFY_MAP_LOCATE,rightPanelServiceLineback.listPatrolZoneItem.polygon);
					}
				}
			}
			else
			{
				sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"没有选择巡区！");
			}
		}
		
		private function onPatrolPoint(event:Event):void
		{
			//var dept:DicDepartment = rightPanelServiceLineback.comboDepartment.selectedItem as DicDepartment;
			//var patrolZone:DicPatrolZone = rightPanelServiceLineback.comboPatrolZone.selectedItem as DicPatrolZone;
			//var patrolPoint:DicPatrolPoint = rightPanelServiceLineback.comboPatrolPoint.selectedItem as DicPatrolPoint;
			//var radius:Number = Number(rightPanelServiceLineback.comboRadius.textInput.text);
			if((rightPanelServiceLineback.listDeptItem != null) 
				&& (rightPanelServiceLineback.listPatrolZoneItem != null) 
				&& (rightPanelServiceLineback.listPatrolPointItem != null))
			{
				if(rightPanelServiceLineback.radius <= 0)
				{
					sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"请输入搜索半径！");
				}
				else
				{							
					
					var tempBeginTime:Date = rightPanelServiceLineback.beginTime;
					var tempEndTime:Date = rightPanelServiceLineback.endTime;			
					var tempTimeSpan:Date = new Date(8*60*60*1000);
					var error:String = "";
					
					if(tempBeginTime.time > tempEndTime.time)
					{				
						sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"开始时间不能晚于结束时间！");
					}
					else if((tempEndTime.time - tempBeginTime.time) > tempTimeSpan.time)
					{			
						if(tempTimeSpan.date > 1)
						{
							error = (tempTimeSpan.date - 1) + "天";
						}
						else if(tempTimeSpan.hours > 0)
						{
							error = tempTimeSpan.hours + "小时";
						}
						else
						{
							error = tempTimeSpan.minutes + "分钟";
						}
						sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"所选时间段不能超过" + error +"！");
					}
					else
					{
						sendNotification(AppNotification.NOTIFY_GEOMETRY_BUFF, 
							[[rightPanelServiceLineback.listPatrolPointItem.mapPoint],[rightPanelServiceLineback.radius],buffResultHandle]);
					}
				}		
			}
			else
			{
				sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"没有选择必到点！");
			}
			
			function buffResultHandle(geometrys:Array):void
			{
				var polygon:Polygon = geometrys[0] as Polygon;
				
				trackLinebackProxy.getGPSTrackHistory(rightPanelServiceLineback.listDeptItem.id
					,rightPanelServiceLineback.beginTime
					,rightPanelServiceLineback.endTime
					,polygon);
				
				sendNotification(AppNotification.NOTIFY_MAP_LOCATE,polygon);
				sendNotification(AppNotification.NOTIFY_DRAW_GEOMETRY,polygon);
			}
		}
				
		/*private function onGridPoliceChange(event:Event):void
		{
			var track:TrackHistoryVO = trackLinebackProxy.dict[rightPanelServiceLineback.listPoliceItem.gpsSimCard];
			
			rightPanelServiceLineback.listPath.removeAll();
			rightPanelServiceLineback.listPath.addAll(track.listPath);
		}*/
		
		private function onGridPoliceClick(event:Event):void
		{
			var track:TrackHistoryVO = trackLinebackProxy.dict[rightPanelServiceLineback.listPoliceItem.gpsSimCard];
			
			rightPanelServiceLineback.listPath.removeAll();
			rightPanelServiceLineback.listPath.addAll(track.listPath);
			
			sendNotification(AppNotification.NOTIFY_TRACKLINEBACK_FLASH,rightPanelServiceLineback.listPoliceItem);
		}
		
		private function onGridPoliceDoubleClick(event:Event):void
		{			
			var track:TrackHistoryVO = trackLinebackProxy.dict[rightPanelServiceLineback.listPoliceItem.gpsSimCard];
			sendNotification(AppNotification.NOTIFY_MAP_LOCATE,track.line);
		}
		
		private function onGridPatrolInfoClick(event:Event):void
		{
			sendNotification(AppNotification.NOTIFY_TRACKLINEBACK_FLASHPATH,rightPanelServiceLineback.listPathItem);
		}
		
		private function onGridPatrolInfoDoubleClick(event:Event):void
		{			
			sendNotification(AppNotification.NOTIFY_MAP_LOCATE,rightPanelServiceLineback.listPathItem.line);
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_APP_INIT,
				AppNotification.NOTIFY_MENUBAR,
				AppNotification.NOTIFY_TRACKLINEBACK_GET
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch(notification.getName())
			{
				case AppNotification.NOTIFY_APP_INIT:
					var list:ArrayCollection = new ArrayCollection;
					for each(var dept:DicDepartment in DicDepartment.list)
					{
						if(dept.ZB != 125)
						{
							list.addItem(dept);
						}
					}
					list.addItem(DicDepartment.TRAFFIC);
					
					rightPanelServiceLineback.listDept = list;
					
					if(AppConfigVO.Auth == "1")
					{
						rightPanelServiceLineback.listDeptItem = rightPanelServiceLineback.listDept[0];
					}
					else
					{
						rightPanelServiceLineback.listDeptItem = AppConfigVO.user.department;
					}					
					
					rightPanelServiceLineback.listPatrolZone = DicPatrolZone.list;
					rightPanelServiceLineback.listPatrolZone.filterFunction = patrolZoneFilterFunction;
					
					rightPanelServiceLineback.listPatrolPoint = DicPatrolPoint.list;
					rightPanelServiceLineback.listPatrolPoint.filterFunction = patrolPointFilterFunction;
										
					rightPanelServiceLineback.listPatrolZone.refresh();			
					if(rightPanelServiceLineback.listPatrolZone.length > 0)
					{
						rightPanelServiceLineback.listPatrolZoneItem = rightPanelServiceLineback.listPatrolZone[0];
					}
					
					rightPanelServiceLineback.listPatrolPoint.refresh();
					if(rightPanelServiceLineback.listPatrolPoint.length > 0)
					{
						rightPanelServiceLineback.listPatrolPointItem = rightPanelServiceLineback.listPatrolPoint[0];
					}
					break;
				
				case AppNotification.NOTIFY_MENUBAR:
					if(notification.getType() == MainMenu.SERVICELINEBACK)
					{
						rightPanelServiceLineback.endTime = new Date;
						rightPanelServiceLineback.beginTime =  new Date((new Date).time - 60*60*1000);
						
						rightPanelServiceLineback.listPolice.removeAll();
						rightPanelServiceLineback.listPath.removeAll();
					}
					break;
				
				case AppNotification.NOTIFY_TRACKLINEBACK_GET:
					rightPanelServiceLineback.listPolice.removeAll();
					rightPanelServiceLineback.listPolice.addAll(trackLinebackProxy.listGPS);
					
					rightPanelServiceLineback.listPath.removeAll();
					break;
			}
		}
	}
}