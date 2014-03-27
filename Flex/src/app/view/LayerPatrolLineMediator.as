package app.view
{
	import com.esri.ags.Graphic;
	import com.esri.ags.events.GraphicEvent;
	import com.esri.ags.layers.GraphicsLayer;
	import com.esri.ags.symbols.SimpleLineSymbol;
	import com.esri.ags.symbols.TextSymbol;
	
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	
	import mx.collections.ArrayCollection;
	
	import app.AppNotification;
	import app.model.vo.PatrolLineVO;
	import app.view.components.MainMenu;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class LayerPatrolLineMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "LayerPatrolLineMediator";
		
		private var tipGraphic:Graphic;
		
		public function LayerPatrolLineMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
						
			layerPatrolLine.visible = false;			
			
			layerPatrolLine.addEventListener(GraphicEvent.GRAPHIC_ADD,onGraphicAdd);			
		}
		
		private function get layerPatrolLine():GraphicsLayer
		{
			return viewComponent as GraphicsLayer;
		}
		
		private function onGraphicAdd(event:GraphicEvent):void
		{				
			event.graphic.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			event.graphic.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		}
		
		private function onMouseOver(event:MouseEvent):void
		{						
			if(tipGraphic != null)
				layerPatrolLine.remove(tipGraphic);
			
			var gr:Graphic = event.currentTarget as Graphic;
			
			var patrolLine:PatrolLineVO = gr.attributes as PatrolLineVO;
			
			tipGraphic = new Graphic;
			tipGraphic.geometry = layerPatrolLine.map.toMapFromStage(event.stageX,event.stageY - 20);//patrolLine.polyline.paths[0][0];
			tipGraphic.attributes = patrolLine;
			
			var textFormat:TextFormat = new TextFormat;
			textFormat.bold = true;
			textFormat.font = "黑体";
			textFormat.size = 16;
			
			var textSymbol:TextSymbol = new TextSymbol;
			textSymbol.text = patrolLine.label + "(" + patrolLine.callNo + ")";
			//textSymbol.yoffset = -10;		
			textSymbol.textFormat = textFormat;
			
			tipGraphic.symbol = textSymbol;
			
			layerPatrolLine.add(tipGraphic);
			
			//sendNotification(AppNotification.NOTIFY_LAYER_MOUSEOVER);			
		}
		
		private function onMouseOut(event:MouseEvent):void
		{						
			if(tipGraphic != null)
				layerPatrolLine.remove(tipGraphic);
			
			tipGraphic = null;
			
			//sendNotification(AppNotification.NOTIFY_LAYER_MOUSEOUT);			
		}
		
		override public function listNotificationInterests():Array
		{
			return [
					AppNotification.NOTIFY_MENUBAR,
					AppNotification.NOTIFY_PATROL_LINE_UPDATE,
					AppNotification.NOTIFY_PATROL_LINE_FLASH
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{			
			switch(notification.getName())
			{
				case AppNotification.NOTIFY_MENUBAR:
					layerPatrolLine.visible = (notification.getType() == MainMenu.PATROL_LINE);
					break;
				
				case AppNotification.NOTIFY_PATROL_LINE_UPDATE:
					if(layerPatrolLine.visible)
					{
						layerPatrolLine.clear();
						
						for each(var patrolLine:PatrolLineVO in notification.getBody())
						{
							if(patrolLine.polyline != null)
							{
								var graphic:Graphic = new Graphic;
								graphic.geometry = patrolLine.polyline;
								graphic.attributes = patrolLine;
								
								graphic.symbol = new SimpleLineSymbol("solid",patrolLine.color,1,4);
															
								layerPatrolLine.add(graphic);
							}
						}
					}
					break;
				
				case AppNotification.NOTIFY_PATROL_LINE_FLASH:					
					patrolLine = notification.getBody() as PatrolLineVO;
					
					var arr:Array = [];
					for each(var gr:Graphic in layerPatrolLine.graphicProvider)
					{
						if(gr.attributes == patrolLine)
							arr.push(gr);
					}
					
					sendNotification(AppNotification.NOTIFY_LAYERFLASH_FLASH_SOURCE,arr);
					break;
			}
		}
	}
}