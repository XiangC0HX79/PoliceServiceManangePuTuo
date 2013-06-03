package app.model.dict
{
	import com.esri.ags.SpatialReference;
	import com.esri.ags.geometry.MapPoint;
	
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	public class DicElePolice
	{		
		public var id:String;
		
		public var depid:String;
		public function get department():DicDepartment
		{
			if(DicDepartment.dict[depid] != undefined)
			{
				return DicDepartment.dict[depid];
			}
			else
			{
				return null;
			}
		}
		
		public var code:String;
		public var name:String;
		
		public var type:String;
		public function get layer():DicLayer
		{			
			if(type == "1")
				return DicLayer.ELEPOLICE;
			else if(type == "2")
				return DicLayer.GATEWAY;
			else
				return DicLayer.VIDEO;
		}
				
		public var mapPoint:MapPoint;
		
		public function DicElePolice(source:Object)
		{
			this.id = source.ID;
			this.depid = source.DEPID;
			this.code = source.CODE;
			this.name = source.NAME;
			this.type = source.TYPE;
			
			var long:Number = Number(source.X);
			var lat:Number = Number(source.Y);
			this.mapPoint =  new MapPoint(
				isNaN(long)?0:long,
				isNaN(lat)?0:lat,
				new SpatialReference(102100)
			);
		}
				
		public static var dict:Dictionary = new Dictionary;
		public static function get list():ArrayCollection
		{
			var arr:Array = new Array;
			for each (var item:DicElePolice in dict)
			{
				arr.push(item);
			}			
			arr.sortOn("id",Array.NUMERIC);
			
			return new ArrayCollection(arr);
		}
	}
}