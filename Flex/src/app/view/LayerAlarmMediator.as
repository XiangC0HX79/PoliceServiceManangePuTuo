package app.view
{
	import app.AppNotification;
	import app.event.AppEvent;
	import app.model.AlarmInfoProxy;
	import app.model.vo.AlarmInfoVO;
	import app.model.vo.AlarmPoliceVO;
	import app.model.vo.AppConfigVO;
	import app.model.vo.GPSNewVO;
	import app.view.components.MainMenu;
	import app.view.components.subComponents.InfoRendererAlarmPolice;
	
	import com.esri.ags.Graphic;
	import com.esri.ags.events.GraphicEvent;
	import com.esri.ags.layers.GraphicsLayer;
	import com.esri.ags.symbols.CompositeSymbol;
	import com.esri.ags.symbols.InfoSymbol;
	import com.esri.ags.symbols.PictureMarkerSymbol;
	import com.esri.ags.symbols.SimpleLineSymbol;
	import com.esri.ags.symbols.SimpleMarkerSymbol;
	
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.core.ClassFactory;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class LayerAlarmMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "LayerAlarmMediator";
		
		private var dicSelect:Dictionary = new Dictionary;
		
		private var dicGraphics:Dictionary = new Dictionary;
		
		private var alarmInfoProxy:AlarmInfoProxy = null;
		
		public function LayerAlarmMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			layerAlarm.addEventListener(GraphicEvent.GRAPHIC_ADD,onGraphicAdd);			
			
			layerAlarm.addEventListener(AppEvent.POLICEARRIVECONFIRM,onPoliceArriveConfim);
			layerAlarm.addEventListener(AppEvent.POLICEARRIVECANCEL,onPoliceArriveCancel);
			
			layerAlarm.visible = false;
			
			alarmInfoProxy = facade.retrieveProxy(AlarmInfoProxy.NAME) as AlarmInfoProxy;
		}
		
		private function get layerAlarm():GraphicsLayer
		{
			return viewComponent as GraphicsLayer;
		}
		
		private function getGraphicByAlarmPolice(alarmPolice:AlarmPoliceVO):Graphic
		{			
			for each(var item:Graphic in layerAlarm.graphicProvider)
			{
				if(item.attributes is AlarmPoliceVO)
				{
					var graphicAlarmPolice:AlarmPoliceVO =  item.attributes as AlarmPoliceVO;
					if(graphicAlarmPolice.userID == alarmPolice.userID)
					{
						return item;
					}
				}
			}
			
			return null;
		}
		
		private function onGraphicAdd(event:GraphicEvent):void
		{	
			if(event.graphic.attributes is AlarmInfoVO)
			{
				event.graphic.addEventListener(MouseEvent.CLICK, onGraphicClick);
			}
		}
		
		private function onGraphicClick(event:MouseEvent):void
		{			
			var graphic:Graphic = event.currentTarget as Graphic;
			sendNotification(AppNotification.NOTIFY_LAYERALARM_GRAPHICCLICK,graphic.attributes);
		}
		
		private function onPoliceArriveConfim(event:AppEvent):void
		{
			var alarmPolice:AlarmPoliceVO = event.data as AlarmPoliceVO;
			var alarmInfoProxy:AlarmInfoProxy = facade.retrieveProxy(AlarmInfoProxy.NAME) as AlarmInfoProxy;
			//alarmInfoProxy.setAlarmPoliceType(alarmPolice,"2");
			
			//var graphic:Graphic = dicGraphicsPolice[alarmPolice.userID];
			layerAlarm.remove(getGraphicByAlarmPolice(alarmPolice));
		}
		
		private function onPoliceArriveCancel(event:AppEvent):void
		{			
			var alarmPolice:AlarmPoliceVO = event.data as AlarmPoliceVO;
			
			//var graphic:Graphic = dicGraphicsPolice[alarmPolice.userID];
			layerAlarm.remove(getGraphicByAlarmPolice(alarmPolice));
		}
		
	/*	private function onGraphicMouseOverHandler(event:MouseEvent):void
		{
			var graphic:Graphic = event.currentTarget as Graphic;	
			sendNotification(AppNotification.NOTIFY_LAYERALARM_GRAPHICMOUSEOVER,graphic.attributes);
		}
		
		private function oGraphicMouseOutHandler(event:MouseEvent):void
		{
			var graphic:Graphic = event.currentTarget as Graphic;	
			sendNotification(AppNotification.NOTIFY_LAYERALARM_GRAPHICMOUSEOUT,graphic.attributes);
		}*/
		
		private function createGraphic(alarm:AlarmInfoVO):Graphic
		{
			var graphic:Graphic = new Graphic(alarm.mapPoint);
			graphic.attributes = alarm;
			if(alarm.isFocus)
			{
				graphic.symbol = new PictureMarkerSymbol("assets/image/alarm4.png");
			}
			else if(alarm.typeColor == 1)
			{
				graphic.symbol = new PictureMarkerSymbol("assets/image/alarm2.png");
			}
			else 
			{
				graphic.symbol = new PictureMarkerSymbol("assets/image/alarm5.png");
			}		
			
			return graphic;
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_MENUBAR,
				
				AppNotification.NOTIFY_ALARM_INIT,
				AppNotification.NOTIFY_ALARM_REALTIME,
				AppNotification.NOTIFY_ALARM_HISTORY,
				
				AppNotification.NOTIFY_ALARM_SELECT,
				
				AppNotification.NOTIFY_ALARM_FLASH,
												
				AppNotification.NOTIFY_ALARM_CORRECT,				
				AppNotification.NOTIFY_ALARM_FOCUS,
				AppNotification.NOTIFY_ALARM_HIDE,
				
				//AppNotification.NOTIFY_MAP_INFOALARMHIDE,
				
				//AppNotification.NOTIFY_GPS_RECEIVE
			];
		}
				
		override public function handleNotification(notification:INotification):void
		{			
			switch(notification.getName())
			{
				case AppNotification.NOTIFY_MENUBAR:
					layerAlarm.visible = (notification.getType() == MainMenu.ALARMINFO);
					break;
				
				case AppNotification.NOTIFY_ALARM_INIT:
				case AppNotification.NOTIFY_ALARM_HISTORY:
					clear();				
										
					for each(var alarm:AlarmInfoVO in alarmInfoProxy.dic)
					{
						if(alarm.isFocus)
						{
							var graphic:Graphic = createGraphic(alarm);
							
							layerAlarm.add(graphic);
							
							dicGraphics[alarm.id] = graphic;
						}
					}
					break;
							
				case AppNotification.NOTIFY_ALARM_SELECT:
					clear();		
					
					for each(alarm in alarmInfoProxy.dic)
					{
						if(alarm.selected)
						{
							graphic = createGraphic(alarm);
							
							layerAlarm.add(graphic);
							
							dicGraphics[alarm.id] = graphic;
						}
					}
					break;
				
				case AppNotification.NOTIFY_ALARM_FLASH:
					flash(notification.getBody() as AlarmInfoVO)
					break;
				
				case AppNotification.NOTIFY_ALARM_REALTIME:					
					var table:ArrayCollection = notification.getBody() as ArrayCollection;
					for(var i:Number = 1;i<table.length;i++)
					{
						refreshAlarm(new AlarmInfoVO(table[i]));
					}
					break;
				
				case AppNotification.NOTIFY_ALARM_FOCUS:
				case AppNotification.NOTIFY_ALARM_HIDE:
				case AppNotification.NOTIFY_ALARM_CORRECT:
					refreshAlarm(notification.getBody() as AlarmInfoVO);
					break;
								
				//测试影藏
				//case AppNotification.NOTIFY_GPS_RECEIVE:
				//	refreshAlarmTip();
				//	break;
			}
		}
		
		private function clear():void
		{
			dicGraphics = new Dictionary;
			layerAlarm.clear();
		}
		
		private function flash(alarm:AlarmInfoVO):void
		{
			dicSelect = new Dictionary;
			dicSelect[alarm.id] = alarm;
			
			var graphic:Graphic = dicGraphics[alarm.id] as Graphic;
			
			if(graphic == null)
			{
				graphic = createGraphic(alarm);
				
				layerAlarm.add(graphic);
				
				dicGraphics[alarm.id] = graphic;
			}
			
			refreshAll();
			
			select(graphic);
			
			sendNotification(AppNotification.NOTIFY_MAP_FLASH,[graphic]);
		}
				
		private function refreshAll():void
		{
			for each(var graphic:Graphic in dicGraphics)
			{
				refresh(graphic);
			}
		}
		
		private function refreshAlarm(alarm:AlarmInfoVO):void
		{
			var graphic:Graphic = dicGraphics[alarm.id] as Graphic;
			
			if(graphic == null)
			{
				graphic = createGraphic(alarm);
				
				layerAlarm.add(graphic);
				
				dicGraphics[alarm.id] = graphic;
			}
			
			refresh(graphic);
		}
		
		private function refresh(graphic:Graphic):void
		{
			var alarm:AlarmInfoVO = graphic.attributes as AlarmInfoVO;			
			graphic.geometry = alarm.mapPoint;
			
			if(alarm.isFocus)
			{
				graphic.symbol = new PictureMarkerSymbol("assets/image/alarm4.png");
			}
			else if(alarm.typeColor == 1)
			{
				graphic.symbol = new PictureMarkerSymbol("assets/image/alarm2.png");
			}
			else 
			{
				graphic.symbol = new PictureMarkerSymbol("assets/image/alarm5.png");
			}		
				
			if(dicSelect[alarm.id] != undefined)
			{
				select(graphic);
			}
			
			graphic.visible = alarm.isMapShow;
			
			graphic.refresh();
		}
		
		private function select(graphic:Graphic):void
		{
			var selectedSymbol:SimpleMarkerSymbol = new SimpleMarkerSymbol(
				SimpleMarkerSymbol.STYLE_SQUARE,32,0x0,0,0,2,0
				,new SimpleLineSymbol(SimpleLineSymbol.STYLE_SOLID,0xFF0000,1,3));
			
			var graphicSymbol:CompositeSymbol = new CompositeSymbol([selectedSymbol,graphic.symbol]);	
			graphic.symbol = graphicSymbol;
			graphic.refresh();
		}
		
		private function refreshAlarmTip():void
		{
			for each(var item:AlarmInfoVO in alarmInfoProxy.listAlarmInfo)
			{
				if((item.isMapShow) && (item.isFocus))
				{
					for each(var alarmPolice:AlarmPoliceVO in item.listPolice)
					{
						if((alarmPolice.type == "1") && (alarmPolice.gps != null))
						{
							var dx:Number = item.mapPoint.x - alarmPolice.gps.mapPoint.x;
							var dy:Number = item.mapPoint.y - alarmPolice.gps.mapPoint.y;
							var dis:Number = Math.sqrt(dx*dx + dy*dy);
							if((AppConfigVO.debug) || (dis < AlarmPoliceVO.TIP_DIS))
							{																
								//sendNotification(AppNotification.NOTIFY_ALARM_POLICEARRIVE,alarmPolice);
								if(alarmPolice.gps.isMapShow)
								{
									var graphic:Graphic = getGraphicByAlarmPolice(alarmPolice); //getGraphicByAlarmPolice(alarmPolice);
									
									if(graphic == null)
									{										
										graphic = new Graphic(alarmPolice.gps.mapPoint);										
										graphic.attributes = alarmPolice;
										
										var infoSymbol:InfoSymbol = new InfoSymbol;
										infoSymbol.infoRenderer = new ClassFactory(InfoRendererAlarmPolice);			
										graphic.symbol = infoSymbol;
										
										//dicGraphicsPolice[alarmPolice.userID] = graphic;
										layerAlarm.add(graphic);
									}
								}
							}
						}
					}
				}
			}
		}
	}
}