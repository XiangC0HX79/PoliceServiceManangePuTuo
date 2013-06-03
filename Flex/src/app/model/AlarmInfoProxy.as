package app.model
{
	import app.AppNotification;
	import app.model.dict.DicAlarmType;
	import app.model.dict.DicDepartment;
	import app.model.vo.AlarmInfoVO;
	import app.model.vo.AlarmPoliceVO;
	import app.model.vo.AppConfigVO;
	import app.model.vo.GPSNewVO;
	
	import com.esri.ags.geometry.MapPoint;
	
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ISort;
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	import spark.collections.Sort;
	import spark.formatters.DateTimeFormatter;
	
	public class AlarmInfoProxy extends Proxy implements IProxy
	{
		public static const NAME:String = "AlarmInfoProxy";
								
		public function AlarmInfoProxy()
		{
			super(NAME, new Dictionary);
		}
		
		public function get dic():Dictionary
		{
			return data as Dictionary;
		}
				
		public function get listAlarmInfo():ArrayCollection
		{
			var result:ArrayCollection = new ArrayCollection;
			
			for each(var item:AlarmInfoVO in dic)
			{
				result.addItem(item);
			}
			
			var sort:Sort = new Sort;
			sort.compareFunction = compareFunction;
			result.sort = sort;
			result.refresh();
			
			return result;
			
			function compareFunction(a:Object, b:Object, fields:Array = null):int
			{
				var alarmA:AlarmInfoVO = a as AlarmInfoVO;
				var alarmB:AlarmInfoVO = b as AlarmInfoVO;
				if(alarmA.time.time < alarmB.time.time)
				{
					return 1;
				}
				else
				{
					return -1;
				}
			}
		}
		
		public function initAlarmRealTime(dept:DicDepartment):void
		{			
			setData(new Dictionary);
						
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["getAlarmInfo",onResult,[dept.label,"所有类别","",""]]);
			
			function onResult(table:ArrayCollection):void
			{							
				for(var i:Number = 0;i<table.length;i++)
				{
					var alarm:AlarmInfoVO = new AlarmInfoVO(table[i]);
					if((alarm.mapPoint.x == 0) && (alarm.mapPoint.y == 0))
					{
						for each(var dept:DicDepartment in DicDepartment.dict)
						{
							if((dept.label == alarm.deptName)
								&& (dept.polygon != null))
							{
								alarm.srcPoint.x = dept.polygon.extent.center.x;
								alarm.srcPoint.y = dept.polygon.extent.center.y;
								
								alarm.mapPoint.x = dept.polygon.extent.center.x;
								alarm.mapPoint.y = dept.polygon.extent.center.y;
								break;
							}
						}
					}
					
					dic[alarm.id] = alarm;
					
					if(i == (table.length - 1))
					{						
						AlarmInfoVO.lastUpdateTime = alarm.time;
					}
					
					sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
						["getAlarmPolice",onPoliceResult,[alarm.id]]);
				}
				
				sendNotification(AppNotification.NOTIFY_ALARM_INIT);
			}
			
			function onPoliceResult(table:ArrayCollection):void
			{				
				if(table.length > 0)
				{
					var alarmPolice:AlarmPoliceVO = new AlarmPoliceVO(table[0]);
					var alarm:AlarmInfoVO = dic[alarmPolice.alarmID];
					alarm.listPolice = new ArrayCollection;
					
					for each(var item:Object in table)
					{
						alarm.listPolice.addItem(new AlarmPoliceVO(item));
					}		
				}
			}
		}
		
		public function initAlarmRealTimeFX(dept:DicDepartment):void
		{			
			setData(new Dictionary);
			
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["getAlarmInfoFX",onResult,[dept.label,"0","",""]]);
			
			function onResult(table:ArrayCollection):void
			{							
				for(var i:Number = 0;i<table.length;i++)
				{
					var alarm:AlarmInfoVO = new AlarmInfoVO(table[i]);
					if((alarm.mapPoint.x == 0) && (alarm.mapPoint.y == 0))
					{
						for each(var dept:DicDepartment in DicDepartment.dict)
						{
							if((dept.label == alarm.deptName)
								&& (dept.polygon != null))
							{
								alarm.srcPoint.x = dept.polygon.extent.center.x;
								alarm.srcPoint.y = dept.polygon.extent.center.y;
								
								alarm.mapPoint.x = dept.polygon.extent.center.x;
								alarm.mapPoint.y = dept.polygon.extent.center.y;
								break;
							}
						}
					}
					
					dic[alarm.id] = alarm;
					
					if(i == (table.length - 1))
					{						
						AlarmInfoVO.lastUpdateTime = alarm.time;
					}
					
					sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
						["getAlarmPolice",onPoliceResult,[alarm.id]]);
				}
				
				sendNotification(AppNotification.NOTIFY_ALARM_INIT);
			}
			
			function onPoliceResult(table:ArrayCollection):void
			{				
				if(table.length > 0)
				{
					var alarmPolice:AlarmPoliceVO = new AlarmPoliceVO(table[0]);
					var alarm:AlarmInfoVO = dic[alarmPolice.alarmID];
					alarm.listPolice = new ArrayCollection;
					
					for each(var item:Object in table)
					{
						alarm.listPolice.addItem(new AlarmPoliceVO(item));
					}		
				}
			}
		}
		
		public function initAlarmHistory(dept:DicDepartment,type:DicAlarmType,beginTime:Date,endTime:Date):void
		{			
			setData(new Dictionary);
			
			var dateFormatter:DateTimeFormatter = new DateTimeFormatter;
			dateFormatter.dateTimePattern = "yyyy-MM-dd HH:mm:ss";
			
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["getAlarmInfo",onResult,[dept.label,type.label,dateFormatter.format(beginTime),dateFormatter.format(endTime)]]);
			
			function onResult(table:ArrayCollection):void
			{							
				for(var i:Number = 0;i<table.length;i++)
				{
					var alarm:AlarmInfoVO = new AlarmInfoVO(table[i]);
					
					if((alarm.mapPoint.x == 0) && (alarm.mapPoint.y == 0))
					{
						for each(var dept:DicDepartment in DicDepartment.dict)
						{
							if((dept.label == alarm.deptName)
							&& (dept.polygon != null))
								{
									alarm.srcPoint.x = dept.polygon.extent.center.x;
									alarm.srcPoint.y = dept.polygon.extent.center.y;
									
									alarm.mapPoint.x = dept.polygon.extent.center.x;
									alarm.mapPoint.y = dept.polygon.extent.center.y;
								break;
							}
						}
					}
					
					dic[alarm.id] = alarm;
				}
				
				sendNotification(AppNotification.NOTIFY_ALARM_HISTORY);
			}
		}
		
		public function initAlarmHistoryFX(dept:DicDepartment,type:DicAlarmType,beginTime:Date,endTime:Date):void
		{			
			setData(new Dictionary);
			
			var dateFormatter:DateTimeFormatter = new DateTimeFormatter;
			dateFormatter.dateTimePattern = "yyyy-MM-dd HH:mm:ss";
			
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["getAlarmInfoFX",onResult,[dept.label,type.id,dateFormatter.format(beginTime),dateFormatter.format(endTime)]]);
			
			function onResult(table:ArrayCollection):void
			{							
				for(var i:Number = 0;i<table.length;i++)
				{
					var alarm:AlarmInfoVO = new AlarmInfoVO(table[i]);
					
					if((alarm.mapPoint.x == 0) && (alarm.mapPoint.y == 0))
					{
						for each(var dept:DicDepartment in DicDepartment.dict)
						{
							if((dept.label == alarm.deptName)
								&& (dept.polygon != null))
							{
								alarm.srcPoint.x = dept.polygon.extent.center.x;
								alarm.srcPoint.y = dept.polygon.extent.center.y;
								
								alarm.mapPoint.x = dept.polygon.extent.center.x;
								alarm.mapPoint.y = dept.polygon.extent.center.y;
								break;
							}
						}
					}
					
					dic[alarm.id] = alarm;
				}
				
				sendNotification(AppNotification.NOTIFY_ALARM_HISTORY);
			}
		}
		
		public function getAlarmInfo(dept:DicDepartment):void
		{
			var dateFormatter:DateTimeFormatter = new DateTimeFormatter;
			dateFormatter.dateTimePattern = "yyyy-MM-dd HH:mm:ss";
			
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["getAlarmInfo",onResult,
					[
						dept.label
						,"所有类别"
						,dateFormatter.format(AlarmInfoVO.lastUpdateTime)
						,""
					]
					,false]);	
			
			function onResult(table:ArrayCollection):void
			{							
				for(var i:Number = 0;i<table.length;i++)
				{
					var alarm:AlarmInfoVO = new AlarmInfoVO(table[i]);
					
					if((alarm.mapPoint.x == 0) && (alarm.mapPoint.y == 0))
					{
						for each(var dept:DicDepartment in DicDepartment.dict)
						{
							if((dept.label == alarm.deptName)
								&& (dept.polygon != null))
							{
								alarm.srcPoint.x = dept.polygon.extent.center.x;
								alarm.srcPoint.y = dept.polygon.extent.center.y;
								
								alarm.mapPoint.x = dept.polygon.extent.center.x;
								alarm.mapPoint.y = dept.polygon.extent.center.y;
								break;
							}
						}
					}
					
					dic[alarm.id] = alarm;
					
					if(i == (table.length - 1))
					{						
						AlarmInfoVO.lastUpdateTime = alarm.time;
					}
					
					sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
						["getAlarmPolice",onPoliceResult,[alarm.id]]);
				}
				
				sendNotification(AppNotification.NOTIFY_ALARM_REALTIME,table);
			}
			
			function onPoliceResult(table:ArrayCollection):void
			{				
				if(table.length > 0)
				{
					var alarmPolice:AlarmPoliceVO = new AlarmPoliceVO(table[0]);
					var alarm:AlarmInfoVO = dic[alarmPolice.alarmID];
					alarm.listPolice = new ArrayCollection;
					
					for each(var item:Object in table)
					{
						alarm.listPolice.addItem(new AlarmPoliceVO(item));
					}		
				}
			}
		}
		
		public function getAlarmInfoFX(dept:DicDepartment):void
		{
			var dateFormatter:DateTimeFormatter = new DateTimeFormatter;
			dateFormatter.dateTimePattern = "yyyy-MM-dd HH:mm:ss";
						
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["getAlarmInfoFX",onResult,
					[
						dept.label
						,"0"
						,dateFormatter.format(AlarmInfoVO.lastUpdateTime)
						,""
					]
					,false]);	
			
			function onResult(table:ArrayCollection):void
			{							
				for(var i:Number = 0;i<table.length;i++)
				{
					var alarm:AlarmInfoVO = new AlarmInfoVO(table[i]);
					
					if((alarm.mapPoint.x == 0) && (alarm.mapPoint.y == 0))
					{
						for each(var dept:DicDepartment in DicDepartment.dict)
						{
							if((dept.label == alarm.deptName)
							&& (dept.polygon != null))
								{
									alarm.srcPoint.x = dept.polygon.extent.center.x;
									alarm.srcPoint.y = dept.polygon.extent.center.y;
									
									alarm.mapPoint.x = dept.polygon.extent.center.x;
									alarm.mapPoint.y = dept.polygon.extent.center.y;
								break;
							}
						}
					}
					
					dic[alarm.id] = alarm;
					
					if(i == (table.length - 1))
					{						
						AlarmInfoVO.lastUpdateTime = alarm.time;
					}
					
					sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
						["getAlarmPolice",onPoliceResult,[alarm.id]]);
				}
								
				sendNotification(AppNotification.NOTIFY_ALARM_REALTIME,table);
			}
						
			function onPoliceResult(table:ArrayCollection):void
			{				
				if(table.length > 0)
				{
					var alarmPolice:AlarmPoliceVO = new AlarmPoliceVO(table[0]);
					var alarm:AlarmInfoVO = dic[alarmPolice.alarmID];
					alarm.listPolice = new ArrayCollection;
					
					for each(var item:Object in table)
					{
						alarm.listPolice.addItem(new AlarmPoliceVO(item));
					}		
				}
			}
		}
			
		public function updateFocus(alarm:AlarmInfoVO):void
		{
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["setAlarmFocus",onResult,[alarm.id,(alarm.isFocus?"1":"0")]]);	
			
			function onResult(result:String):void
			{						
				if(result == "")
				{								
				}
			}			
		}
		
		public function correct(alarm:AlarmInfoVO,mapPoint:MapPoint):void
		{			
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["setAlarmPos",onResult,[alarm.id,mapPoint.x,mapPoint.y]]);	
			
			function onResult(result:String):void
			{						
				if(result == "")
				{								
					alarm.mapPoint = mapPoint;
					sendNotification(AppNotification.NOTIFY_ALARM_CORRECT,alarm);
				}
			}
		}	
		
		public function setAlarmNewType(alarm:AlarmInfoVO):void
		{
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["setAlarmNewType",onResult,[alarm.id,alarm.newType]]);	
			
			function onResult(result:String):void
			{						
				if(result == "")
				{								
				}
			}			
		}	
	}
}