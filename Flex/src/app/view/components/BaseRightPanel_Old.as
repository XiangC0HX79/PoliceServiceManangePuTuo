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
	import spark.effects.Resize;
	
	[SkinState("open")]
	[SkinState("min")]
	[SkinState("close")]
	
	[Style(name="paddingTop",type="uint",inherit="no")]	
	[Style(name="paddingBottom",type="uint",inherit="no")]	
	[Style(name="paddingLeft",type="uint",inherit="no")]	
	[Style(name="paddingRight",type="uint",inherit="no")]
	
	public class BaseRightPanel_Old extends SkinnableContainer
	{		
		[SkinPart(required = "true")]
		public var closeButton:Image;
				
		[Bindable]
		public var panelTitle:String = "";
				
		private var _panelState:String = "";
		
		public static const PANEL_OPEN:String = "open";
		
		public static const PANEL_MIN:String = "min";
		
		public static const PANEL_CLOSE:String = "close";
		
		public function BaseRightPanel_Old()
		{
			super();
			
			this.width = 0;
			//this.height = 300;
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
		}
		
		private function creationCompleteHandler(event:FlexEvent):void
		{
		}
				
		protected override function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			if (instance == closeButton)
			{
				closeButton.addEventListener(MouseEvent.CLICK ,closeButtonDownHandler);
			}
		}
		
		private function closeButtonDownHandler(event:MouseEvent):void
		{
			close();
		}
		
		public function open():void
		{
			this.width = 320;
			//_panelState = PANEL_OPEN;
			
			//invalidateSkinState();
		}
		
		public function close():void
		{
			this.width = 0;
			//_panelState = PANEL_CLOSE;
			
			//invalidateSkinState();
		}
		
		override protected function getCurrentSkinState():String
		{
			return _panelState;
		}
	}
}