package app.view.components
{
	import flash.events.Event;
	
	import spark.components.CheckBox;
	
	[Event(name="CheckName",type ="flash.events.Event")]   
	
	[Event(name="CheckGps",type ="flash.events.Event")]   
	
	public class BaseSubPanelServicePoint extends BaseSubPanel
	{
		public static const CHECK_NAME:String = "CheckName";
		
		public static const CHECK_GPS:String = "CheckGps";
		
		[SkinPart(required = "true")]
		public var skinCheckName:CheckBox;
		
		[SkinPart(required = "true")]
		public var skinCheckGps:CheckBox;
		
		public function BaseSubPanelServicePoint()
		{
			super();
		}
		
		protected override function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if (instance == skinCheckName)
			{
				skinCheckName.addEventListener(Event.CHANGE , checkNameChangeHandle);
			}
			
			if (instance == skinCheckGps)
			{
				skinCheckGps.addEventListener(Event.CHANGE , checkGpsChangeHandle);
			}
		}
		
		private function checkNameChangeHandle(event:Event):void
		{
			dispatchEvent(new Event(CHECK_NAME));
		}
		
		private function checkGpsChangeHandle(event:Event):void
		{
			dispatchEvent(new Event(CHECK_GPS));
		}
	}
}