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
	import app.view.components.RightPanelServiceCall;
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
	
	public class RightPanelServiceCallMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "RightPanelServiceCallMediator";
		
		public function RightPanelServiceCallMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			rightPanelServiceCall.addEventListener(RightPanelServiceCall.SEARCH,onSearchPolice);
			
			rightPanelServiceCall.addEventListener(RightPanelServiceCall.GETCALL,onGetCall);
			
			rightPanelServiceCall.addEventListener(RightPanelServiceCall.ANSWER,onAnswer);
			
			rightPanelServiceCall.addEventListener(RightPanelServiceCall.NOANSWER,onNoAnswer);
			
			rightPanelServiceCall.addEventListener(RightPanelServiceCall.ONLYCALL,onOnlyCall);
		}
				
		private function get rightPanelServiceCall():RightPanelServiceCall
		{
			return viewComponent as RightPanelServiceCall;
		}
		
		private function onSearchPolice(event:Event = null):void
		{						
			onGetCall();
			
			//rightPanelServiceCall.listPolice.removeAll();
			
			var gpsRealTimeInfoProxy:GPSRealTimeInfoProxy = facade.retrieveProxy(GPSRealTimeInfoProxy.NAME) as GPSRealTimeInfoProxy;
			
			var arr:Array = new Array;
			for each(var gps:GPSNewVO in gpsRealTimeInfoProxy.dicGPS)
			{
				if((gps.policeType != DicPoliceType.VEHICLE)
					&& (rightPanelServiceCall.dictSelect[gps.serviceType])
					&& ((rightPanelServiceCall.listDeptItem == DicDepartment.ALL) 
						|| ((rightPanelServiceCall.listDeptItem == DicDepartment.TRAFFIC) && (gps.department != null) && (gps.department.ZB == 125))
						|| (gps.department == rightPanelServiceCall.listDeptItem)))
				{			
					arr.push(gps);
					//rightPanelServiceCall.listPolice.addItem(gps);
				}
			}
			
			arr.sort(compareFunction);
			
			rightPanelServiceCall.listPolice = new ArrayCollection(arr);
				
			function compareFunction(a:GPSNewVO, b:GPSNewVO, fields:Array = null):int
			{
				if((a.inService) && (!b.inService))
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
					["getCallInfo",onResult,[user.userId,user.radioNo],false]);
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
				
		private function setCall(police:GPSNewVO,isresponse:String,memo:String):void
		{
			if(police != null)
			{				
				sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
					["setCallInfo",onResult,
						[
							isresponse
							,"0"
							,"0"
							,police.radioNo
							,police.gpsName
							,police.departmentNAME
							,police.userId
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
			setCall(rightPanelServiceCall.listPoliceItem,"是",rightPanelServiceCall.textDemo);
		}
		
		private function onNoAnswer(event:Event):void
		{
			setCall(rightPanelServiceCall.listPoliceItem,"否",rightPanelServiceCall.textDemo);
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
					
					rightPanelServiceCall.listServiceType = DicServiceType.list;
					
					for each(var item:DicServiceType in DicServiceType.list)
					{
						rightPanelServiceCall.dictSelect[item] = true;
					}
					break;
				
				case AppNotification.NOTIFY_MENUBAR:
					if(notification.getType() == MainMenu.SERVICECALL)
					{						
						onSearchPolice();
					}
				break;
				
				case AppNotification.NOTIFY_INFOPOLICE_CALL:
					setCall(notification.getBody()[0],notification.getBody()[1],notification.getBody()[3]);
					break;
			}
		}
	}
}