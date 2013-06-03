package app.model.vo
{
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	import spark.formatters.DateTimeFormatter;

	[Bindable]
	public class TaskVO
	{
		//TASKID 任务序列号    
		public var taskID:String = "";
		
		//COMMCHANEL通讯频点(电台呼号)
		public var commChanel:String = "";
		
		//TASKNAME 任务名称
		public var taskName:String = "";
		
		//SCENECOMMAND 现场指挥点
		public var sceneCommand:String = "";
		
		//CONTACTWAY 联系方式
		public var contactWay:String = "";
				
		//COMMANDER 组织指挥
		public var commander:String = "";
		
		//STARTDATE 开始时间
		public var startDate:Date;		
		public var startDateString:String = "";
		
		public var listPolice:Array;
		
		public function TaskVO(source:Object)
		{
			this.taskID = source.TASKID;
			this.commChanel = source.COMMCHANEL;
			this.taskName = source.TASKNAME;
			this.sceneCommand = source.SCENECOMMAND;
			this.contactWay = source.CONTACTWAY;
			this.commander = source.COMMANDER;
			
			var dateF:DateTimeFormatter = new DateTimeFormatter;
			dateF.dateTimePattern = "yyyy-MM-dd HH:mm:ss";
			this.startDate = source.STARTDATE;
			this.startDateString = dateF.format(this.startDate);
			
			this.listPolice = new Array;
		}
		
		public function get dictPolice():Dictionary
		{
			var dict:Dictionary = new Dictionary;
			for each(var taskPolice:TaskPoliceVO in this.listPolice)
			{
				if(dict[taskPolice.deptName] == undefined)
				{
					dict[taskPolice.deptName] =  new ArrayCollection;					
				}
				
				var arr:ArrayCollection = dict[taskPolice.deptName] as ArrayCollection;
				arr.addItem(taskPolice);
			}
			
			return dict;
		}
	}
}