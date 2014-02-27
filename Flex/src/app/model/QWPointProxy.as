package app.model
{
	import mx.collections.ArrayCollection;
	
	import app.AppNotification;
	import app.model.vo.QwPointVO;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public class QWPointProxy extends Proxy implements IProxy
	{
		public static const NAME:String = "QWPointProxy";
		
		public function QWPointProxy()
		{
			super(NAME, new ArrayCollection);
		}
		
		public function get col():ArrayCollection
		{
			return data as ArrayCollection;
		}
		
		private function filterFunction(item:QwPointVO):Boolean
		{	
			return item.Level.isMapShow && item.Type.isMapShow;
		}
		
		public function load():void
		{			
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				[
					"GetQwPoint",onResult,[]
				]);
			
			function onResult(table:ArrayCollection):void
			{			
				col.source = [];
				
				for each(var item:Object in table)
				{
					col.addItem(new QwPointVO(item));
				}
								
				col.filterFunction = filterFunction;
				
				update();
			}
		}
		
		public function update():void
		{						
			col.refresh();			
			
			sendNotification(AppNotification.NOTIFY_LAYER_QWPOINT_REFRESH);
		}
	}
}