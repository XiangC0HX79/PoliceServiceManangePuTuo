package app.model.vo
{
	import app.model.dict.DicExceptType;
	
	import spark.formatters.DateTimeFormatter;

	[Bindable]
	public class ServiceExceptVO
	{
		public static var CROSSING_DIFF:Number = 60;//异常报警越界时间判定长度（分钟）
		public static var STOPPING_DIFF:Number = 60;//异常报警车辆停止时间判定长度（分钟）
		public static var LONGTIME_DIFF:Number = 60;//异常报警处警警员处警时间过长判定长度（分钟）
		public static var NOPATROL_DIFF:Number = 60;//异常报警巡区无人巡逻时间判定长度（分钟）
		
		public var ExceptID:String = "";
		
		private var exceptTypeID:String = "";
		
		public function get ExceptType():DicExceptType
		{
			for each(var item:DicExceptType in DicExceptType.list)
			{
				if(item.exceptID == this.exceptTypeID)
					return item;
			}
			
			return DicExceptType.UNKNOWN;
		}
		
		public var GpsIDOrZoneID:String = "";
		public var GPSNameOrZoneName:String = "";
		public var DepID:String = "";
		public var DepName:String = "";
		public var UnNormalDesc:String = "";
		public var UnNormalDate:String = "";
		public var ReportDateTime:Date = null;
		public var ReportDateTimeFormat:String = "";
		public var object:* = null;
		
		public var gps:GPSNewVO = null;
		
		protected function ConvertDate(o:Object):Date
		{			
			var date:Date;
			
			if(o is Date)
			{
				date = o as Date;
			}
			else if(o is XMLList)
			{
				var dateString:String = o.toString();
				var pattern:RegExp = /\.(\d+)[-|+]/;
				var arr:Array = pattern.exec(dateString);
				dateString = dateString.substr(0,dateString.indexOf("."));						
				dateString = dateString.replace(/-/g,"/");						
				dateString = dateString.replace("T"," ");
				
				var ms:Number = (arr == null)?0:Number(arr[1]);
				
				date = new Date(Date.parse(dateString));
				date.setSeconds(date.seconds,ms);
			}
			
			return date;
		}
		
		protected function ConvertDateFormat(date:Date):String
		{						
			var dateF:DateTimeFormatter = new DateTimeFormatter;
			dateF.dateTimePattern = "yyyy-MM-dd HH:mm:ss";
			
			return dateF.format(date);
		}
				
		public function ServiceExceptVO(source:Object)
		{			
			this.ExceptID = source.ID;
			this.exceptTypeID = source.UnNormalType;
			this.UnNormalDate = source.UnNormalDesc;
			this.GpsIDOrZoneID = source.GpsIDOrZoneID;
			this.ReportDateTime = ConvertDate(source.ReportDateTime);
			this.ReportDateTimeFormat = ConvertDateFormat(this.ReportDateTime);	
		}
	}
}