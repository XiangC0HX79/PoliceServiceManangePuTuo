package app.view.components.subComponents
{
	import mx.binding.utils.BindingUtils;
	import mx.controls.treeClasses.TreeItemRenderer;
	import mx.controls.treeClasses.TreeListData;
	import mx.events.FlexEvent;
	
	import spark.components.CheckBox;
	
	public class TreeItemRendererUnitSelect extends TreeItemRenderer
	{		
		protected var checkBox:CheckBox;
				
		public function TreeItemRendererUnitSelect()
		{
			super();
		}
		
		//----------------------------------
		//  labelField
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for labelField property.
		 */
		private var _selectedField:String = "selected";
		
		[Inspectable(category="Data", defaultValue="selected")]
		
		public function get selectedField():String
		{
			return _selectedField;
		}
		
		public function set selectedField(value:String):void
		{
			_selectedField = value;
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			if(!checkBox)
			{
				checkBox = new CheckBox;
				checkBox.mouseEnabled = false;
								
				addChild(checkBox);
			}
		}
		
		override public function set data(value:Object):void
		{
			super.data = value;
			
			mx.binding.utils.BindingUtils.bindProperty(checkBox,"selected",data,_selectedField);
		}
		
		override protected function measure():void
		{
			super.measure();
			measuredWidth += checkBox.getExplicitOrMeasuredWidth();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			
			var startx:Number = data?TreeListData(listData).indent:0;
			
			if(disclosureIcon)
			{
				disclosureIcon.x = startx;
				
				startx += disclosureIcon.width + 2;
				
				disclosureIcon.setActualSize(disclosureIcon.width,disclosureIcon.height);
				
				disclosureIcon.visible = data?TreeListData(listData).hasChildren:false;
			}
			
			if(icon)
			{
				icon.visible = false;
				/*icon.x = startx;
				
				startx += icon.measuredWidth;
				
				icon.setActualSize(icon.measuredWidth,icon.measuredHeight);*/
			}
			
			checkBox.move(startx,(this.unscaledHeight - checkBox.height) / 2);
			
			label.x = startx + checkBox.getExplicitOrMeasuredWidth();
		}
	}
}