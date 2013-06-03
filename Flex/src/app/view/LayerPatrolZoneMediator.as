package app.view
{
	import app.AppNotification;
	import app.model.dict.DicDepartment;
	import app.model.dict.DicLayer;
	import app.model.dict.DicPatrolZone;
	import app.model.vo.AppConfigVO;
	import app.view.components.MainMenu;
	
	import com.esri.ags.Graphic;
	import com.esri.ags.layers.GraphicsLayer;
	import com.esri.ags.symbols.SimpleFillSymbol;
	import com.esri.ags.symbols.SimpleLineSymbol;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class LayerPatrolZoneMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "LayerPatrolZoneMediator";
		
		private var overviewVisible:Boolean = false;
		private var panelVisible:Boolean = false;
		
		public function LayerPatrolZoneMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			//layerPatrolZone.symbol = new SimpleFillSymbol("solid",0xFF0000,0.1,new SimpleLineSymbol("solid",0xFF0000,1,2));
			
			layerPatrolZone.visible = false;
		}
		
		private function get layerPatrolZone():GraphicsLayer
		{
			return viewComponent as GraphicsLayer;
		}
		
		private function refresh():void
		{			
			layerPatrolZone.visible = overviewVisible || panelVisible;
			
			if(layerPatrolZone.visible)
			{
				for each(var graphic:Graphic in layerPatrolZone.graphicProvider)
				{
					var patrolZone:DicPatrolZone = graphic.attributes as DicPatrolZone;
					
					var dept:DicDepartment = DicDepartment.dict[patrolZone.depid] as DicDepartment;
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
					AppNotification.NOTIFY_MENUBAR,
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
					for each(var patrolZone:DicPatrolZone in DicPatrolZone.list)
					{
						if(patrolZone.polygon != null)
						{
							var graphic:Graphic = new Graphic;
							graphic.geometry = patrolZone.polygon;
							graphic.attributes = patrolZone;
							graphic.symbol = (AppConfigVO.Auth == "1")
								?new SimpleFillSymbol("solid",DicPatrolZone.defaultColor,0.1,new SimpleLineSymbol("solid",DicPatrolZone.defaultColor,1,2))
								:new SimpleFillSymbol("solid",patrolZone.color,0.1,new SimpleLineSymbol("solid",patrolZone.color,1,2));
							
							layerPatrolZone.add(graphic);
						}
					}
					break;
				
				case AppNotification.NOTIFY_OVERVIEW_SET:
					overviewVisible = DicLayer.PATROLZONE.selected;
					
					refresh();
					break;
			}
		}
	}
}