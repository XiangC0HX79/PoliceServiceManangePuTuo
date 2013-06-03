package app.model.dict
{
	import mx.collections.ArrayCollection;

	[Bindable]
	public class DicKind
	{	
		public static const ALL:DicKind = new DicKind("所有警种");
		
		public var sName:String = "";
		public var isMapShow:Boolean = true;
		public static var list:ArrayCollection = new ArrayCollection;
		
		public function DicKind(name_:String)
		{
			if(name_ == "")
				this.sName = "无警种";	
			else
				this.sName = name_;			
		}	
		
		public static function getKind(name_:String):DicKind
		{
			for each(var item:DicKind in DicKind.list)
			{
				if(
					(item.sName == name_)
					||
					(
						(name_ == "")
						&&
						(item.sName == "无警种")
					)
				   )
				{
					return item;
				}
			}
			
			return null;
		}
	}
}