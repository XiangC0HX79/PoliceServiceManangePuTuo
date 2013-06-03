package app.model.vo
{
	[Bindable]
	public class AlleyVO
	{
		public function AlleyVO(object:Object)
		{
			if(object != null)
			{
				this.roadName = object.道路名;
				
				if(object.弄号 == "")
					this.alleyName = " ";
				else
					this.alleyName = object.弄号;
				
				if(object.小区名 == "")
					this.quarterName = " ";
				else
					this.quarterName = object.小区名;
				
				this.doorplate = object.门牌号;
			}
		}
		
		public var roadName:String = "";
		public var quarterName:String = "";
		public var alleyName:String = "";
		public var doorplate:String = "";
	}
}