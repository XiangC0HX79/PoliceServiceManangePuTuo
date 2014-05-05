package app.view
{
	import com.esri.ags.FeatureSet;
	import com.esri.ags.Graphic;
	import com.esri.ags.Map;
	import com.esri.ags.SpatialReference;
	import com.esri.ags.components.supportClasses.InfoWindow;
	import com.esri.ags.events.DrawEvent;
	import com.esri.ags.events.ExtentEvent;
	import com.esri.ags.events.GraphicEvent;
	import com.esri.ags.events.MapEvent;
	import com.esri.ags.events.MapMouseEvent;
	import com.esri.ags.geometry.Extent;
	import com.esri.ags.geometry.Geometry;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.geometry.Polygon;
	import com.esri.ags.geometry.Polyline;
	import com.esri.ags.layers.GraphicsLayer;
	import com.esri.ags.layers.supportClasses.LayerInfo;
	import com.esri.ags.layers.supportClasses.StaticLayer;
	import com.esri.ags.skins.InfoWindowSkin;
	import com.esri.ags.symbols.CompositeSymbol;
	import com.esri.ags.symbols.PictureMarkerSymbol;
	import com.esri.ags.symbols.SimpleFillSymbol;
	import com.esri.ags.symbols.SimpleLineSymbol;
	import com.esri.ags.symbols.SimpleMarkerSymbol;
	import com.esri.ags.symbols.Symbol;
	import com.esri.ags.symbols.TextSymbol;
	import com.esri.ags.tasks.GeometryService;
	import com.esri.ags.tasks.QueryTask;
	import com.esri.ags.tasks.supportClasses.AddressCandidate;
	import com.esri.ags.tasks.supportClasses.BufferParameters;
	import com.esri.ags.tasks.supportClasses.Query;
	import com.esri.ags.tools.DrawTool;
	import com.esri.ags.tools.EditTool;
	import com.esri.ags.tools.NavigationTool;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.SWFLoader;
	import mx.core.BitmapAsset;
	import mx.core.UIComponent;
	import mx.effects.Effect;
	import mx.effects.Sequence;
	import mx.events.EffectEvent;
	import mx.events.FlexEvent;
	import mx.graphics.SolidColor;
	import mx.managers.CursorManager;
	import mx.managers.CursorManagerPriority;
	import mx.printing.FlexPrintJob;
	import mx.printing.FlexPrintJobScaleType;
	import mx.resources.ResourceManager;
	import mx.rpc.AsyncResponder;
	import mx.utils.StringUtil;
	
	import spark.components.Group;
	import spark.components.VGroup;
	import spark.components.supportClasses.Skin;
	import spark.effects.Fade;
	import spark.effects.Move;
	import spark.effects.supportClasses.AnimateTransformInstance;
	import spark.events.GridEvent;
	import spark.primitives.Rect;
	
	import app.AppNotification;
	import app.model.AlarmInfoProxy;
	import app.model.GPSRealTimeInfoProxy;
	import app.model.QWPointProxy;
	import app.model.TrackHistoryProxy;
	import app.model.TrackRealtimeProxy;
	import app.model.dict.DicDepartment;
	import app.model.dict.DicElePolice;
	import app.model.dict.DicPatrolPoint;
	import app.model.dict.DicPatrolType;
	import app.model.dict.DicPatrolZone;
	import app.model.dict.DicPoliceType;
	import app.model.dict.DicServiceStatus;
	import app.model.dict.DicServiceType;
	import app.model.vo.AlarmInfoVO;
	import app.model.vo.AlarmPoliceVO;
	import app.model.vo.AppConfigVO;
	import app.model.vo.GPSNewVO;
	import app.model.vo.GPSVO;
	import app.model.vo.MapCursor;
	import app.model.vo.PatrolLineVO;
	import app.model.vo.QwPointVO;
	import app.model.vo.ServiceExceptVO;
	import app.model.vo.TrackHistoryVO;
	import app.view.components.InfoStatis;
	import app.view.components.MainMap;
	import app.view.components.MainMenu;
	import app.view.components.MainTool;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.facade.Facade;
	import org.puremvc.as3.patterns.mediator.Mediator;
		
	public class MainMapMediator extends Mediator implements IMediator
	{		
		public static const NAME:String = "MainMapMediator";
						
		private static var currentCursor:MapCursor = null;
		
		public function MainMapMediator( viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			facade.registerMediator(new InfoWindowCarInfoMediator(mainMap.infoWindowCarInfo));
			facade.registerMediator(new InfoWindowPoliceInfoMediator(mainMap.infoWindowPoliceInfo));
			facade.registerMediator(new InfoWindowPoliceInfoPTMediator(mainMap.infoWindowPoliceInfoPT));
			facade.registerMediator(new InfoWindowPoliceInfoFXMediator(mainMap.infoWindowPoliceInfoFX));
			facade.registerMediator(new InfoWindowAlarmInfoMediator(mainMap.infoWindowAlarmInfo));
			facade.registerMediator(new InfoWindowTrackPointInfoMediator(mainMap.infoWindowTrackPointInfo));
			facade.registerMediator(new InfoWindowAlarmStatisMediator(mainMap.infoWindowAlarmStatis));
			facade.registerMediator(new InfoWindowExceptInfoMediator(mainMap.infoWindowExceptInfo));
			facade.registerMediator(new InfoWindowElePoliceMediator(mainMap.infoWindowElePolice));
			facade.registerMediator(new InfoWindowPatrolPointMediator(mainMap.infoWindowPatrolPoint));
			
			facade.registerMediator(new LayerTileMediator(mainMap.tileLayer));
			facade.registerMediator(new LayerPatrolZoneMediator(mainMap.patrolAreaLayer));
			facade.registerMediator(new LayerPatrolLineMediator(mainMap.patrolLineLayer));
			facade.registerMediator(new LayerPatrolPointMediator(mainMap.patrolPointLayer));
			facade.registerMediator(new LayerElePoliceMediator(mainMap.elePoliceLayer));
			facade.registerMediator(new LayerTrackHistoryMediator(mainMap.trackLayer));
			facade.registerMediator(new LayerGPSMediator(mainMap.gpsLayer));
			facade.registerMediator(new LayerDrawMediator(mainMap.drawLayer));
			facade.registerMediator(new LayerTrackLinebackMediator(mainMap.trackLinebackLayer));
			facade.registerMediator(new LayerAlarmMediator(mainMap.alarmLayer));
			facade.registerMediator(new LayerMeasureMediator(mainMap.measureLayer));
			facade.registerMediator(new LayerRealExceptMediator(mainMap.layerRealExcept));
			facade.registerMediator(new LayerExceptMediator(mainMap.layerExcept));
			facade.registerMediator(new LayerWarningAreaMediator(mainMap.layerWarningArea));
			facade.registerMediator(new LayerQwPointMediator(mainMap.qwPointLayer));
			facade.registerMediator(new LayerFlashMediator(mainMap.flashLayer));
													
			//将infoWindow放置于staticLayer最顶层			
			var mainMenu:MainMenu = new MainMenu;
			facade.registerMediator(new MainMenuMediator(mainMenu));
			mainMenu.y = -5;
			mainMenu.horizontalCenter = 0;
			mainMap.map.staticLayer.addElement(mainMenu);
			
			var mainTool:MainTool = new MainTool;
			facade.registerMediator(new MainToolMediator(mainTool));
			mainTool.bottom = 5;
			mainTool.horizontalCenter = 0;
			mainMap.map.staticLayer.addElement(mainTool);
			
			var infoStatis:InfoStatis = new InfoStatis;
			facade.registerMediator(new InfoStatisMediator(infoStatis));
			infoStatis.bottom = 10;
			infoStatis.x = 10;
			mainMap.map.staticLayer.addElement(infoStatis);
			
			mainMap.map.staticLayer.setElementIndex(mainMap.map.infoWindow,mainMap.map.staticLayer.numElements - 1);
			//---将infoWindow放置于staticLayer最顶层
			
			//地图鼠标指针管理
			mainMap.map.addEventListener(MouseEvent.MOUSE_OVER,onMapMouseOver);
			mainMap.map.addEventListener(MouseEvent.MOUSE_OUT,onMapMouseOut);
			
			mainMap.map.staticLayer.addEventListener(MouseEvent.MOUSE_OVER,onStaticLayerOver);
			mainMap.map.staticLayer.addEventListener(MouseEvent.MOUSE_OUT,onStaticLayerOut);
			//---地图鼠标指针管理
			
			mainMap.map.infoWindow.addEventListener(Event.OPEN,onInfoWindowOpen);
			mainMap.map.infoWindow.addEventListener(Event.CLOSE,onInfoWindowClose);
		}
				
		private function get mainMap():MainMap
		{
			return viewComponent as MainMap;
		}
					
		private function onInfoWindowOpen(event:Event):void
		{
		}
		
		private function onInfoWindowClose(event:Event):void
		{			
			if(mainMap.infoWindowView.selectedChild == mainMap.infoWindowPoliceInfo)
			{
				sendNotification(AppNotification.NOTIFY_MAP_INFOPOLICEHIDE);
			}
			else if(mainMap.infoWindowView.selectedChild == mainMap.infoWindowAlarmInfo)
			{
				sendNotification(AppNotification.NOTIFY_MAP_INFOALARMHIDE);
			}			
		}
				
		private function onMapMouseOver(event:MouseEvent):void
		{
			if(currentCursor != null)
				CursorManager.setCursor(currentCursor.currentCursor,2,currentCursor.xOffset,currentCursor.yOffset); 				
		}
		
		private function onMapMouseOut(event:MouseEvent):void
		{
			CursorManager.removeAllCursors();			
		}
		
		private function onStaticLayerOver(event:MouseEvent):void
		{		
			mainMap.map.removeEventListener(MouseEvent.MOUSE_OVER,onMapMouseOver);
			CursorManager.removeAllCursors();
			
			//mainMap.map.mouseEnabled = false;		
		}
		
		private function onStaticLayerOut(event:MouseEvent):void
		{			
			mainMap.map.addEventListener(MouseEvent.MOUSE_OVER,onMapMouseOver);
		}
		
		override public function listNotificationInterests():Array
		{
			return [
						AppNotification.NOTIFY_APP_INIT,
						
						AppNotification.NOTIFY_TOOLBAR,
						AppNotification.NOTIFY_MENUBAR,
						
						AppNotification.NOTIFY_LAYER_MOUSEOVER,
						AppNotification.NOTIFY_LAYER_MOUSEOUT,
						
						AppNotification.NOTIFY_LAYERGPS_POLICECLICK,
						//AppNotification.NOTIFY_LAYERGPS_PEOPLECLICK,
						AppNotification.NOTIFY_LAYERGPS_VEHICLECLICK,
												
						AppNotification.NOTIFY_LAYERTRACK_POINTMOUSEOVER,
						AppNotification.NOTIFY_LAYERTRACK_POINTMOUSEOUT,						
						
						//AppNotification.NOTIFY_SEARCH_GRAPHICSTART,
						//AppNotification.NOTIFY_SEARCH_GRAPHICSTOP,
																
						AppNotification.NOTIFY_MAP_LOCATE,
						AppNotification.NOTIFY_MAP_OPREATOR,
						
						
						//AppNotification.NOTIFY_MAP_ALARMLOCATE,
						AppNotification.NOTIFY_INFOWINDOW_TRACKHISTORY,
						AppNotification.NOTIFY_LAYERALARM_GRAPHICCLICK,
						AppNotification.NOTIFY_LAYEREXCEPT_GRAPHICCLICK,
						AppNotification.NOTIFY_LAYERELEPOLICE_GRAPHICCLICK,
						
						AppNotification.NOTIFY_TRACKHISTORY_CHANGE,
						
						AppNotification.NOTIFY_LAYERGPS_LOCATE,
						
						AppNotification.NOTIFY_ALARM_STATISCLICK,
						AppNotification.NOTIFY_LAYER_QWPOINT_CLICK,
						AppNotification.NOTIFY_LAYERPATROPOINT_GRAPHICCLICK
						];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			var gr:Graphic = null;
			var gpsInfo:GPSNewVO = null;
			var alarmInfo:AlarmInfoVO = null;
			var trackHistory:TrackHistoryVO  = null;
			
			switch(notification.getName())
			{								
				case AppNotification.NOTIFY_APP_INIT:
					locateUnit();
					break;
								
				case AppNotification.NOTIFY_TOOLBAR:
					handleToolEvent(notification.getType());
					break;
				
				case AppNotification.NOTIFY_MENUBAR:
					handleMenuEvent(notification.getType());
					break;
								
				case AppNotification.NOTIFY_MAP_OPREATOR:
					changeOperator(notification.getBody() as MapCursor);
					break;
				
				case AppNotification.NOTIFY_MAP_LOCATE:
					locateGeometry(notification.getBody() as Geometry);
					break;
				
				case AppNotification.NOTIFY_LAYER_MOUSEOVER:
					MapCursor.HAND.cursorId = CursorManager.setCursor(MapCursor.HAND.currentCursor,CursorManagerPriority.HIGH,MapCursor.HAND.xOffset,MapCursor.HAND.yOffset);					
					break;
				
				case AppNotification.NOTIFY_LAYER_MOUSEOUT:
					CursorManager.removeCursor(MapCursor.HAND.cursorId);
					break;		
								
				case AppNotification.NOTIFY_LAYERGPS_POLICECLICK:
					showPoliceInfoWindow(notification.getBody() as GPSNewVO);
					break;
								
				case AppNotification.NOTIFY_LAYERGPS_VEHICLECLICK:
					showVehicleInfoWindow(notification.getBody() as GPSNewVO);
					break;
				
				case AppNotification.NOTIFY_LAYERTRACK_POINTMOUSEOVER:
					showTrackPointInfoWindow(notification.getBody()[0],notification.getBody()[1]);
					break;
				
				case AppNotification.NOTIFY_LAYERTRACK_POINTMOUSEOUT:
					hideTrackPointInfoWindow();
					break;
												
				case AppNotification.NOTIFY_INFOWINDOW_TRACKHISTORY:
					mainMap.map.infoWindow.hide();
					break;
				
				case AppNotification.NOTIFY_TRACKHISTORY_CHANGE:
					var trackHistoryProxy:TrackHistoryProxy = facade.retrieveProxy(TrackHistoryProxy.NAME) as TrackHistoryProxy;
					locateGeometry(trackHistoryProxy.trackExtent);
					break;
								
				
				case AppNotification.NOTIFY_LAYERGPS_LOCATE:
					locateGeometry((notification.getBody() as GPSVO).mapPoint);
					break;
								
				case AppNotification.NOTIFY_LAYERALARM_GRAPHICCLICK:
					showAlarmInfoWindow(notification.getBody() as AlarmInfoVO);
					break;
				
				case AppNotification.NOTIFY_LAYEREXCEPT_GRAPHICCLICK:
					showExceptInfoWindow(notification.getBody() as ServiceExceptVO);
					break;
					
				case AppNotification.NOTIFY_LAYERELEPOLICE_GRAPHICCLICK:
					var elePolice:DicElePolice = notification.getBody() as DicElePolice;
					if(elePolice.type == "3")
						mainMap.map.infoWindow.label = elePolice.layer.layerName + "：" + elePolice.code;
					else
						mainMap.map.infoWindow.label = elePolice.layer.layerName;
					mainMap.infoWindowView.selectedChild = mainMap.infoWindowElePolice;
					mainMap.map.infoWindow.show(elePolice.mapPoint);
					break;
				
				case AppNotification.NOTIFY_ALARM_STATISCLICK:
					showAlarmStatisWindow(notification.getBody() as DicPatrolZone);
					break;
				
				case AppNotification.NOTIFY_LAYER_QWPOINT_CLICK:
					var qwPoint:QwPointVO = notification.getBody() as QwPointVO;			
					mainMap.infoWindowQwPoint.qwPoint = qwPoint;					
					mainMap.map.infoWindow.label = qwPoint.Name;
					mainMap.infoWindowView.selectedChild = mainMap.infoWindowQwPoint;
					mainMap.map.infoWindow.show(qwPoint.pt);
					break;
				
				case AppNotification.NOTIFY_LAYERPATROPOINT_GRAPHICCLICK:
					var patrolPoint:DicPatrolPoint = notification.getBody() as DicPatrolPoint;		
					mainMap.map.infoWindow.label = patrolPoint.label;
					mainMap.infoWindowView.selectedChild = mainMap.infoWindowPatrolPoint;
					mainMap.map.infoWindow.show(patrolPoint.mapPoint);
					break;
			}
		}
				
		private function locateUnit():void
		{			
			mainMap.map.initialExtent = AppConfigVO.districtGeometry.extent.expand(1.1);
			
			if((AppConfigVO.Auth == "0")
				&& (AppConfigVO.user.department != null)
				&& (AppConfigVO.user.department.polygon != null))
			{
				sendNotification(AppNotification.NOTIFY_MAP_LOCATE,AppConfigVO.user.department.polygon);
			}
			else
			{
				mainMap.map.zoomToInitialExtent();
			}
		}
		
		private function handleToolEvent(type:String):void
		{					
			switch(type)
			{
				case MainTool.PAN:
					changeOperator(MapCursor.PAN);
					break;
				
				case MainTool.ZOOMIN:
					changeOperator(MapCursor.ZOOMIN);
					break;
				
				case MainTool.ZOOMOUT:
					changeOperator(MapCursor.ZOOMOUT);
					break;
				
				case MainTool.FULLEXTENT:
					mainMap.map.zoomToInitialExtent();
					break;
				
				case MainTool.NEXTVIEW:
					if(!mainMap.navTool.isLastExtent)
						mainMap.navTool.zoomToNextExtent();
					break;
				
				case MainTool.PREVIEW:
					if(!mainMap.navTool.isFirstExtent)
						mainMap.navTool.zoomToPrevExtent();
					break;
				
				case MainTool.MEASURELENGTH:		
					changeOperator(MapCursor.MEASURELENGTH);
					break;
				
				case MainTool.MEASUREAREA:		
					changeOperator(MapCursor.MEASUREAREA);
					break;
				
				case MainTool.CLEARMAP:		
					changeOperator(MapCursor.PAN);
					break;
				
				case MainTool.PRINT:
					mainMap.map.staticLayer.visible = false;
					
					var printJob:FlexPrintJob = new FlexPrintJob();					
					if (printJob.start() == true)
					{
						printJob.addObject(mainMap.map, FlexPrintJobScaleType.SHOW_ALL);
						printJob.send();
					}
					
					mainMap.map.staticLayer.visible = true;
					break;
			}
		}
		
		private function handleMenuEvent(type:String):void
		{					
			/*if((currentCursor == MapCursor.DRAWCIRCLE)
				|| (currentCursor == MapCursor.DRAWPOINT)
				|| (currentCursor == MapCursor.DRAWPOLY)
				|| (currentCursor == MapCursor.DRAWRECT))
				
				changeOperator(null);*/
		}
		
		private function changeOperator(mapCursor:MapCursor):void
		{
			if(mapCursor == null)
			{
				if((currentCursor == MapCursor.DRAWCIRCLE)
					|| (currentCursor == MapCursor.DRAWPOINT)
					|| (currentCursor == MapCursor.DRAWPOLY)
					|| (currentCursor == MapCursor.DRAWRECT))
				{
					currentCursor = null;
				}
			}
			else
			{
				mainMap.navTool.deactivate();
				
				currentCursor = mapCursor;
				
				switch(mapCursor)
				{
					case MapCursor.PAN:
						currentCursor = null;
						break;
					
					case MapCursor.ZOOMIN:					
						mainMap.navTool.activate(NavigationTool.ZOOM_IN);					
						break;
					
					case MapCursor.ZOOMOUT:					
						mainMap.navTool.activate(NavigationTool.ZOOM_OUT);					
						break;
				}
			}
		}
		
		private function showExceptInfoWindow(except:ServiceExceptVO):void
		{				
			mainMap.map.infoWindow.label = "异常类型：" + except.ExceptType.exceptName;
			mainMap.infoWindowView.selectedChild = mainMap.infoWindowExceptInfo;
			mainMap.map.infoWindow.show(except.object as MapPoint);
		}
		
		private function showAlarmInfoWindow(alarm:AlarmInfoVO):void
		{					
			mainMap.map.infoWindow.label = "警情单号：" + alarm.id;
			mainMap.infoWindowView.selectedChild = mainMap.infoWindowAlarmInfo;
			mainMap.map.infoWindow.show(alarm.mapPoint);
		}
		
		private function showAlarmStatisWindow(alarmStatis:DicPatrolZone):void
		{
			mainMap.map.infoWindow.label = alarmStatis.label;
			mainMap.infoWindowView.selectedChild = mainMap.infoWindowAlarmStatis;
			mainMap.map.infoWindow.show(alarmStatis.polygon.extent.center);
		}
		/*private function hideInfoWindow():void
		{
			mainMap.map.infoWindow.hide();
		}*/
		
		private function showPoliceInfoWindow(gps:GPSNewVO):void
		{
			if(AppConfigVO.district.indexOf('奉贤') >= 0)
			{
				mainMap.infoWindowView.selectedChild = mainMap.infoWindowPoliceInfoFX;					
			}
			else if(AppConfigVO.district.indexOf('普陀') >= 0)
			{
				mainMap.infoWindowView.selectedChild = mainMap.infoWindowPoliceInfoPT;					
			}
			else
			{
				mainMap.infoWindowView.selectedChild = mainMap.infoWindowPoliceInfo;				
			}
			
			mainMap.map.infoWindow.label = gps.gpsName + " ( " + gps.policeNo + " ) ";
			mainMap.map.infoWindow.show(gps.mapPoint);			
		}
		
		/*private function showPeopleInfoWindow(gps:GPSNewVO):void
		{
			mainMap.infoWindowView.selectedChild = mainMap.infoWindowPeopleInfo;	
			mainMap.map.infoWindow.label = gps.gpsName + " ( " + gps.policeNo + " ) ";
			mainMap.map.infoWindow.show(gps.mapPoint);			
		}*/
		
		private function showVehicleInfoWindow(gps:GPSNewVO):void
		{
			mainMap.infoWindowView.selectedChild = mainMap.infoWindowCarInfo;		
			mainMap.map.infoWindow.label = gps.gpsName;
			mainMap.map.infoWindow.show(gps.mapPoint);			
		}
				
		private var hideTimeout:Number = 0;
		private function showTrackPointInfoWindow(gps:GPSVO,mapPoint:MapPoint):void
		{
			if(hideTimeout != 0)
			{
				flash.utils.clearTimeout(hideTimeout);
				
				hideTimeout = 0;
			}
			
			mainMap.infoWindowView.selectedChild = mainMap.infoWindowTrackPointInfo;		
			mainMap.map.infoWindow.label = gps.gpsName;
			mainMap.map.infoWindow.show(mapPoint);	
			
			mainMap.map.infoWindow.addEventListener(MouseEvent.MOUSE_OVER,onInfoWindowOver);
			mainMap.map.infoWindow.addEventListener(MouseEvent.MOUSE_OUT,onInfoWindowOut);				
		}
				
		private function onInfoWindowOver(event:MouseEvent):void
		{		
			if(hideTimeout != 0)
			{
				flash.utils.clearTimeout(hideTimeout);
				
				hideTimeout = 0;
			}
		}
		
		private function onInfoWindowOut(event:MouseEvent):void
		{			
			hideTrackPointInfoWindow();
		}
		
		private function hideTrackPointInfoWindow():void
		{			
			if(hideTimeout == 0)
			{
				hideTimeout = flash.utils.setTimeout(hideInfoWindow,100);
			}
			
			function hideInfoWindow():void
			{
				mainMap.map.infoWindow.removeEventListener(MouseEvent.MOUSE_OVER,onInfoWindowOver);
				mainMap.map.infoWindow.removeEventListener(MouseEvent.MOUSE_OUT,onInfoWindowOut);
				
				mainMap.map.infoWindow.hide();
			}
		}
		
		/*private function activeNavigator(type:String,cursorClass:Class = null):void
		{					
			//mainMap.measureTool.deactivate();
			//(facade.retrieveProxy(MapDrawProxy.NAME) as MapDrawProxy).drawTool.deactivate();
			
			if(type == NavigationTool.PAN)
			{
				mainMap.navTool.deactivate();
				_currentCursor =  null;
			}
			else 
			{
				mainMap.navTool.activate(type);
				_currentCursor = new MapCursor(cursorClass,-12,-12);
			}
		}
		
		private function activeMeasure(type:String):void
		{		
			mainMap.navTool.deactivate();
			//(facade.retrieveProxy(MapDrawProxy.NAME) as MapDrawProxy).drawTool.deactivate();
			
			//mainMap.measureTool.activate(type);
			
			_currentCursor =  new MapCursor(MapCursor.CURSORMEASURELENGTH,-8,-12);
		}
				
		private function setMapCursor2(mapCursor:MapCursor):void
		{
			if(mapCursor != MapCursor.PAN)
			{
				currentCursor = mapCursor;
			}
			else
			{
				currentCursor = null;
			}
			
			if(mapCursor == MapCursor.ZOOMIN)
			{
				mainMap.navTool.activate(NavigationTool.ZOOM_IN);
			}
			else if(mapCursor == MapCursor.ZOOMOUT)
			{
				mainMap.navTool.activate(NavigationTool.ZOOM_OUT);
			}
			else
			{				
				mainMap.navTool.deactivate();
			}
		}
		
	private function handleMenuEvent(type:String):void
		{						
			switch(type)
			{
				case MenuBar.SERVICETRACKHISTORY:
					mainMap.gpsLayer.visible = false;
					mainMap.trackLayer.visible = true;
					break;
				
				case MenuBar.SERVICELINEBACK:
					mainMap.gpsLayer.visible = false;
					
					//mainMap.trackLayer.visible = true;		
					
					mainMap.patrolAreaLayer.visible = true;
					mainMap.patrolPointLayer.visible = true;
					break;
				
				case MenuBar.ALARMINFO:
					mainMap.alarmLayer.visible = true;
					break;
				
				default:
					mainMap.gpsLayer.visible = true;
					mainMap.trackLayer.visible = false;
					mainMap.alarmLayer.visible = false;
					break;
			}
		}
						
		private function trackPointMouseOver(graphic:Graphic):void
		{
			var gps:GPSVO = graphic.attributes as GPSVO;
			mainMap.map.infoWindow.label = gps.gpsName;
			mainMap.infoWindowView.selectedChild = mainMap.infoWindowTrackPointInfo;
			mainMap.infoWindowTrackPointInfo.gps = gps;
			mainMap.map.infoWindow.show(graphic.geometry as MapPoint);
		}
		
		private function trackPointMouseOut():void
		{
			mainMap.map.infoWindow.hide();
		}
		
		private function mapQuery(notifyMapQuery:NotifyMapQuery):void
		{
			var mapQueryTask:QueryTask = new QueryTask(mainMap.tileLayer.url + "/" + getLayerIdByLayerName(notifyMapQuery.layerName));
			mapQueryTask.useAMF = false;
			mapQueryTask.execute(notifyMapQuery.query,new AsyncResponder(notifyMapQuery.resultHandle,onAsyncResponderFault));
		}
			
		private function onAsyncResponderFault(info:Object, token:Object = null):void
		{
			trace(info.toString());
		}
								
		private function mapLocate(graphic:Graphic):void
		{			
			locateGeometry(graphic.geometry);
			
			mainMap.otherLayer.clear();
			//标注道路
			if(graphic.attributes.propertyIsEnumerable("左起门牌"))//["左起门牌"] != undefined)
			{
				var road:RoadVO = new RoadVO(graphic);
				
				var textFormat:TextFormat = new TextFormat;
				textFormat.bold = true;
				
				var labelSymbol:TextSymbol = new TextSymbol;
				labelSymbol.textFormat = textFormat;
				labelSymbol.text = road.l_f_door + '号';
				labelSymbol.yoffset = 10;
				labelSymbol.xoffset = -10;
				
				var beginDoorplate:Graphic = new Graphic;
				beginDoorplate.geometry = road.polyline.getPoint(0,0);	
				beginDoorplate.symbol = labelSymbol;
				mainMap.flashLayer.add(beginDoorplate);
				
				labelSymbol = new TextSymbol;
				labelSymbol.textFormat = textFormat;
				labelSymbol.text = road.l_t_door + '号';
				labelSymbol.yoffset = -10;
				labelSymbol.xoffset = 10;
				
				var pathCount:Number = road.polyline.paths.length;
				var lastPathLenth:Number = road.polyline.paths[pathCount - 1].length;;
				var endDoorplate:Graphic = new Graphic;
				endDoorplate.geometry = road.polyline.getPoint(pathCount-1,lastPathLenth-1);	
				endDoorplate.symbol = labelSymbol;
				mainMap.otherLayer.add(endDoorplate);
			}
						
			flashGeometry(graphic.geometry);
		}
		
		private function searchPolygon(polygon:Polygon):void
		{			
			mainMap.map.extent = polygon.extent.expand(1.5);
		}
						
		private function flashDoorPlate(graphic:Graphic):void
		{			
			mainMap.flashLayer.clear();
			
			var textFormat:TextFormat = new TextFormat;
			textFormat.bold = true;			
			var labelSymbol:TextSymbol = new TextSymbol(graphic.attributes["道路名"] + graphic.attributes["弄号"] + graphic.attributes["门牌号"]);
			labelSymbol.yoffset = -10;
			labelSymbol.textFormat = textFormat;
						
			var doorplate:Graphic = new Graphic;
			doorplate.geometry = graphic.geometry;	
			doorplate.symbol = labelSymbol;
			
			mainMap.flashLayer.add(doorplate);
			
			flashGraphic(graphic);
		}
		
		private function flashQuarterDoorPlate(gr:Graphic):void
		{			
			mainMap.flashLayer.clear();
			
			var textFormat:TextFormat = new TextFormat;
			textFormat.bold = true;			
			var labelSymbol:TextSymbol = new TextSymbol(gr.attributes["道路名"] + gr.attributes["小区名"] + gr.attributes["门牌号"]);
			labelSymbol.yoffset = - 10;
			labelSymbol.textFormat = textFormat;
			
			var doorplate:Graphic = new Graphic;
			doorplate.geometry = gr.geometry;	
			doorplate.symbol = labelSymbol;
			mainMap.flashLayer.add(doorplate);
			
			flashGraphic(gr);
		}
		
		private function flashAddress(gr:Graphic):void
		{			
			mainMap.flashLayer.clear();
			
			var textFormat:TextFormat = new TextFormat;
			textFormat.bold = true;			
			var labelSymbol:TextSymbol = new TextSymbol(gr.attributes["名称"]);
			labelSymbol.yoffset = -10;
			labelSymbol.textFormat = textFormat;
			
			var doorplate:Graphic = new Graphic;
			doorplate.geometry = gr.geometry;	
			doorplate.symbol = labelSymbol;
			mainMap.flashLayer.add(doorplate);
			
			flashGraphic(gr);
		}
		
		private function flashGeometry(geometry:Geometry):void
		{
			var graphic:Graphic = new Graphic;
			graphic.geometry = geometry;
			
			switch(geometry.type)
			{
				case Geometry.MAPPOINT:   					
					var iconSymbol:PictureMarkerSymbol = new PictureMarkerSymbol("assets/image/i_pin.png",40,40);
					iconSymbol.xoffset = 15;
					iconSymbol.yoffset = 18;					
					graphic.symbol = iconSymbol;
					break;
				
				case Geometry.MULTIPOINT:
					graphic.symbol = new SimpleMarkerSymbol(SimpleMarkerSymbol.STYLE_CIRCLE,15,0xFF0000);
					break;
				
				case Geometry.POLYLINE:  
					graphic.symbol = new SimpleLineSymbol(SimpleLineSymbol.STYLE_SOLID,0xFF0000,1,5);
					break;
				
				case Geometry.POLYGON:  
					graphic.symbol = new SimpleFillSymbol;
					break;
			}
						
			flashGraphic(graphic);
		}
		
		private function flashGraphic(array:Array):void
		{				
			if(mainMap.flashMovie.isPlaying)
			{
				mainMap.flashMovie.end();			
			}
			
			mainMap.flashMovie.play(array); 
		}*/
										
		private function locateGeometry(geometry:Geometry):void
		{
			if(geometry == null)
				return;
			
			var extent:Extent;
			switch(geometry.type)
			{
				case Geometry.MAPPOINT:				
					var mapPoint:MapPoint = geometry as MapPoint;
					extent = new Extent(mapPoint.x - 500,mapPoint.y - 500,mapPoint.x + 500,mapPoint.y + 500);
					break;
				
				case Geometry.POLYLINE:
					var polyline:Polyline = geometry as Polyline;
					var pointCount:Number = 0;
					for each(var item:Array in polyline.paths)
					{
						pointCount += item.length;
					}
					if(pointCount == 1)
					{	
						mapPoint = polyline.getPoint(0,0);
						extent = new Extent(mapPoint.x - 500,mapPoint.y - 500,mapPoint.x + 500,mapPoint.y + 500);
						extent = extent;
					}
					else
					{						
						extent = geometry.extent.expand(1.5);    	
					}
					break;
				
				default:				
					extent = geometry.extent.expand(1.5);    						
					break;
			}
			
			if(extent != null)				
			{				
				extent = extent.intersection(mainMap.map.initialExtent);
				
				if(extent != null)
					mainMap.map.extent = extent;
				else
					mainMap.map.zoomToInitialExtent();
			}
		}
										
		/*private function flashGps(gps:GPSVO):void
		{	
			mainMap.otherLayer.clear();		
			var borderSymbol:SimpleLineSymbol = new SimpleLineSymbol(SimpleLineSymbol.STYLE_SOLID,0xFFFF,1,3);
			var symbol:SimpleMarkerSymbol = new SimpleMarkerSymbol(SimpleMarkerSymbol.STYLE_SQUARE,60,0x0,0);
			symbol.outline = borderSymbol;
			var focusGraphic:Graphic = new Graphic(gps.mapPoint,symbol);
			focusGraphic.attributes = gps;
			//focusGraphic.addEventListener(MouseEvent.CLICK, onGPSClick);
			mainMap.otherLayer.add(focusGraphic);
			
			var gr:Graphic = this.dicGPSGraphics[gps.gpsSimCard]
				
			var sequence:Sequence = new Sequence;
			
			var fade2:Fade = new Fade;
			fade2.alphaFrom = 1;
			fade2.alphaTo = 0;
			sequence.addChild(fade2);
			
			var fade1:Fade = new Fade;
			fade1.alphaFrom = 0;
			fade1.alphaTo = 1;
			sequence.addChild(fade1);
			
			sequence.duration = 500;
			sequence.repeatCount = 3;
			
			sequence.play([gr]); 
		}
						
		private function focusBitmap(bitmapAsset:BitmapAsset,focusColor:Number):BitmapAsset
		{			
			var bitmapData:BitmapData = bitmapAsset.bitmapData.clone();
			
			bitmapData.lock();
			for(var x:Number = 0;x<bitmapData.width - 1;x++)
			{
				bitmapData.setPixel32(x,0,focusColor);
				bitmapData.setPixel32(x,1,focusColor);
				bitmapData.setPixel32(x,bitmapData.height - 2,focusColor);
				bitmapData.setPixel32(x,bitmapData.height - 1,focusColor);
			}
			for(var y:Number = 0;y<bitmapData.height - 1;y++)
			{
				bitmapData.setPixel32(0,y,focusColor);	
				bitmapData.setPixel32(1,y,focusColor);	
				bitmapData.setPixel32(bitmapData.width - 2,y,focusColor);	
				bitmapData.setPixel32(bitmapData.width - 1,y,focusColor);				
			}
			bitmapData.unlock();
				
			return new BitmapAsset(bitmapData);
		}
		
		private function renderBitmap(bimmapData:BitmapData,renderColor:Number):BitmapData
		{			
			var result:BitmapData = bimmapData.clone();
			
			var srcRed:Number =  ((renderColor & 0xFF0000) >> 16) / 3 / 255;
			var srcGreen:Number =  ((renderColor & 0x00FF00) >> 8) / 3 / 255;
			var srcBlue:Number =  (renderColor & 0x0000FF) / 3 / 255;
			
			var matrix:Array = new Array();
			matrix = matrix.concat([srcRed, srcRed, srcRed, 0, 0]); // red
			matrix = matrix.concat([srcGreen, srcGreen, srcGreen, 0, 0]); // green
			matrix = matrix.concat([srcBlue,srcBlue, srcBlue, 0, 0]); // blue
			matrix = matrix.concat([0, 0, 0, 1, 0]); // alpha
			
			var filter:ColorMatrixFilter = new ColorMatrixFilter(matrix);
			
			result.applyFilter(result,
				new Rectangle(0, 0, result.width, result.height),
				new Point(0, 0),
				filter);
			
			return result;	
		}
		
		private function getGraphicByAlarm(alarm:AlarmInfoVO):Graphic
		{
			for each(var graphic:Graphic in mainMap.alarmLayer.graphicProvider)
			{
				if((graphic.attributes as AlarmInfoVO).id == alarm.id)
					return graphic;
			}
			
			return null;
		}*/
	}
}