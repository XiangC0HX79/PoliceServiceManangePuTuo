package app.view
{
	import com.esri.ags.FeatureSet;
	import com.esri.ags.Graphic;
	import com.esri.ags.SpatialReference;
	import com.esri.ags.events.LayerEvent;
	import com.esri.ags.geometry.Geometry;
	import com.esri.ags.layers.ArcGISTiledMapServiceLayer;
	import com.esri.ags.layers.supportClasses.LayerDetails;
	import com.esri.ags.layers.supportClasses.LayerInfo;
	import com.esri.ags.tasks.FindTask;
	import com.esri.ags.tasks.QueryTask;
	import com.esri.ags.tasks.supportClasses.FindParameters;
	import com.esri.ags.tasks.supportClasses.Query;
	
	import flash.filters.ColorMatrixFilter;
	
	import mx.rpc.AsyncResponder;
	
	import app.AppNotification;
	import app.model.vo.AppConfigVO;
	import app.view.components.MainMenu;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class LayerTileMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "LayerTileMediator";
		
		private var queryTask:QueryTask;
		
		private var findTask:FindTask;
		
		private var init:Number = 0;
		
		public function LayerTileMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			layerTile.addEventListener(LayerEvent.LOAD_ERROR,onLayerLoadError);
			
			queryTask = new QueryTask;
			queryTask.useAMF = false;
			
			findTask = new FindTask;
			
		/*	var matrix:Array = new Array();
			matrix = matrix.concat([0.3,0.59,0.11,0,0]);
			matrix = matrix.concat([0.3,0.59,0.11,0,0]);
			matrix = matrix.concat([0.3,0.59,0.11,0,0]);
			matrix = matrix.concat([0,0,0,1,0]);
			
			var filter:ColorMatrixFilter = new ColorMatrixFilter(matrix);
			layerTile.filters = [filter];*/
		}
		
		private function get layerTile():ArcGISTiledMapServiceLayer
		{
			return viewComponent as ArcGISTiledMapServiceLayer;
		}
		
		private static var mapIndex:Number = 0;
						
		private function onLayerLoadError(event:LayerEvent):void
		{
			mapIndex++;
			
			if(mapIndex < AppConfigVO.mapServerArr.length)
			{
				AppConfigVO.mapServerUrl = AppConfigVO.mapServerArr[mapIndex];
				layerTile.url = AppConfigVO.tileMapUrl;	
			}
			else
			{
				sendNotification(AppNotification.NOTIFY_APP_ALERTERROR,event.fault.faultDetail + "\n" + event.fault.faultString);
			}
		}
		
		private function getLayerID(layerName:String):String
		{
			var layerID:String = "0";
			
			for each(var layerInfo:LayerInfo in layerTile.layerInfos)
			{
				if(layerInfo.name == layerName)
					layerID = layerInfo.id.toString();
			}
			
			return layerID;
		}
		
		public function getLayerUrl(layerName:String):String
		{			
			return layerTile.url + "/" + getLayerID(layerName);
		}
				
		override public function listNotificationInterests():Array
		{
			return [
					AppNotification.NOTIFY_INIT_MAP,
					AppNotification.NOTIFY_LAYERTILE_QUERY,
					AppNotification.NOTIFY_LAYERTILE_FIND
				];
		}
		
		override public function handleNotification(notification:INotification):void
		{			
			switch(notification.getName())
			{				
				case AppNotification.NOTIFY_INIT_MAP:	
					layerTile.addEventListener(LayerEvent.LOAD,notification.getBody() as Function);
					
					layerTile.url = AppConfigVO.tileMapUrl;	
					break;
				
				case AppNotification.NOTIFY_LAYERTILE_QUERY:	
					var arr:Array = notification.getBody() as Array;
					var layerName:String = arr[0];
					var where:String = arr[1];
					var outFields:Array = arr[2];
					var resultFunction:Function = arr[3];
					var returnGeometry:Boolean = (arr.length > 4)?arr[4]:true;
					var showLoading:Boolean = (arr.length > 5)?arr[5]:true;
					var geometry:Geometry = (arr.length > 6)?arr[6]:null;
					
					query(layerName,where,outFields,resultFunction,returnGeometry,showLoading,geometry);
					break;
				
				case AppNotification.NOTIFY_LAYERTILE_FIND:	
					arr = notification.getBody() as Array;
					var layers:Array = arr[0];
					var name:String = arr[1];
					resultFunction = arr[2];
					returnGeometry = (arr.length > 3)?arr[3]:true;
					showLoading = (arr.length > 4)?arr[4]:true;
					find(layers,name,resultFunction,returnGeometry,showLoading);
					break;
			}
		}
		
		private function query(layerName:String,where:String,outFields:Array,resultFunction:Function
							   ,returnGeometry:Boolean = true,showLoading:Boolean = true,geometry:Geometry = null):void
		{						
			var query:Query = new Query;
			query.outFields = outFields;
			if(where != "")
				query.where = where;
			else
				query.where = "1=1";
			query.returnGeometry = returnGeometry;	
			query.outSpatialReference = new SpatialReference(102100);
			
			if(geometry != null)
			{
				query.geometry = geometry;
			}
			
			queryTask.url = getLayerUrl(layerName);
			queryTask.execute(query,new AsyncResponder(queryResultHandle,onAsyncResponderFault));
			
			if(showLoading)
			{
				sendNotification(AppNotification.NOTIFY_APP_LOADINGSHOW,"正在查询地图数据，请等待系统响应...");
			}
			
			function queryResultHandle(featureSet:FeatureSet, token:Object = null):void
			{				
				if(showLoading)
				{
					sendNotification(AppNotification.NOTIFY_APP_LOADINGHIDE);
				}
				
				resultFunction(featureSet);
			}
			
			function onAsyncResponderFault(info:Object, token:Object = null):void
			{
				if(showLoading)
				{
					sendNotification(AppNotification.NOTIFY_APP_LOADINGHIDE);
				}
				
				sendNotification(AppNotification.NOTIFY_APP_ALERTERROR,info.toString());
			}
		}
		
		private function findByLayers(layerIDs:Array,name:String,resultFunction:Function):void
		{
			var find:FindParameters = new FindParameters;
			
			find.layerIds = layerIDs;
			
			find.outSpatialReference = new SpatialReference(102100);			
			find.returnGeometry = true;
			find.searchFields = ["名称"];
			find.searchText = name;			
			
			findTask.url = layerTile.url + "/find";
			findTask.execute(find,new AsyncResponder(queryResultHandle,onAsyncResponderFault));
			
			sendNotification(AppNotification.NOTIFY_APP_LOADINGSHOW,"正在查询地图数据，请等待系统响应...");
			
			function queryResultHandle(findResultArray:Array, token:Object = null):void
			{			
				sendNotification(AppNotification.NOTIFY_APP_LOADINGHIDE);
				
				resultFunction(findResultArray);
			}
			
			function onAsyncResponderFault(info:Object, token:Object = null):void
			{
				sendNotification(AppNotification.NOTIFY_APP_LOADINGHIDE);
				
				sendNotification(AppNotification.NOTIFY_APP_ALERTERROR,info.toString());
			}
		}
		
		private function find(layers:Array,name:String,resultFunction:Function,
							  returnGeometry:Boolean = true,showLoading:Boolean = true):void
		{						
			var layerIDs:Array = new Array;
			if(layers.length > 0)
			{
				for each(var layerName:String in layers)
				{
					layerIDs.push(getLayerID(layerName));
				}
				
				findByLayers(layerIDs,name,resultFunction);
			}
			/*else
			{
				layerTile.getAllDetails(new AsyncResponder(detailsResultHandle,onAsyncResponderFault)); 
				
				sendNotification(AppNotification.NOTIFY_APP_LOADINGSHOW,"正在查询地图数据，请等待系统响应...");
			}
			
			function detailsResultHandle(detailsResultArray:Array, token:Object = null):void
			{			
				sendNotification(AppNotification.NOTIFY_APP_LOADINGHIDE);
				
				findByLayers([],name,resultFunction);
			}
			
			function onAsyncResponderFault(info:Object, token:Object = null):void
			{
				sendNotification(AppNotification.NOTIFY_APP_LOADINGHIDE);
				
				sendNotification(AppNotification.NOTIFY_APP_ALERTERROR,info.toString());
			}*/
		}
	}
}