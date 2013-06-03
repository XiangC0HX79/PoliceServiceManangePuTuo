package app.model.vo
{
	[Bindable]
	public class MapCursor
	{
		[Embed(source="assets/image/map_zoomin.png")]
		private static const CLASS_ZOOMIN:Class;
		public static const ZOOMIN:MapCursor = new MapCursor(CLASS_ZOOMIN,-12,-12);
		
		[Embed(source="assets/image/map_zoomout.png")]
		private static const CLASS_ZOOMOUT:Class;
		public static const ZOOMOUT:MapCursor = new MapCursor(CLASS_ZOOMOUT,-12,-12);
		
		[Embed(source="assets/image/map_pan.png")]
		private static const CLASS_PAN:Class;
		public static const PAN:MapCursor = new MapCursor(CLASS_PAN,-12,-12);
		
		[Embed(source="assets/image/map_measurelength.png")]
		private static const CLASS_MEASURELENGTH:Class;
		public static const MEASURELENGTH:MapCursor = new MapCursor(CLASS_MEASURELENGTH,-8,-12);
		
		[Embed(source="assets/image/map_measurearea.png")]
		private static const CLASS_MEASUREAREA:Class;
		public static const MEASUREAREA:MapCursor = new MapCursor(CLASS_MEASUREAREA,-8,-12);
		
		[Embed(source="assets/image/b_cross.png")]
		private static const CLASS_DRAWPOINT:Class;
		public static const DRAWPOINT:MapCursor = new MapCursor(CLASS_DRAWPOINT,0,0);
		
		[Embed(source="assets/image/map_drawcircle.png")]
		private static const CLASS_DRAWCIRCLE:Class;
		public static const DRAWCIRCLE:MapCursor = new MapCursor(CLASS_DRAWCIRCLE,-9,-12);
		
		[Embed(source="assets/image/map_drawrect.png")]
		private static const CLASS_DRAWRECT:Class;
		public static const DRAWRECT:MapCursor = new MapCursor(CLASS_DRAWRECT,-9,-12);
		
		[Embed(source="assets/image/map_drawpoly.png")]
		private static const CLASS_DRAWPOLY:Class;
		public static const DRAWPOLY:MapCursor = new MapCursor(CLASS_DRAWPOLY,-9,-12);
		
		
		public var currentCursor:Class = null;
		public var xOffset:Number = 0;
		public var yOffset:Number = 0;
		
		public function MapCursor(currentCursor:Class,xOffset:Number = 0,yOffset:Number = 0)
		{
			this.currentCursor = currentCursor;			
			this.xOffset = xOffset;
			this.yOffset = yOffset;
		}
	}
}