package app.view
{
	import app.AppNotification;
	import app.event.AppEvent;
	import app.model.AlarmInfoProxy;
	import app.model.GPSRealTimeInfoProxy;
	import app.model.TrackHistoryProxy;
	import app.model.dict.DicDepartment;
	import app.model.dict.DicExceptType;
	import app.model.dict.DicPatrolZone;
	import app.model.dict.DicPoliceType;
	import app.model.vo.AlarmInfoVO;
	import app.model.vo.AppConfigVO;
	import app.model.vo.GPSNewVO;
	import app.model.vo.ServiceExceptVO;
	import app.model.vo.TrackHistoryVO;
	import app.view.components.MainMenu;
	import app.view.components.RightPanelServiceExcept;
	
	import com.esri.ags.Graphic;
	import com.esri.ags.geometry.Extent;
	import com.esri.ags.geometry.MapPoint;
	
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.events.GridEvent;
	import spark.events.IndexChangeEvent;
	
	public class RightPanelServiceExceptMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "RightPanelServiceExceptMediator";
		
		public function RightPanelServiceExceptMediator( viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			rightPanelServiceExcept.addEventListener(RightPanelServiceExcept.SEARCH,onSearch);
			
			rightPanelServiceExcept.addEventListener(RightPanelServiceExcept.GRIDCLICK,onGridExceptClick);
			rightPanelServiceExcept.addEventListener(RightPanelServiceExcept.GRIDDOUBLECLICK,onGridExceptDoubleClick);
			
			rightPanelServiceExcept.addEventListener(RightPanelServiceExcept.UPDATE,onUpdate);
		}
		
		private function get rightPanelServiceExcept():RightPanelServiceExcept
		{
			return viewComponent as RightPanelServiceExcept;
		}
						
		private function onSearch(event:Event = null):void
		{
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				[
					"getExceptService",onResult,[rightPanelServiceExcept.listDeptItem.id]
				]);
			
			function onResult(table:ArrayCollection):void
			{				
				var filter:Boolean = false;
				
				rightPanelServiceExcept.listExcept.removeAll();
				
				for each(var row:Object in table)
				{
					var serviceExcept:ServiceExceptVO = new ServiceExceptVO(row);
					
					var realTimeInfoProxy:GPSRealTimeInfoProxy = facade.retrieveProxy(GPSRealTimeInfoProxy.NAME) as GPSRealTimeInfoProxy;
					if(serviceExcept.ExceptType == DicExceptType.CROSSING)
					{
						var gps:GPSNewVO = realTimeInfoProxy.dicGPS[serviceExcept.GpsIDOrZoneID] as GPSNewVO;
						if(gps != null)
						{
							serviceExcept.GPSNameOrZoneName = gps.gpsName;
							serviceExcept.DepID = gps.departmentID;
							serviceExcept.DepName = gps.departmentNAME;
							serviceExcept.object = new MapPoint(Number(row.X),Number(row.Y));// gps;
							serviceExcept.UnNormalDesc = serviceExcept.GPSNameOrZoneName + "巡逻越界。";
							serviceExcept.gps = gps;				
							
							rightPanelServiceExcept.listExcept.addItem(serviceExcept);
						}
					}
					else if(serviceExcept.ExceptType == DicExceptType.STOPPING)
					{
						gps = realTimeInfoProxy.dicGPS[serviceExcept.GpsIDOrZoneID] as GPSNewVO;
						if(gps != null)
						{
							serviceExcept.GPSNameOrZoneName = gps.gpsName;
							serviceExcept.DepID = gps.departmentID;
							serviceExcept.DepName = gps.departmentNAME;
							serviceExcept.object = new MapPoint(Number(row.X),Number(row.Y));// gps;
							serviceExcept.UnNormalDesc = serviceExcept.GPSNameOrZoneName + "滞留时间过长。";
							serviceExcept.gps = gps;							
							
							rightPanelServiceExcept.listExcept.addItem(serviceExcept);
						}
					}
					else if(serviceExcept.ExceptType == DicExceptType.NOPATROL)
					{
						var patrolZone:DicPatrolZone = DicPatrolZone.dict[serviceExcept.GpsIDOrZoneID] as DicPatrolZone;
						if(patrolZone != null)
						{
							serviceExcept.GPSNameOrZoneName = patrolZone.label;
							serviceExcept.DepID = patrolZone.depid;
							var department:DicDepartment = DicDepartment.dict[patrolZone.depid] as DicDepartment;
							serviceExcept.DepName = (department == null)?"":department.label;
							serviceExcept.object = patrolZone.polygon;
							serviceExcept.UnNormalDesc = serviceExcept.GPSNameOrZoneName + "无人巡逻。";
														
							rightPanelServiceExcept.listExcept.addItem(serviceExcept);
						}
					}
					else if(serviceExcept.ExceptType == DicExceptType.EMERGENCY)
					{						
						gps = realTimeInfoProxy.dicGPS[serviceExcept.GpsIDOrZoneID] as GPSNewVO;
						if(gps != null)
						{
							filter = false;
							for(var i:Number =0;i<rightPanelServiceExcept.listExcept.length;i++)
							{
								var item:ServiceExceptVO = rightPanelServiceExcept.listExcept[i];
								
								if((item.GpsIDOrZoneID == serviceExcept.GpsIDOrZoneID)
									&& (item.ExceptType == DicExceptType.EMERGENCY))
								{
									if(item.ReportDateTime > serviceExcept.ReportDateTime)
									{										
										filter = true;
										break;
									}
									else
									{
										rightPanelServiceExcept.listExcept.removeItemAt(i);
										break;
									}
								}
							}
							
							if(!filter)
							{
								serviceExcept.GPSNameOrZoneName = gps.gpsName;
								serviceExcept.DepID = gps.departmentID;
								serviceExcept.DepName = gps.departmentNAME;
								serviceExcept.object = new MapPoint(Number(row.X),Number(row.Y));// gps;
								serviceExcept.UnNormalDesc = serviceExcept.GPSNameOrZoneName + "警员告警。";
								serviceExcept.gps = gps;	
								
								rightPanelServiceExcept.listExcept.addItem(serviceExcept);
							}
						}						
					}
					else if(serviceExcept.ExceptType == DicExceptType.MANUAL)
					{
						gps = realTimeInfoProxy.dicGPS[serviceExcept.GpsIDOrZoneID] as GPSNewVO;
						if(gps != null) 
						{
							filter = false;
							for(i =0;i<rightPanelServiceExcept.listExcept.length;i++)
							{
								item = rightPanelServiceExcept.listExcept[i];
								
								if((item.GpsIDOrZoneID == serviceExcept.GpsIDOrZoneID)
								&& (item.ExceptType == DicExceptType.MANUAL))
								{
									if(item.ReportDateTime > serviceExcept.ReportDateTime)
									{										
										filter = true;
										break;
									}
									else
									{
										rightPanelServiceExcept.listExcept.removeItemAt(i);
										break;
									}
								}
							}
							
							if(!filter)
							{
								serviceExcept.GPSNameOrZoneName = gps.gpsName;
								serviceExcept.DepID = gps.departmentID;
								serviceExcept.DepName = gps.departmentNAME;
								serviceExcept.object = new MapPoint(Number(row.X),Number(row.Y));// gps;
								serviceExcept.UnNormalDesc = serviceExcept.GPSNameOrZoneName + "手动修改异常。";
								serviceExcept.gps = gps;	
								
								rightPanelServiceExcept.listExcept.addItem(serviceExcept);
							}
						}
					}
				}
			}
		}
		
		private function onGridExceptClick(event:Event):void
		{
			sendNotification(AppNotification.NOTIFY_TRACKEXCEPT_FLASH,rightPanelServiceExcept.listExceptItem);
		}
		
		private function onGridExceptDoubleClick(event:Event):void
		{			
			sendNotification(AppNotification.NOTIFY_TRACKEXCEPT_LOCATE,rightPanelServiceExcept.listExceptItem);
		}
		
		private function onUpdate(event:Event):void
		{
			var s:String = "";
			for each(var item:DicExceptType in DicExceptType.list)
			{
				if(item != DicExceptType.ALL)
				{
					s += item.exceptName + "," + (item.isMonitoring?"1":"0") + ";";
				}
			}
			
			s = s.substr(0,s.length - 1);
			
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				[
					"SaveExceptMonitor"
					,onResult
					,[s]
				]);	
			
			function onResult(result:Number):void
			{
				
			}
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
					rightPanelServiceExcept.listDept = DicDepartment.listOverview;
					
					DicExceptType.ALL.isMonitoring = true;
					for each(var item:DicExceptType in DicExceptType.list)
						DicExceptType.ALL.isMonitoring &&= item.isMonitoring;
						
					rightPanelServiceExcept.exceptTypeArray = DicExceptType.list;
					
					if(AppConfigVO.Auth == "1")
					{
						rightPanelServiceExcept.listDeptItem = DicDepartment.ALL;
					}
					else
					{
						rightPanelServiceExcept.listDeptItem = AppConfigVO.user.department;
					}
					
					if(AppConfigVO.exceptMonitorArray.indexOf(Number(AppConfigVO.user.department.id)) >= 0)
						rightPanelServiceExcept.currentState = "Command";
					break;
				
				case AppNotification.NOTIFY_MENUBAR:	
					if(notification.getType() == MainMenu.SERVICEEXCEPT)
					{						
						onSearch();
					}
					break;
			}
		}
	}
}