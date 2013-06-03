package app.event
{
	import flash.events.Event;
	
	public class AppEvent extends Event
	{
		public static const FLASHGPS:String 			= "flashgps";
		public static const LOCATEGPS:String 			= "locategps";
		
		public static const ITEMCHECK:String 			= "itemcheck";
		
		public static const GRIDHEADCHECK:String 		= "gridheadcheck";
		public static const GRIDITEMCHECK:String 		= "griditemcheck";
		
		public static const GRIDITEMCLICK:String 		= "griditemclick";
		public static const GRIDITEMDOUBLECLICK:String 	= "griditemdoubleclick";
		
		public static const POLICEARRIVECONFIRM:String 	= "policearriveconfirm";
		public static const POLICEARRIVECANCEL:String 	= "policearrivecancel";
		
		public static const ITEMCLICK:String 			= "appevent_itemclick";
		public static const ITEMDOUBLECLICK:String 		= "appevent_itemdoubleclick";
		
		public static const HEADCLICK:String 			= "appevent_headclick";
		
		public static const ERROR:String 				= "appevent_error";
		
		public function AppEvent(type:String, data:Object = null,bubbles:Boolean = false)
		{
			super(type,bubbles);
			_data = data;
		}
		
		private var _data:Object;
		
		public function get data():Object
		{
			return _data;
		}
		
		public function set data(value:Object):void
		{
			_data = value;
		}
	}
}