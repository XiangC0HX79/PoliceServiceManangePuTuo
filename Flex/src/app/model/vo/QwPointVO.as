package app.model.vo
{
	import com.esri.ags.geometry.MapPoint;
	
	import app.model.dict.DicPointLevel;
	import app.model.dict.DicPointType;

	[Bindable]
	public class QwPointVO
	{
		public static var SHOW_NAME:Boolean = false;
		
		public var Id:int;
		public var Name:String;
		//public var Level:DicPointLevel;
		public var Dep:String;
		public var Note:String;
		public var Leader:String;
		public var PoliceNum:String;
		public var Type:DicPointType;
		public var Address:String;
		public var Cross:String;
		public var Neighbour:String;
		public var ImgPath:String;
		
		public var pt:MapPoint;
		
		public function QwPointVO(item:Object)
		{
			this.Id = item.Id;
			this.Name = item.Name;
			//this.Level = DicPointLevel.dict[item.Level];
			this.Dep = item.Dep;
			this.Note = item.Note;
			this.Leader = item.Leader;
			this.PoliceNum = item.PoliceNum;
			this.Type = DicPointType.dict[item.Type];
			this.Address = item.Address;
			this.Cross = item.Cross;
			this.Neighbour = item.Neighbour;
			this.ImgPath = item.ImgPath;
			
			var x:Number = Number(item.Extent1);
			var y:Number = Number(item.Extent2);
			if(!isNaN(x) && !isNaN(y))
				this.pt = new MapPoint(x,y);
		}
	}
}