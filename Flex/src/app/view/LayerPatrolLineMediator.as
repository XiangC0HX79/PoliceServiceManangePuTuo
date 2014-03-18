package app.view
{
	import com.esri.ags.Graphic;
	import com.esri.ags.layers.GraphicsLayer;
	import com.esri.ags.symbols.CompositeSymbol;
	import com.esri.ags.symbols.SimpleFillSymbol;
	import com.esri.ags.symbols.SimpleLineSymbol;
	import com.esri.ags.symbols.TextSymbol;
	
	import flash.text.TextFormat;
	
	import app.AppNotification;
	import app.model.dict.DicDepartment;
	import app.model.dict.DicLayer;
	import app.model.dict.DicPatrolLine;
	import app.model.vo.AppConfigVO;
	import app.view.components.MainMenu;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class LayerPatrolLineMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "LayerPatrolLineMediator";
		
		private var overviewVisible:Boolean = false;
		private var panelVisible:Boolean = false;
		
		public function LayerPatrolLineMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
						
			layerPatrolLine.visible = false;
		}
		
		private function get layerPatrolLine():GraphicsLayer
		{
			return viewComponent as GraphicsLayer;
		}
		
		private function refresh():void
		{			
			layerPatrolLine.visible = overviewVisible || panelVisible;
			
			if(layerPatrolLine.visible)
			{
				for each(var graphic:Graphic in layerPatrolLine.graphicProvider)
				{
					var patrolLine:DicPatrolLine = graphic.attributes as DicPatrolLine;
					
					var dept:DicDepartment = DicDepartment.dict[patrolLine.depid] as DicDepartment;
					if(dept != null)
					{
						graphic.visible = dept.isMapShow;
					}
				}
			}
		}
		
		override public function listNotificationInterests():Array
		{
			return [
					//AppNotification.NOTIFY_MENUBAR,
					AppNotification.NOTIFY_APP_INIT,
					AppNotification.NOTIFY_OVERVIEW_SET
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{			
			switch(notification.getName())
			{
				case AppNotification.NOTIFY_MENUBAR:
					panelVisible = (notification.getType() == MainMenu.SERVICELINEBACK);
					
					refresh();
					break;
				
				case AppNotification.NOTIFY_APP_INIT:
					for each(var patrolLine:DicPatrolLine in DicPatrolLine.list)
					{
						if(patrolLine.polyline != null)
						{
							var graphic:Graphic = new Graphic;
							graphic.geometry = patrolLine.polyline;
							graphic.attributes = patrolLine;
							
							graphic.symbol = new SimpleLineSymbol("solid",patrolLine.color,1,2);
														
							layerPatrolLine.add(graphic);
							
							var txtGraphic:Graphic = new Graphic;
							txtGraphic.geometry = patrolLine.polyline.paths[0][0];
							txtGraphic.attributes = patrolLine;
							
							var textFormat:TextFormat = new TextFormat;
							textFormat.bold = true;
							textFormat.font = "黑体";
							textFormat.size = 12;
							
							var textSymbol:TextSymbol = new TextSymbol;
							textSymbol.text = patrolLine.label + "(" + patrolLine.callNo + ")";
							//textSymbol.yoffset = -10;			
							textSymbol.textFormat = textFormat;
							
							txtGraphic.symbol = textSymbol;
													
							layerPatrolLine.add(txtGraphic);
						}
					}
					break;
				
				case AppNotification.NOTIFY_OVERVIEW_SET:
					overviewVisible = DicLayer.PATROLLINE.selected;
					
					refresh();
					break;
			}
		}
	}
}