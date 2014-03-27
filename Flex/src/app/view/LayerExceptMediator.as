package app.view
{
	import app.AppNotification;
	import app.model.dict.DicDepartment;
	import app.model.dict.DicExceptType;
	import app.model.dict.DicGPSImage;
	import app.model.dict.DicPatrolPoint;
	import app.model.dict.DicPoliceType;
	import app.model.dict.DicServiceStatus;
	import app.model.vo.AppConfigVO;
	import app.model.vo.ServiceExceptVO;
	import app.view.components.MainMenu;
	import app.view.components.MainTool;
	
	import com.esri.ags.Graphic;
	import com.esri.ags.events.GraphicEvent;
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
	
	import org.osmf.events.TimeEvent;
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class LayerExceptMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "LayerExceptMediator";
		
		public function LayerExceptMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			 
			layerExcept.addEventListener(GraphicEvent.GRAPHIC_ADD,onGraphicAdd);
		}
		
		private function get layerExcept():GraphicsLayer
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
			var bitmap:Bitmap = new Bitmap(DicGPSImage.getImageClass(DicPoliceType.VEHICLE.id,0) as BitmapData);
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
			graphic.symbol = new CompositeSymbol([labelSymbol,iconSymbol,selectedSymbol]);
			
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
			graphic.symbol = new CompositeSymbol([labelSymbol,iconSymbol,selectedSymbol]);
			
			return graphic;
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_MENUBAR,
				
				AppNotification.NOTIFY_TRACKEXCEPT_LOCATE,
				AppNotification.NOTIFY_TRACKEXCEPT_FLASH,
				
				AppNotification.NOTIFY_TOOLBAR
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{			
			switch(notification.getName())
			{				
				case AppNotification.NOTIFY_MENUBAR:
					layerExcept.clear();
					
					layerExcept.visible = (notification.getType() == MainMenu.SERVICEEXCEPT);
					break;
				
				case AppNotification.NOTIFY_TRACKEXCEPT_FLASH:
					flash(notification.getBody() as ServiceExceptVO);
					break;
				
				case AppNotification.NOTIFY_TRACKEXCEPT_LOCATE:
					locate(notification.getBody() as ServiceExceptVO);
					break;
				
				case AppNotification.NOTIFY_TOOLBAR:
					if(notification.getType() == MainTool.CLEARMAP)
					{
						layerExcept.clear();
					}
					break;
			}
		}
		
		private function locate(except:ServiceExceptVO):void
		{
			sendNotification(AppNotification.NOTIFY_MAP_LOCATE,except.object);
		}
				
		private function flash(except:ServiceExceptVO):void
		{
			var graphic:Graphic = null;
			
			layerExcept.clear();
			
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
			
			layerExcept.add(graphic);
			sendNotification(AppNotification.NOTIFY_MAP_FLASH,[graphic]);
		}
	}
}