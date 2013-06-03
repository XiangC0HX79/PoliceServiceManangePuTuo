package app.model.vo
{
	[Bindable]
	public class TaskPoliceVO
	{
		//TaskId 任务ID
		public var taskID:String = "";
		
		//TaskName 任务名
		
		//D.UerID AS UserID 警员ID
		public var userID:String = "";
		
		//D.PoliceName 警员名
		//E.STID   手台ID
		//E.HH 	呼号
		//E.XB   性别
		//JH 警号
		
		//B.PostName   岗位
		public var postName:String = "";
		
		//F.DWMC  单位
		public var deptName:String = "";
		public var deptID:String = "";
		
		//D.IsPlainclothes 是否便衣（0 否，1 是）
		public var isPlainclothes:Boolean = false;
				
		public var gps:GPSNewVO;
		
		public function TaskPoliceVO(source:Object)
		{
			this.taskID = source.TASKID;
			this.postName = source.POSTNAME;
			this.userID = source.USERID;
			this.deptName = source.DWMC;
			this.deptID = source.DEPID;
			this.isPlainclothes = ((source.ISPLAINCLOTHES == undefined) || (source.ISPLAINCLOTHES == "0"));
		}
	}
}