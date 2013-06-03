package app.model.vo
{
	import com.esri.ags.geometry.Extent;
	import com.esri.ags.geometry.Geometry;

	[Bindable]
	public final class AppConfigVO
	{
		public static var debug:Boolean = true;
		
		public static var district:String = "";
		
		public static var districtGeometry:Geometry = null;
		
		public static var webServiceUrl:String = "http://218.242.45.170/PTGAWebServcie/Service.asmx?wsdl";
		
		public static var mapServerArr:Array = new Array;
		public static var mapServerUrl:String = "http://218.242.45.170/ArcGIS/rest/services/";
		
		public static var moduleHideArr:Array = new Array;
		
		public static var mapName:String = "MHGAXM";
		
		public static var imageName:String = "MHGAYG";
		
		public static function get tileMapUrl():String
		{
			return mapServerUrl + mapName +"/MapServer";
		}
		
		public static function get imageMapUrl():String
		{
			return mapServerUrl + imageName +"/MapServer";
		}
		
		//public static var initialExtent:Extent = null;
		
		
		public static var userid:String = "";
		
		public static var user:GPSVO = null;
		
		public static var Auth:String = "1";
		
		public static var arrScale:Array = new Array;
		
		public static var scaleVisible:Number = 0;
	}
}