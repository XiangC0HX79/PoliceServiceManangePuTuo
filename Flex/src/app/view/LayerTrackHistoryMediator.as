package app.view
{
	import app.AppNotification;
	import app.model.TrackHistoryProxy;
	import app.model.dict.DicGPSImage;
	import app.model.dict.DicPoliceType;
	import app.model.dict.DicServiceStatus;
	import app.model.vo.GPSVO;
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
	
	public class LayerTrackHistoryMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "LayerTrackHistoryMediator";
		
		private var trackHistoryProxy:TrackHistoryProxy = null;
				
		private var trackLine:Dictionary = new Dictionary;
		private var trackPoint:Dictionary = new Dictionary;
		private var trackGPS:Dictionary = new Dictionary;
		private var movieLine:Dictionary = new Dictionary;
						
		private var trackTimer:Timer = new Timer(50);
		private var trackTime:Date = new Date;
		private var trackSpeed:Number = 60;
		
		public function LayerTrackHistoryMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
						
			trackTimer.addEventListener(TimerEvent.TIMER,onTimer);
			
			trackHistoryProxy = facade.retrieveProxy(TrackHistoryProxy.NAME) as TrackHistoryProxy;
			
			trackLayer.visible = false;
		}
		
		private function get trackLayer():GraphicsLayer
		{
			return viewComponent as GraphicsLayer;
		}
		
		private function onTimer(event:TimerEvent):void
		{						
			trackTime = new Date(trackTime.time + trackTimer.delay * trackSpeed);
			
			drawMovieLine(trackTime);
			
			if(trackTime.time > trackHistoryProxy.trackEndTime.time)
			{
				trackTimer.stop();
			}
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
		
		private function getTrackPoint(gps:GPSVO):Array
		{
			var result:Array = new Array;
			
			for each(var item:Graphic in trackPoint)
			{
				var gpsItem:GPSVO = item.attributes as GPSVO;
				if(gpsItem.gpsSimCard == gps.gpsSimCard)
				{
					result.push(item);
				}
			}
			
			return result;
		}
		
		private function getTrackHistory(gps:GPSVO):TrackHistoryVO
		{
			return (trackLine[gps.gpsSimCard] as Graphic).attributes as TrackHistoryVO;
		}
				
		private function drawMovieLine(date:Date):void
		{
			for each(var gr:Graphic in trackGPS)
			{	
				var gps:GPSVO = gr.attributes as GPSVO;
				
				var trackHistory:TrackHistoryVO = getTrackHistory(gps);
				
				var path:Array = new Array;
				for each(var item:GPSVO in trackHistory.listGPS)
				{				
					if(date.time > item.gpsDate.time)
					{
						path.push(item.mapPoint);
					}
					else
					{
						break;
					}
				}			
				
				var curGPS:GPSVO = trackHistoryProxy.getGPSByDate(gps,date);
				
				//var mapPoint:MapPoint = trackHistoryProxy.getMapPointByDate(gps,date);
				path.push(curGPS.mapPoint);
				
				var graphic:Graphic = movieLine[gps.gpsSimCard];
				graphic.geometry = new Polyline([path]);
				graphic.refresh();
				
				//更新GPS图标/位置/属性
				graphic = trackGPS[gps.gpsSimCard];
				
				var graphicSymbol:CompositeSymbol = graphic.symbol as CompositeSymbol;				
				var symbolArr:ArrayCollection = graphicSymbol.symbols as ArrayCollection;
				
				var iconSymbol:PictureMarkerSymbol = symbolArr[1] as PictureMarkerSymbol;
				iconSymbol.source = curGPS.graphicSource;
				
				graphic.attributes = curGPS;
				
				graphic.geometry = curGPS.mapPoint;
				
				graphic.refresh();	
			}
			
			sendNotification(AppNotification.NOTIFY_LAYERTRACK_MOVEUPDATE,date);
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_MENUBAR,
				AppNotification.NOTIFY_TRACKHISTORY_CLEAR,
				//AppNotification.NOTIFY_TRACKHISTORY_GET,		
				AppNotification.NOTIFY_TRACKHISTORY_CHANGE,
				//AppNotification.NOTIFY_TRACKHISTORY_GETLIST,
				AppNotification.NOTIFY_TRACKHISTORY_FLASH,
				AppNotification.NOTIFY_TRACKHISTORY_LOCATE,
				AppNotification.NOTIFY_TRACKHISTORY_PLAY,
				AppNotification.NOTIFY_TRACKHISTORY_PAUSE,
				AppNotification.NOTIFY_TRACKHISTORY_STOP,
				AppNotification.NOTIFY_TRACKHISTORY_SLIDE,
				AppNotification.NOTIFY_TRACKHISTORY_SPEED,
				//AppNotification.NOTIFY_TRACKHISTORY_FLASHPOINT,
				//AppNotification.NOTIFY_TRACKHISTORY_LOCATEPOINT
				//AppNotification.NOTIFY_TRACKHISTORY_INFOWINDOWGETLIST
				];
		}
		
		override public function handleNotification(notification:INotification):void
		{			
			switch(notification.getName())
			{			
				case AppNotification.NOTIFY_MENUBAR:	
					trackLayer.visible = (notification.getType() == MainMenu.SERVICETRACKHISTORY);
					break;
				
				//case AppNotification.NOTIFY_TRACKHISTORY_INFOWINDOWGETLIST:
				//	trackLayer.visible = true;
				//	break;
				
				//case AppNotification.NOTIFY_TRACKHISTORY_GET:
					//clear();					
				//	draw(notification.getBody() as TrackHistoryVO);
				//	break;
				
				case AppNotification.NOTIFY_TRACKHISTORY_CHANGE:
					refresh();
					break;
				
				case AppNotification.NOTIFY_TRACKHISTORY_CLEAR:
				//case AppNotification.NOTIFY_TRACKHISTORY_GETLIST:
					clear();	
					break;
				
				case AppNotification.NOTIFY_TRACKHISTORY_FLASH:
					flashTrackHistory(notification.getBody() as GPSVO);
					break;
				
				case AppNotification.NOTIFY_TRACKHISTORY_LOCATE:
					locateTrackHistory(notification.getBody() as GPSVO);
					break;
				
				case AppNotification.NOTIFY_TRACKHISTORY_PLAY:
					play(
						notification.getBody()[0] as Date,
						notification.getBody()[1] as Number
						);
					break;		
				
				case AppNotification.NOTIFY_TRACKHISTORY_PAUSE:					
					if(trackTimer.running)
					{
						trackTimer.stop();
					}
					break;
				
				case AppNotification.NOTIFY_TRACKHISTORY_STOP:	
					stop();
					break;
				
				case AppNotification.NOTIFY_TRACKHISTORY_SLIDE:
					slide(notification.getBody() as Date);
					break;
				
				case AppNotification.NOTIFY_TRACKHISTORY_SPEED:
					trackSpeed = notification.getBody() as Number;
					break;
				
			/*	case AppNotification.NOTIFY_TRACKHISTORY_FLASHPOINT:
					flashTrackPoint(notification.getBody() as GPSVO);
					break;
				
				case AppNotification.NOTIFY_TRACKHISTORY_LOCATEPOINT:
					locateTrackPoint(notification.getBody() as GPSVO);
					break;*/
			}
		}
		
		private function refresh():void
		{
			trackLayer.clear();
			
			for each(var trackHistory:TrackHistoryVO in trackHistoryProxy.listTrackHistory)
			{
				draw(trackHistory);
			}			
		}
		
		/*private function update():void
		{
			for each(var graphic:Graphic in trackLine)
			{
				graphic.visible = false;
			}
			for each(graphic in trackPoint)
			{
				graphic.visible = false;
			}
			for each(graphic in trackGPS)
			{
				graphic.visible = false;
			}
			for each(graphic in movieLine)
			{
				graphic.visible = false;
			}
			
			for each(var gps:GPSVO in trackHistoryProxy.listSelected)
			{
				if(trackLine[gps.gpsSimCard] != undefined)
				{
					trackLine[gps.gpsSimCard].visible = true;
				}
				for each(graphic in getTrackPoint(gps))
				{
					graphic.visible = true;	
				}
				if(trackGPS[gps.gpsSimCard] != undefined)
				{
					trackGPS[gps.gpsSimCard].visible = true;
				}
				if(movieLine[gps.gpsSimCard] != undefined)
				{
					movieLine[gps.gpsSimCard].visible = true;
				}
			}
		}*/
		
		private function slide(date:Date):void
		{
			if(trackTimer.running)
			{
				trackTime = date;
			}
			else
			{
				drawMovieLine(date);
			}
		}
		
		private function clear():void
		{
			trackTimer.stop();
			
			trackLayer.clear();
			
			trackLine 	= new Dictionary;
			trackPoint 	= new Dictionary;
			trackGPS 	= new Dictionary;
			movieLine 	= new Dictionary;
		}
		
		private function draw(trackHistory:TrackHistoryVO):void
		{						
			//for each(var trackHistory:TrackHistoryVO in trackHistoryProxy.listTrackHistory)
			//{
				//var gps:GPSVO = trackHistory.gps;
				
				//画GPS轨迹线
				var symbolTrackLine:SimpleLineSymbol = new SimpleLineSymbol;	
				symbolTrackLine.style = SimpleLineSymbol.STYLE_DASH;
				symbolTrackLine.color = 0xFF0000;
				symbolTrackLine.width = 2;
				
				var graphic:Graphic = new Graphic;
				graphic.attributes = trackHistory;
				graphic.geometry = trackHistory.line;
				graphic.symbol = symbolTrackLine;
				graphic.mouseEnabled = false;
				
				trackLine[trackHistory.firstGPS.gpsSimCard] = graphic;
				trackLayer.add(graphic);
				
				//动画轨迹线
				symbolTrackLine = new SimpleLineSymbol;	
				symbolTrackLine.style = SimpleLineSymbol.STYLE_SOLID;
				symbolTrackLine.color = 0xFF0000;
				symbolTrackLine.width = 2;
				
				graphic = new Graphic;
				//graphic.geometry = new Polyline;
				graphic.symbol = symbolTrackLine;
				graphic.mouseEnabled = false;
				
				movieLine[trackHistory.firstGPS.gpsSimCard] = graphic;
				trackLayer.add(graphic);
				
				//画GPS轨迹点
				for each(var item:GPSVO in trackHistory.listGPS)
				{
					var pointSymbol:PictureMarkerSymbol = item.inService?
						new PictureMarkerSymbol(new Bitmap(item.serviceStatus.imageSource as BitmapData))
						:
						new PictureMarkerSymbol(new Bitmap(DicGPSImage.getImageClass(DicGPSImage.STATUS) as BitmapData));
										
					//var symbolPoint:SimpleMarkerSymbol = new SimpleMarkerSymbol(SimpleMarkerSymbol.STYLE_SQUARE,10,0x888888);
					
					//默认非勤务颜色
					//symbolPoint.color = 0x555555;
					/*for each(var dicServiceStatus:DicServiceStatus in DicServiceStatus.list)
					{
						if(item.serviceStatusName == dicServiceStatus.label)
						{
							symbolPoint.color = dicServiceStatus.color;
							break;
						}
					}*/
					
					graphic = new Graphic;
					graphic.attributes = item;
					graphic.geometry = item.mapPoint;
					graphic.symbol = pointSymbol;
					
					graphic.addEventListener(MouseEvent.MOUSE_OVER, onTrackPointMouseOverHandler);
					graphic.addEventListener(MouseEvent.MOUSE_OUT, onTrackPointMouseOutHandler);
					
					trackPoint[item.gpsID] = graphic;
					trackLayer.add(graphic);				
				}
				
				//画当前GPS图标
				var labelSymbol:TextSymbol = new TextSymbol;
				var textFormat:TextFormat = new TextFormat;
				textFormat.bold = true;
				labelSymbol.textFormat = textFormat;
				labelSymbol.text = trackHistory.firstGPS.gpsName;
				if(trackHistory.firstGPS.policeTypeID == DicPoliceType.VEHICLE.id)
					labelSymbol.yoffset = 20;
				else
					labelSymbol.yoffset = 30;
				
				var iconSymbol:PictureMarkerSymbol = new PictureMarkerSymbol(trackHistory.firstGPS.graphicSource);
				
				graphic = new Graphic;				
				graphic.attributes = trackHistory.firstGPS;//gps;
				graphic.geometry = trackHistory.firstGPS.mapPoint
				graphic.symbol = new CompositeSymbol([labelSymbol,iconSymbol]);
				
				graphic.addEventListener(MouseEvent.MOUSE_OVER, onTrackPointMouseOverHandler);
				graphic.addEventListener(MouseEvent.MOUSE_OUT, onTrackPointMouseOutHandler);
				
				trackGPS[trackHistory.firstGPS.gpsSimCard] = graphic;
				trackLayer.add(graphic);
			//}
		}
		
		/*private function onTrackPointMouseOverHandler(event:MouseEvent):void
		{
			sendNotification(AppNotification.NOTIFY_LAYERTRACK_POINTMOUSEOVER,event.currentTarget);
		}
		
		private function onTrackPointMouseOutHandler(event:MouseEvent):void
		{
			sendNotification(AppNotification.NOTIFY_LAYERTRACK_POINTMOUSEOUT);
		}*/
		
		private function flashTrackHistory(gps:GPSVO):void
		{
			if(trackLine[gps.gpsSimCard] != undefined)
			{
				var array:Array = getTrackPoint(gps);
				array.push(trackLine[gps.gpsSimCard]);	
				array.push(trackGPS[gps.gpsSimCard]);				
				sendNotification(AppNotification.NOTIFY_MAP_FLASH,array);
			}
		}
		
		private function locateTrackHistory(gps:GPSVO):void
		{
			if(trackLine[gps.gpsSimCard] != undefined)
			{
				sendNotification(AppNotification.NOTIFY_MAP_LOCATE,(trackLine[gps.gpsSimCard] as Graphic).geometry);
			}
		}
		
		/*private function flashTrackPoint(gps:GPSVO):void
		{
			if(trackPoint[gps.gpsID] != undefined)
			{			
				sendNotification(AppNotification.NOTIFY_LAYERTRACK_FLASHTRACKPOINT,[trackPoint[gps.gpsID]]);
			}
		}
		
		private function locateTrackPoint(gps:GPSVO):void
		{
			if(trackPoint[gps.gpsID] != undefined)
			{
				sendNotification(AppNotification.NOTIFY_LAYERTRACK_LOCATETRACKPOINT,(trackPoint[gps.gpsID] as Graphic).geometry);
			}
		}*/
		
		private function stop():void
		{					
			if(trackTimer.running)
			{
				trackTimer.stop();
			}
			
			for each(var item:Graphic in trackLine)
			{
				var symbolTrackLine:SimpleLineSymbol = item.symbol as SimpleLineSymbol;
				symbolTrackLine.alpha = 1;
				//item.alpha = 1;
			}
			
			for each(item in trackPoint)
			{
				var symbolPoint:PictureMarkerSymbol = item.symbol as PictureMarkerSymbol;
				//symbolPoint. . = 1;
				//item.alpha = 1;
			}
			
			drawMovieLine(trackHistoryProxy.trackBeginTime);
		}
		
		private function play(beginTime:Date,speed:Number):void
		{			
			if(!trackTimer.running)
			{
				//trackLayer.map.extent = trackHistoryProxy.trackExtent.expand(1.5);
				
				for each(var item:Graphic in trackLine)
				{
					var symbolTrackLine:SimpleLineSymbol = item.symbol as SimpleLineSymbol;
					symbolTrackLine.alpha = 0.3;
					//item.alpha = 0.3;
				}
				for each(item in trackPoint)
				{
					var symbolPoint:PictureMarkerSymbol = item.symbol as PictureMarkerSymbol;
					//symbolPoint.alpha = 0.3;
					//item.alpha = 0.3;
				}
				
				trackTime = beginTime;
				trackSpeed = speed;
				
				trackTimer.start();
			}	
		}
	}
}