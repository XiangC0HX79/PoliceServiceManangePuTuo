package app.view
{
	import com.esri.ags.Graphic;
	import com.esri.ags.events.GraphicEvent;
	import com.esri.ags.events.ZoomEvent;
	import com.esri.ags.geometry.Polygon;
	import com.esri.ags.layers.GraphicsLayer;
	import com.esri.ags.layers.supportClasses.LOD;
	import com.esri.ags.symbols.CompositeSymbol;
	import com.esri.ags.symbols.MarkerSymbol;
	import com.esri.ags.symbols.PictureMarkerSymbol;
	import com.esri.ags.symbols.SimpleFillSymbol;
	import com.esri.ags.symbols.SimpleLineSymbol;
	import com.esri.ags.symbols.SimpleMarkerSymbol;
	import com.esri.ags.symbols.TextSymbol;
	
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.effects.Sequence;
	
	import spark.effects.Fade;
	import spark.formatters.DateTimeFormatter;
	
	import app.AppNotification;
	import app.model.GPSRealTimeInfoProxy;
	import app.model.dict.DicGPSImage;
	import app.model.dict.DicLayer;
	import app.model.dict.DicPoliceType;
	import app.model.vo.AppConfigVO;
	import app.model.vo.GPSNewVO;
	import app.view.components.MainMenu;
	import app.view.components.MainTool;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class LayerGPSMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "LayerGPSMediator";
				
		private var gpsRealTimeInfoProxy:GPSRealTimeInfoProxy;
				
		private var dicSelected:Dictionary = new Dictionary;
		
		private var dicGraphics:Dictionary = new Dictionary;
		
		private var tempGpsGraphic:Graphic = null;
		
		private var gpsTimer:Timer = new Timer(10000);
				
		private var isServicePointPanel:Boolean = false;
		
		public function LayerGPSMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			gpsTimer.addEventListener(TimerEvent.TIMER,onTimer);
			
			gpsLayer.addEventListener(GraphicEvent.GRAPHIC_ADD,onGraphicAdd);
			
			gpsRealTimeInfoProxy = facade.retrieveProxy(GPSRealTimeInfoProxy.NAME) as GPSRealTimeInfoProxy;
		}
		
		private function get gpsLayer():GraphicsLayer
		{
			return viewComponent as GraphicsLayer;
		}
		
		private function get isShowLabel():Boolean
		{
			return ((this.scale >= AppConfigVO.scaleVisible) && (DicLayer.GPSNAME.selected));
		}
		
		private var scale:Number = 1;
				
		private function onTimer(event:TimerEvent):void
		{
			gpsRealTimeInfoProxy.GetGPSRealTimeInfo();
		}		
		
		private function onGraphicAdd(event:GraphicEvent):void
		{	
			event.graphic.addEventListener(MouseEvent.CLICK, onGPSClick);
		}
		
		private function onZoomEnd(event:ZoomEvent):void
		{			
			for(var i:Number = 0;i<gpsLayer.map.lods.length;i++)
			{
				var lod:LOD = gpsLayer.map.lods[i];
				if(gpsLayer.map.scale == lod.scale)
				{
					if(AppConfigVO.arrScale.length > i)
						this.scale = AppConfigVO.arrScale[i];
					else
						this.scale = 1;
				}
			}
			
			refreshAll();
		}
		
		private function onGPSClick(event:MouseEvent):void
		{
			var gps:GPSNewVO = (event.currentTarget as Graphic).attributes as GPSNewVO;
			
			if(gps.policeTypeID == DicPoliceType.VEHICLE.id)
			{
				sendNotification(AppNotification.NOTIFY_LAYERGPS_VEHICLECLICK,gps);
			}
			else //if(gps.inService)
			{
				sendNotification(AppNotification.NOTIFY_LAYERGPS_POLICECLICK,gps);
			}
			/*else
			{
				sendNotification(AppNotification.NOTIFY_LAYERGPS_PEOPLECLICK,gps);				
			}*/
		}
		
		/*private function selectGPS(arr:Array):void
		{
			for each(var item:Graphic in dicGraphics)
			{
				(item.attributes as GPSVO).selected = false;
			}
			
			for each(var gps:GPSVO in arr)
			{
				gps.selected = true;
			}
		}*/
		
		private function createGPSGraphic(gps:GPSNewVO):Graphic
		{
			var labelSymbol:TextSymbol = null;
			var labelBackSymbol:TextSymbol = null;
			var iconSymbol:PictureMarkerSymbol = null;
			var textFormat:TextFormat = null;			
			if((gps.type == "A") || (gps.type == "Z"))
			{
				iconSymbol = new PictureMarkerSymbol("assets/image/emergency.swf");
			}
			else
			{
				iconSymbol = new PictureMarkerSymbol(gps.graphicSource);
				
				iconSymbol.width = gps.graphicSource.width * this.scale;
				iconSymbol.height = gps.graphicSource.height * this.scale;
			}
			
			textFormat = new TextFormat;
			textFormat.bold = true;
			//textFormat.font = "宋体";
			
			labelSymbol = new TextSymbol;		
			labelSymbol.textFormat = textFormat;
			labelSymbol.backgroundColor = 0xFF;
			labelSymbol.color = 0xFFFFFF;			
			
			labelSymbol.background = this.isShowLabel;
			
			var name:String = gps.radioNo + " " + gps.gpsName + " " + (gps.department?gps.department.shortName:"") + " " + (gps.policeType?gps.policeType.label:"");
			//var name:String = gps.radioNo + " " + gps.gpsName + " " + gps.department.shortName + " " + gps.policeType.label;
			labelSymbol.text = labelSymbol.background?name:" ";
			
			if(gps.policeTypeID == DicPoliceType.VEHICLE.id)
				labelSymbol.yoffset = 20;
			else
				labelSymbol.yoffset = 30;
			
			/*labelBackSymbol = new TextSymbol;
			labelBackSymbol.textFormat = textFormat;
			labelBackSymbol.color = 0xEEEEEE;			
			labelBackSymbol.text = gps.gpsName;
			if(gps.policeTypeID == DicPoliceType.VEHICLE.id)
				labelBackSymbol.yoffset = 18;
			else
				labelBackSymbol.yoffset = 28;
			labelBackSymbol.xoffset = 2;*/
			
			var result:Graphic = new Graphic();						
			result.attributes = gps;
			result.geometry = gps.mapPoint;	
			result.symbol = new CompositeSymbol([labelSymbol,iconSymbol]);
			result.visible = gps.isMapShow;
			
			return result;
		}
		
		private function createTempGpsGraphic(gps:GPSNewVO):Graphic
		{
			var labelSymbol:TextSymbol = null;
			var iconSymbol:PictureMarkerSymbol = null;
			var textFormat:TextFormat = null;
			if((gps.type == "A") || (gps.type == "Z"))
			{
				iconSymbol = new PictureMarkerSymbol("assets/image/emergency.swf");
			}
			else
			{
				iconSymbol = new PictureMarkerSymbol(gps.graphicSource);
				
				iconSymbol.width = gps.graphicSource.width * this.scale;
				iconSymbol.height = gps.graphicSource.height * this.scale;
			}
			
			labelSymbol = new TextSymbol;
			textFormat = new TextFormat;
			textFormat.bold = true;
			labelSymbol.textFormat = textFormat;
			labelSymbol.backgroundColor = 0xFF;
			labelSymbol.color = 0xFFFFFF;			
			
			labelSymbol.background = this.isShowLabel;
			
			var name:String = gps.radioNo + " " + gps.gpsName + " " + (gps.department?gps.department.shortName:"") + " " + (gps.policeType?gps.policeType.label:"");
			labelSymbol.text = labelSymbol.background?name:" ";
			
			if(gps.policeTypeID == DicPoliceType.VEHICLE.id)
				labelSymbol.yoffset = 20;
			else
				labelSymbol.yoffset = 30;
						
			var selectedSymbol:SimpleMarkerSymbol = null;
			if(gps.policeTypeID != DicPoliceType.VEHICLE.id)
			{
				selectedSymbol = new SimpleMarkerSymbol(SimpleMarkerSymbol.STYLE_SQUARE,60,0x0,0,0,9,0
					,new SimpleLineSymbol(SimpleLineSymbol.STYLE_SOLID,0xFF0000,1,3));
			}
			else
			{
				selectedSymbol = new SimpleMarkerSymbol(SimpleMarkerSymbol.STYLE_SQUARE,60,0x0,0,0,2,0
					,new SimpleLineSymbol(SimpleLineSymbol.STYLE_SOLID,0xFF0000,1,3));
			}
			
			var result:Graphic = new Graphic();						
			result.attributes = gps;
			result.geometry = gps.mapPoint;	
			result.symbol = new CompositeSymbol([labelSymbol,iconSymbol,selectedSymbol]);
			result.visible = gps.isMapShow;
			
			return result;
		}
		
		private function refresh(gps:GPSNewVO):void
		{
			var graphic:Graphic = dicGraphics[gps.gpsSimCard] as Graphic;
			
			if(graphic == null)
			{
				graphic = createGPSGraphic(gps);
				
				gpsLayer.add(graphic);
				
				dicGraphics[gps.gpsSimCard] = graphic;
			}
			else
			{
				if(isServicePointPanel)
				{
					graphic.visible = gps.gpsValid;
				}
				else
				{
					graphic.visible = gps.isMapShow;					
				}
				
				graphic.geometry = gps.mapPoint;
				
				//更新勤务图标
				var graphicSymbol:CompositeSymbol = graphic.symbol as CompositeSymbol;				
				var symbolArr:ArrayCollection = graphicSymbol.symbols as ArrayCollection;
				
				var iconSymbol:PictureMarkerSymbol = symbolArr[1] as PictureMarkerSymbol;
				if((gps.type == "A") || (gps.type == "Z"))
				{
					iconSymbol.source = "assets/image/emergency.swf";
				}
				else
				{
					iconSymbol.source = gps.graphicSource;
					
					iconSymbol.width = gps.graphicSource.width * this.scale;
					iconSymbol.height = gps.graphicSource.height * this.scale;
				}
				
				
				var labelSymbol:TextSymbol = symbolArr[0] as TextSymbol;
				labelSymbol.background = this.isShowLabel;
				
				var name:String = gps.radioNo + " " + gps.gpsName + " " + (gps.department?gps.department.shortName:"") + " " + (gps.policeType?gps.policeType.label:"");
				//var name:String = gps.radioNo + " " + gps.gpsName + " " + gps.department.shortName + " " + gps.policeType.label;
				labelSymbol.text = labelSymbol.background?name:" ";
				
				if(symbolArr.length == 3)
				{
					symbolArr.removeItemAt(2);
				}
				
				if(dicSelected[gps.gpsSimCard] != undefined) 
				{
					var selectedSymbol:SimpleMarkerSymbol = null;
					if(gps.policeTypeID != DicPoliceType.VEHICLE.id)
					{
						selectedSymbol = new SimpleMarkerSymbol(SimpleMarkerSymbol.STYLE_SQUARE,60,0x0,0,0,9,0
							,new SimpleLineSymbol(SimpleLineSymbol.STYLE_SOLID,0xFF0000,1,3));
					}
					else
					{
						selectedSymbol = new SimpleMarkerSymbol(SimpleMarkerSymbol.STYLE_SQUARE,60,0x0,0,0,2,0
							,new SimpleLineSymbol(SimpleLineSymbol.STYLE_SOLID,0xFF0000,1,3));
					}
					symbolArr.addItem(selectedSymbol);
				}
				
				graphic.refresh();
			}
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_MENUBAR,
				
				//AppNotification.NOTIFY_TRACKHISTORY_INFOWINDOWGETLIST,
				
				//AppNotification.NOTIFY_INIT_REMOTECONFIG,
				AppNotification.NOTIFY_APP_INIT,
				AppNotification.NOTIFY_GPS_RECEIVE,
				AppNotification.NOTIFY_GPS_CHANGESTATE,
				
				AppNotification.NOTIFY_OVERVIEW_SET,
				
				AppNotification.NOTIFY_LAYERGPS_FLASH,
				
				AppNotification.NOTIFY_TOOLBAR,
				
				AppNotification.NOTIFY_LAYER_GPS_VISIBLE
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{			
			switch(notification.getName())
			{
				case AppNotification.NOTIFY_MENUBAR:
					gpsLayer.visible = (
						(notification.getType() != MainMenu.SERVICELINEBACK)
						&& (notification.getType() != MainMenu.SERVICETRACKHISTORY)
						//&& (notification.getType() != MainMenu.QW_POINT)
					);
					
					isServicePointPanel = notification.getType() == MainMenu.QW_POINT;
					
					clearSelect();
					
					refreshAll();
					break;
								
				//case AppNotification.NOTIFY_TRACKHISTORY_INFOWINDOWGETLIST:
				//	gpsLayer.visible = false;
				//	break;
				
				//case AppNotification.NOTIFY_INIT_REMOTECONFIG:
				//	break;
				
				case AppNotification.NOTIFY_APP_INIT:
					onZoomEnd(null);
					
					if(!AppConfigVO.debug)
					{
						gpsTimer.delay = GPSNewVO.RefreshDiff*60*1000;
					}
										
					gpsTimer.start();
										
					gpsLayer.map.addEventListener(ZoomEvent.ZOOM_END,onZoomEnd);
					break;
				
				case AppNotification.NOTIFY_GPS_RECEIVE:
					refreshAll();
					break;
				
				case AppNotification.NOTIFY_GPS_CHANGESTATE:
					refresh(notification.getBody() as GPSNewVO);
					break;
				
				case AppNotification.NOTIFY_OVERVIEW_SET:
					refreshAll();
					break;
				
				case AppNotification.NOTIFY_LAYERGPS_FLASH:
					flash(notification.getBody() as GPSNewVO);
					break;
				
				case AppNotification.NOTIFY_TOOLBAR:
					if(notification.getType() == MainTool.CLEARMAP)
					{
						clearSelect();
					}
					else if(notification.getType() == MainTool.REFRESHGPS)
					{
						gpsRealTimeInfoProxy.RefreshAll();
					}
					break;
				
				case AppNotification.NOTIFY_LAYER_GPS_VISIBLE:
					gpsLayer.visible = Boolean(notification.getBody());
					break;
			}			
		}
		
		private function refreshAll():void
		{			
			for each(var gps:GPSNewVO in gpsRealTimeInfoProxy.dicGPS)
			{
				refresh(gps);
			}
			
			sendNotification(AppNotification.NOTIFY_LAYERGPS_REFRESH);
		}
		
		private function clearSelect():void
		{			
			var preSelected:Array = new Array;
			for each(var item:GPSNewVO in dicSelected)
			{				
				preSelected.push(item);
			}
			
			dicSelected = new Dictionary;	
			
			for each(item in preSelected)
			{
				refresh(item);
			}
			
			if(tempGpsGraphic != null)
			{
				gpsLayer.remove(tempGpsGraphic);
				tempGpsGraphic = null;
			}
		}
		
		private function flash(gps:GPSNewVO):void
		{			
			clearSelect();
			
			if(gps.isMapShow)
			{
				dicSelected[gps.gpsSimCard] = gps;
				
				refresh(gps);
				
				sendNotification(AppNotification.NOTIFY_MAP_FLASH,[dicGraphics[gps.gpsSimCard]]);
			}
			else
			{
				tempGpsGraphic = createTempGpsGraphic(gps);			
				gpsLayer.add(tempGpsGraphic);			
				sendNotification(AppNotification.NOTIFY_MAP_FLASH,[tempGpsGraphic]);
			}
		}
	}
}