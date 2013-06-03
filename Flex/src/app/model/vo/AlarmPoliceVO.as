package app.model.vo
{
	import spark.formatters.DateTimeFormatter;

	[Bindable]
	public class AlarmPoliceVO
	{
		public static var TIP_DIS:Number = 200;
		
		public var id:String = "";
		public var alarmID:String = "";
		public var userID:String = "";
		public var type:String = "";
		public var time:Date;
		
		public var timeFormat:String;
		
		public var selected:Boolean = false;
		
		public function AlarmPoliceVO(source:Object)
		{
			if(source != null)
			{
				this.id = source.ID;
				this.alarmID = source.JQID;
				this.userID = source.JYID;
				this.type = source.pType;
				this.time = source.TypeDateTime;
				
				var dateF:DateTimeFormatter = new DateTimeFormatter;
				dateF.dateTimePattern = "HH:mm:ss";
				this.timeFormat = dateF.format(this.time);
			}
		}
						
		public var gps:GPSNewVO;
	}
}