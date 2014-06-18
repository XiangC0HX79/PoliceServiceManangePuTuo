package app.view
{
	import com.esri.ags.Graphic;
	import com.esri.ags.events.GraphicEvent;
	import com.esri.ags.events.ZoomEvent;
	import com.esri.ags.layers.GraphicsLayer;
	import com.esri.ags.layers.supportClasses.LOD;
	import com.esri.ags.symbols.CompositeSymbol;
	import com.esri.ags.symbols.PictureMarkerSymbol;
	import com.esri.ags.symbols.SimpleMarkerSymbol;
	import com.esri.ags.symbols.TextSymbol;
	
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	
	import mx.collections.ArrayCollection;
	
	import app.AppNotification;
	import app.model.QWPointProxy;
	import app.model.dict.DicDepartment;
	import app.model.dict.DicLayer;
	import app.model.dict.DicPatrolPoint;
	import app.model.dict.DicPatrolZone;
	import app.model.vo.QwPointVO;
	import app.view.components.MainMenu;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class LayerQwPointMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "LayerQwPointMediator";
					
		public function LayerQwPointMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			layerQwPoint.addEventListener(GraphicEvent.GRAPHIC_ADD,onGraphicAdd);
						
			layerQwPoint.visible = false;
		}
		
		private function get layerQwPoint():GraphicsLayer
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
			sendNotification(AppNotification.NOTIFY_LAYER_QWPOINT_CLICK,graphic.attributes);
		}
		
		private function refresh():void
		{			
			layerQwPoint.clear();
			
			var qwPointProxy:QWPointProxy = facade.retrieveProxy(QWPointProxy.NAME) as QWPointProxy;
			for each(var item:QwPointVO in qwPointProxy.col)
			{
				layerQwPoint.add(createGraphic(item));
			}
		}
		
		private function createGraphic(qwPoint:QwPointVO):Graphic
		{			
			var graphic:Graphic = new Graphic;
			graphic.geometry = qwPoint.pt;
			graphic.attributes = qwPoint;
						
			var symbol:PictureMarkerSymbol = new PictureMarkerSymbol;
			symbol.source = qwPoint.ImgPath;
			symbol.yoffset = 10;
			
			if(QwPointVO.SHOW_NAME)
			{
				var textFormat:TextFormat = new TextFormat;
				textFormat.bold = true;
				textFormat.font = "黑体";
				textFormat.size = 12;
				
				var textSymbol:TextSymbol = new TextSymbol;
				textSymbol.text = qwPoint.Name;
				textSymbol.yoffset = -10;			
				textSymbol.textFormat = textFormat;
							
				graphic.symbol = new CompositeSymbol([symbol,textSymbol]);
			}
			else
			{
				graphic.symbol = symbol;				
			}
			
			return graphic;
		}
		
		override public function listNotificationInterests():Array
		{
			return [
					AppNotification.NOTIFY_MENUBAR,
					AppNotification.NOTIFY_APP_INIT,
					
					AppNotification.NOTIFY_LAYER_QWPOINT_REFRESH,
					AppNotification.NOTIFY_QWPOINT_FLASH
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{			
			switch(notification.getName())
			{	
				case AppNotification.NOTIFY_MENUBAR:
					layerQwPoint.visible = (notification.getType() == MainMenu.QW_POINT);
					break;
				
				case AppNotification.NOTIFY_APP_INIT:
					break;
				
				case AppNotification.NOTIFY_LAYER_QWPOINT_REFRESH:
					refresh();
					break;
				
				case AppNotification.NOTIFY_QWPOINT_FLASH:
					var qwPoint:QwPointVO = notification.getBody() as QwPointVO;
					for each(var graphic:Graphic in layerQwPoint.graphicProvider)
					{
						if(graphic.attributes == qwPoint)
						{
							sendNotification(AppNotification.NOTIFY_MAP_FLASH,[graphic]);
						}
					}
					break;
			}
		}
	}
}