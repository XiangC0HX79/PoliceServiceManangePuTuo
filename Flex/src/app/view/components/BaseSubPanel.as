package app.view.components
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.managers.DragManager;
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.Image;
	import spark.components.Label;
	import spark.components.SkinnableContainer;
	
	[SkinState("min")]
	
	[Style(name="contentGap",type="int",inherit="no")]	
	[Style(name="contentPaddingTop",type="Number",inherit="no")]	
	[Style(name="contentPaddingBottom",type="Number",inherit="no")]	
	[Style(name="contentPaddingLeft",type="Number",inherit="no")]	
	[Style(name="contentPaddingRight",type="Number",inherit="no")]
	[Style(name="verticalScrollPolicy",type="String",inherit="no")]
	[Style(name="horizontalScrollPolicy",type="String",inherit="no")]
	
	public class BaseSubPanel extends SkinnableContainer
	{		
		[SkinPart(required = "true")]
		public var minButton:Image;
				
		[Bindable]
		public var panelTitle:String = "";
						
		[Bindable]
		public var minButtonShow:Boolean = true;
		
		private var _subpanelState:String = "";
		
		public static const SUBPANEL_OPEN:String = "open";
		
		public static const SUBPANEL_MIN:String = "min";
		
		public function BaseSubPanel()
		{
			super();
			
			//this.width = 300;
			//this.height = 300;
			
			
			this.setStyle("contentGap",2);
			this.setStyle("contentPaddingTop",0);
			this.setStyle("contentPaddingBottom",0);
			this.setStyle("contentPaddingLeft",0);
			this.setStyle("contentPaddingRight",0);
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
		}
		
		private function creationCompleteHandler(event:FlexEvent):void
		{
		}
				
		protected override function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			if (instance == minButton)
			{
				minButton.addEventListener(MouseEvent.CLICK , minButtonDownHandler);
			}
		}
		
		public function minButtonDownHandler(event:MouseEvent):void
		{
			_subpanelState = (_subpanelState == SUBPANEL_MIN)?"":SUBPANEL_MIN;
			
			invalidateSkinState();
		}
		
		override protected function getCurrentSkinState():String
		{
			return _subpanelState;
		}
	}
}