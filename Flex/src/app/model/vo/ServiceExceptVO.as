package app.model.vo
{
	import spark.formatters.DateTimeFormatter;

	[Bindable]
	public class ServiceExceptVO
	{
		public static var CROSSING_DIFF:Number = 60;//异常报警越界时间判定长度（分钟）
		public static var STOPPING_DIFF:Number = 60;//异常报警车辆停止时间判定长度（分钟）
		public static var LONGTIME_DIFF:Number = 60;//异常报警处警警员处警时间过长判定长度（分钟）
		public static var NOPATROL_DIFF:Number = 60;//异常报警巡区无人巡逻时间判定长度（分钟）
		
		public static const CROSSING:String ="1";//越界报警
		public static const STOPPING:String ="2";//车辆停止时间过长报警
		public static const LONGTIME:String ="3";//处警时间过长
		public static const NOPATROL:String ="4";//巡区长时间无人员及车辆巡逻报警
		public static const EMERGENCY:String ="5";//警员告警异常
		public static const MANUAL:String ="6";//手动修改警员状态为异常
				
		public var UnNormalType:String = "";
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
		
		public function get exceptLabel():String
		{
			if(this.UnNormalType == ServiceExceptVO.CROSSING)
				return "巡逻越界";
			else if(this.UnNormalType == ServiceExceptVO.LONGTIME)
				return "处警过长";
			else if(this.UnNormalType == ServiceExceptVO.NOPATROL)
				return "无人巡逻";
			else if(this.UnNormalType == ServiceExceptVO.STOPPING)
				return "人员车辆滞留";
			else if(this.UnNormalType == ServiceExceptVO.EMERGENCY)
				return "警员告警";
			else if(this.UnNormalType == ServiceExceptVO.MANUAL)
				return "手动修改";
			else
				return "未知异常";
		}
		
		public function ServiceExceptVO(source:Object)
		{			
			this.UnNormalType = source.UnNormalType;
			this.UnNormalDate = source.UnNormalDesc;
			this.GpsIDOrZoneID = source.GpsIDOrZoneID;
			this.ReportDateTime = ConvertDate(source.ReportDateTime);
			this.ReportDateTimeFormat = ConvertDateFormat(this.ReportDateTime);	
		}
	}
}