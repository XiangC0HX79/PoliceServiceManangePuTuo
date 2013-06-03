package app.view
{
	import app.AppNotification;
	import app.model.vo.AppConfigVO;
	
	import com.esri.ags.SpatialReference;
	import com.esri.ags.events.GeometryServiceEvent;
	import com.esri.ags.geometry.Polygon;
	import com.esri.ags.geometry.Polyline;
	import com.esri.ags.tasks.GeometryService;
	import com.esri.ags.tasks.supportClasses.AreasAndLengthsParameters;
	import com.esri.ags.tasks.supportClasses.AreasAndLengthsResult;
	import com.esri.ags.tasks.supportClasses.BufferParameters;
	import com.esri.ags.tasks.supportClasses.LengthsParameters;
	import com.esri.ags.tasks.supportClasses.RelationParameters;
	
	import mx.rpc.AsyncResponder;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class GeometryServiceMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "GeometryServiceMediator";
		
		private var showLoading:Boolean = true
			
		public function GeometryServiceMediator()
		{
			super(NAME,new GeometryService);
		}
		
		private function get geometryService():GeometryService
		{
			return viewComponent as GeometryService;
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_APP_INIT,
				AppNotification.NOTIFY_GEOMETRY_BUFF,
				AppNotification.NOTIFY_GEOMETRY_LEGHTN,
				AppNotification.NOTIFY_GEOMETRY_AREA,
				AppNotification.NOTIFY_GEOMETRY_RELATION
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{			
			switch(notification.getName())
			{
				case AppNotification.NOTIFY_APP_INIT:
					geometryService.url = AppConfigVO.mapServerArr[0] + "Geometry/GeometryServer";
					break;
				
				case AppNotification.NOTIFY_GEOMETRY_BUFF:
					buffer(notification.getBody()[0],notification.getBody()[1],notification.getBody()[2]);
					break;
				
				case AppNotification.NOTIFY_GEOMETRY_LEGHTN:
					length(notification.getBody()[0],notification.getBody()[1]);
					break;
				
				case AppNotification.NOTIFY_GEOMETRY_AREA:
					area(notification.getBody()[0],notification.getBody()[1]);
					break;
				
				case AppNotification.NOTIFY_GEOMETRY_RELATION:
					intersect(notification.getBody()[0],notification.getBody()[1],notification.getBody()[2]);
					break;
			}
		}
				
		private function onAsyncResponderFault(info:Object, token:Object = null):void
		{
			if(showLoading)
			{
				sendNotification(AppNotification.NOTIFY_APP_LOADINGHIDE);
			}
			
			sendNotification(AppNotification.NOTIFY_APP_ALERTERROR,info.toString());
		}
		
		private function area(geometries:Array,resultFunction:Function):void
		{
			var areaParameters:AreasAndLengthsParameters = new AreasAndLengthsParameters;
			areaParameters.polygons = geometries;
			
			geometryService.areasAndLengths(areaParameters,new AsyncResponder(areaResultHandle,onAsyncResponderFault));
			
			function areaResultHandle(areas:AreasAndLengthsResult,token:Object):void
			{
				//sendNotification(AppNotification.NOTIFY_APP_LOADINGHIDE);
				
				resultFunction(areas.areas);
			}
		}
		
		private function length(geometries:Array,resultFunction:Function):void
		{
			var lengthsParameters:LengthsParameters = new LengthsParameters();
			//lengthsParameters.geodesic = false;
			lengthsParameters.polylines = geometries;
			
			geometryService.lengths(lengthsParameters,new AsyncResponder(lengthResultHandle,onAsyncResponderFault));
			
			function lengthResultHandle(lengths:Array,token:Object):void
			{
				//sendNotification(AppNotification.NOTIFY_APP_LOADINGHIDE);
				
				resultFunction(lengths);
			}
		}
		
		private function buffer(geometries:Array,distances:Array,resultFunction:Function):void
		{
			var bufferParameters:BufferParameters = new BufferParameters;
			bufferParameters.bufferSpatialReference = new SpatialReference(102100);
			bufferParameters.outSpatialReference = new SpatialReference(102100);
			bufferParameters.unit = GeometryService.UNIT_METER;		
			bufferParameters.geometries = geometries;
			bufferParameters.distances = distances;	
			
			geometryService.buffer(bufferParameters,new AsyncResponder(buffResultHandle,onAsyncResponderFault));
			
			sendNotification(AppNotification.NOTIFY_APP_LOADINGSHOW,"正在查询地图数据，请等待系统响应...");
			
			function buffResultHandle(geometrys:Array,token:Object):void
			{
				sendNotification(AppNotification.NOTIFY_APP_LOADINGHIDE);
				
				resultFunction(geometrys);
			}
		}
				
		private function intersect(geometries1:Array,geometries2:Array,resultFunction:Function):void
		{
			var relationParameters:RelationParameters = new RelationParameters;
			relationParameters.geometries1 = geometries1;
			relationParameters.geometries2 = geometries2;
			relationParameters.spatialRelationship = RelationParameters.SPATIAL_REL_CROSS;
			
			geometryService.relation(relationParameters,new AsyncResponder(relationResultHandle,onAsyncResponderFault));
			
			sendNotification(AppNotification.NOTIFY_APP_LOADINGSHOW,"正在查询地图数据，请等待系统响应...");
				
			function relationResultHandle(geometrys:Array,token:Object):void
			{
				sendNotification(AppNotification.NOTIFY_APP_LOADINGHIDE);
				
				
			}
		}
	}
}