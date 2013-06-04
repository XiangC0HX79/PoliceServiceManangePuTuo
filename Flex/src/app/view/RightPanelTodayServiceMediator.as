package app.view
{
	import app.AppNotification;
	import app.model.GPSRealTimeInfoProxy;
	import app.model.dict.DicDepartment;
	import app.model.dict.DicPoliceType;
	import app.model.dict.DicServiceType;
	import app.model.vo.AppConfigVO;
	import app.model.vo.GPSNewVO;
	import app.view.components.MainMenu;
	import app.view.components.RightPanelTodayService;
	
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	import mx.events.IndexChangedEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.components.DataGrid;
	import spark.components.NavigatorContent;
	import spark.components.gridClasses.GridColumn;
	import spark.events.GridEvent;
	import spark.events.IndexChangeEvent;
	
	public class RightPanelTodayServiceMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "RightPanelTodayServiceMediator";
		
		private var dictNavi:Dictionary = new Dictionary;
		private var dictGrid:Dictionary = new Dictionary;
		private var dictGridDataPro:Dictionary = new Dictionary;
		
		private var listServiceFilter:Dictionary = new Dictionary;
		private var listService:ArrayCollection = new ArrayCollection;
		
		public function RightPanelTodayServiceMediator( viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			rightPanelTodayService.addEventListener(RightPanelTodayService.SEARCH,onSearch);
			
			rightPanelTodayService.addEventListener(RightPanelTodayService.ACCORDIONINIT,onAccordionInit);
			
			/*rightPanelTodayService.comboDepartment.addEventListener(IndexChangeEvent.CHANGE,onChange);
			
			rightPanelTodayService.tabNavi.addEventListener(IndexChangedEvent.CHANGE,onTabChange);*/
		}
		
		private function get rightPanelTodayService():RightPanelTodayService
		{
			return viewComponent as RightPanelTodayService;
		}
		
		private function calculateChart():void
		{
			var gpsRealTimeInfoProxy:GPSRealTimeInfoProxy = facade.retrieveProxy(GPSRealTimeInfoProxy.NAME) as GPSRealTimeInfoProxy;
			var gps:GPSNewVO;
			
			var nowDate:Number = (new Date).date;
			
			var dept:DicDepartment = rightPanelTodayService.listDeptItem;	
			
			//初始化勤务图表
			var dictService:Dictionary = new Dictionary;
			var arrService:ArrayCollection = new ArrayCollection;
			for each(var serviceType:DicServiceType in DicServiceType.listService)
			{
				dictService[serviceType] = {type:serviceType.label,sum:0,normal:0};
				arrService.addItem(dictService[serviceType]);
			}
						
			for each(var item:GPSNewVO in listServiceFilter)
			{
				if(
					((dept == DicDepartment.ALL) 
						|| ((dept == DicDepartment.TRAFFIC) && (item.department != null) && (item.department.ZB == 125))
						|| (item.department == dept))
					)
					
				{
					dictService[item.serviceType].sum++;
					
					gps = gpsRealTimeInfoProxy.getPoliceByUserID(item.userId);
					if((gps != null) && (gps.gpsValid))
					{
						dictService[item.serviceType].normal++;
					}
				}
			}
			rightPanelTodayService.listService.removeAll();
			rightPanelTodayService.listService.addAll(arrService);
			
			var sum:Number = 0;
			for each(item in listService)
			{
				if((dept == DicDepartment.ALL) 
					|| ((dept == DicDepartment.TRAFFIC) && (item.department != null) && (item.department.ZB == 125))
					|| (item.department == dept))
					sum++;
			}
			rightPanelTodayService.labelSum = sum.toString();
						
			var valid:Number = 0;
			var normal:Number = 0;
			for each(item in listServiceFilter)
			{
				if((dept == DicDepartment.ALL) 
					|| ((dept == DicDepartment.TRAFFIC) && (item.department != null) && (item.department.ZB == 125))
					|| (item.department == dept))
				{
					valid++;
										
					gps = gpsRealTimeInfoProxy.getPoliceByUserID(item.userId);
					if((gps != null) && (gps.gpsValid))
					{
						normal++;
					}	
				}
			}
			rightPanelTodayService.labelValid = valid.toString();
			rightPanelTodayService.labelNormal = normal.toString();
			
			//初始化GPS图表
			var dictGPS:Dictionary = new Dictionary;
			
		//11.6 	今日勤务统计的今日GPS统计图修改为与悬浮窗信息一致分为派出所、交警、其他的实时GPS数据
		/*	for each(var policeType:DicPoliceType in DicPoliceType.list)
			{
				dictGPS[policeType] = {type:policeType.label,count:0};
			}
			
			for each(item in gpsRealTimeInfoProxy.dicGPS)
			{				
				if(
					((dept == DicDepartment.ALL) 
						|| ((dept == DicDepartment.TRAFFIC) && (item.department != null) && (item.department.ZB == 125))
						|| (item.department == dept))
					&& (item.gpsDate.date == nowDate)
					)
				{
					dictGPS[item.policeType].count++;
				}
			}*/
			
			dictGPS["交警"] = {type:"交警",count:0};
			dictGPS["派出所"] = {type:"派出所",count:0};
			dictGPS["其他"] = {type:"其他",count:0};
			
			for each(item in gpsRealTimeInfoProxy.dicGPS)
			{
				if((item.gpsValid) && (item.policeType != null))
				{					
					if(item.policeType.id != DicPoliceType.TRAFFIC.id)
					{
						if((item.department == null) || (item.department.ZB == 123))
						{
							dictGPS["其他"].count ++;
						}
						else
						{
							dictGPS["派出所"].count ++;
						}
					}
					else
					{
						dictGPS["交警"].count ++;
					}
				}
			}
			//END 11.6 	今日勤务统计的今日GPS统计图修改为与悬浮窗信息一致分为派出所、交警、其他的实时GPS数据
			
			var arrGPS:ArrayCollection = new ArrayCollection;
			for each(var o:Object in dictGPS)
			{
				arrGPS.addItem(o);
			}
			rightPanelTodayService.listGPS.removeAll();
			rightPanelTodayService.listGPS.addAll(arrGPS);
		}
		
		private function calculateTable():void
		{
			for each(var serviceType:DicServiceType in DicServiceType.listService)
			{
				(dictGridDataPro[serviceType] as ArrayCollection).removeAll();
			}
			
			//var gpsRealTimeInfoProxy:GPSRealTimeInfoProxy = facade.retrieveProxy(GPSRealTimeInfoProxy.NAME) as GPSRealTimeInfoProxy;
			var dept:DicDepartment = rightPanelTodayService.listDeptItem;		
						
			for each(var item:GPSNewVO in listService)
			{
				if(
					//(item.serviceType.label != "值班警力")
					((dept == DicDepartment.ALL) 						
						|| ((dept == DicDepartment.TRAFFIC) && (item.department != null) && (item.department.ZB == 125))
						|| (item.department == dept))
				)
					
				{
					(dictGridDataPro[item.serviceType] as ArrayCollection).addItem(item);
				}
			}
			
			for each(serviceType in DicServiceType.listService)
			{
				if(dictNavi[serviceType] != undefined)
				{
					dictNavi[serviceType].label = serviceType.label + "(" +
						(dictGridDataPro[serviceType] as ArrayCollection).length + ")";
				}
			}
		}
		
		private function onAccordionInit(event:Event):void
		{
			for each(var serviceType:DicServiceType in DicServiceType.listService)
			{
				var dataPro:ArrayCollection = dictGridDataPro[serviceType] as ArrayCollection;
				var dataGrid:DataGrid = new DataGrid;
				dictGrid[serviceType] = dataGrid;			
				
				dataGrid.dataProvider = dataPro;
				dataGrid.addEventListener(FlexEvent.CREATION_COMPLETE,handleGridCreate);
				dataGrid.doubleClickEnabled = true;
				dataGrid.setStyle("alternatingRowColors",[0xEEEEEE,0xFFFFFF]);		
				dataGrid.percentHeight = 100;
				dataGrid.percentWidth = 100;
				
				dataGrid.columns = new ArrayCollection;
				
				var gridColumn:GridColumn = new GridColumn("姓名");
				gridColumn.dataField = "gpsName";
				dataGrid.columns.addItem(gridColumn);
				
				gridColumn = new GridColumn("警号");
				gridColumn.dataField = "policeNo";
				dataGrid.columns.addItem(gridColumn);
				
				gridColumn = new GridColumn("班次");
				gridColumn.dataField = "runName";
				dataGrid.columns.addItem(gridColumn);
				
				if(serviceType.label == "值班警力")
				{
					gridColumn = new GridColumn("类型");
					gridColumn.dataField = "dutyNote";
					dataGrid.columns.addItem(gridColumn);
				}
				else
				{
					gridColumn = new GridColumn("状态");
					gridColumn.dataField = "serviceStatusName";
					dataGrid.columns.addItem(gridColumn);
				}
				
				var navi:NavigatorContent = new NavigatorContent;
				navi.label = serviceType.label + "(" +
					(dictGridDataPro[serviceType] as ArrayCollection).length + ")"
				navi.addElement(dataGrid);				
				
				rightPanelTodayService.accordion.addChild(navi);
				
				dictNavi[serviceType] = navi;	
				
				navi.percentHeight = 100;
				navi.percentWidth = 100;
			}
		}
		
		private function handleGridCreate(event:FlexEvent):void
		{
			var grid:DataGrid = event.currentTarget as DataGrid;
			grid.addEventListener(GridEvent.GRID_CLICK,handleGridClick);
			grid.addEventListener(GridEvent.GRID_DOUBLE_CLICK,handleGridDoubleClick);
		}
				
		private function handleGridClick(event:GridEvent):void
		{			
			if(event.item != null)
			{
				var gpsStatic:GPSNewVO = event.item as GPSNewVO;
				var gpsRealTimeInfoProxy:GPSRealTimeInfoProxy = facade.retrieveProxy(GPSRealTimeInfoProxy.NAME) as GPSRealTimeInfoProxy;
				var gps:GPSNewVO = gpsRealTimeInfoProxy.getPoliceByUserID(gpsStatic.userId);
				
				if(gps != null)
					sendNotification(AppNotification.NOTIFY_LAYERGPS_FLASH,gps);
			}
		}
		
		private function handleGridDoubleClick(event:GridEvent):void
		{
			if(event.item != null)
			{
				var gpsStatic:GPSNewVO = event.item as GPSNewVO;
				var gpsRealTimeInfoProxy:GPSRealTimeInfoProxy = facade.retrieveProxy(GPSRealTimeInfoProxy.NAME) as GPSRealTimeInfoProxy;
				var gps:GPSNewVO = gpsRealTimeInfoProxy.getPoliceByUserID(gpsStatic.userId);
				
				if(gps != null)
					sendNotification(AppNotification.NOTIFY_LAYERGPS_LOCATE,gps);
			}
		}
		
		private function onSearch(event:Event = null):void
		{
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["getServiceStatic",onResult,[]]);	
			
			function onResult(result:ArrayCollection):void
			{		
				listServiceFilter = new Dictionary;
				listService = new ArrayCollection;
				
				for(var i:Number = 0;i<result.length;i++)
				{
					var gps:GPSNewVO = new GPSNewVO(result[i]);
					if(listServiceFilter[gps.userId] != undefined)
					{
						if(gps.serviceType.label != "值班警力")
						{
							listServiceFilter[gps.userId] = gps;
						}
					}
					else
					{
						listServiceFilter[gps.userId] = gps;
					}
					
					listService.addItem(gps);
				}
				
				if(rightPanelTodayService.tabNaviIndex == 0)
				{
					calculateChart();
				}
				else
				{
					calculateTable();
				}
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
					rightPanelTodayService.listDept = DicDepartment.listPolice;
					
					if(AppConfigVO.Auth == "0")
					{
						rightPanelTodayService.listDeptItem = DicDepartment.dict[AppConfigVO.user.departmentID];
					}
					else
					{
						rightPanelTodayService.listDeptItem = DicDepartment.ALL;
					}
					
					for each(var serviceType:DicServiceType in DicServiceType.listService)
					{
						dictGridDataPro[serviceType] = new ArrayCollection;	
					}
					break;
				
				case AppNotification.NOTIFY_MENUBAR:
					if(notification.getType() == MainMenu.TODAYSERVICE)
					{
						rightPanelTodayService.tabNaviIndex = 0;
						
						onSearch();
					}
					break;
			}
		}
	}
}