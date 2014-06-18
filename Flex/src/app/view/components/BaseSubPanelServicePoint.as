package app.view.components
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	
	import spark.components.CheckBox;
	import spark.components.Image;
	
	[Event(name="checkchange",type ="flash.events.Event")]   
	
	public class BaseSubPanelServicePoint extends BaseSubPanel
	{
		public static const CHECK_CHANGE:String = "checkchange";
		
		[SkinPart(required = "true")]
		public var skinCheckTitle:CheckBox;
		
		public function BaseSubPanelServicePoint()
		{
			super();
		}
		
		protected override function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			if (instance == skinCheckTitle)
			{
				skinCheckTitle.addEventListener(Event.CHANGE , checkTitleChangeHandle);
			}
		}
		
		private function checkTitleChangeHandle(event:Event):void
		{
			dispatchEvent(new Event(CHECK_CHANGE));
		}
	}
}