package app.view
{
	import app.AppNotification;
	import app.event.AppEvent;
	import app.model.AlarmInfoProxy;
	import app.model.GPSRealTimeInfoProxy;
	import app.model.dict.DicAlarmType;
	import app.model.dict.DicDepartment;
	import app.model.dict.DicServiceStatus;
	import app.model.vo.AlarmInfoVO;
	import app.model.vo.AlarmPoliceVO;
	import app.model.vo.AppConfigVO;
	import app.model.vo.GPSNewVO;
	import app.model.vo.GPSVO;
	import app.view.components.MainMenu;
	import app.view.components.RightPanelAlarmInfo;
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
	
	public class RightPanelAlarmInfoMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "RightPanelAlarmInfoMediator";
				
		private var alarmInfoProxy:AlarmInfoProxy = null;
		
		private var timer:Timer = new Timer(10000);
		
		public function RightPanelAlarmInfoMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
							
			rightPanelAlarmInfo.addEventListener(RightPanelAlarmInfo.SEARCHCUR,onSearchCur);
			rightPanelAlarmInfo.addEventListener(RightPanelAlarmInfo.SEARCHHIS,onSearchHis);
						
			rightPanelAlarmInfo.addEventListener(RightPanelAlarmInfo.ALARMVISIBLE,onGridAlarmVisible);
			rightPanelAlarmInfo.addEventListener(RightPanelAlarmInfo.ALARMFOCUS,onGridAlarmFocus);
			
			rightPanelAlarmInfo.addEventListener(RightPanelAlarmInfo.ALARMCLICK,onGridAlarmClick);
			rightPanelAlarmInfo.addEventListener(RightPanelAlarmInfo.ALARMDOUBLECLICK,onGridAlarmDoubleClick);
			
			rightPanelAlarmInfo.addEventListener(RightPanelAlarmInfo.ALARMCHANGE,onGridAlarmChange);
			
			rightPanelAlarmInfo.addEventListener(RightPanelAlarmInfo.ALARMCORRECT,onBtnAlarmCorrectButtonDown);
			rightPanelAlarmInfo.addEventListener(RightPanelAlarmInfo.ALARMUNDO,onBtnAlarmUndoButtonDown);
			
			rightPanelAlarmInfo.addEventListener(RightPanelAlarmInfo.ALARMSHOWSELECT,onBtnAlarmShowSelectButtonDown);
			
			rightPanelAlarmInfo.addEventListener(RightPanelAlarmInfo.POLICESELECT,onPoliceSelect);			
			rightPanelAlarmInfo.addEventListener(RightPanelAlarmInfo.POLICECONFIRM,onPoliceConfirm);
			//rightPanelAlarmInfo.addEventListener(RightPanelAlarmInfo.POLICEDELETE,onPoliceDelete);			
			//rightPanelAlarmInfo.addEventListener(RightPanelAlarmInfo.POLICECHANGESTATE,onPoliceChangeState);
				
			timer.addEventListener(TimerEvent.TIMER,onTimer);
			
			alarmInfoProxy = facade.retrieveProxy(AlarmInfoProxy.NAME) as AlarmInfoProxy;
		}
				
		private function get rightPanelAlarmInfo():RightPanelAlarmInfo
		{
			return viewComponent as RightPanelAlarmInfo;
		}
							
		private function onTimer(event:TimerEvent):void
		{
			alarmInfoProxy.getAlarmInfo(rightPanelAlarmInfo.listDeptItem);
		}
		
		private function onSearchCur(event:Event = null):void
		{			
			timer.stop();
			
			alarmInfoProxy.initAlarmRealTime(rightPanelAlarmInfo.listDeptItem);
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
				alarmInfoProxy.initAlarmHistory(
					rightPanelAlarmInfo.listDeptItem,
					rightPanelAlarmInfo.listAlarmTypeItem,
					rightPanelAlarmInfo.beginTime,
					rightPanelAlarmInfo.endTime
				)
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
			}
			else
			{
				rightPanelAlarmInfo.gridAlarmPolice.dataProvider = null;
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
					
					rightPanelAlarmInfo.listAlarmType = DicAlarmType.listAll;
					rightPanelAlarmInfo.listAlarmTypeItem = DicAlarmType.ALL;
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
	}
}