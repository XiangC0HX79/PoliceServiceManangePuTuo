package app.view
{
	import app.AppNotification;
	import app.model.TrackRealtimeProxy;
	import app.model.vo.GPSNewVO;
	import app.view.components.SubPanelMap;
	import app.view.components.SubPanelMapManager;
	
	import flash.utils.Dictionary;
	
	import mx.core.IVisualElementContainer;
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class SubPanelMapManagerMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "SubPanelMapManagerMediator";
				
		public function SubPanelMapManagerMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
		}
		
		private function get subPanelMapManager():SubPanelMapManager
		{
			return viewComponent as SubPanelMapManager;
		}
						
		private function gpsExist(gps:GPSNewVO):Boolean
		{
			var elementContainer:IVisualElementContainer = subPanelMapManager as IVisualElementContainer;
			for(var i:Number = 0;i< elementContainer.numElements;i++)
			{
				var subMap:SubPanelMap = elementContainer.getElementAt(i) as SubPanelMap;
				if(gps.gpsSimCard == subMap.gps.gpsSimCard)
					return true;
			}
			
			return false;
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_TRACKREALTIME_REFRESH
				];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch(notification.getName())
			{				
				case AppNotification.NOTIFY_TRACKREALTIME_REFRESH:
					var trackRealtimeProxy:TrackRealtimeProxy = facade.retrieveProxy(TrackRealtimeProxy.NAME) as TrackRealtimeProxy;	
					
					var elementContainer:IVisualElementContainer = subPanelMapManager as IVisualElementContainer;
					
					var arrRemove:Array = new Array;
					for(var i:Number = 0;i< elementContainer.numElements;i++)
					{
						var subMap:SubPanelMap = elementContainer.getElementAt(i) as SubPanelMap;
						if(trackRealtimeProxy.getGpsIndex(subMap.gps) == -1)
						{
							arrRemove.push(subMap);
						}
					}
					for each(var item:SubPanelMap in arrRemove)
					{
						facade.removeMediator("SubPanelMapMediator" + item.gps.gpsSimCard);
						elementContainer.removeElement(item);
					}
					
					for (i = 0;i<trackRealtimeProxy.MAXCOUNT;i++)
					{
						var gps:GPSNewVO = trackRealtimeProxy.listTrackRealtime[i] as GPSNewVO;
						if((gps != null) && (!gpsExist(gps)))
						{	
							var offset:Number = subPanelMapManager.height / trackRealtimeProxy.MAXCOUNT;
							
							var subPanelMap:SubPanelMap = new SubPanelMap;	
							subPanelMap.gps = gps;
							subPanelMap.width = subPanelMap.height = offset;
							subPanelMap.right = 0;
							//subPanelMap.x = subPanelMapManager.width - offset;
							subPanelMap.y = i * offset;
							
							var subPanelMapMediator:SubPanelMapMediator = new SubPanelMapMediator("SubPanelMapMediator" + gps.gpsSimCard,subPanelMap);
							facade.registerMediator(subPanelMapMediator);
							
							subPanelMapManager.addElement(subPanelMap);
						}
					}
					break;
			}
		}
	}
}