package app.view
{
	import app.AppNotification;
	import app.model.dict.DicDepartment;
	import app.model.dict.DicLayer;
	import app.model.dict.DicPatrolPoint;
	import app.model.dict.DicPatrolZone;
	import app.view.components.MainMenu;
	
	import com.esri.ags.Graphic;
	import com.esri.ags.events.ZoomEvent;
	import com.esri.ags.layers.GraphicsLayer;
	import com.esri.ags.layers.supportClasses.LOD;
	import com.esri.ags.symbols.CompositeSymbol;
	import com.esri.ags.symbols.PictureMarkerSymbol;
	import com.esri.ags.symbols.SimpleMarkerSymbol;
	import com.esri.ags.symbols.TextSymbol;
	
	import flash.text.TextFormat;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class LayerPatrolPointMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "LayerPatrolPointMediator";
		
		private var overviewVisible:Boolean = false;
		private var panelVisible:Boolean = false;
		
		private var scaleVisible:Boolean = false;
				
		[Embed(source="assets/image/m_book1.png")]
		public static const patrolPointClass1:Class;
		
		[Embed(source="assets/image/m_book2.png")]
		public static const patrolPointClass2:Class;
		
		public function LayerPatrolPointMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
						
			layerPatrolPoint.visible = false;
		}
		
		private function get layerPatrolPoint():GraphicsLayer
		{
			return viewComponent as GraphicsLayer;
		}
		
		private function onZoomEnd(event:ZoomEvent):void
		{			
			this.scaleVisible  = false;
			
			for(var i:Number = layerPatrolPoint.map.lods.length - 3;i<layerPatrolPoint.map.lods.length;i++)
			{
				var lod:LOD = layerPatrolPoint.map.lods[i];
				if(layerPatrolPoint.map.scale == lod.scale)
				{
					this.scaleVisible = true;
					break;
				}
			}
			
			refresh();
		}
		
		private function refresh():void
		{
			layerPatrolPoint.visible = overviewVisible || panelVisible;
			
			if(layerPatrolPoint.visible)
			{
				for each(var graphic:Graphic in layerPatrolPoint.graphicProvider)
				{										
					var patrolPoint:DicPatrolPoint = graphic.attributes as DicPatrolPoint;
					var patrolZone:DicPatrolZone = DicPatrolZone.dict[patrolPoint.patrolZoneID] as DicPatrolZone;
					
					var graphicSymbol:CompositeSymbol = graphic.symbol as CompositeSymbol;				
					var symbolArr:ArrayCollection = graphicSymbol.symbols as ArrayCollection;
					
					var labelSymbol:TextSymbol = symbolArr[1] as TextSymbol;
					labelSymbol.text = (this.scaleVisible)?patrolPoint.label:" ";
					
					if(patrolZone != null)
					{
						var dept:DicDepartment = DicDepartment.dict[patrolZone.depid] as DicDepartment;
						if(dept != null)
						{
							graphic.visible = dept.isMapShow;
						}
					}
				}
			}
		}
		
		private function createGraphic(patrolPoint:DicPatrolPoint):Graphic
		{			
			var graphic:Graphic = new Graphic;
			graphic.geometry = patrolPoint.mapPoint;
			graphic.attributes = patrolPoint;
			
			var textFormat:TextFormat = new TextFormat;
			textFormat.bold = true;
			textFormat.font = "黑体";
			textFormat.size = 12;
			
			var textSymbol:TextSymbol = new TextSymbol;
			textSymbol.text = patrolPoint.label;
			textSymbol.yoffset = -10;			
			textSymbol.textFormat = textFormat;
			
			var symbol:PictureMarkerSymbol = new PictureMarkerSymbol;
			symbol.source = (patrolPoint.type == "岗亭")?patrolPointClass2:patrolPointClass1;
			symbol.yoffset = 10;
						
			graphic.symbol = new CompositeSymbol([symbol,textSymbol]);
			
			return graphic;
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
					for each(var patrolPoint:DicPatrolPoint in DicPatrolPoint.dict)
					{
						layerPatrolPoint.add(createGraphic(patrolPoint));
					}
					
					onZoomEnd(null);
					layerPatrolPoint.map.addEventListener(ZoomEvent.ZOOM_END,onZoomEnd);
					break;
				
				case AppNotification.NOTIFY_OVERVIEW_SET:
					overviewVisible = DicLayer.PATROLPOINT.selected;
					
					refresh();
					break;
			}
		}
	}
}