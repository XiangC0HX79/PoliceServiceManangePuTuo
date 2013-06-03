package app.model.vo
{
	import com.esri.ags.geometry.MapPoint;
	
	import flash.utils.Dictionary;
	
	import mx.charts.chartClasses.DataDescription;
	import mx.collections.ArrayCollection;
	
	import spark.formatters.DateTimeFormatter;

	[Bindable]
	public class AlarmInfoVO
	{
		public static var lastUpdateTime:Date;
		
		public var id:String = "";
		public var type:String = "";
		public var typeColor:Number;
		public var newType:String = "";
		
		public var time:Date;
		public var datetimeFormat:String = "";
		public var timeFormat:String = "";
		
		public var name:String = "";
		public var address:String = "";
		public var title:String = "";
		public var phone:String = "";
		public var contactphone:String = "";
		public var deptName:String = "";
		public var info:String = "";
				
		public var isFocus:Boolean = false;
		
		public var mapPoint:MapPoint;
		public var srcPoint:MapPoint;
		
		public function AlarmInfoVO(source:Object)
		{
			var dateF:DateTimeFormatter = new DateTimeFormatter;
			
			this.id = source.id;
			this.type = source.type;
			this.typeColor = source.color;
			this.newType = source.newType;
			this.time = source.time;
			
			dateF.dateTimePattern = "yyyy-MM-dd HH:mm:ss";
			this.datetimeFormat = dateF.format(time);
			
			dateF.dateTimePattern = "HH:mm:ss";
			this.timeFormat = dateF.format(time);
			
			this.name = source.name;
			this.address = source.address;
			this.title = source.title;
			this.phone = source.phone;
			this.contactphone = source.contactphone;
			this.info = source.info;
			this.isFocus = (source.ISMUST == "1");
			this.deptName = source.dept;
			
			var long:Number = Number(source.x);
			long = isNaN(long)?0:long;
			var lat:Number = Number(source.y);
			lat = isNaN(lat)?0:lat;
			this.srcPoint = new MapPoint(long,lat);
			
			long = Number((source.NEWX == undefined)?source.x:source.NEWX);
			long = isNaN(long)?0:long;
			lat = Number((source.NEWY == undefined)?source.y:source.NEWY);
			lat = isNaN(lat)?0:lat;
			this.mapPoint = new MapPoint(long,lat);
		}
		
		public var listPolice:ArrayCollection = new ArrayCollection;
		
		/*public var dicPolice:Dictionary;
		public function get listPolice():ArrayCollection
		{			
			var arr:ArrayCollection = new ArrayCollection;
			
			for each(var item:AlarmPoliceVO in dicPolice)
			{
				if(item.gps != null)
				{
					arr.addItem(item);
				}
			}
			
			return arr;
		}*/
							
		//是否最新警情
		/*public function get isNew():Boolean
		{
			var timeDiff:Number = AlarmInfoVO.lastUpdateTime.time - time.time;
			return (timeDiff < 2*60*60*1000);
		}*/
		
		//是否显示警情
		public var isMapShow:Boolean = true;
		
		public var selected:Boolean = false;
	}
}