package app.view
{
	import app.AppNotification;
	import app.model.TrackHistoryProxy;
	import app.model.TrackLinebackProxy;
	import app.model.dict.DicGPSImage;
	import app.model.dict.DicPoliceType;
	import app.model.vo.GPSVO;
	import app.model.vo.PathVO;
	import app.model.vo.TrackHistoryVO;
	import app.view.components.MainMenu;
	
	import com.esri.ags.Graphic;
	import com.esri.ags.Map;
	import com.esri.ags.events.ExtentEvent;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.geometry.Polyline;
	import com.esri.ags.layers.GraphicsLayer;
	import com.esri.ags.symbols.CompositeSymbol;
	import com.esri.ags.symbols.PictureMarkerSymbol;
	import com.esri.ags.symbols.SimpleLineSymbol;
	import com.esri.ags.symbols.SimpleMarkerSymbol;
	import com.esri.ags.symbols.Symbol;
	import com.esri.ags.symbols.TextSymbol;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.effects.Parallel;
	import mx.effects.Sequence;
	import mx.events.EffectEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.effects.Move;
	import spark.effects.supportClasses.AnimateTransformInstance;
	
	public class LayerTrackLinebackMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "LayerTrackLinebackMediator";
		
		private var trackLinebackProxy:TrackLinebackProxy = null;
				
		private var trackGraphics:ArrayCollection = new ArrayCollection;
		private var trackGPS:Dictionary = new Dictionary;
								
		public function LayerTrackLinebackMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
									
			trackLinebackProxy = facade.retrieveProxy(TrackLinebackProxy.NAME) as TrackLinebackProxy;
									
			trackLayer.visible = false;
		}
		
		private function get trackLayer():GraphicsLayer
		{
			return viewComponent as GraphicsLayer;
		}
		
		private function onTrackPointMouseOverHandler(event:MouseEvent):void
		{
			var graphic:Graphic = event.currentTarget as Graphic;
			
			var gps:GPSVO = graphic.attributes as GPSVO;
			
			//var mapPoint:MapPoint = trackLayer.map.toMapFromStage(event.stageX, event.stageY);
			
			sendNotification(AppNotification.NOTIFY_LAYERTRACK_POINTMOUSEOVER,[gps,graphic.geometry]);
		}
		
		private function onTrackPointMouseOutHandler(event:MouseEvent):void
		{
			sendNotification(AppNotification.NOTIFY_LAYERTRACK_POINTMOUSEOUT);
		}
		
		private function refreshGPS(curGPS:GPSVO):void
		{
			for each(var gps:GPSVO in trackLinebackProxy.listGPS)
			{
				var graphic:Graphic = trackGPS[gps.gpsSimCard];
				var labelSymbol:TextSymbol = (graphic.symbol as CompositeSymbol).symbols[0];
				var iconSymbol:PictureMarkerSymbol = (graphic.symbol as CompositeSymbol).symbols[1];
				var bitmap:Bitmap = iconSymbol.source as Bitmap;
				if(gps.gpsSimCard == curGPS.gpsSimCard)
				{
					labelSymbol.alpha = 1;
					bitmap.alpha = 1;
				}
				else
				{
					labelSymbol.alpha = 0.3;
					bitmap.alpha = 0.3;
				}
				graphic.geometry = gps.mapPoint;
				graphic.refresh();
			}
		}
		
		private function drawPath(path:PathVO):void
		{
			//画GPS轨迹线
			var symbolTrackLine:SimpleLineSymbol = new SimpleLineSymbol;	
			symbolTrackLine.style = SimpleLineSymbol.STYLE_DASH;
			symbolTrackLine.color = 0xFF0000;
			symbolTrackLine.width = 2;
			
			var graphic:Graphic = new Graphic;
			graphic.attributes = path;
			graphic.geometry = path.line;
			graphic.symbol = symbolTrackLine;
			graphic.autoMoveToTop = false;
			
			trackGraphics.addItem(graphic);
			trackLayer.add(graphic);
			
			//画GPS轨迹点
			for each(var item:GPSVO in path.listGPS)
			{
				var pointSymbol:PictureMarkerSymbol = item.inService?
					new PictureMarkerSymbol(new Bitmap(item.serviceStatus.imageSource as BitmapData))
					:
					new PictureMarkerSymbol(new Bitmap(DicGPSImage.getImageClass(DicGPSImage.STATUS,0) as BitmapData));
				
				/*var symbolPoint:SimpleMarkerSymbol = new SimpleMarkerSymbol(SimpleMarkerSymbol.STYLE_SQUARE,10,0x888888);
				symbolPoint.color = (item.serviceStatus != null)?item.serviceStatus.color:0x555555;*/
				
				graphic = new Graphic;
				graphic.attributes = item;
				graphic.geometry = item.mapPoint;
				graphic.symbol = pointSymbol;
				graphic.addEventListener(MouseEvent.MOUSE_OVER, onTrackPointMouseOverHandler);
				graphic.addEventListener(MouseEvent.MOUSE_OUT, onTrackPointMouseOutHandler);
				
				trackGraphics.addItem(graphic);
				trackLayer.add(graphic);				
			}
			
			var graphicGPS:Graphic = trackGPS[path.lastGPS.gpsSimCard];
			graphicGPS.geometry = path.lastGPS.mapPoint;
			graphicGPS.refresh();
			
			trackLayer.moveToTop(graphicGPS);
		}
				
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_MENUBAR,	
				AppNotification.NOTIFY_TRACKLINEBACK_GET,	
				AppNotification.NOTIFY_TRACKLINEBACK_FLASH,
				AppNotification.NOTIFY_TRACKLINEBACK_FLASHPATH
				//AppNotification.NOTIFY_TRACKLINEBACK_LOCATE
				];
		}
		
		override public function handleNotification(notification:INotification):void
		{			
			switch(notification.getName())
			{			
				case AppNotification.NOTIFY_MENUBAR:
					trackLayer.visible = (notification.getType() == MainMenu.SERVICELINEBACK);
					
					if(notification.getType() == MainMenu.SERVICELINEBACK)
					{
						trackGraphics.removeAll();
						trackGPS = new Dictionary;
						trackLayer.clear();
					}
					break;
				
				case AppNotification.NOTIFY_TRACKLINEBACK_GET:
					drawAll();
					break;
				
				case AppNotification.NOTIFY_TRACKLINEBACK_FLASH:
					flashTrack(notification.getBody() as GPSVO);
					break;
				
				case AppNotification.NOTIFY_TRACKLINEBACK_FLASHPATH:
					flashPath(notification.getBody() as PathVO);
					break;
			}
		}
		
		private function drawAll():void
		{				
			trackLayer.clear();
			
			trackGPS 	=  new Dictionary;
			
			for each(var gps:GPSVO in trackLinebackProxy.listGPS)
			{
				//画当前GPS图标
				var labelSymbol:TextSymbol = new TextSymbol;
				var textFormat:TextFormat = new TextFormat;
				textFormat.bold = true;
				labelSymbol.textFormat = textFormat;
				labelSymbol.text = gps.gpsName;
				if(gps.policeTypeID == DicPoliceType.VEHICLE.id)
					labelSymbol.yoffset = 20;
				else
					labelSymbol.yoffset = 30;
				
				var iconSymbol:PictureMarkerSymbol = new PictureMarkerSymbol(gps.graphicSource);
				
				var graphic:Graphic = new Graphic;				
				graphic.attributes = gps;
				graphic.geometry = gps.mapPoint;
				graphic.symbol = new CompositeSymbol([labelSymbol,iconSymbol]);
				graphic.autoMoveToTop = false;
				
				graphic.addEventListener(MouseEvent.MOUSE_OVER, onTrackPointMouseOverHandler);
				graphic.addEventListener(MouseEvent.MOUSE_OUT, onTrackPointMouseOutHandler);
				
				trackLayer.add(graphic);
				
				trackGPS[gps.gpsSimCard] = graphic;
			}
		}
				
		/*private function onTrackPointMouseOverHandler(event:MouseEvent):void
		{
			sendNotification(AppNotification.NOTIFY_LAYERTRACK_POINTMOUSEOVER,event.currentTarget);
		}
		
		private function onTrackPointMouseOutHandler(event:MouseEvent):void
		{
			sendNotification(AppNotification.NOTIFY_LAYERTRACK_POINTMOUSEOUT);
		}*/
		
		
		private function flashTrack(gps:GPSVO):void
		{			
			for each(var graphic:Graphic in trackGraphics)
			{
				trackLayer.remove(graphic);
			}
			trackGraphics.removeAll();
			
			refreshGPS(gps);			
			
			var track:TrackHistoryVO = trackLinebackProxy.dict[gps.gpsSimCard];
						
			for each(var path:PathVO in track.listPath)
			{					
				drawPath(path);
			}		
			
			var graphics:Array = new Array;
			graphics = graphics.concat(trackGraphics);
			graphics.push(trackGPS[gps.gpsSimCard]);
			
			sendNotification(AppNotification.NOTIFY_MAP_FLASH,graphics)
		}
		
		private function flashPath(path:PathVO):void
		{			
			for each(var graphic:Graphic in trackGraphics)
			{
				trackLayer.remove(graphic);
			}
			trackGraphics.removeAll();
			
			refreshGPS(path.lastGPS);
			
			var track:TrackHistoryVO = trackLinebackProxy.dict[path.lastGPS.gpsSimCard];
			
			drawPath(path);
			
			var graphics:Array = new Array;
			graphics = graphics.concat(trackGraphics);
			graphics.push(trackGPS[path.lastGPS.gpsSimCard]);
			
			sendNotification(AppNotification.NOTIFY_MAP_FLASH,graphics)
		}
	}
}