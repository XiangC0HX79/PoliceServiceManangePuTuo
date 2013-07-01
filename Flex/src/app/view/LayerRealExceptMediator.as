package app.view
{
	import app.AppNotification;
	import app.ApplicationFacade;
	import app.model.GPSRealTimeInfoProxy;
	import app.model.dict.DicDepartment;
	import app.model.dict.DicExceptType;
	import app.model.dict.DicGPSImage;
	import app.model.dict.DicPatrolPoint;
	import app.model.dict.DicPatrolZone;
	import app.model.dict.DicPoliceType;
	import app.model.dict.DicServiceStatus;
	import app.model.vo.AppConfigVO;
	import app.model.vo.GPSNewVO;
	import app.model.vo.ServiceExceptVO;
	import app.view.components.MainMenu;
	import app.view.components.MainTool;
	
	import com.esri.ags.Graphic;
	import com.esri.ags.events.GraphicEvent;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.layers.GraphicsLayer;
	import com.esri.ags.symbols.CompositeSymbol;
	import com.esri.ags.symbols.PictureMarkerSymbol;
	import com.esri.ags.symbols.SimpleFillSymbol;
	import com.esri.ags.symbols.SimpleLineSymbol;
	import com.esri.ags.symbols.SimpleMarkerSymbol;
	import com.esri.ags.symbols.TextSymbol;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.effects.Fade;
	import mx.effects.Sequence;
	
	import org.osmf.events.TimeEvent;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class LayerRealExceptMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "LayerRealExceptMediator";
				
		private var exceptTimer:Timer;
		
		private var soundPlay:Sound;
		
		private var _dictExceptGraphic:Dictionary;
		
		private var _flashMovie:Sequence;
		
		public function LayerRealExceptMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			 
			layerRealExcept.addEventListener(GraphicEvent.GRAPHIC_ADD,onGraphicAdd);	
			
			_dictExceptGraphic = new Dictionary;
			
			_flashMovie = new Sequence;
		}
		
		private function get layerRealExcept():GraphicsLayer
		{
			return viewComponent as GraphicsLayer;
		}
		
		private function onGraphicAdd(event:GraphicEvent):void
		{	
			event.graphic.addEventListener(MouseEvent.CLICK, onGraphicClick);
		}
		
		private function onGraphicClick(event:MouseEvent):void
		{			
			var graphic:Graphic = event.currentTarget as Graphic;
			var except:ServiceExceptVO = graphic.attributes as ServiceExceptVO;
			if(except.ExceptType != DicExceptType.NOPATROL)
			{
				sendNotification(AppNotification.NOTIFY_LAYEREXCEPT_GRAPHICCLICK,except);
			}
		}
		
		private function createPatrolGraphic(except:ServiceExceptVO):Graphic
		{
			var graphic:Graphic = new Graphic;
			graphic.geometry = except.object;
			graphic.attributes = except;
			graphic.symbol = new SimpleFillSymbol("solid",0xFF0000,0.1,new SimpleLineSymbol("solid",0xFF0000,1,2));
			return graphic;
		}
		
		private function createCarGraphic(except:ServiceExceptVO):Graphic
		{
			var labelSymbol:TextSymbol = null;
			var iconSymbol:PictureMarkerSymbol = null;
			var textFormat:TextFormat = null;		
			var selectedSymbol:SimpleMarkerSymbol = null;
			var tt:DicPoliceType
			var bitmap:Bitmap = new Bitmap(DicGPSImage.getImageClass(DicPoliceType.VEHICLE.id) as BitmapData);
			iconSymbol = new PictureMarkerSymbol(bitmap);
			
			textFormat = new TextFormat;
			textFormat.bold = true;			
			labelSymbol = new TextSymbol;		
			labelSymbol.textFormat = textFormat;
			labelSymbol.color = 0x0000FF;
			
			labelSymbol.text = except.GPSNameOrZoneName;
			labelSymbol.yoffset = 20;
			
			selectedSymbol = new SimpleMarkerSymbol(SimpleMarkerSymbol.STYLE_SQUARE,60,0x0,0,0,2,0
				,new SimpleLineSymbol(SimpleLineSymbol.STYLE_SOLID,0xFF0000,1,3));
			
			var graphic:Graphic = new Graphic();						
			graphic.attributes = except;
			graphic.geometry = except.object;	
			graphic.symbol = new CompositeSymbol([labelSymbol,iconSymbol]);
			
			return graphic;
		}
		
		private function createPeopleGraphic(except:ServiceExceptVO):Graphic
		{
			var labelSymbol:TextSymbol = null;
			var iconSymbol:PictureMarkerSymbol = null;
			var textFormat:TextFormat = null;		
			var selectedSymbol:SimpleMarkerSymbol = null;
			
			if(except.ExceptType == DicExceptType.EMERGENCY)
			{
				iconSymbol = new PictureMarkerSymbol("assets/image/emergency.swf");
			}
			else
			{
				iconSymbol = new PictureMarkerSymbol("assets/image/emergency.png");
			}
			
			textFormat = new TextFormat;
			textFormat.bold = true;			
			labelSymbol = new TextSymbol;		
			labelSymbol.textFormat = textFormat;
			labelSymbol.color = 0x0000FF;
			
			labelSymbol.text = except.GPSNameOrZoneName;
			labelSymbol.yoffset = 30;
			
			selectedSymbol = new SimpleMarkerSymbol(SimpleMarkerSymbol.STYLE_SQUARE,60,0x0,0,0,9,0
				,new SimpleLineSymbol(SimpleLineSymbol.STYLE_SOLID,0xFF0000,1,3));
			
			var graphic:Graphic = new Graphic();						
			graphic.attributes = except;
			graphic.geometry = except.object;	
			graphic.symbol = new CompositeSymbol([labelSymbol,iconSymbol]);
			
			return graphic;
		}
		
		private function onExceptTimer(event:TimerEvent):void
		{
			//var id:String = (AppConfigVO.Auth == "1")?DicDepartment.ALL.id:AppConfigVO.user.department.id;
			
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				[
					"GetRealExcept"
					,onResult
					,[]
					,false
				]);	
			
			function onResult(result:ArrayCollection):void
			{
				for each(var gr:Graphic in _dictExceptGraphic)
				{
					var se:ServiceExceptVO = gr.attributes as ServiceExceptVO;
										
					if(
						(_dictExceptGraphic[se.ExceptID])
						&&
						(GPSNewVO.CurrentTime.time - se.ReportDateTime.time > 600 * 1000)
						)
					{
						del(se);
					}
				}
				
				var alarm:Boolean = false;
								
				for each(var o:Object in result)
				{
					se = new ServiceExceptVO(o);
					if(se.ExceptType.isMonitoring)
					{
						var realTimeInfoProxy:GPSRealTimeInfoProxy = facade.retrieveProxy(GPSRealTimeInfoProxy.NAME) as GPSRealTimeInfoProxy;
						if(se.ExceptType == DicExceptType.CROSSING)
						{
							var gps:GPSNewVO = realTimeInfoProxy.dicGPS[se.GpsIDOrZoneID] as GPSNewVO;
							if(gps != null)
							{
								se.GPSNameOrZoneName = gps.gpsName;
								se.DepID = gps.departmentID;
								se.DepName = gps.departmentNAME;
								se.object = new MapPoint(Number(o.X),Number(o.Y));// gps;
								se.UnNormalDesc = se.GPSNameOrZoneName + "巡逻越界。";
								se.gps = gps;				
							}
						}
						else if(se.ExceptType == DicExceptType.STOPPING)
						{
							gps = realTimeInfoProxy.dicGPS[se.GpsIDOrZoneID] as GPSNewVO;
							if(gps != null)
							{
								se.GPSNameOrZoneName = gps.gpsName;
								se.DepID = gps.departmentID;
								se.DepName = gps.departmentNAME;
								se.object = new MapPoint(Number(o.X),Number(o.Y));// gps;
								se.UnNormalDesc = se.GPSNameOrZoneName + "滞留时间过长。";
								se.gps = gps;						
							}
						}
						else if(se.ExceptType == DicExceptType.NOPATROL)
						{
							var patrolZone:DicPatrolZone = DicPatrolZone.dict[se.GpsIDOrZoneID] as DicPatrolZone;
							if(patrolZone != null)
							{
								se.GPSNameOrZoneName = patrolZone.label;
								se.DepID = patrolZone.depid;
								var department:DicDepartment = DicDepartment.dict[patrolZone.depid] as DicDepartment;
								se.DepName = (department == null)?"":department.label;
								se.object = patrolZone.polygon;
								se.UnNormalDesc = se.GPSNameOrZoneName + "无人巡逻。";
							}
						}
						else if(se.ExceptType == DicExceptType.EMERGENCY)
						{						
							gps = realTimeInfoProxy.dicGPS[se.GpsIDOrZoneID] as GPSNewVO;
							if(gps != null)
							{
								se.GPSNameOrZoneName = gps.gpsName;
								se.DepID = gps.departmentID;
								se.DepName = gps.departmentNAME;
								se.object = new MapPoint(Number(o.X),Number(o.Y));// gps;
								se.UnNormalDesc = se.GPSNameOrZoneName + "警员告警。";
								se.gps = gps;	
							}						
						}
						else if(se.ExceptType == DicExceptType.MANUAL)
						{
							gps = realTimeInfoProxy.dicGPS[se.GpsIDOrZoneID] as GPSNewVO;
							if(gps != null) 
							{
								se.GPSNameOrZoneName = gps.gpsName;
								se.DepID = gps.departmentID;
								se.DepName = gps.departmentNAME;
								se.object = new MapPoint(Number(o.X),Number(o.Y));// gps;
								se.UnNormalDesc = se.GPSNameOrZoneName + "手动修改异常。";
								se.gps = gps;	
							}
						}
					
						if(!_dictExceptGraphic[se.ExceptID])
						{
							add(se);
							
							alarm = true;
						}
					}
				}
					
				if(alarm)
				{											
					soundPlay.play(0,3);
					
					var a:Array = new Array;
					for each(gr in _dictExceptGraphic)
						a.push(gr);
						
					_flashMovie.play(a);
				}
			}
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_APP_INIT,
				
				AppNotification.NOTIFY_TOOLBAR
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{			
			switch(notification.getName())
			{
				case AppNotification.NOTIFY_APP_INIT:
					if(AppConfigVO.exceptMonitorArray.indexOf(Number(AppConfigVO.user.department.id)) >= 0)
					{
						soundPlay = new Sound;
						soundPlay.load(new URLRequest("assets/msg.mp3"));
						
						exceptTimer = new Timer(10000);
						exceptTimer.addEventListener(TimerEvent.TIMER,onExceptTimer);
						exceptTimer.start();
						
						var fade2:Fade = new Fade;
						fade2.alphaFrom = 1;
						fade2.alphaTo = 0;
						_flashMovie.addChild(fade2);
						
						var fade1:Fade = new Fade;
						fade1.alphaFrom = 0;
						fade1.alphaTo = 1;
						_flashMovie.addChild(fade1);
						
						_flashMovie.duration = 500;
						_flashMovie.repeatCount = 0;
					}
					break;
				
				case AppNotification.NOTIFY_TOOLBAR:
					if(notification.getType() == MainTool.CLEARMAP)
					{
						layerRealExcept.clear();
						
						_dictExceptGraphic = new Dictionary;
					}
					break;
			}
		}
		
		private function del(serviceExcept:ServiceExceptVO):void
		{
			var gr:Graphic = _dictExceptGraphic[serviceExcept.ExceptID];
			
			layerRealExcept.remove(gr);
			
			delete _dictExceptGraphic[serviceExcept.ExceptID];			
		}
		
		private function add(except:ServiceExceptVO):void
		{
			var graphic:Graphic = null;
						
			if(except.ExceptType == DicExceptType.STOPPING)
			{
				if((except.gps != null) && (except.gps.policeType != DicPoliceType.VEHICLE))
				{
					graphic = createPeopleGraphic(except);
				}
				else
				{
					graphic = createCarGraphic(except);
				}
			}
			else if(except.ExceptType == DicExceptType.NOPATROL)
			{
				graphic = createPatrolGraphic(except)
			}
			else
			{				
				graphic = createPeopleGraphic(except);
			}
			
			layerRealExcept.add(graphic);
			
			_dictExceptGraphic[except.ExceptID] = graphic;
		}
	}
}