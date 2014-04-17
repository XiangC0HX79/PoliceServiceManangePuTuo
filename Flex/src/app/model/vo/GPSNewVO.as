package app.model.vo
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.core.BitmapAsset;
	
	import app.model.dict.DicDepartment;
	import app.model.dict.DicGPSImage;
	import app.model.dict.DicKind;
	import app.model.dict.DicPoliceType;
	import app.model.dict.DicServiceStatus;
	import app.model.dict.DicServiceType;

	[Bindable]
	public class GPSNewVO extends GPSVO
	{
		//服务器当前时间
		public static var CurrentTime:Date;
		
		//GPS最近更新时间
		//public static var LastUpdateTime:Date;
		
		//GPS设备失效时间间隔(单位：分钟)
		public static var ValidDiff:Number = 40;
		
		//GPS显示刷新间隔(单位：分钟)
		public static var RefreshDiff:Number = 1;
		
		//GPS初始化页数
		//public static var PageCount:Number = 100;
		
		public var carNo:String = "";
		
		public var stateChangeTime:Date;
		public var stateChangeTimeFormat:String = "";
		
		public var dutyNote:String = "";
				
		//GPS有效性
		public function get gpsValid():Boolean
		{
			IFDEF::Debug{
				return true;
			}
				
			if(this.gpsDate != null)
			{
				var diff:Number = (GPSNewVO.CurrentTime.time - this.gpsDate.time) / (1000*60);
				return (diff <= GPSNewVO.ValidDiff);
			}
			else
			{
				return false;
			}
		}
				
		public function GPSNewVO(source:Object)
		{
			if(source != null)
			{				
				super(source);
				
				this.carNo = (source.CARNO == undefined)?"":source.CARNO;
				this.dutyNote = (source.DUTYNOTE == undefined)?"":source.DUTYNOTE;
				
				this.stateChangeTime = ConvertDate(source.STATECHANGETIME);
				this.stateChangeTimeFormat = ConvertDateFormat(this.stateChangeTime);	
			}
		}
		
		//是否显示
		public function get isMapShow():Boolean
		{			
			//判断警力类型
			if(this.policeType == null)
				return true;
			
			if(!this.policeType.isMapShow)
				return false;		
			
			if(this.policeType.id != DicPoliceType.VEHICLE.id)
			{
				//武装巡逻
				if(this.hasGun && !DicServiceType.WEAPON.isMapShow)
					return false;
				
				//非勤务				
				if((!this.inService) && (!DicServiceType.NOSERVICE.isMapShow || !this.gpsValid))
					return false;
				
				if(inService)
				{
					//判断勤务类型
					var serviceType:DicServiceType = DicServiceType.dict[serviceTypeID] as DicServiceType;				
					if((serviceType != null) && (!serviceType.isMapShow))
						return false;	
					
					//判断勤务状态
					var serviceStatus:DicServiceStatus = DicServiceStatus.dict[serviceStatusID] as DicServiceStatus;				
					if((serviceStatus != null) && (!serviceStatus.isMapShow))
						return false;		
					
					//判断是否显示失效
					//if((!this.gpsValid) && (!DicServiceType.NOGPS.isMapShow))
					//	return false;
				}
			}
			else
			{
				if(!this.gpsValid)
					return false;
			}
			
			//判断单位
			var department:DicDepartment = DicDepartment.dict[departmentID] as DicDepartment;
			if((department != null) && (!department.isMapShow))
				return false;
			
			//判断警种-仅普陀
			var kind:DicKind = DicKind.dict[this.policeKind] as DicKind;
			if(((kind != null) && (!kind.isMapShow))
				|| ((kind == null) && (!DicKind.NONE.isMapShow)))
				return false;
			
			return true;
		}
			
		override protected function GetImageSouce():Object
		{
			//var type:String = "1";	
			var status:String = "0";
			
			//基地台
			if(this.policeTypeID == DicPoliceType.BASEDMG.id)
			{
				//type = DicPoliceType.BASEDMG.id;
			}
			//车辆\交警\特警
			else if((this.policeType == DicPoliceType.VEHICLE)
				|| (this.policeType == DicPoliceType.TRAFFIC)
				|| (this.policeType == DicPoliceType.SPECIAL))
			{	
				//type = this.policeType.id;	
				if(!this.gpsValid)
				{
					status = "99";
				}
				else if(this.gpsStatus == "0")
				{
					status = "98";
				}
			}
			//民警
			else
			{
				//人员 - 勤务 - 勤务类型		
				//type = DicPoliceType.PEOPLE.id;	
				if(this.serviceType != DicServiceType.NOSERVICE) 
				{
					var arr:Array = this.serviceType.imagelist.split(",");
					var index:Number = 0;
					if(this.patrolType != null) 
					{
						if(this.patrolType.label == "四轮机动车")
						{
							index = (arr.length > 2)?2:(arr.length - 1);
						}
						else if(this.patrolType.label == "二轮机动车")
						{
							index = (arr.length > 1)?1:(arr.length - 1);
						}		
					}	
					type = arr[index];
				}
				
				//人员 - 勤务 - 勤务状态
				if(!this.gpsValid)
				{
					status = "99";
				}
				else if(this.gpsStatus == "0")
				{
					status = "98";
				}
				else if(this.serviceStatus != null)
				{
					status = this.serviceStatus.orderNum;						
				}			
			}
						
			return DicGPSImage.getImageClass(this.policeType.id,this.hasGun,status);
		}
		
		public function refresh():void
		{
			this.imageSource = GetImageSouce();
		}
		
		override public function copy(source:GPSVO):void
		{			
			super.copy(source);
			
			this.carNo = (source as GPSNewVO).carNo;
			this.type = (source as GPSNewVO).type;
			this.gpsStatus = (source as GPSNewVO).gpsStatus;
			
			this.stateChangeTime = (source as GPSNewVO).stateChangeTime;
			this.stateChangeTimeFormat = (source as GPSNewVO).stateChangeTimeFormat;
			
			//this.gpsValid = (source as GPSNewVO).gpsValid;
		}
	}
}