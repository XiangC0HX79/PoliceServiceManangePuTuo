package app.view
{
	import app.AppNotification;
	import app.view.components.MainTool;
	import app.view.components.subComponents.InfoRendererMeasure;
	
	import com.esri.ags.Graphic;
	import com.esri.ags.SpatialReference;
	import com.esri.ags.events.DrawEvent;
	import com.esri.ags.geometry.Geometry;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.geometry.Polygon;
	import com.esri.ags.geometry.Polyline;
	import com.esri.ags.layers.GraphicsLayer;
	import com.esri.ags.symbols.InfoSymbol;
	import com.esri.ags.symbols.SimpleFillSymbol;
	import com.esri.ags.symbols.SimpleLineSymbol;
	import com.esri.ags.tasks.supportClasses.LengthsParameters;
	import com.esri.ags.tools.DrawTool;
	
	import flash.utils.setTimeout;
	
	import mx.core.ClassFactory;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class LayerMeasureMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "LayerMeasureMediator";
		
		private var measureTool:DrawTool = new DrawTool;
		private var infoSymbol:InfoSymbol = new InfoSymbol;
		
		public function LayerMeasureMediator( viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			measureTool.addEventListener(DrawEvent.DRAW_END,onDrawEnd);
			
			infoSymbol.infoRenderer = new ClassFactory(InfoRendererMeasure);
		}
		
		private function get layerMeasure():GraphicsLayer
		{
			return viewComponent as GraphicsLayer;
		}
		
		private function onDrawEnd(drawevent:DrawEvent):void
		{					
			if(drawevent.graphic.geometry.type == Geometry.POLYLINE)
			{
				var polyline:Polyline = drawevent.graphic.geometry as Polyline; 
				polyline.spatialReference = new SpatialReference(102100);
								
				var pathLength:Number = polyline.paths.length;
				var pointLength:Number = polyline.paths[pathLength - 1].length;
				var latestEndpoint:MapPoint = polyline.paths[pathLength - 1][pointLength - 1] as MapPoint;
				
				sendNotification(AppNotification.NOTIFY_GEOMETRY_LEGHTN,[[polyline],lengthResultHandle]);
			}
			else if(drawevent.graphic.geometry.type == Geometry.POLYGON)
			{
				var polygon:Polygon = drawevent.graphic.geometry as Polygon; 
				polygon.spatialReference = new SpatialReference(102100);
				
				latestEndpoint = polygon.extent.center;
				
				sendNotification(AppNotification.NOTIFY_GEOMETRY_AREA,[[polygon],areaResultHandle]);
			}
			
			function lengthResultHandle(lengths:Array):void
			{
				var dist:Number = lengths[0];
				var myAttributes:String = "";
				if (dist < 3000)
					myAttributes = "长度：" + Math.round(dist) + " 米";
				else
					myAttributes = "长度：" + Number(dist / 1000).toFixed(2) + " 千米";
												
				layerMeasure.add(new Graphic(latestEndpoint,infoSymbol,myAttributes));
			}
			
			function areaResultHandle(areas:Array):void
			{
				var area:Number = areas[0];
				var myAttributes:String = "";
				if (area < 1000*1000)
					myAttributes = "面积：" + Math.round(area) + " 平方米";
				else
					myAttributes = "面积：" + Number(area / (1000*1000)).toFixed(2) + " 平方公里";
				
				layerMeasure.add( new Graphic(latestEndpoint, infoSymbol, myAttributes)); 
			}
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_APP_INIT,
				AppNotification.NOTIFY_TOOLBAR,
				AppNotification.NOTIFY_SEARCH_GRAPHICSTART
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{			
			switch(notification.getName())
			{
				case AppNotification.NOTIFY_APP_INIT:
					measureTool.showDrawTips = false;
					measureTool.graphicsLayer = layerMeasure;
					measureTool.fillSymbol = new SimpleFillSymbol("solid",0,0.15,new SimpleLineSymbol);
					//measureTool.markerSymbol = new SimpleMarkerSymbol("circle",0,0,0);
					measureTool.map = layerMeasure.map;
					break;
				
				case AppNotification.NOTIFY_TOOLBAR:					
					switch(notification.getType())
					{
						case MainTool.PAN:
						case MainTool.ZOOMIN:
						case MainTool.ZOOMOUT:
							measureTool.deactivate();
							break;
						
						case MainTool.MEASURELENGTH:							
							flash.utils.setTimeout(measureTool.activate,100,DrawTool.POLYLINE);
							break;
						
						case MainTool.MEASUREAREA:		
							flash.utils.setTimeout(measureTool.activate,100,DrawTool.POLYGON);
							break;
						
						case MainTool.CLEARMAP:
							measureTool.deactivate();
							
							layerMeasure.clear();
							break;
					}
					break;
				
				case AppNotification.NOTIFY_SEARCH_GRAPHICSTART:
					measureTool.deactivate();
					break;
			}
		}
	}
}