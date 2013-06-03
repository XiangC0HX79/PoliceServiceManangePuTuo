package app.view
{
	import app.AppNotification;
	import app.model.dict.DicPatrolZone;
	import app.model.dict.DicPoliceType;
	import app.model.dict.DicRoad;
	import app.model.vo.GPSNewVO;
	import app.model.vo.MapCursor;
	import app.view.components.MainMenu;
	import app.view.components.MainTool;
	
	import com.esri.ags.Graphic;
	import com.esri.ags.Map;
	import com.esri.ags.events.DrawEvent;
	import com.esri.ags.events.ZoomEvent;
	import com.esri.ags.geometry.Extent;
	import com.esri.ags.geometry.Geometry;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.geometry.Polygon;
	import com.esri.ags.layers.GraphicsLayer;
	import com.esri.ags.symbols.CompositeSymbol;
	import com.esri.ags.symbols.PictureMarkerSymbol;
	import com.esri.ags.symbols.SimpleFillSymbol;
	import com.esri.ags.symbols.SimpleLineSymbol;
	import com.esri.ags.symbols.SimpleMarkerSymbol;
	import com.esri.ags.symbols.TextSymbol;
	import com.esri.ags.tools.DrawTool;
	
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextFormat;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class LayerDrawMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "LayerDrawMediator";
		
		private var drawTool:DrawTool = new DrawTool;
		
		private var _radius:Number;
		private var _drawType:String = "";
		private var _resultHandle:Function;
		
		private var buffSymbol:SimpleFillSymbol;
		
		public function LayerDrawMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			drawTool.addEventListener(DrawEvent.DRAW_END,onDrawEnd);
			drawTool.addEventListener(DrawEvent.DRAW_START,onDrawStart);	
			
			layerDraw.addEventListener(MouseEvent.CLICK,onLayerMouseClick);
		}
		
		private function get layerDraw():GraphicsLayer
		{
			return viewComponent as GraphicsLayer;
		}
				
		private function onDrawStart(event:DrawEvent):void
		{			
			layerDraw.clear();
			
			var geometry:MapPoint;
			var graphic:Graphic;
			if(_drawType == DrawTool.CIRCLE)
			{
				var iconSymbol:PictureMarkerSymbol = new PictureMarkerSymbol("assets/image/i_pin.png",40,40);
				iconSymbol.xoffset = 15;
				iconSymbol.yoffset = 18;
				geometry = layerDraw.map.toMap(new Point(event.graphic.contentMouseX,event.graphic.contentMouseY));
				graphic = new Graphic(geometry,iconSymbol);
				layerDraw.add(graphic);
			}
			else if(_drawType == DrawTool.POLYGON)
			{
				var markerSymbol:SimpleMarkerSymbol = new SimpleMarkerSymbol(SimpleMarkerSymbol.STYLE_SQUARE,10);
				geometry = layerDraw.map.toMap(new Point(event.graphic.contentMouseX,event.graphic.contentMouseY));
				graphic = new Graphic(geometry,markerSymbol);
				layerDraw.add(graphic);
			}
		}		
		
		private function onDrawEnd(event:DrawEvent):void
		{			
			if(_resultHandle != null)
				_resultHandle(event.graphic.geometry);
		}
		
		private function onLayerMouseClick(event:MouseEvent):void
		{
			if(_drawType == DrawTool.POLYGON)
			{
				var polygon:Polygon = layerDraw.graphicProvider[1].geometry as Polygon;
				var ring:Array = polygon.rings[0] as Array;
				if(ring.length > 3)
				{
					var firstPoint:Point = layerDraw.map.toScreen(ring[0]);
					var lastPoint:Point = layerDraw.map.toScreen(ring[ring.length -1]);
					
					if((Math.abs(lastPoint.x - firstPoint.x) < 10)
						&& (Math.abs(lastPoint.y - firstPoint.y) < 10))
					{
						drawTool.deactivate();
						
						polygon.removePoint(0,ring.length - 1);
						polygon.removePoint(0,ring.length - 1);
						
						layerDraw.add(new Graphic(polygon,buffSymbol));
						
						drawTool.activate(DrawTool.POLYGON);
						
						if(_resultHandle != null)
							_resultHandle(polygon);
					}
				}
			}
			
		}
		
		private function onZoomEnd(event:ZoomEvent):void
		{
			if(_drawType != "")
			{
				drawTool.defaultDrawSize = 
					(layerDraw.map.toScreen(new MapPoint(0,0)).y 
						- layerDraw.map.toScreen(new MapPoint(0,_radius)).y) * 2;
				
				drawTool.activate(_drawType);
			}
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_APP_INIT,
				
				AppNotification.NOTIFY_MENUBAR,
				AppNotification.NOTIFY_TOOLBAR,
								
				AppNotification.NOTIFY_SEARCH_GRAPHICSTART,
				AppNotification.NOTIFY_SEARCH_GRAPHICSTOP,
				
				AppNotification.NOTIFY_SEARCH_SEARCHROAD,
				AppNotification.NOTIFY_SEARCH_SEARCHPOINT,
				
				AppNotification.NOTIFY_SEARCH_LOCATEROAD,
				AppNotification.NOTIFY_SEARCH_LOCATEPOINT,	
				
				AppNotification.NOTIFY_DRAW_GEOMETRY,
				
				AppNotification.NOTIFY_SEARCH_ATTRIBUTE,
				
				AppNotification.NOTIFY_ALARM_STATIS,
				AppNotification.NOTIFY_ALARM_STATISDIS
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{			
			switch(notification.getName())
			{
				case AppNotification.NOTIFY_APP_INIT:
					buffSymbol = new SimpleFillSymbol("solid",0,0.15,new SimpleLineSymbol);
					
					drawTool.showDrawTips = false;
					drawTool.graphicsLayer = layerDraw;
					drawTool.fillSymbol = buffSymbol;
					drawTool.markerSymbol = new SimpleMarkerSymbol("circle",0,0,0);
					drawTool.map = layerDraw.map;
					
					layerDraw.map.addEventListener(ZoomEvent.ZOOM_END,onZoomEnd);
					break;
												
				case AppNotification.NOTIFY_SEARCH_GRAPHICSTART:
					start(notification.getBody()[0],notification.getBody()[1],notification.getBody()[2]);
					break;
				
				case AppNotification.NOTIFY_MENUBAR:
				case AppNotification.NOTIFY_SEARCH_GRAPHICSTOP:
					stop();
					break;
				
				case AppNotification.NOTIFY_SEARCH_LOCATEROAD:
					locateRoad(notification.getBody() as DicRoad);
					break;
				
				case AppNotification.NOTIFY_SEARCH_LOCATEPOINT:
					locatePoint(notification.getBody()[0],notification.getBody()[1]);
					break;
				
				case AppNotification.NOTIFY_SEARCH_SEARCHROAD:	
					searchRoad(notification.getBody()[0],notification.getBody()[1]);
					break;
				
				case AppNotification.NOTIFY_SEARCH_SEARCHPOINT:
					searchPoint(notification.getBody()[0],notification.getBody()[1],notification.getBody()[2]);
					break;
				
				case AppNotification.NOTIFY_SEARCH_ATTRIBUTE:
					layerDraw.clear();
					break;
				
				case AppNotification.NOTIFY_DRAW_GEOMETRY:
					drawGeometry(notification.getBody() as Geometry);
					break;
										
				case AppNotification.NOTIFY_TOOLBAR:
					switch(notification.getType())
					{
						case MainTool.PAN:
						case MainTool.ZOOMIN:
						case MainTool.ZOOMOUT:
						case MainTool.MEASURELENGTH:	
						case MainTool.MEASUREAREA:
							_drawType = "";
							drawTool.deactivate();		
							break;
						
						case MainTool.CLEARMAP:
							layerDraw.clear();
							break;
					}
					break;	
				
				case AppNotification.NOTIFY_ALARM_STATIS:
					drawAlarmStatis();
					break;
				
				case AppNotification.NOTIFY_ALARM_STATISDIS:
					drawAlarmStatisDis(notification.getBody() as DicPatrolZone);
					break;
			}
		}
		
		private function drawGeometry(geometry:Geometry):void
		{				
			layerDraw.clear();
			
			switch(geometry.type)
			{
				case Geometry.POLYGON: 
					layerDraw.add(new Graphic(geometry as Polygon,buffSymbol));
					break;
			}
		}
				
		private function stop():void
		{
			_drawType = "";					
			drawTool.deactivate();						
			layerDraw.clear();				
			
			sendNotification(AppNotification.NOTIFY_MAP_OPREATOR);
		}
		
		private function start(radius:Number,drawType:String,resultHandle:Function):void
		{							
			if(drawType == DrawTool.CIRCLE)
			{
				sendNotification(AppNotification.NOTIFY_MAP_OPREATOR,MapCursor.DRAWCIRCLE);
			}
			else if(drawType == DrawTool.EXTENT)
			{
				sendNotification(AppNotification.NOTIFY_MAP_OPREATOR,MapCursor.DRAWRECT);
			}
			else if(drawType == DrawTool.POLYGON)
			{
				sendNotification(AppNotification.NOTIFY_MAP_OPREATOR,MapCursor.DRAWPOLY);
			}
			else if(drawType == DrawTool.MAPPOINT)
			{
				sendNotification(AppNotification.NOTIFY_MAP_OPREATOR,MapCursor.DRAWPOINT);
			}
			
			flash.utils.setTimeout(excute,100);
			
			function excute():void
			{
				_radius = radius;
				_drawType = drawType;
				_resultHandle = resultHandle;
				
				drawTool.defaultDrawSize = 
					(layerDraw.map.toScreen(new MapPoint(0,0)).y 
						- layerDraw.map.toScreen(new MapPoint(0,radius)).y) * 2;
				
				drawTool.activate(drawType);
			}
		}
		
		private function drawRoad(road:DicRoad):void
		{
			var textFormat:TextFormat = new TextFormat;
			textFormat.bold = true;
			
			var labelSymbol:TextSymbol = new TextSymbol;
			labelSymbol.textFormat = textFormat;
			labelSymbol.color = 0xFF0000;
			labelSymbol.text = road.l_t_door + '号';
			labelSymbol.yoffset = 10;
			labelSymbol.xoffset = -10;
			
			var beginDoorplate:Graphic = new Graphic;
			beginDoorplate.geometry = road.polyline.getPoint(0,0);	
			beginDoorplate.symbol = labelSymbol;
			layerDraw.add(beginDoorplate);
			
			labelSymbol = new TextSymbol;
			labelSymbol.textFormat = textFormat;
			labelSymbol.color = 0xFF0000;
			labelSymbol.text = road.l_f_door + '号';
			labelSymbol.yoffset = -10;
			labelSymbol.xoffset = 10;
			
			var pathCount:Number = road.polyline.paths.length;
			var lastPathLenth:Number = road.polyline.paths[pathCount - 1].length;;
			var endDoorplate:Graphic = new Graphic;
			endDoorplate.geometry = road.polyline.getPoint(pathCount-1,lastPathLenth-1);	
			endDoorplate.symbol = labelSymbol;
			layerDraw.add(endDoorplate);
			
			var graphicRoad:Graphic = new Graphic;
			graphicRoad.symbol = new SimpleLineSymbol(SimpleLineSymbol.STYLE_SOLID,0xFF0000,1,5);
			graphicRoad.geometry = road.polyline;
			layerDraw.add(graphicRoad);
			
			sendNotification(AppNotification.NOTIFY_MAP_FLASH,[graphicRoad]);
		}
		
		private function locateRoad(road:DicRoad):void
		{
			layerDraw.clear();
			
			sendNotification(AppNotification.NOTIFY_MAP_LOCATE,road.polyline);
			
			drawRoad(road);			
		}
		
		private function searchRoad(road:DicRoad,polygon:Polygon):void
		{
			drawGeometry(polygon);
			
			sendNotification(AppNotification.NOTIFY_MAP_LOCATE,polygon);
			
			drawRoad(road);
		}
		
		private function drawPoint(point:MapPoint,label:String):void
		{						
			var textFormat:TextFormat = new TextFormat;
			textFormat.bold = true;			
			
			var labelSymbol:TextSymbol = new TextSymbol(label);
			labelSymbol.yoffset = 45;
			labelSymbol.textFormat = textFormat;
			
			var graphicLabel:Graphic = new Graphic;
			graphicLabel.geometry = point;	
			graphicLabel.symbol = labelSymbol;
			layerDraw.add(graphicLabel);
			
			var graphicPoint:Graphic = new Graphic;
			graphicPoint.geometry = point;			
			
			var iconSymbol:PictureMarkerSymbol = new PictureMarkerSymbol("assets/image/i_pin.png",40,40);
			iconSymbol.xoffset = 15;
			iconSymbol.yoffset = 18;					
			graphicPoint.symbol = iconSymbol;
			
			layerDraw.add(graphicPoint);
			
			sendNotification(AppNotification.NOTIFY_MAP_FLASH,[graphicPoint]);
		}
		
		private function locatePoint(point:MapPoint,label:String):void
		{
			layerDraw.clear();
			
			sendNotification(AppNotification.NOTIFY_MAP_LOCATE,point);
			
			drawPoint(point,label);
		}
		
		private function searchPoint(point:MapPoint,label:String,polygon:Polygon):void
		{
			drawGeometry(polygon);
			
			sendNotification(AppNotification.NOTIFY_MAP_LOCATE,polygon);
			
			drawPoint(point,label);
		}
		
		private function drawAlarmStatis():void
		{
			layerDraw.clear();
			
			var list:ArrayCollection = new ArrayCollection;
			list.addItem(new DicPatrolZone({KEYID:'1',DEPID:'A派出所',ZONENM:'区域A',ZONEGPSRANGE:'-23720.816772,16961.729919;-21846.408569,18171.862122;-21610.294128,17699.633118;-22200.580383,16198.619324;-23465.47949,16249.215271'}));
			list.addItem(new DicPatrolZone({KEYID:'2',DEPID:'B派出所',ZONENM:'区域B',ZONEGPSRANGE:'-21964.465698,15338.488098;-20648.97052,15507.141113;-20244.203003,14984.316101;-21475.371399,14326.568726'}));
			list.addItem(new DicPatrolZone({KEYID:'3',DEPID:'A派出所',ZONENM:'区域C',ZONEGPSRANGE:'-17398.514404,14153.097107;-15907.405701,14892.493896;-14822.135925,12218.40332;-16119.159302,11516.752686'}));
			list.addItem(new DicPatrolZone({KEYID:'4',DEPID:'B派出所',ZONENM:'区域D',ZONEGPSRANGE:'-18693.66412,20738.603699;-16961.086487,21478.000671;-16797.787903,18760.006714;-18907.023804,18299.824524'}));
				
			var fullExtent:Extent;
			for(var i:Number = 0;i< list.length;i++)
			{
				var patrolZone:DicPatrolZone = list[i];
				
				if(fullExtent == null)
					fullExtent = patrolZone.polygon.extent;
				else
					fullExtent = fullExtent.union(patrolZone.polygon.extent);
				
				var outlineSymbol:SimpleLineSymbol = new SimpleLineSymbol("solid",0x0,1,2);
				var symbol:SimpleFillSymbol = new SimpleFillSymbol("solid",0x0,0.2,outlineSymbol);
				var index:Number = Number(patrolZone.id);
				
				switch(index % 4)
				{
					case 0:
						outlineSymbol.color = 0x0;
						symbol.color = 0xFFFFFF;
						break;
					case 1:
						outlineSymbol.color = 0xFF8400;
						symbol.color = 0xFF8400;
						break;
					case 2:
						outlineSymbol.color = 0xFF0000;
						symbol.color = 0xFF0000;
						break;
					case 3:
						outlineSymbol.color = 0x0;
						symbol.color = 0x0;
						break;
				}
				
				var graphic:Graphic = new Graphic(patrolZone.polygon,symbol);
				graphic.attributes = patrolZone;
				graphic.addEventListener(MouseEvent.CLICK,onAlarmStatisClick);
				layerDraw.add(graphic);
			}
			
			sendNotification(AppNotification.NOTIFY_MAP_LOCATE,fullExtent);
		}
		
		private function onAlarmStatisClick(event:MouseEvent):void
		{
			var graphic:Graphic = event.currentTarget as Graphic;
			sendNotification(AppNotification.NOTIFY_ALARM_STATISCLICK,graphic.attributes);;
		}
		
		private var statisArr:ArrayCollection = new ArrayCollection;
		private function drawAlarmStatisDis(alarmStatis:DicPatrolZone):void
		{
			for each(var gr:Graphic in statisArr)
			{
				layerDraw.remove(gr);
			}
			statisArr.removeAll();
			
			var dx:Number = alarmStatis.polygon.extent.width
			for(var i:Number = 0;i<15;i++)
			{
				var point:MapPoint = new MapPoint;
				point.x = alarmStatis.polygon.extent.xmin + Math.random() * alarmStatis.polygon.extent.width;
				point.y = alarmStatis.polygon.extent.ymin + Math.random() * alarmStatis.polygon.extent.height;
				while(!alarmStatis.polygon.contains(point))
				{
					point.x = alarmStatis.polygon.extent.xmin + Math.random() * alarmStatis.polygon.extent.width;
					point.y = alarmStatis.polygon.extent.ymin + Math.random() * alarmStatis.polygon.extent.height;
				}
								
				statisArr.addItem(new Graphic(point,new SimpleMarkerSymbol("circle")));
			}
			
			for each(gr in statisArr)
			{
				layerDraw.add(gr);
			}
		}
	}
}