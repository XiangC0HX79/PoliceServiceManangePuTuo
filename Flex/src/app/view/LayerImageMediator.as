package app.view
{
	import app.AppNotification;
	import app.model.vo.AppConfigVO;
	import app.view.components.MainMenu;
	import app.view.components.MainTool;
	
	import com.esri.ags.FeatureSet;
	import com.esri.ags.Graphic;
	import com.esri.ags.SpatialReference;
	import com.esri.ags.events.LayerEvent;
	import com.esri.ags.geometry.Geometry;
	import com.esri.ags.layers.ArcGISTiledMapServiceLayer;
	import com.esri.ags.layers.supportClasses.LayerInfo;
	import com.esri.ags.tasks.FindTask;
	import com.esri.ags.tasks.QueryTask;
	import com.esri.ags.tasks.supportClasses.FindParameters;
	import com.esri.ags.tasks.supportClasses.Query;
	
	import mx.rpc.AsyncResponder;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class LayerImageMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "LayerImageMediator";
				
		private var init:Number = 0;
		
		public function LayerImageMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);		
			
			layerImage.visible = false;
		}
		
		private function get layerImage():ArcGISTiledMapServiceLayer
		{
			return viewComponent as ArcGISTiledMapServiceLayer;
		}
								
		private function onLayerLoadError(event:LayerEvent):void
		{
			sendNotification(AppNotification.NOTIFY_APP_ALERTERROR,event.fault.faultDetail + "\n" + event.fault.faultString);			
		}
		
		override public function listNotificationInterests():Array
		{
			return [
					AppNotification.NOTIFY_INIT_MAP,
					AppNotification.NOTIFY_TOOLBAR
				];
		}
		
		override public function handleNotification(notification:INotification):void
		{			
			switch(notification.getName())
			{				
				case AppNotification.NOTIFY_INIT_MAP:	
					//layerTile.addEventListener(LayerEvent.LOAD,notification.getBody() as Function);
					if(AppConfigVO.district == "闵行区")
					{
						layerImage.url = AppConfigVO.imageMapUrl;	
					}
					break;
				
				case AppNotification.NOTIFY_TOOLBAR:
					if(notification.getType() == MainTool.IMAGESHOW)
					{
						layerImage.visible = true;
					}
					else if(notification.getType() == MainTool.IMAGEHIDE)
					{
						layerImage.visible = false;
					}
					break;
			}
		}
	}
}