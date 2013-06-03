package app.view
{
	import app.AppFunction;
	import app.AppNotification;
	import app.event.AppEvent;
	import app.model.GPSRealTimeInfoProxy;
	import app.model.TrackRealtimeProxy;
	import app.model.dict.DicDepartment;
	import app.model.dict.DicPoliceType;
	import app.model.dict.DicServiceType;
	import app.model.vo.AppConfigVO;
	import app.model.vo.CallVO;
	import app.model.vo.GPSNewVO;
	import app.model.vo.GPSVO;
	import app.view.components.MainMenu;
	import app.view.components.RightPanelServiceCallFX;
	import app.view.components.subComponents.ItemRendererCallPolice;
	import app.view.components.subComponents.ItemRendererServiceType;
	
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.events.IndexChangeEvent;
	
	public class RightPanelServiceCallFXMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "RightPanelServiceCallFXMediator";
		
		private var listBaseDMG:ArrayCollection;
		
		public function RightPanelServiceCallFXMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			rightPanelServiceCall.addEventListener(RightPanelServiceCallFX.SEARCH,onSearchPolice);
			
			rightPanelServiceCall.addEventListener(RightPanelServiceCallFX.GETCALL,onGetCall);
			
			rightPanelServiceCall.addEventListener(RightPanelServiceCallFX.ANSWER,onAnswer);
			
			rightPanelServiceCall.addEventListener(RightPanelServiceCallFX.NOANSWER,onNoAnswer);
			
			rightPanelServiceCall.addEventListener(RightPanelServiceCallFX.ONLYCALL,onOnlyCall);
		}
				
		private function get rightPanelServiceCall():RightPanelServiceCallFX
		{
			return viewComponent as RightPanelServiceCallFX;
		}
						
		private function onGetCallInfo_TodayResult(result:ArrayCollection):void
		{
			var todayCalled:Boolean = false;
			
			var gpsRealTimeInfoProxy:GPSRealTimeInfoProxy = facade.retrieveProxy(GPSRealTimeInfoProxy.NAME) as GPSRealTimeInfoProxy;
			for each(var gps:GPSNewVO in gpsRealTimeInfoProxy.dicGPS)
			{
				todayCalled = false;
				for each(var item:Object in  result)
				{
					if(item.USERID == gps.userId)
					{
						todayCalled = true;
						break;
					}
				}
				
				gps.todayCalled = todayCalled;
			}
			
			for each(gps in this.listBaseDMG)
			{
				todayCalled = false;
				for each(item in  result)
				{
					if(item.RADIONO == gps.radioNo)
					{
						todayCalled = true;
						break;
					}
				}
				
				gps.todayCalled = todayCalled;					
			}
		}
		
		private function onSearchPolice(event:Event = null):void
		{	
			onGetCall();
			
			//rightPanelServiceCall.listPolice.removeAll();
			
			var gpsRealTimeInfoProxy:GPSRealTimeInfoProxy = facade.retrieveProxy(GPSRealTimeInfoProxy.NAME) as GPSRealTimeInfoProxy;
			
			var arr:Array = new Array;
			for each(var gps:GPSNewVO in gpsRealTimeInfoProxy.dicGPS)
			{
				if(rightPanelServiceCall.dictSelect[DicServiceType.NOGPS] || gps.gpsValid)
				{
					if(rightPanelServiceCall.dictSelect[DicPoliceType.VEHICLE] && (gps.policeType == DicPoliceType.VEHICLE))
					{
						if((rightPanelServiceCall.listDeptItem == DicDepartment.ALL) 
								|| ((rightPanelServiceCall.listDeptItem == DicDepartment.TRAFFIC) && (gps.department != null) && (gps.department.ZB == 125))
								|| (gps.department == rightPanelServiceCall.listDeptItem))
							arr.push(gps);
					}
					//else if(rightPanelServiceCall.dictSelect[DicPoliceType.PEOPLE] && (gps.policeType != DicPoliceType.VEHICLE))
					else if(gps.policeType != DicPoliceType.VEHICLE)
					{
						if((rightPanelServiceCall.dictSelect[gps.serviceType])
						&& ((rightPanelServiceCall.listDeptItem == DicDepartment.ALL) 
							|| ((rightPanelServiceCall.listDeptItem == DicDepartment.TRAFFIC) && (gps.department != null) && (gps.department.ZB == 125))
							|| (gps.department == rightPanelServiceCall.listDeptItem)))
							arr.push(gps);
					}
				}
			}
			
			if(rightPanelServiceCall.dictSelect[DicPoliceType.BASEDMG])
			{
				for each(gps in this.listBaseDMG)
				{
					if((rightPanelServiceCall.listDeptItem == DicDepartment.ALL) 
						|| ((rightPanelServiceCall.listDeptItem == DicDepartment.TRAFFIC) && (gps.department != null) && (gps.department.ZB == 125))
						|| (gps.department == rightPanelServiceCall.listDeptItem))
						arr.push(gps);
				}
			}
						
			arr.sort(compareFunction);
			
			rightPanelServiceCall.listPolice = new ArrayCollection(arr);
				
			function compareFunction(a:GPSNewVO, b:GPSNewVO, fields:Array = null):int
			{
				if((a.policeTypeID != DicPoliceType.BASEDMG.id) && (b.policeTypeID == DicPoliceType.BASEDMG.id))
				{
					return -1;
				}
				else if((a.policeTypeID == DicPoliceType.BASEDMG.id) && (b.policeTypeID != DicPoliceType.BASEDMG.id))
				{
					return 1;
				}
				else if((a.policeType != DicPoliceType.VEHICLE) && (b.policeType == DicPoliceType.VEHICLE))
				{
					return -1;
				}
				else if((a.inService) && (!b.inService))
				{
					return -1;
				}
				else if((!a.inService) && (b.inService))
				{
					return 1;
				}
				else
				{
					for(var i:Number = 0;i < a.gpsName.length;i++)
					{
						if(i >= b.gpsName.length)
						{
							return 1;
						}
						
						var bytesA:ByteArray = new ByteArray;
						bytesA.writeMultiByte(a.gpsName.toUpperCase().charAt(i), "cn-gb");
						var a1:Number = (bytesA.length == 1)?Number(bytesA[0]):Number(bytesA[0] << 8) +  bytesA[1];
						
						var bytesB:ByteArray = new ByteArray;
						bytesB.writeMultiByte(b.gpsName.toUpperCase().charAt(i), "cn-gb");
						var b1:Number = (bytesB.length == 1)?Number(bytesB[0]):Number(bytesB[0] << 8) +  bytesB[1];
								
						if(a1 < b1)
						{
							return -1;
						}
						else if(a1 > b1)
						{
							return 1;
						}
					}
					
					if(a.gpsName.length < b.gpsName.length)
					{
						return -1;
					}
					else 
					{
						return 1;
					}
				}
			}
		}
										
		private function onGetCall(event:Event = null):void
		{
			rightPanelServiceCall.textLastCallTime = "";
			
			rightPanelServiceCall.textDemo = "";
			
			rightPanelServiceCall.listCallHistory.removeAll();
			
			var user:GPSVO = rightPanelServiceCall.listPoliceItem as GPSVO;
			if(user != null)
			{
				sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
					["getCallInfo",onResult,[(user.userId == "")?"0":user.userId,user.radioNo],false]);
			}
			
			function onResult(table:ArrayCollection):void
			{						
				for each(var row:Object in table)
				{
					rightPanelServiceCall.listCallHistory.addItem(new CallVO(row));
				}
				
				if(rightPanelServiceCall.listCallHistory.length > 0)
				{
					rightPanelServiceCall.textLastCallTime =
						(rightPanelServiceCall.listCallHistory[0] as CallVO).callDateFormat;
				}
			}
		}
				
		private function setCall(police:GPSNewVO,isresponse:String,isconfirm:String,memo:String):void
		{
			if(police != null)
			{				
				var frequency:Number = 1;
				if(police.policeType == DicPoliceType.VEHICLE)
				{
					frequency = 1;
				}
				else if(police.policeType == DicPoliceType.BASEDMG)
				{
					frequency = 3;
				}
				else
				{
					frequency = 2;
				}
				
				sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
					["setCallInfo",onResult,
						[
							isresponse
							,(isresponse=="否")?"0":isconfirm
							,frequency
							,police.radioNo
							,police.gpsName
							,police.departmentNAME
							,(police.userId == "")?"0":police.userId
							,police.departmentID
							,AppConfigVO.user.gpsName
							,AppConfigVO.user.userId
							,AppConfigVO.user.departmentNAME
							,AppConfigVO.user.departmentID
							,memo
						]
					]);	
			}
			
			function onResult(table:ArrayCollection):void
			{				
				police.todayCalled = true;
				
				if((rightPanelServiceCall.gridPolice != null)
					&& (police == rightPanelServiceCall.gridPolice.selectedItem))
				{
					var call:CallVO = new CallVO(table[0]);
					
					rightPanelServiceCall.listCallHistory.addItemAt(call,0);
					
					rightPanelServiceCall.textLastCallTime =
						(rightPanelServiceCall.listCallHistory[0] as CallVO).callDateFormat;
				}
			}
		}
		
		private function onAnswer(event:Event):void
		{
			setCall(rightPanelServiceCall.listPoliceItem,"是",String(rightPanelServiceCall.radioButtonGroupCorrect.selectedValue),rightPanelServiceCall.textDemo);
		}
		
		private function onNoAnswer(event:Event):void
		{
			setCall(rightPanelServiceCall.listPoliceItem,"否",String(rightPanelServiceCall.radioButtonGroupCorrect.selectedValue),rightPanelServiceCall.textDemo);
		}
		
		private function onOnlyCall(event:Event):void
		{
			sendNotification(AppNotification.NOTIFY_APP_ALERTINFO,"当前GPS已失效，无法定位！");
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_APP_INIT,
				AppNotification.NOTIFY_MENUBAR,
				AppNotification.NOTIFY_INFOPOLICE_CALL
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch(notification.getName())
			{
				case AppNotification.NOTIFY_APP_INIT:
					rightPanelServiceCall.listDept = DicDepartment.listOverview;
					
					if(AppConfigVO.Auth == "1")
					{
						rightPanelServiceCall.listDeptItem = DicDepartment.ALL;
					}
					else
					{
						rightPanelServiceCall.listDeptItem = AppConfigVO.user.department;
					}
					
					rightPanelServiceCall.listServiceType.addItem(DicPoliceType.VEHICLE);
					rightPanelServiceCall.dictSelect[DicPoliceType.VEHICLE] = true;
					
					//rightPanelServiceCall.listServiceType.addItem(DicPoliceType.PEOPLE);
					//rightPanelServiceCall.dictSelect[DicPoliceType.PEOPLE] = true;
					
					rightPanelServiceCall.listServiceType.addItem(DicPoliceType.BASEDMG);
					rightPanelServiceCall.dictSelect[DicPoliceType.BASEDMG] = true;
					
					for each(var item:DicServiceType in DicServiceType.list)
					{
						rightPanelServiceCall.listServiceType.addItem(item);
						rightPanelServiceCall.dictSelect[item] = true;
					}
					
					rightPanelServiceCall.listServiceType.addItem(DicServiceType.NOGPS);
					rightPanelServiceCall.dictSelect[DicServiceType.NOGPS] = false;
					
					sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
						["getBaseSTIDDMG",onGetBaseDMGResult,[]]);	
					break;
				
				case AppNotification.NOTIFY_MENUBAR:
					if(notification.getType() == MainMenu.SERVICECALL)
					{						
						sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
							["getCallInfo_Today",onGetCallInfo_TodayResult,[]]);	
						
						onSearchPolice();
					}
				break;
				
				case AppNotification.NOTIFY_INFOPOLICE_CALL:
					setCall(notification.getBody()[0],notification.getBody()[1],notification.getBody()[2],notification.getBody()[3]);
					break;
			}
		}
		
		private function onGetBaseDMGResult(result:ArrayCollection):void
		{
			this.listBaseDMG = new ArrayCollection;
			for each(var item:Object in result)
			{
				var gps:GPSNewVO = new GPSNewVO(item);				
				this.listBaseDMG.addItem(gps);
			}
		}
	}
}