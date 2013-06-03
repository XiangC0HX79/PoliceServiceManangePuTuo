package app.view
{
	import app.AppNotification;
	import app.model.GPSRealTimeInfoProxy;
	import app.model.dict.DicDepartment;
	import app.model.dict.DicPoliceType;
	import app.model.vo.GPSNewVO;
	import app.view.components.InfoStatis;
	import app.view.components.MainTool;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class InfoStatisMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "InfoStatisMediator";
		
		public function InfoStatisMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
		}
		
		protected function get infoStatis():InfoStatis
		{
			return viewComponent as InfoStatis;
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_APP_INIT,
				AppNotification.NOTIFY_GPS_RECEIVE,
				AppNotification.NOTIFY_LAYERGPS_REFRESH,
				AppNotification.NOTIFY_TOOLBAR
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch(notification.getName())
			{
				case AppNotification.NOTIFY_APP_INIT:
				case AppNotification.NOTIFY_GPS_RECEIVE:
				case AppNotification.NOTIFY_LAYERGPS_REFRESH:
					infoStatis.countTatol = 0;
					infoStatis.countVisible = 0;
					infoStatis.countTraffic = 0;
					infoStatis.countPeople = 0;
					infoStatis.countVehicle = 0;
					infoStatis.countOffice = 0;
					
					var realTimeInfoProxy:GPSRealTimeInfoProxy = facade.retrieveProxy(GPSRealTimeInfoProxy.NAME) as GPSRealTimeInfoProxy;
					for each(var gps:GPSNewVO in realTimeInfoProxy.dicGPS)
					{
						if((gps.gpsValid) && (gps.policeType != null))
						{
							infoStatis.countTatol ++;
							
							if(gps.policeType.id != DicPoliceType.TRAFFIC.id)
							{
								if((gps.department == null) || (gps.department.ZB == 123))
								{
									infoStatis.countOffice ++;
								}
								else
								{
									infoStatis.countPeople ++;
								}
							}
							else
							{
								infoStatis.countTraffic ++;
							}
						}
						
						if(gps.isMapShow)
							infoStatis.countVisible ++;
					}
					break;
				
				case AppNotification.NOTIFY_TOOLBAR:
					if(notification.getType() == MainTool.STATIS)
					{
						infoStatis.visible = !infoStatis.visible;
					}
					break;
			}
		}
	}
}