package app.view
{
	import app.AppNotification;
	import app.model.dict.DicElePolice;
	import app.model.dict.DicLayer;
	
	import com.esri.ags.Graphic;
	import com.esri.ags.events.GraphicEvent;
	import com.esri.ags.events.ZoomEvent;
	import com.esri.ags.layers.GraphicsLayer;
	import com.esri.ags.layers.supportClasses.LOD;
	import com.esri.ags.symbols.CompositeSymbol;
	import com.esri.ags.symbols.PictureMarkerSymbol;
	import com.esri.ags.symbols.SimpleLineSymbol;
	import com.esri.ags.symbols.SimpleMarkerSymbol;
	import com.esri.ags.symbols.TextSymbol;
	
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class LayerElePoliceMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "LayerElePoliceMediator";
						
		[Embed(source="assets/image/elepolice.png")]
		public static const elepoliceClass:Class;
		
		[Embed(source="assets/image/gateway.png")]
		public static const gatewayClass:Class;
		
		[Embed(source="assets/image/video.png")]
		public static const videoClass:Class;
		
		private var initial:Number = 0;
		
		public function LayerElePoliceMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			layerElePolicePoint.addEventListener(GraphicEvent.GRAPHIC_ADD,onGraphicAdd);
		}
		
		private function get layerElePolicePoint():GraphicsLayer
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
			sendNotification(AppNotification.NOTIFY_LAYERELEPOLICE_GRAPHICCLICK,graphic.attributes);
		}
		
		private function createGraphic(patrolPoint:DicElePolice):Graphic
		{			
			var graphic:Graphic = new Graphic;
			graphic.geometry = patrolPoint.mapPoint;
			graphic.attributes = patrolPoint;
						
			var symbol:PictureMarkerSymbol = new PictureMarkerSymbol;
			if(patrolPoint.type == "1")
				symbol.source = elepoliceClass;
			else if(patrolPoint.type == "2")
				symbol.source = gatewayClass;
			else if(patrolPoint.type == "3")
				symbol.source = videoClass;
						
			graphic.symbol = symbol;
			
			return graphic;
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_OVERVIEW_SET,
				AppNotification.NOTIFY_LAYERELEPOLICE_FLASH
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{			
			switch(notification.getName())
			{				
				case AppNotification.NOTIFY_OVERVIEW_SET:
					if(!(initial & 0x1))
					{
						for each(var elePolice:DicElePolice in DicElePolice.dict)
						{
							if(elePolice.type == "1")
							{
								layerElePolicePoint.add(createGraphic(elePolice));
							}
						}
						
						initial |= 0x1;
					}
					
					if(!(initial & 0x2))
					{
						for each(elePolice in DicElePolice.dict)
						{
							if(elePolice.type == "2")
							{
								layerElePolicePoint.add(createGraphic(elePolice));
							}
						}
						
						initial |= 0x2;
					}
					
					if(!(initial & 0x4))
					{
						for each(elePolice in DicElePolice.dict)
						{
							if(elePolice.type == "3")
							{
								layerElePolicePoint.add(createGraphic(elePolice));
							}
						}
						
						initial |= 0x4;
					}
					
					for each(var graphic:Graphic in layerElePolicePoint.graphicProvider)
					{
						elePolice = graphic.attributes as DicElePolice;
						if(elePolice.type == "1")
							graphic.visible = DicLayer.ELEPOLICE.selected;
						else if(elePolice.type == "2")
							graphic.visible = DicLayer.GATEWAY.selected;
						else if(elePolice.type == "3")
							graphic.visible = DicLayer.VIDEO.selected;
					}			
					break;
				
				case AppNotification.NOTIFY_LAYERELEPOLICE_FLASH:
					elePolice = notification.getBody() as DicElePolice;
					
					sendNotification(AppNotification.NOTIFY_LAYERFLASH_FLASH,[createFlashGraphic(elePolice)]);
					break;
			}
		}
		
		private function createFlashGraphic(patrolPoint:DicElePolice):Graphic
		{
			var graphic:Graphic = new Graphic;
			graphic.geometry = patrolPoint.mapPoint;
			graphic.attributes = patrolPoint;
			
			/*var iconSymbol:PictureMarkerSymbol = new PictureMarkerSymbol;
			if(patrolPoint.type == "1")
				iconSymbol.source = elepoliceClass;
			else if(patrolPoint.type == "2")
				iconSymbol.source = gatewayClass;
			else if(patrolPoint.type == "3")
				iconSymbol.source = videoClass;*/
			
			var selectedSymbol:SimpleMarkerSymbol = new SimpleMarkerSymbol(SimpleMarkerSymbol.STYLE_SQUARE,30,0x0,0,0,0,0
				,new SimpleLineSymbol(SimpleLineSymbol.STYLE_SOLID,0xFF0000,1,3));
			
			graphic.symbol =  selectedSymbol;
			
			return graphic;
		}
	}
}