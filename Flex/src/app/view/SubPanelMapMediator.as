package app.view
{
	import app.event.AppEvent;
	import app.AppNotification;
	import app.model.vo.AppConfigVO;
	import app.model.GPSRealTimeInfoProxy;
	import app.model.TrackRealtimeProxy;
	import app.model.vo.GPSNewVO;
	import app.model.dict.DicPoliceType;
	import app.model.dict.DicServiceStatus;
	import app.view.components.BasePopupPanel;
	import app.view.components.SubPanelMap;
	
	import com.esri.ags.Graphic;
	import com.esri.ags.events.MapEvent;
	import com.esri.ags.geometry.Extent;
	import com.esri.ags.symbols.CompositeSymbol;
	import com.esri.ags.symbols.PictureMarkerSymbol;
	import com.esri.ags.symbols.TextSymbol;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	import mx.events.FlexEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class SubPanelMapMediator extends Mediator implements IMediator
	{
		private var trackRealtimeProxy:TrackRealtimeProxy;
		
		public function SubPanelMapMediator(mediatorName:String=null, viewComponent:Object=null)
		{
			super(mediatorName, viewComponent);
			
			subPanelMap.addEventListener(FlexEvent.CREATION_COMPLETE,onCreateComplete);
			subPanelMap.addEventListener(BasePopupPanel.SUBPANEL_CLOSED,onClosed);
			
			subPanelMap.addEventListener(AppEvent.FLASHGPS,onClick);
			subPanelMap.addEventListener(AppEvent.LOCATEGPS,onDoubleClick);
			
			trackRealtimeProxy = facade.retrieveProxy(TrackRealtimeProxy.NAME) as TrackRealtimeProxy;
		}
		
		private function get subPanelMap():SubPanelMap
		{
			return viewComponent as SubPanelMap;
		}
		
		private function onClick(event:AppEvent):void
		{
			sendNotification(AppNotification.NOTIFY_LAYERGPS_FLASH,event.data);
		}
		
		private function onDoubleClick(event:AppEvent):void
		{
			sendNotification(AppNotification.NOTIFY_LAYERGPS_LOCATE,event.data);
		}
		
		private function onCreateComplete(event:FlexEvent):void
		{			
			subPanelMap.map.addEventListener(MapEvent.LOAD,onMapLoad);
			
			subPanelMap.map.initialExtent =  new Extent(
				subPanelMap.gps.mapPoint.x - 100
				,subPanelMap.gps.mapPoint.y - 100
				,subPanelMap.gps.mapPoint.x + 100
				,subPanelMap.gps.mapPoint.y + 100
					);
			
			subPanelMap.tileLayer.url = AppConfigVO.tileMapUrl;
		}
		
		private function onMapLoad(event:MapEvent):void
		{
			subPanelMap.map.zoomToInitialExtent();
			
			var graphicGPS:Graphic = subPanelMap.gr;
			var labelSymbol:TextSymbol = null;
			var iconSymbol:PictureMarkerSymbol = null;
			var textFormat:TextFormat = null;
			iconSymbol = new PictureMarkerSymbol(subPanelMap.gps.graphicSource);
			
			labelSymbol = new TextSymbol;
			textFormat = new TextFormat;
			textFormat.bold = true;
			labelSymbol.textFormat = textFormat;
			labelSymbol.text = subPanelMap.gps.gpsName;
			
			if(subPanelMap.gps.policeTypeID == DicPoliceType.VEHICLE.id)
				labelSymbol.yoffset = 20;
			else
				labelSymbol.yoffset = 30;
							
			graphicGPS.attributes = subPanelMap.gps;
			graphicGPS.geometry = subPanelMap.gps.mapPoint;	
			graphicGPS.symbol = new CompositeSymbol([labelSymbol,iconSymbol]);
			
			graphicGPS.refresh();
		}
		
		private function onClosed(event:Event):void
		{
			trackRealtimeProxy.remove(subPanelMap.gps);
		}
		
		override public function listNotificationInterests():Array
		{
			return [				
				AppNotification.NOTIFY_GPS_RECEIVE,
				AppNotification.NOTIFY_GPS_CHANGESTATE
				];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch(notification.getName())
			{				
				case AppNotification.NOTIFY_GPS_RECEIVE:
					if(subPanelMap.map.loaded)
					{
						subPanelMap.map.extent = new Extent(
							subPanelMap.gps.mapPoint.x - 100
							,subPanelMap.gps.mapPoint.y - 100
							,subPanelMap.gps.mapPoint.x + 100
							,subPanelMap.gps.mapPoint.y + 100
						);
						
						subPanelMap.gr.geometry = subPanelMap.gps.mapPoint;
						subPanelMap.gr.attributes = subPanelMap.gps;
						
						//更新勤务图标
						var graphicSymbol:CompositeSymbol = subPanelMap.gr.symbol as CompositeSymbol;				
						var symbolArr:ArrayCollection = graphicSymbol.symbols as ArrayCollection;
						
						var iconSymbol:PictureMarkerSymbol =  symbolArr[1];
						iconSymbol.source = subPanelMap.gps.graphicSource;
						
						subPanelMap.gr.refresh();
					}
					break;
				
				case AppNotification.NOTIFY_GPS_CHANGESTATE:
					if(subPanelMap.map.loaded)
					{
						/*subPanelMap.map.extent = new Extent(
							subPanelMap.gps.mapPoint.x - 250
							,subPanelMap.gps.mapPoint.y - 250
							,subPanelMap.gps.mapPoint.x + 250
							,subPanelMap.gps.mapPoint.y + 250
						);
											
						subPanelMap.gr.geometry = subPanelMap.gps.mapPoint;
						subPanelMap.gr.attributes = subPanelMap.gps;*/
						
						//更新勤务图标
						graphicSymbol = subPanelMap.gr.symbol as CompositeSymbol;				
						symbolArr = graphicSymbol.symbols as ArrayCollection;
						
						iconSymbol =  symbolArr[1];
						iconSymbol.source = subPanelMap.gps.graphicSource;
												
						subPanelMap.gr.refresh();
					}
					break;
			}
		}
	}
}