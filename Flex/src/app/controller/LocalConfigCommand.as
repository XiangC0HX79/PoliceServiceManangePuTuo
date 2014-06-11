package app.controller
{
	import com.esri.ags.FeatureSet;
	import com.esri.ags.Graphic;
	import com.esri.ags.events.LayerEvent;
	import com.esri.ags.geometry.Extent;
	import com.esri.ags.geometry.Geometry;
	import com.esri.ags.geometry.Polygon;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	import app.AppNotification;
	import app.model.GPSRealTimeInfoProxy;
	import app.model.dict.DicAlarmType;
	import app.model.dict.DicDepartment;
	import app.model.dict.DicElePolice;
	import app.model.dict.DicExceptType;
	import app.model.dict.DicGPSImage;
	import app.model.dict.DicKind;
	import app.model.dict.DicPatrolLineType;
	import app.model.dict.DicPatrolPoint;
	import app.model.dict.DicPatrolType;
	import app.model.dict.DicPatrolZone;
	import app.model.dict.DicPointLevel;
	import app.model.dict.DicPointType;
	import app.model.dict.DicPoliceType;
	import app.model.dict.DicRoad;
	import app.model.dict.DicServiceStatus;
	import app.model.dict.DicServiceType;
	import app.model.vo.AlarmPoliceVO;
	import app.model.vo.AppConfigVO;
	import app.model.vo.GPSNewVO;
	import app.model.vo.GPSVO;
	import app.model.vo.ServiceExceptVO;
	import app.view.RightPanelAlarmInfoFXMediator;
	import app.view.RightPanelAlarmInfoMediator;
	import app.view.RightPanelAlarmStatisMediator;
	import app.view.RightPanelPatrolLineMediator;
	import app.view.RightPanelQwPointMediator;
	import app.view.RightPanelServiceCallMediator;
	import app.view.RightPanelServiceCallPTMediator;
	import app.view.RightPanelServiceExceptMediator;
	import app.view.RightPanelServiceLinebackMediator;
	import app.view.RightPanelServiceOverviewMediator;
	import app.view.RightPanelServiceOverviewPTMediator;
	import app.view.RightPanelServiceSearchFXMediator;
	import app.view.RightPanelServiceSearchMediator;
	import app.view.RightPanelServiceSearchPTMediator;
	import app.view.RightPanelServiceTrackHistoryMediator;
	import app.view.RightPanelServiceTrackRealtimeMediator;
	import app.view.RightPanelTodayQuestMediator;
	import app.view.RightPanelTodayServiceMediator;
	import app.view.RightPanelWarningAreaMediator;
	import app.view.components.RightPanelAlarmInfo;
	import app.view.components.RightPanelAlarmInfoFX;
	import app.view.components.RightPanelAlarmStatis;
	import app.view.components.RightPanelPatrolLine;
	import app.view.components.RightPanelQwPoint;
	import app.view.components.RightPanelServiceCall;
	import app.view.components.RightPanelServiceCallFX;
	import app.view.components.RightPanelServiceCallPT;
	import app.view.components.RightPanelServiceExcept;
	import app.view.components.RightPanelServiceLineback;
	import app.view.components.RightPanelServiceOverview;
	import app.view.components.RightPanelServiceOverviewPT;
	import app.view.components.RightPanelServiceSearch;
	import app.view.components.RightPanelServiceSearchFX;
	import app.view.components.RightPanelServiceSearchPT;
	import app.view.components.RightPanelServiceTrackHistory;
	import app.view.components.RightPanelServiceTrackRealtime;
	import app.view.components.RightPanelTodayQuest;
	import app.view.components.RightPanelTodayService;
	import app.view.components.RightPanelWarningArea;
	
	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class LocalConfigCommand extends SimpleCommand implements ICommand
	{
		private static const INITCOUNT:Number = 13;
		private static var init:Number = 0;
		
		private var arrGPSTemp:ArrayCollection = new ArrayCollection;
		
		private var dictUnitArea:Dictionary;
		
		override public function execute(note:INotification):void
		{			
			sendNotification(AppNotification.NOTIFY_APP_LOADINGSHOW,"系统初始化：加载本地配置...");
				
			var request:URLRequest = new URLRequest("config.xml");
			var load:URLLoader = new URLLoader(request);
			load.addEventListener(Event.COMPLETE,onLocaleConfigResult);
			load.addEventListener(IOErrorEvent.IO_ERROR,onIOError);
		}
		
		private function appInit():void
		{
			if(++init == INITCOUNT)
			{				
				//单位初始信息
				for each(var department:DicDepartment in DicDepartment.listOverview)
				{				
					department.isGisShow = (AppConfigVO.Auth == "1")
						|| (department.id == AppConfigVO.user.departmentID);
					
					department.isMapShow = department.isGisShow;
					
					var grUnit:Graphic = dictUnitArea[department.label + "辖区"] as Graphic;
					if(grUnit != null)
					{
						department.polygon = grUnit.geometry as Polygon;
					}
				}
				
				//交警初始可见性				
				/*DicDepartment.TRAFFIC.isGisShow = ((AppConfigVO.Auth == "0")
					&& (AppConfigVO.user.department != null)
					&& (AppConfigVO.user.department.ZB == 125));*/
				DicDepartment.TRAFFIC.isGisShow = true;
				DicDepartment.TRAFFIC.isMapShow = DicDepartment.TRAFFIC.isGisShow;
				
				DicDepartment.ALL.isGisShow = false;
				DicDepartment.ALL.isMapShow = DicDepartment.ALL.isGisShow;
				
				for each(department in DicDepartment.listTraffic)
				{				
					department.isGisShow = DicDepartment.TRAFFIC.isGisShow;
					department.isMapShow = department.isGisShow;					
				}
				
				
				//巡区初始信息
				if(AppConfigVO.Auth == "0")
				{
					for each(var patrolZone:DicPatrolZone in DicPatrolZone.list)
					{
						if(patrolZone.depid != AppConfigVO.user.departmentID)
						{
							delete DicPatrolZone.dict[patrolZone.id];
						}
					}
					
					for each(var patrolPoint:DicPatrolPoint in DicPatrolPoint.list)
					{						
						if(DicPatrolZone.dict[patrolPoint.patrolZoneID] == undefined)
						{
							delete DicPatrolPoint.dict[patrolPoint.id];
						}
					}
				}
								
				//GPS初始信息
				var gpsPrxoy:GPSRealTimeInfoProxy = 
					facade.retrieveProxy(GPSRealTimeInfoProxy.NAME) as GPSRealTimeInfoProxy;
				for(var i:Number = 0;i<arrGPSTemp.length;i++)
				{
					var gps:GPSNewVO = new GPSNewVO(arrGPSTemp[i]);
					
					if((gps.inService) && (gps.serviceType.label == "值班警力"))
					{
						gpsPrxoy.dicDuty[gps.gpsSimCard] = gps;
					}
					
					gpsPrxoy.refresh(gps);
				}
								
				sendNotification(AppNotification.NOTIFY_APP_INIT);
			}
		}
		
		private function onIOError(event:IOErrorEvent):void
		{
			sendNotification(AppNotification.NOTIFY_APP_ALERTERROR,event.text);
		}
		
		private function onLocaleConfigResult(event:Event):void
		{				
			try
			{
				var xml:XML = new XML(event.currentTarget.data);
			}
			catch(e:Object)
			{
				trace(e);
			}
			
			if(xml == null)
			{
				sendNotification(AppNotification.NOTIFY_APP_ALERTERROR,"配置文件损坏，请检查config.xml文件正确性！");
				
				sendNotification(AppNotification.NOTIFY_APP_LOADINGSHOW,"程序初始化：本地配置加载失败！");	
				return;
			}
			
			AppConfigVO.debug = (xml.AppConfig.Debug == "1");
			
			AppConfigVO.district = xml.AppConfig.District;
			
			for each(var mapUrl:XML in xml.MapConfig.MapUrl)
			{
				AppConfigVO.mapServerArr.push(String(mapUrl));
			}
			AppConfigVO.mapServerUrl = AppConfigVO.mapServerArr[0];
			
			for each(var moduleHide:XML in xml.AppConfig.ModuleHide)
			{
				AppConfigVO.moduleHideArr.push(String(moduleHide));
			}
			
			AppConfigVO.mapName = xml.MapConfig.MapName;
			
			AppConfigVO.webServiceUrl = xml.AppConfig.WebServiceUrl;
						
			var n:Number;
			if(xml.AppConfig.Scale != undefined)
			{
				for each(var s:String in String(xml.AppConfig.Scale).split("/"))
				{
					n = Number(s);
					if(!isNaN(n) && (n > 0))
						AppConfigVO.arrScale.push(n);
					else 
						AppConfigVO.arrScale.push(1);
				}
			}
			
			if(xml.AppConfig.ScaleVisible != undefined)
			{
				AppConfigVO.scaleVisible = Number(String(xml.AppConfig.ScaleVisible));
			}
			
			if(xml.AppConfig.ExceptMonitor != undefined)
			{
				for each(s in String(xml.AppConfig.ExceptMonitor).split("/"))
				{
					n = Number(s);
					if(!isNaN(n) && (n > 0))
						AppConfigVO.exceptMonitorArray.push(n);
				}
			}
			
			n = Number(xml.AppConfig.Image.Vehicle.@w);
			if(!isNaN(n) && (n > 0))
				DicGPSImage.VEHICLE_W = n;
			n = Number(xml.AppConfig.Image.Vehicle.@h);
			if(!isNaN(n) && (n > 0))
				DicGPSImage.VEHICLE_H = n;
			n = Number(xml.AppConfig.Image.People.@w);
			if(!isNaN(n) && (n > 0))
				DicGPSImage.PEOPLE_W = n;
			n = Number(xml.AppConfig.Image.People.@h);
			if(!isNaN(n) && (n > 0))
				DicGPSImage.PEOPLE_H = n;
			n = Number(xml.AppConfig.Image.Status.@w);
			if(!isNaN(n) && (n > 0))
				DicGPSImage.STATUS_W = n;
			n = Number(xml.AppConfig.Image.Status.@h);
			if(!isNaN(n) && (n > 0))
				DicGPSImage.STATUS_H = n;
												
			//初始化PoliceType
			DicPoliceType.dict[DicPoliceType.VEHICLE.id] = DicPoliceType.VEHICLE;
			DicPoliceType.dict[DicPoliceType.PEOPLE.id] = DicPoliceType.PEOPLE;
			DicPoliceType.dict[DicPoliceType.TRAFFIC.id] = DicPoliceType.TRAFFIC;
			DicPoliceType.dict[DicPoliceType.SPECIAL.id] = DicPoliceType.SPECIAL;
			
			//初始化面板
			initRightPanel();			
			
			//初始化地图
			sendNotification(AppNotification.NOTIFY_APP_LOADINGSHOW);
			sendNotification(AppNotification.NOTIFY_INIT_MAP,onMapLoad);
			
			//验证权限
			sendNotification(AppNotification.NOTIFY_APP_LOADINGSHOW);			
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["getAuth",onAuthResult,[AppConfigVO.userid],false]);
			
			//加载系统配置
			sendNotification(AppNotification.NOTIFY_APP_LOADINGSHOW);
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["getSysConfig",onSysConfigResult,[],false]);
			
			//加载系统字典
			sendNotification(AppNotification.NOTIFY_APP_LOADINGSHOW);
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["getSysDic",onSysDicResult,[],false,"e4x"]);	
			
			//加载勤务类型字典			
			sendNotification(AppNotification.NOTIFY_APP_LOADINGSHOW);
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["getServiceDic",onServiceDicResult,[],false]);
			
			//加载单位字典
			sendNotification(AppNotification.NOTIFY_APP_LOADINGSHOW);
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["getDepartmentInfo",onDepartmentInfoResult,[],false]);
			
			//加载警情类型字典
			sendNotification(AppNotification.NOTIFY_APP_LOADINGSHOW);
			if(AppConfigVO.district.indexOf('奉贤') >= 0)
				sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
					["getAlarmTypeInfoFX",onAlarmTypeInfoResult,[],false]);
			else
				sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
					["getAlarmTypeInfo",onAlarmTypeInfoResult,[],false]);
			
			//加载巡区数据
			sendNotification(AppNotification.NOTIFY_APP_LOADINGSHOW);
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["getPatrolZone",onPatrolZoneResult,[],false]);		
			
			//加载卡点类型
			sendNotification(AppNotification.NOTIFY_APP_LOADINGSHOW);
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["GetQwPointType",onGetQwPointTypeResult,[],false]);		
			
			//加载卡点数据
			sendNotification(AppNotification.NOTIFY_APP_LOADINGSHOW);
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["getPatrolPoint",onPatrolPointResult,[],false]);	
			
			//加载电子警察数据
			if(AppConfigVO.district.indexOf('奉贤') >= 0)
				sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
					["getElePolice",onElePoliceResult,[],false]);
			else
				appInit();
				
				
			//初始化GPS数据
			sendNotification(AppNotification.NOTIFY_APP_LOADINGSHOW);
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["getGPSRealTimeInfo",onGPSResult,["","1"],false]);	
			
			sendNotification(AppNotification.NOTIFY_APP_LOADINGHIDE,"程序初始化：本地配置加载完成！");		
		}
		
		private function initRightPanel():void
		{			
			facade.registerMediator(new RightPanelTodayServiceMediator(new RightPanelTodayService));
			facade.registerMediator(new RightPanelServiceTrackRealtimeMediator(new RightPanelServiceTrackRealtime));
			facade.registerMediator(new RightPanelServiceTrackHistoryMediator(new RightPanelServiceTrackHistory));	
			facade.registerMediator(new RightPanelServiceExceptMediator(new RightPanelServiceExcept));
			facade.registerMediator(new RightPanelServiceLinebackMediator(new RightPanelServiceLineback));			
			facade.registerMediator(new RightPanelTodayQuestMediator(new RightPanelTodayQuest));
			facade.registerMediator(new RightPanelAlarmStatisMediator(new RightPanelAlarmStatis));
			facade.registerMediator(new RightPanelWarningAreaMediator(new RightPanelWarningArea));
			facade.registerMediator(new RightPanelQwPointMediator(new RightPanelQwPoint));
			facade.registerMediator(new RightPanelPatrolLineMediator(new RightPanelPatrolLine));			
			facade.registerMediator(new RightPanelServiceOverviewPTMediator(new RightPanelServiceOverviewPT));
			facade.registerMediator(new RightPanelAlarmInfoMediator(new RightPanelAlarmInfo));				
			facade.registerMediator(new RightPanelServiceCallPTMediator(new RightPanelServiceCallPT));
			facade.registerMediator(new RightPanelServiceSearchPTMediator(new RightPanelServiceSearchPT));	
		}
		
		private function onMapLoad(event:LayerEvent):void
		{						
			sendNotification(AppNotification.NOTIFY_APP_LOADINGHIDE,"程序初始化：地图加载完成！");
			
			sendNotification(AppNotification.NOTIFY_APP_LOADINGSHOW);
			sendNotification(AppNotification.NOTIFY_LAYERTILE_QUERY,
				[
					"派出所辖区",
					"",
					["名称"]
					,queryUnitAreaResultHandle,true,false
				]);
			
			sendNotification(AppNotification.NOTIFY_APP_LOADINGSHOW);
			sendNotification(AppNotification.NOTIFY_LAYERTILE_QUERY,
				[
					"行政区",
					"名称  = '" + AppConfigVO.district + "'",
					[]
					,queryDistrictResultHandle,true,false
				]);
			
			function queryUnitAreaResultHandle(featureSet:FeatureSet):void
			{
				dictUnitArea = new Dictionary;
				for each(var graphic:Graphic in featureSet.features)
				{
					dictUnitArea[graphic.attributes["名称"]] = graphic;
				}
				
				sendNotification(AppNotification.NOTIFY_APP_LOADINGHIDE);
				appInit();
			}
			
			function queryDistrictResultHandle(featureSet:FeatureSet):void
			{
				if(featureSet.features.length > 0)
				{
					AppConfigVO.districtGeometry = featureSet.features[0].geometry;
					
					sendNotification(AppNotification.NOTIFY_LAYERTILE_QUERY,
						[
							"道路中心线",
							"OBJECTID > 0 AND OBJECTID <= 500",
							['名称','首拼','全名首拼','拼音全称 ','类别','左起门牌','左止门牌','右起门牌','右止门牌']
							,queryRoadResultHandle,false,false,AppConfigVO.districtGeometry
						]);
				}
				else
				{
					sendNotification(AppNotification.NOTIFY_APP_ALERTERROR,"未找到所属行政区，无法读取道路信息，请检查地图配置文件！");
				}
			}
			
			var endOfRecord:Boolean = false;
			var pageCount:Number = 1;
			function queryRoadResultHandle(featureSet:FeatureSet):void
			{
				for each(var graphic:Graphic in featureSet.features)
				{
					DicRoad.dict[graphic.attributes["名称"]] = new DicRoad(graphic);
				}
				
				endOfRecord = (featureSet.features.length == 0);
				
				if(!endOfRecord)
				{
					sendNotification(AppNotification.NOTIFY_LAYERTILE_QUERY,
						[
							"道路中心线",
							"OBJECTID > " + (pageCount*500).toString() + " AND OBJECTID <= " + ((pageCount + 1)*500).toString(),
							['名称','首拼','全名首拼','拼音全称 ','类别','左起门牌','左止门牌','右起门牌','右止门牌']
							,queryRoadResultHandle,false,false,AppConfigVO.districtGeometry
						]);
					
					pageCount++;
				}
				else
				{
					sendNotification(AppNotification.NOTIFY_APP_LOADINGHIDE);
					appInit();
				}
			}
		}
		
		private function onAuthResult(result:ArrayCollection):void
		{			
			if(result.length == 0)				
			{					
				sendNotification(AppNotification.NOTIFY_APP_ALERTERROR,"未找到登录用户，请更换用户名重新登录。");
				
				sendNotification(AppNotification.NOTIFY_APP_LOADINGSHOW,"程序初始化：权限验证失败！");	
			}
			else
			{				
				AppConfigVO.user = new GPSVO(result[0]);
				
				sendNotification(AppNotification.NOTIFY_APP_LOADINGHIDE,"程序初始化：权限验证成功！");	
				
				appInit();
			}		
		}
		
		private function onSysDicResult(result:XML):void
		{								 
			var xmlList:XMLList = result.descendants("Table");
			//勤务状态			
			DicServiceStatus.dict[DicServiceStatus.ALL.id] = DicServiceStatus.ALL;
			for each(var item:XML in xmlList.(PDICID == 19))
			{
				var serviceStatus:DicServiceStatus = new DicServiceStatus(item);
				DicServiceStatus.dict[serviceStatus.id] = serviceStatus;
			}
			//执勤类型
			for each(item in xmlList.(PDICID == 158))
			{
				var patorl:DicPatrolType = new DicPatrolType(item);
				DicPatrolType.dict[patorl.id] = patorl;
			}
			//卡点等级
			/*DicPointLevel.dict[DicPointLevel.ALL.id] = DicPointLevel.ALL;
			for each(item in xmlList.(PDICID == 353))
			{
				var pointLevel:DicPointLevel = new DicPointLevel(item);
				DicPointLevel.dict[pointLevel.id] = pointLevel;
			}*/
			//卡点类型
			/*DicPointType.dict[DicPointType.ALL.id] = DicPointType.ALL;
			for each(item in xmlList.(PDICID == 352))
			{
				var piontType:DicPointType = new DicPointType(item);
				DicPointType.dict[piontType.id] = piontType;
			}*/
			//巡线类型
			DicPatrolLineType.dict[DicPatrolLineType.ALL.id] = DicPatrolLineType.ALL;
			for each(item in xmlList.(PDICID == 359))
			{
				var patrolLineType:DicPatrolLineType = new DicPatrolLineType(item);
				DicPatrolLineType.dict[patrolLineType.id] = patrolLineType;
			}
			//警种
			for each(item in xmlList.(PDICID == 181))
			{
				var dicKind:DicKind = new DicKind(item);
				DicKind.dict[dicKind.label] = dicKind;
			}
			
			
			sendNotification(AppNotification.NOTIFY_APP_LOADINGHIDE,"程序初始化：系统字典加载完成！");	
			
			appInit();
		}
		
		private function onServiceDicResult(result:ArrayCollection):void
		{			
			DicServiceType.dict[DicServiceType.NOSERVICE.id] = DicServiceType.NOSERVICE;
			for each(var row:Object in result)
			{
				var serviceType:DicServiceType = new DicServiceType(row);
				DicServiceType.dict[serviceType.id] = serviceType;
			}
			
			for each (var item:DicServiceType in DicServiceType.dict)
			{
				if((item.label != "街面警力")
					&& (item.label != "社区警力"))
				{
					item.isMapShow = false;
				}
			}
			
			sendNotification(AppNotification.NOTIFY_APP_LOADINGHIDE,"程序初始化：勤务字典加载完成！");		
			
			appInit();
		}
		
		private function onSysConfigResult(result:ArrayCollection):void
		{			
			DicPatrolZone.defaultColor = 0xFF0000;
			
			for each(var row:Object in result)
			{
				switch(Number(row.PARAID))
				{						
					//GPS显示刷新间隔(单位：分钟)
					case 1:
						GPSNewVO.RefreshDiff = Number(row.PARAVALUE);
						break;
					
					//GPS设备失效时间间隔(单位：分钟)
					case 18:
						GPSNewVO.ValidDiff = Number(row.PARAVALUE);
						break;
					
					//未排班警力地图是否默认显示
					case 12:
						DicServiceType.NOSERVICE.isGisShow = (row.PARAVALUE == "1");
						DicServiceType.NOSERVICE.isMapShow = DicServiceType.NOSERVICE.isGisShow;
						break;
					
					//异常报警越界时间判定长度（分钟）
					case 13:
						ServiceExceptVO.CROSSING_DIFF = Number(row.PARAVALUE);
						break;
					
					//异常报警车辆停止时间判定长度（分钟）
					case 14:
						ServiceExceptVO.STOPPING_DIFF = Number(row.PARAVALUE);
						break;
					
					//异常报警巡区无人巡逻时间判定长度（分钟）
					case 15:
						ServiceExceptVO.NOPATROL_DIFF = Number(row.PARAVALUE);
						break;
					
					//处警警员离现场到达提示距离（米）
					case 16:
						AlarmPoliceVO.TIP_DIS = Number(row.PARAVALUE);
						break;
					
					//异常报警处警警员处警时间过长判定长度（分钟）
					case 17:
						ServiceExceptVO.LONGTIME_DIFF = Number(row.PARAVALUE);
						break;
					
					default:
						for each(var item:DicExceptType in DicExceptType.list)
						{
							if(item.exceptName == row.PARANAME)
							{
								item.isMonitoring = (row.PARAVALUE == "1");
								break;
							}
						}
						break;
				}
			}
			sendNotification(AppNotification.NOTIFY_APP_LOADINGHIDE,"程序初始化：系统配置加载完成！");		
			
			appInit();
		}
		
		private function onDepartmentInfoResult(result:ArrayCollection):void
		{
			DicDepartment.dict[DicDepartment.ALL.id] = DicDepartment.ALL;
			
			for each(var row:Object in result)
			{
				var department:DicDepartment = new DicDepartment(row);
				DicDepartment.dict[department.id] = department;
			}
			
			sendNotification(AppNotification.NOTIFY_APP_LOADINGHIDE,"程序初始化：单位字典加载完成！");		
			
			appInit();
		}
		
		private function onAlarmTypeInfoResult(result:ArrayCollection):void
		{			
			for each(var row:Object in result)
			{
				var alarmType:DicAlarmType = new DicAlarmType(row);
				DicAlarmType.dict[alarmType.id] = alarmType;
			}
			sendNotification(AppNotification.NOTIFY_APP_LOADINGHIDE,"程序初始化：警情字典加载完成！");		
			
			appInit();
		}
		
		private function onPatrolZoneResult(result:ArrayCollection):void
		{	
			DicPatrolZone.dict[DicPatrolZone.ALL.id] = DicPatrolZone.ALL;
			
			for each(var row:Object in result)
			{
				var patrolZone:DicPatrolZone = new DicPatrolZone(row);				
				DicPatrolZone.dict[patrolZone.id] = patrolZone;
			}
			sendNotification(AppNotification.NOTIFY_APP_LOADINGHIDE,"程序初始化：巡区数据加载完成！");		
			
			appInit();
		}
		
		private function onGetQwPointTypeResult(result:ArrayCollection):void
		{	
			DicPointType.dict[DicPointType.ALL.id] = DicPointType.ALL;
			for each(var row:Object in result)
			{
				var pointType:DicPointType = new DicPointType(row);		
				DicPointType.dict[pointType.id] = pointType; 
			}
			sendNotification(AppNotification.NOTIFY_APP_LOADINGHIDE,"程序初始化：卡点类型数据加载完成！");		
			
			appInit();
		}
		
		private function onPatrolPointResult(result:ArrayCollection):void
		{	
			for each(var row:Object in result)
			{
				var patrolPoint:DicPatrolPoint = new DicPatrolPoint(row);				
				DicPatrolPoint.dict[patrolPoint.id] = patrolPoint;
			}
			sendNotification(AppNotification.NOTIFY_APP_LOADINGHIDE,"程序初始化：卡点数据加载完成！");		
			
			appInit();
		}
		
		private function onElePoliceResult(result:ArrayCollection):void
		{	
			for each(var row:Object in result)
			{
				var elePolice:DicElePolice = new DicElePolice(row);				
				DicElePolice.dict[elePolice.id] = elePolice;
			}
			sendNotification(AppNotification.NOTIFY_APP_LOADINGHIDE,"程序初始化：电子警察数据加载完成！");		
			
			appInit();
		}
		
		private function onGPSResult(result:ArrayCollection):void
		{			
			GPSNewVO.CurrentTime = new Date(Date.parse(result[0].DATARECORDTIME));
			
			for(var i:Number = 1;i< result.length;i++)
			{
				var curTime:Date = new Date(Date.parse(result[i].DATARECORDTIME));
								
				arrGPSTemp.addItem(result[i]);
			}
						
			sendNotification(AppNotification.NOTIFY_APP_LOADINGHIDE,"程序初始化：GPS初始化完成！");		
			
			appInit();
		}
	}
}