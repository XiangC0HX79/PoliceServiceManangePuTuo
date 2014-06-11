package app.model.dict
{
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	public class DicPointType
	{				
		public static const ALL:DicPointType = new DicPointType({KEYID:'0',NAME:'所有',PX:'0',PID:'-1'});
		
		public var id:int;
		
		public var pid:int;
		
		public var orderNum:int;
		
		public var label:String = "";
		
		public var parent:DicPointType;
		
		public var children:Array;
		
		public var isMapShow:Boolean = true;
		
		public static var dict:Dictionary = new Dictionary;
		
		public function DicPointType(source:Object)
		{
			this.id = int(source.KEYID);
			this.pid = int(source.PID);
			this.orderNum = int(source.PX);
			this.label = source.NAME;
		}
		
		public static function get list():ArrayCollection
		{
			var r:ArrayCollection = new ArrayCollection;
			
			for each(var t:DicPointType in dict)
			{
				var parent:DicPointType = dict[t.pid] as DicPointType;
				if(parent != null)
				{
					if(parent.children == null)
					{
						parent.children = new Array;
					}
					
					parent.children.push(t);
					
					t.parent = parent;
				}
			}
			
			for each(t in dict)
			{
				if(!t.parent)
				{
					r.addItem(t);
				}
			}
			
			return r;
		}
	}
}