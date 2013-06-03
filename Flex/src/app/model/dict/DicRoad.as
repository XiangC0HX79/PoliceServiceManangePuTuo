package app.model.dict
{
	import com.esri.ags.Graphic;
	import com.esri.ags.geometry.Polyline;
	
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.utils.StringUtil;
	
	import spark.collections.Sort;

	[Bindable]
	public class DicRoad
	{
		private var _graphic:Graphic = null;
				
		public function get roadName():String{return _graphic.attributes["名称"];}
		
		public function get firstName():String{return _graphic.attributes["全名首拼"];}
				
		public function get locateName():String{return _graphic.attributes["拼音全称"];}
		
		public function get type():String{return _graphic.attributes["类别"];}
		
		public function set crossRoad(arr:ArrayCollection):void{}
		public function get crossRoad():ArrayCollection
		{
			var crossRoads:String = _graphic.attributes["交叉道路1"]
				+ _graphic.attributes["交叉道路2"]
				+ _graphic.attributes["交叉道路3"]
				+ _graphic.attributes["交叉道路4"]
				+ _graphic.attributes["交叉道路5"];
			
			var result:ArrayCollection = new ArrayCollection;
			for each(var crossRoadName:String in crossRoads.split(','))
			{
				if(crossRoadName != roadName)
					result.addItem(StringUtil.trim(crossRoadName));
			}
			
			return result;
		}
		
		public function get l_f_door():String{return _graphic.attributes["左起门牌"];}
		public function get l_t_door():String{return _graphic.attributes["左止门牌"];}
		public function get r_f_door():String{return _graphic.attributes["右起门牌"];}
		public function get r_t_door():String{return _graphic.attributes["右止门牌"];}
		
		public function get graphic():Graphic{return _graphic;}
		public function get polyline():Polyline{return _graphic.geometry as Polyline;}
		
		public function DicRoad(graphic:Graphic = null)
		{
			if(graphic != null)
				this._graphic = graphic
		}
				
		public static var dict:Dictionary = new Dictionary;
		public static function get list():ArrayCollection
		{
			var arr:Array = new Array;
			for each (var item:DicRoad in dict)
			{
				arr.push(item);
			}			
			
			//var sortRoad:Sort = new Sort;
			//sortRoad.compareFunction = compareFunction;
			arr.sort(compareFunction);
			//arr.refresh();				
			
			return new ArrayCollection(arr);
			
			function compareFunction(a:Object, b:Object, fields:Array = null):int
			{
				var roadA:DicRoad = a as DicRoad;
				var roadB:DicRoad = b as DicRoad;
				if((roadA == null) || (roadB == null))
				{				
					return 0;
				}
				
				for(var i:Number = 0; i<roadA.firstName.length;i++)
				{
					if(i > roadB.firstName.length)
						return 1;
					
					var firstNameA:String = roadA.firstName.charAt(i);
					var firstNameB:String = roadB.firstName.charAt(i);
					
					var roadNameA:String = roadA.roadName.charAt(i);
					var roadNameB:String = roadB.roadName.charAt(i);
					
					if(firstNameA > firstNameB)
					{
						return 1;
					}
					else if(firstNameA == firstNameB)
					{
						if(roadNameA > roadNameB)
							return 1;
						else if(roadNameA < roadNameB)
							return -1;
					}
					else
					{
						return -1;
					}
				}
				
				return 0;
			}
		}
	}
}