package app.view
{
	import app.AppNotification;
	import app.model.dict.DicDepartment;
	import app.model.vo.AppConfigVO;
	import app.model.vo.WarningAreaVO;
	import app.view.components.MainMenu;
	
	import com.esri.ags.Graphic;
	import com.esri.ags.layers.GraphicsLayer;
	import com.esri.ags.symbols.SimpleFillSymbol;
	import com.esri.ags.symbols.SimpleLineSymbol;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class LayerWarningAreaMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "LayerWarningAreaMediator";
				
		public function LayerWarningAreaMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			layerWarningArea.visible = false;
		}
		
		private function get layerWarningArea():GraphicsLayer
		{
			return viewComponent as GraphicsLayer;
		}
				
		override public function listNotificationInterests():Array
		{
			return [
					AppNotification.NOTIFY_MENUBAR,
					AppNotification.NOTIFY_WARNINGAREA_REFRESH,
					AppNotification.NOTIFY_WARNINGAREA_FLASH
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{			
			switch(notification.getName())
			{
				case AppNotification.NOTIFY_MENUBAR:
					layerWarningArea.visible = (notification.getType() == MainMenu.WARNING);
					break;
				
				case AppNotification.NOTIFY_WARNINGAREA_REFRESH:
					layerWarningArea.clear();
					
					for each(var waningArea:WarningAreaVO in notification.getBody())
					{
						if(waningArea.polygon != null)
						{
							var graphic:Graphic = new Graphic;
							graphic.geometry = waningArea.polygon;
							graphic.attributes = waningArea;
							graphic.symbol = new SimpleFillSymbol("solid",waningArea.color,0.1,new SimpleLineSymbol("solid",waningArea.color,1,2));
							
							layerWarningArea.add(graphic);
						}
					}
					break;
				
				case AppNotification.NOTIFY_WARNINGAREA_FLASH:
					waningArea = notification.getBody() as WarningAreaVO;
					for each(graphic in layerWarningArea.graphicProvider)
					{
						if(graphic.attributes == waningArea)
						{
							sendNotification(AppNotification.NOTIFY_MAP_FLASH,[graphic]);
						}
					}
					break;
			}
		}
	}
}