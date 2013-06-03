package app.model.vo
{
	import spark.formatters.DateTimeFormatter;

	[Bindable]
	public class CallVO
	{
		public var isResponse:String = "";
		public var isConfirm:Number = 1;
		
		public var callDate:Date;
		public var callDateFormat:String = "";
		
		public var callName:String = "";
		
		public var memo:String = "";
		
		public var trueName:String = "";
		public var trueKind:String = "";
		public var truePosition:String = "";		
		
		public function CallVO(source:Object)
		{
			var dateF:DateTimeFormatter = new DateTimeFormatter;
			dateF.dateTimePattern = "yyyy-MM-dd HH:mm:ss";
			
			this.isResponse = source.IsResponse;
			this.isConfirm = source.ISCONFIRM;
			
			this.callDate = source.DMDate;						
			this.callDateFormat = dateF.format(this.callDate);
			
			this.callName = source.DMNAME;
				
			this.memo = source.MEMO;
			
			this.trueName = source.TRUENAME;
			this.trueKind = source.TRUERYBH;
			this.truePosition = source.TRUELOCATION;
		}
		
		/*private var _source:Object = null;
		
		public function get id():String{return _source.ID}
		
		public function get callDate():Date{return new Date(Date.parse(_source.DMDate));}
		public function get callDateFormat():String
		{
			var dateF:DateTimeFormatter = new DateTimeFormatter;
			dateF.dateTimePattern = "yyyy-MM-dd HH:mm:ss";
			return dateF.format(callDate);
		}
		
		public function get isResponse():Boolean{return (_source.IsResponse != undefined)?(_source.IsResponse == "是"):false;}
		public function set isResponse(b:Boolean):void{_source.IsResponse = b?"是":"否";}
		public function get isResponseFormat():String{return isResponse?"是":"否";}
		
		public function get responseDate():Date{return (_source.ResponseDate != undefined)?(new Date(Date.parse(_source.ResponseDate))):null;}
		public function get responseDateFormat():String
		{
			if(responseDate != null)
			{
				var dateF:DateTimeFormatter = new DateTimeFormatter;
				dateF.dateTimePattern = "yyyy-MM-dd HH:mm:ss";
				return dateF.format(responseDate);
			}
			else 
				return "";
		}
		
		public function get calledName():String{return (_source.BDMNAME != undefined)?_source.BDMNAME:"";}
		
		public function get calledDeptName():String{return (_source.BDMDepName != undefined)?_source.BDMDepName:"";}
		
		public function get calledPoliceNo():String{return (_source.BDMJYID != undefined)?_source.BDMJYID:"";}
		
		public function get calledDeptID():String{return (_source.BDMDEPID != undefined)?_source.BDMDEPID:"";}
		
		public function get callName():String{return (_source.DMNAME != undefined)?_source.DMNAME:"";}
		
		public function get callPoliceNo():String{return (_source.DMJYID != undefined)?_source.DMJYID:"";}
		
		public function get callDeptName():String{return (_source.DMDEPNAME != undefined)?_source.DMDEPNAME:"";}
		
		public function get memo():String{return (_source.MEMO != undefined)?_source.MEMO:"";}
		public function set memo(s:String):void{_source.MEMO = s;}
		
		public function get isConfirm():Boolean{return (_source.ISCONFIRM != undefined)?(_source.ISCONFIRM == "1"):false;}
		public function set isConfirm(b:Boolean):void{_source.ISCONFIRM = b?"1":"0";}*/
	}
}