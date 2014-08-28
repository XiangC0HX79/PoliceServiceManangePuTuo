package app.model
{
	import mx.collections.ArrayCollection;
	import mx.collections.ISort;
	
	import spark.collections.Sort;
	
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
			return item.Type.isMapShow;
		}
		
		public function load():void
		{			
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				[
					"GetQwPoint",onResult,[]
				]);
		}
				
		private function onResult(table:ArrayCollection):void
		{			
			col.source = [];
			
			for each(var item:Object in table)
			{
				col.addItem(new QwPointVO(item));
			}
			
			var sort:ISort = new Sort();
			sort.compareFunction = sortPoint;
			col.sort = sort;
			
			col.filterFunction = filterFunction;
			
			update();
		}
		
		private function sortPoint(a:QwPointVO, b:QwPointVO, fields:Array = null):int
		{
			if(a.Type.pid != b.Type.pid)
			{
				return a.Type.pid < b.Type.pid?-1:1;
			}
			
			if(a.Dep != b.Dep)
			{
				return a.Dep < b.Dep?-1:1;
			}
			
			return 0;
		}

		public function update():void
		{						
			col.refresh();			
			
			sendNotification(AppNotification.NOTIFY_LAYER_QWPOINT_REFRESH);
		}
	}
}