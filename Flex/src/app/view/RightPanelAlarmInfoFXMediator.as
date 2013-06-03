package app.view
{
	import app.AppNotification;
	import app.event.AppEvent;
	import app.model.AlarmInfoProxy;
	import app.model.GPSRealTimeInfoProxy;
	import app.model.dict.DicAlarmType;
	import app.model.dict.DicDepartment;
	import app.model.dict.DicElePolice;
	import app.model.dict.DicLayer;
	import app.model.dict.DicServiceStatus;
	import app.model.vo.AlarmInfoVO;
	import app.model.vo.AlarmPoliceVO;
	import app.model.vo.AppConfigVO;
	import app.model.vo.GPSNewVO;
	import app.model.vo.GPSVO;
	import app.view.components.MainMenu;
	import app.view.components.RightPanelAlarmInfoFX;
	import app.view.components.subComponents.ItemRendererCheck;
	
	import com.esri.ags.FeatureSet;
	import com.esri.ags.Graphic;
	import com.esri.ags.geometry.Geometry;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.geometry.Polygon;
	import com.esri.ags.tools.DrawTool;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.events.CalendarLayoutChangeEvent;
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.components.gridClasses.GridItemRenderer;
	import spark.components.supportClasses.ItemRenderer;
	import spark.events.GridEvent;
	import spark.events.GridSelectionEvent;
	import spark.events.IndexChangeEvent;
	import spark.events.TextOperationEvent;
	import spark.formatters.DateTimeFormatter;
	
	public class RightPanelAlarmInfoFXMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "RightPanelAlarmInfoFXMediator";
				
		private var alarmInfoProxy:AlarmInfoProxy = null;
		
		private var timer:Timer = new Timer(10000);
		
		public function RightPanelAlarmInfoFXMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
							
			rightPanelAlarmInfo.addEventListener(RightPanelAlarmInfoFX.SEARCHCUR,onSearchCur);
			rightPanelAlarmInfo.addEventListener(RightPanelAlarmInfoFX.SEARCHHIS,onSearchHis);
						
			rightPanelAlarmInfo.addEventListener(RightPanelAlarmInfoFX.ALARMVISIBLE,onGridAlarmVisible);
			rightPanelAlarmInfo.addEventListener(RightPanelAlarmInfoFX.ALARMFOCUS,onGridAlarmFocus);
			
			rightPanelAlarmInfo.addEventListener(RightPanelAlarmInfoFX.ALARMCLICK,onGridAlarmClick);
			rightPanelAlarmInfo.addEventListener(RightPanelAlarmInfoFX.ALARMDOUBLECLICK,onGridAlarmDoubleClick);
			
			rightPanelAlarmInfo.addEventListener(RightPanelAlarmInfoFX.ALARMCHANGE,onGridAlarmChange);
			
			rightPanelAlarmInfo.addEventListener(RightPanelAlarmInfoFX.ALARMCORRECT,onBtnAlarmCorrectButtonDown);
			rightPanelAlarmInfo.addEventListener(RightPanelAlarmInfoFX.ALARMUNDO,onBtnAlarmUndoButtonDown);
			
			rightPanelAlarmInfo.addEventListener(RightPanelAlarmInfoFX.ALARMSHOWSELECT,onBtnAlarmShowSelectButtonDown);
			
			rightPanelAlarmInfo.addEventListener(RightPanelAlarmInfoFX.POLICESELECT,onPoliceSelect);			
			rightPanelAlarmInfo.addEventListener(RightPanelAlarmInfoFX.POLICECONFIRM,onPoliceConfirm);
			
			rightPanelAlarmInfo.addEventListener(RightPanelAlarmInfoFX.EDITNEWTYPE,onEditNewType);
			
			rightPanelAlarmInfo.addEventListener(RightPanelAlarmInfoFX.FLASHELE,onFlashEle);
			rightPanelAlarmInfo.addEventListener(RightPanelAlarmInfoFX.LOCATEELE,onLocateEle);				
			
			timer.addEventListener(TimerEvent.TIMER,onTimer);
			
			alarmInfoProxy = facade.retrieveProxy(AlarmInfoProxy.NAME) as AlarmInfoProxy;
		}
				
		private function get rightPanelAlarmInfo():RightPanelAlarmInfoFX
		{
			return viewComponent as RightPanelAlarmInfoFX;
		}
							
		private function onTimer(event:TimerEvent):void
		{
			timer.stop();
			
			alarmInfoProxy.getAlarmInfoFX(rightPanelAlarmInfo.listDeptItem);
		}
		
		private function onSearchCur(event:Event = null):void
		{			
			timer.stop();
			
			alarmInfoProxy.initAlarmRealTimeFX(rightPanelAlarmInfo.listDeptItem);
		}
		
		private function onSearchHis(event:Event):void
		{
			timer.stop();
			
			var tempBeginTime:Date = rightPanelAlarmInfo.beginTime;
			var tempEndTime:Date = rightPanelAlarmInfo.endTime;	
			var error:String = "";
			
			if(tempBeginTime.time > tempEndTime.time)
			{				
				sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"开始时间不能晚于结束时间！");
			}
			else
			{
				alarmInfoProxy.initAlarmHistoryFX(
					rightPanelAlarmInfo.listDeptItem,
					rightPanelAlarmInfo.listAlarmTypeItem,
					rightPanelAlarmInfo.beginTime,
					rightPanelAlarmInfo.endTime
				);
			}
		}
		
		private function onGridAlarmVisible(event:Event):void
		{
			sendNotification(AppNotification.NOTIFY_ALARM_HIDE,rightPanelAlarmInfo.listAlarmItem);
		}
		
		private function onGridAlarmFocus(event:Event):void
		{
			alarmInfoProxy.updateFocus(rightPanelAlarmInfo.listAlarmItem);
			
			sendNotification(AppNotification.NOTIFY_ALARM_FOCUS,rightPanelAlarmInfo.listAlarmItem);
		}
		
		private function onGridAlarmClick(event:Event):void
		{
			sendNotification(AppNotification.NOTIFY_ALARM_FLASH,rightPanelAlarmInfo.listAlarmItem);
		}
		
		private function onGridAlarmDoubleClick(event:Event):void
		{
			sendNotification(AppNotification.NOTIFY_MAP_LOCATE,rightPanelAlarmInfo.listAlarmItem.mapPoint);
		}
								
		private function onGridAlarmChange(event:Event):void
		{
			if(rightPanelAlarmInfo.listAlarmItem != null)
			{				
				var gpsRealTimeInfoProxy:GPSRealTimeInfoProxy = facade.retrieveProxy(GPSRealTimeInfoProxy.NAME) as GPSRealTimeInfoProxy;
				
				var arrPolice:Array = new Array;			
				for each(var police:GPSNewVO in gpsRealTimeInfoProxy.listPolice)
				{							
					if((police.inService || police.gpsValid) && ((police.department == null) || (police.department.label == rightPanelAlarmInfo.listAlarmItem.deptName)))
					{
						var tempAlarmPolice:AlarmPoliceVO = null;
						
						for each(var alarmPolice:AlarmPoliceVO in rightPanelAlarmInfo.listAlarmItem.listPolice)
						{
							if(alarmPolice.userID == police.userId)
							{
								tempAlarmPolice = alarmPolice;
								tempAlarmPolice.selected = true;
								break;
							}
						}
						
						if(tempAlarmPolice == null)
						{
							tempAlarmPolice = new AlarmPoliceVO(null);
						}
						
						tempAlarmPolice.gps = police;
						
						arrPolice.push(tempAlarmPolice);
					}
				}
				
				arrPolice.sort(compareFunction);
								
				rightPanelAlarmInfo.gridAlarmPolice.dataProvider = new ArrayCollection(arrPolice);
				
				var arrElePolice:Array = new Array;
				var range:Number = Number(rightPanelAlarmInfo.dis);
				if(DicLayer.VIDEO.selected)
				{
					for each(var elePolice:DicElePolice in DicElePolice.dict)
					{
						if(elePolice.layer == DicLayer.VIDEO)
						{							
							var dx:Number = elePolice.mapPoint.x - rightPanelAlarmInfo.listAlarmItem.mapPoint.x;
							var dy:Number = elePolice.mapPoint.y - rightPanelAlarmInfo.listAlarmItem.mapPoint.y;
							var dis:Number = dx*dx+dy*dy;
							if(dis < range*range)
							{
								arrElePolice.push(elePolice);
							}
						}
					}
				}
				
				arrElePolice.sort(compareEleFunction);
				
				rightPanelAlarmInfo.listElePolice = new ArrayCollection(arrElePolice);
				//rightPanelAlarmInfo.gridElePolice.dataProvider = new ArrayCollection(arrElePolice);
			}
			else
			{
				rightPanelAlarmInfo.gridAlarmPolice.dataProvider = null;
				
				rightPanelAlarmInfo.listElePolice = null;
				//rightPanelAlarmInfo.gridElePolice.dataProvider = null;
			}		
			
			sendNotification(AppNotification.NOTIFY_SEARCH_GRAPHICSTOP);
						
			function compareFunction(a:AlarmPoliceVO, b:AlarmPoliceVO, fields:Array = null):int
			{
				if((a.id != "") && (b.id == ""))
					return -1;
				else if ((a.id == "") && (b.id != ""))
					return 1;
				else
				{
					var dx:Number = a.gps.mapPoint.x - rightPanelAlarmInfo.listAlarmItem.mapPoint.x;
					var dy:Number = a.gps.mapPoint.y - rightPanelAlarmInfo.listAlarmItem.mapPoint.y;
					var disA:Number = dx*dx+dy*dy;
					
					dx = b.gps.mapPoint.x - rightPanelAlarmInfo.listAlarmItem.mapPoint.x;
					dy = b.gps.mapPoint.y - rightPanelAlarmInfo.listAlarmItem.mapPoint.y;
					var disB:Number = dx*dx+dy*dy;
					
					if(disA < disB)
						return -1;
					else if(disA > disB)
						return 1;
					else
						return 0;
				}
			}
			
			function compareEleFunction(a:DicElePolice, b:DicElePolice, fields:Array = null):int
			{
				var dx:Number = a.mapPoint.x - rightPanelAlarmInfo.listAlarmItem.mapPoint.x;
				var dy:Number = a.mapPoint.y - rightPanelAlarmInfo.listAlarmItem.mapPoint.y;
				var disA:Number = dx*dx+dy*dy;
				
				dx = b.mapPoint.x - rightPanelAlarmInfo.listAlarmItem.mapPoint.x;
				dy = b.mapPoint.y - rightPanelAlarmInfo.listAlarmItem.mapPoint.y;
				var disB:Number = dx*dx+dy*dy;
				
				if(disA < disB)
					return -1;
				else if(disA > disB)
					return 1;
				else
					return 0;
			}
		}
						
		private function onBtnAlarmUndoButtonDown(event:Event):void
		{			
			if(rightPanelAlarmInfo.listAlarmItem != null)
			{
				var alarm:AlarmInfoVO = rightPanelAlarmInfo.listAlarmItem as AlarmInfoVO;
				alarmInfoProxy.correct(rightPanelAlarmInfo.listAlarmItem,alarm.srcPoint);
				sendNotification(AppNotification.NOTIFY_MAP_LOCATE,alarm.srcPoint);
			}
			else
			{
				sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"请先选择警情。");
			}
			
			function queryResultHandle(featureSet:FeatureSet):void
			{			
				if(featureSet.features.length > 0)
				{
					var polygon:Polygon = (featureSet.features[0] as Graphic).geometry as Polygon;
					
					alarmInfoProxy.correct(rightPanelAlarmInfo.listAlarmItem,polygon.extent.center);		
					
					sendNotification(AppNotification.NOTIFY_MAP_LOCATE,polygon.extent.center);
				}
				else
				{
					
				}
			}
		}
		
		private function onBtnAlarmShowSelectButtonDown(event:Event):void
		{			
			sendNotification(AppNotification.NOTIFY_ALARM_SELECT);
		}
		
		private function onBtnAlarmCorrectButtonDown(event:Event):void
		{			
			if(rightPanelAlarmInfo.listAlarmItem != null)
			{
				sendNotification(AppNotification.NOTIFY_SEARCH_GRAPHICSTART,[0,DrawTool.MAPPOINT,drawResultHandle]);
			}
			else
			{
				sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"请先选择警情。");
			}
			
			function drawResultHandle(geometry:Geometry):void
			{
				sendNotification(AppNotification.NOTIFY_SEARCH_GRAPHICSTOP);
								
				alarmInfoProxy.correct(rightPanelAlarmInfo.listAlarmItem,geometry as MapPoint);
			}
		}
						
		private function onPoliceSelect(event:AppEvent):void
		{
			var alarmPolice:AlarmPoliceVO = event.data as AlarmPoliceVO;
			alarmPolice.selected = !alarmPolice.selected;			
		}
		
		private function onPoliceConfirm(event:Event):void
		{
			var gpsRealTimeInfoProxy:GPSRealTimeInfoProxy = facade.retrieveProxy(GPSRealTimeInfoProxy.NAME) as GPSRealTimeInfoProxy;
						
			if(rightPanelAlarmInfo.listAlarmItem != null)
			{
				var resultCount:Number = 0;
				var curCount:Number = 0;
				
				for each(var alarmPolice:AlarmPoliceVO in rightPanelAlarmInfo.listAlarmItem.listPolice)
				{
					for each(var police:AlarmPoliceVO in rightPanelAlarmInfo.gridAlarmPolice.dataProvider)
					{
						if(
							(DicServiceStatus.idle != null)
							&& (police.gps.gpsSimCard == alarmPolice.gps.gpsSimCard)
							&& (!police.selected)
							)
						{
							resultCount ++;
							
							sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
								["deleteAlarmPolice",onResult,[rightPanelAlarmInfo.listAlarmItem.id,alarmPolice.userID]]);
							
							gpsRealTimeInfoProxy.setServiceState(
								DicServiceStatus.idle.id
								,DicServiceStatus.idle.label
								,alarmPolice.gps.userId
								,AppConfigVO.user.gpsName
								,alarmPolice.gps.gpsDateFormat
							);
						}
					}
				}
				
				for each(police in rightPanelAlarmInfo.gridAlarmPolice.dataProvider)
				{
					if(police.selected)
					{
						var exist:Boolean = false;
						for each(alarmPolice in rightPanelAlarmInfo.listAlarmItem.listPolice)
						{
							if(police.gps.gpsSimCard == alarmPolice.gps.gpsSimCard)
							{
								exist = true;
								break;
							}
						}
						
						if(
							(DicServiceStatus.chujin != null)
							&&(!exist)
							)
						{
							resultCount ++;
							
							sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
								["setAlarmPolice",onResult,[rightPanelAlarmInfo.listAlarmItem.id,police.gps.userId,"",AppConfigVO.user.userId,""]]);
							
							gpsRealTimeInfoProxy.setServiceState(
								DicServiceStatus.chujin.id
								,DicServiceStatus.chujin.label
								,police.gps.userId
								,AppConfigVO.user.gpsName
								,police.gps.gpsDateFormat
							);
						}
					}
				}
			}
						
			function onResult(table:ArrayCollection):void
			{				
				curCount ++;
				if(curCount == resultCount)
				{
					rightPanelAlarmInfo.listAlarmItem.listPolice = new ArrayCollection;
					for each(var item:Object in table)
					{
						rightPanelAlarmInfo.listAlarmItem.listPolice.addItem(new AlarmPoliceVO(item));
					}	
					
					onGridAlarmChange(null);
				}
			}
		}
		
		private function onEditNewType(event:Event):void
		{			
			if(rightPanelAlarmInfo.treeAlarm.selectedItem != null)
			{
				if(rightPanelAlarmInfo.listAlarmItem != null)
				{
					rightPanelAlarmInfo.listAlarmItem.newType = rightPanelAlarmInfo.treeAlarm.selectedItem.@label;
						
					alarmInfoProxy.setAlarmNewType(rightPanelAlarmInfo.listAlarmItem);
				}
				
				rightPanelAlarmInfo.panelNewAlarmType.visible = false;
			}
			else
			{
				sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"请选择警情类型。");
			}
		}
				
		private function onFlashEle(event:Event):void
		{
			var elePolice:DicElePolice = rightPanelAlarmInfo.gridElePolice.selectedItem as DicElePolice;
			if(elePolice != null)
			{
				sendNotification(AppNotification.NOTIFY_LAYERELEPOLICE_FLASH,elePolice);
			}
		}
		
		private function onLocateEle(event:Event):void
		{			
			var elePolice:DicElePolice = rightPanelAlarmInfo.gridElePolice.selectedItem as DicElePolice;
			if(elePolice != null)
			{
				sendNotification(AppNotification.NOTIFY_MAP_LOCATE,elePolice.mapPoint);
			}
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_APP_INIT,
				AppNotification.NOTIFY_MENUBAR,
				
				AppNotification.NOTIFY_ALARM_INIT,
				
				AppNotification.NOTIFY_ALARM_HISTORY,
				AppNotification.NOTIFY_ALARM_REALTIME,
				//AppNotification.NOTIFY_ALARM_GETPOLICE,
				AppNotification.NOTIFY_ALARM_SETPOLICE,
				AppNotification.NOTIFY_ALARM_DELPOLICE,
				AppNotification.NOTIFY_ALARM_SETPOLICETYPE,
				
				AppNotification.NOTIFY_ALARM_CORRECT
				];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch(notification.getName())
			{
				case AppNotification.NOTIFY_APP_INIT:
					rightPanelAlarmInfo.listDept = DicDepartment.listOverview;
					
					if(AppConfigVO.Auth == "0")
					{
						if(AppConfigVO.user.department == null)
							rightPanelAlarmInfo.listDeptItem = DicDepartment.ALL;
						else 
							rightPanelAlarmInfo.listDeptItem = AppConfigVO.user.department;
					}
					else
					{
						rightPanelAlarmInfo.listDeptItem = DicDepartment.ALL;
					}
					
					rightPanelAlarmInfo.listAlarmType = DicAlarmType.listLevelFirst;
										
					var listAlarmTypeItem:DicAlarmType = rightPanelAlarmInfo.listAlarmType[0];
					
					rightPanelAlarmInfo.listAlarmTypeSecond.addItem(DicAlarmType.ALL);
					
					for each(var item:DicAlarmType in DicAlarmType.listLevelSecond)
					{
						if(item.pid == listAlarmTypeItem.id)
						{
							rightPanelAlarmInfo.listAlarmTypeSecond.addItem(item);
						}
					}
					
					rightPanelAlarmInfo.listAlarmTypeItem = rightPanelAlarmInfo.listAlarmType[0];
					
					rightPanelAlarmInfo.treeAlarmType = addNode(DicAlarmType.ALL);
					break;
					
				case AppNotification.NOTIFY_MENUBAR:
					if(notification.getType() == MainMenu.ALARMINFO)
					{				
						if(rightPanelAlarmInfo.initialized)
						{
							rightPanelAlarmInfo.radioButtonGroupAlarmType.selectedValue = 'cur';
						}
						
						rightPanelAlarmInfo.currentState = "cur";
						
						onSearchCur();
						
						if(rightPanelAlarmInfo.initialized)
						{
							rightPanelAlarmInfo.panelNewAlarmType.visible = false;
						}
					}		
					else
					{
						timer.stop();
					}
					break;
								
				case AppNotification.NOTIFY_ALARM_INIT:
					rightPanelAlarmInfo.listAlarm.removeAll();
					rightPanelAlarmInfo.listAlarm.addAll(alarmInfoProxy.listAlarmInfo);
					rightPanelAlarmInfo.listAlarmItem = null;
					
					rightPanelAlarmInfo.gridAlarmPolice.dataProvider = null;
					
					timer.start();
					break;
					
				case AppNotification.NOTIFY_ALARM_HISTORY:
					rightPanelAlarmInfo.listAlarm.removeAll();
					rightPanelAlarmInfo.listAlarm.addAll(alarmInfoProxy.listAlarmInfo);
					rightPanelAlarmInfo.listAlarmItem = null;
					break;
				
				case AppNotification.NOTIFY_ALARM_REALTIME:
					var table:ArrayCollection = notification.getBody() as ArrayCollection;
					for(var i:Number = 0;i<table.length;i++)
					{
						rightPanelAlarmInfo.listAlarm.addItemAt(new AlarmInfoVO(table[i]),0);
					}
					
					timer.start();
					break;
								
				case AppNotification.NOTIFY_ALARM_SETPOLICE:
				case AppNotification.NOTIFY_ALARM_DELPOLICE:
				case AppNotification.NOTIFY_ALARM_SETPOLICETYPE:
					if(rightPanelAlarmInfo.listAlarmItem != null)
					{
						rightPanelAlarmInfo.gridAlarmPolice.dataProvider = rightPanelAlarmInfo.listAlarmItem.listPolice;
					}
					break;
				
				case AppNotification.NOTIFY_ALARM_CORRECT:
					if(rightPanelAlarmInfo.listAlarmItem != null)
					{
						onGridAlarmChange(null);
					}
					break;
			}
		}
		
		private function addNode(node:DicAlarmType):XML
		{
			var xml:XML = <node/>;
			xml.@id = node.id;
			xml.@label = node.label;
			
			for each(var item:DicAlarmType in DicAlarmType.dict)
			{
				if(item.pid == node.id)
				{
					xml.appendChild(addNode(item));
				}
			}
			
			return xml;
		}
	}
}