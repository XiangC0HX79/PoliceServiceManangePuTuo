package app.model.vo
{
	import com.esri.ags.SpatialReference;
	import com.esri.ags.geometry.MapPoint;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.core.BitmapAsset;
	
	import spark.formatters.DateTimeFormatter;
	
	import app.model.dict.DicDepartment;
	import app.model.dict.DicGPSImage;
	import app.model.dict.DicPatrolType;
	import app.model.dict.DicPatrolZone;
	import app.model.dict.DicPoliceType;
	import app.model.dict.DicServiceStatus;
	import app.model.dict.DicServiceType;
	
	[Bindable]
	public class GPSVO
	{
		public var gpsID:Number;
		public var gpsSimCard:String = "";
		public var type:String = "";
		public var gpsName:String = "";
		public var policeTypeID:String = "";
		public var departmentID:String = "";
		public var departmentNAME:String = "";
		public var policeNo:String = "";
		public var phone:String = "";
		
		public var hasGun:int = 0;
		
		public var gpsDate:Date;
		public var gpsDateFormat:String = "";
		
		public var mapPoint:MapPoint;
		
		public var inService:Boolean = true;		
		public var serviceTypeID:String = "";
		public var serviceStatusID:String = "";
		public var serviceStatusName:String = "";
		public var gpsStatus:String = "";
		
		public var patrolTypeID:String = "";
		public var patrolTypeName:String = "";
		public var patrolZoneName:String = "";
		
		/*public var policeType:DicPoliceType;
		public var serviceType:DicServiceType;
		public var serviceStatus:DicServiceStatus;
		public var department:DicDepartment;
		public var patrolType:DicPatrolType;
		public var patrolZone:DicPatrolZone;*/
		
		public function get patrolZone():DicPatrolZone
		{
			for each(var item:DicPatrolZone in DicPatrolZone.dict)
			{
				if((item.depid == this.departmentID)
					&& (item.label == this.patrolZoneName))
				{
					return item;
				}
			}
			
			return null;
		}
		
		public function get policeType():DicPoliceType
		{
			if(DicPoliceType.dict[policeTypeID] != undefined)
			{
				return DicPoliceType.dict[policeTypeID];
			}
			else if(DicPoliceType.BASEDMG.id == policeTypeID)
			{
				return DicPoliceType.BASEDMG;
			}
			else
			{
				return null;
			}
		}
		
		public function get serviceType():DicServiceType
		{
			if((this.inService) && (DicServiceType.dict[serviceTypeID] != undefined))
			{
				return DicServiceType.dict[serviceTypeID];
			}
			else
			{
				return DicServiceType.NOSERVICE;
			}
		}
		
		public function get serviceStatus():DicServiceStatus
		{
			if(DicServiceStatus.dict[serviceStatusID] == undefined)
			{
				return DicServiceStatus.idle;
			}
			else
			{
				return DicServiceStatus.dict[serviceStatusID];
			}
		}
		
		public function get department():DicDepartment
		{
			if(DicDepartment.dict[departmentID] != undefined)
			{
				return DicDepartment.dict[departmentID];
			}
			else
			{
				return null;
			}
		}
		
		public function get patrolType():DicPatrolType
		{
			return DicPatrolType.dict[patrolTypeID];
		}
		
		public var userId:String = "";
		public var radioNo:String = "";	
		public var callNo:String = "";
		public var policeKind:String = "";//警种
		
		public var policeSex:String = "";
		
		public var runName:String = "";
		public var runStartTime:Date;
		public var runEndTime:Date;
		public var runStartTimeFormat:String = "";
		public var runEndTimeFormat:String = "";
		
		//GPS图标
		protected var imageSource:Object;
		
		//GPS图标(Layer)
		public function get graphicSource():Bitmap{return new Bitmap(this.imageSource as BitmapData);}
		public function set graphicSource(value:Bitmap):void{}
				
		public var selected:Boolean = false;
		
		public var todayCalled:Boolean = false;
		
		protected function ConvertDate(o:Object):Date
		{			
			var date:Date;// = new Date(0);
			
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
		
		protected function GetImageSouce():Object
		{
			//var imageClass:Class = null;
			
			/*if(this.policeType == null)
			{
				return null;
			}
			//车辆
			else*/ 
			if(this.policeType == DicPoliceType.VEHICLE)
			{
				return DicGPSImage.getImageClass(DicPoliceType.VEHICLE.id,this.hasGun);		
				//BitmapAsset(new DicGPSImage.CAR).bitmapData;		
				//imageClass = DicGPSImage.CAR;
			}
			//交警
			else if(this.policeType == DicPoliceType.TRAFFIC)
			{				
				return DicGPSImage.getImageClass(DicPoliceType.TRAFFIC.id,this.hasGun);
			}
			//民警
			else
			{
				//人员 - 勤务
				if(this.inService)
				{
					//人员 - 勤务 - 勤务类型				
					var type:String = DicPoliceType.PEOPLE.id;	
					if(this.serviceType != null) 
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
					var status:String = (this.serviceStatus == null)?"0":this.serviceStatus.orderNum;	
					return DicGPSImage.getImageClass(type,this.hasGun,status);	
				}					
				//人员 - 非勤务
				else
				{
					return DicGPSImage.getImageClass(DicPoliceType.PEOPLE.id,this.hasGun);	
					//return BitmapAsset(new DicGPSImage.PEOPLE).bitmapData;	
					//return DicGPSImage.PEOPLE;					
					//imageClass = DicGPSImage.PEOPLE;
				}
			}
			
			return null;
		}
		
		public function GPSVO(source:Object)
		{
			if(source != null)
			{
				this.gpsID = (source.GPSID == undefined)?0:source.GPSID;
				this.gpsSimCard = (source.GPSSIMCARD == undefined)?"":source.GPSSIMCARD;
				this.type = (source.TYPE == undefined)?"":source.TYPE;
				this.gpsName = ((source.GPSNAME == undefined) || (String(source.GPSNAME).toUpperCase() == "UNKNOWN"))?"?":source.GPSNAME;
				this.policeTypeID = (source.GPSTYPE == undefined)?"":source.GPSTYPE;
				this.departmentID = (source.GPSDEPID == undefined)?"":source.GPSDEPID;
				
				if(this.department != null)
					this.departmentNAME = this.department.label;
				else
					this.departmentNAME = (source.GPSDEPNAME == undefined)?"":source.GPSDEPNAME;
				
				this.policeNo = (source.POLICENO == undefined)?"":source.POLICENO;
				this.phone = (source.PHONE == undefined)?"":source.PHONE;
				
				this.hasGun = (source.HASGUN == undefined)?0:source.HASGUN;
				
				this.gpsDate = ConvertDate(source.DATARECORDTIME);
				this.gpsDateFormat = ConvertDateFormat(this.gpsDate);
				
				var long:Number = Number(source.LONGITUDE);
				var lat:Number = Number(source.LATITUDE);
				this.mapPoint = new MapPoint(
					isNaN(long)?0:long,
					isNaN(lat)?0:lat,
					new SpatialReference(102100)
				);
				
				this.inService = (source.QWTYPE != undefined);
				this.serviceTypeID = (source.QWTYPE == undefined)?"":source.QWTYPE;
				this.serviceStatusID = (source.QWSTATUS == undefined)?"":source.QWSTATUS;
				this.serviceStatusName = (source.QWSTATUSNAME == undefined)?"":source.QWSTATUSNAME;
				this.gpsStatus = (source.GPSSTATUS == undefined)?"":source.GPSSTATUS;	
				this.patrolTypeID = (source.PATROLTYPE == undefined)?"":source.PATROLTYPE;
				if(DicPatrolType.dict[this.patrolTypeID] != undefined)
				{
					this.patrolTypeName = DicPatrolType.dict[this.patrolTypeID].label;
				}
				this.patrolZoneName = (source.ZONENM == undefined)?"":source.ZONENM;
							
				this.userId = (source.USERID == undefined)?"":source.USERID; 
				this.callNo = (source.CALLNO == undefined)?"":source.CALLNO;
				this.policeKind = (source.RYBH == undefined)?"":source.RYBH;
				//this.STID = (source.RADIONO == undefined)?"":source.RADIONO;
				
				this.radioNo = this.gpsSimCard;
				/*if(this.gpsName == "?")
				{
					this.radioNo = this.gpsSimCard;
				}
				else
				{
					this.radioNo = (source.RADIONO == undefined)?"":source.RADIONO;
				}*/
				
				this.policeSex = (source.SEX == undefined)?"":source.SEX;
				
				this.runName = (source.RUNNAME == undefined)?"":source.RUNNAME;
				this.runStartTime = ConvertDate(source.STARTTIME);
				this.runEndTime = ConvertDate(source.ENDTIME);
				this.runStartTimeFormat = ConvertDateFormat(this.runStartTime);
				this.runEndTimeFormat = ConvertDateFormat(this.runEndTime);
				
				this.imageSource = GetImageSouce();
			}
		}
		
		public function copy(source:GPSVO):void
		{
			this.gpsID = source.gpsID;
			this.gpsSimCard = source.gpsSimCard;
			this.gpsName = source.gpsName;
			this.policeTypeID = source.policeTypeID;
			this.departmentID = source.departmentID;
			this.departmentNAME = source.departmentNAME;
			this.policeNo = source.policeNo;
			this.phone = source.phone;
			
			this.gpsDate = source.gpsDate;
			this.gpsDateFormat = source.gpsDateFormat;
			
			this.mapPoint = source.mapPoint;
			
			this.inService = source.inService;
			this.serviceTypeID = source.serviceTypeID;
			this.serviceStatusID = source.serviceStatusID;
			this.serviceStatusName = source.serviceStatusName;
			this.patrolTypeID = source.patrolTypeID;
			this.patrolTypeName = source.patrolTypeName;
			this.patrolZoneName = source.patrolZoneName;
			
			/*this.policeType = source.policeType;
			this.serviceType = source.serviceType;
			this.serviceStatus = source.serviceStatus;
			this.department = source.department;
			this.patrolType = source.patrolType;*/
			
			this.userId = source.userId;
			this.callNo = source.callNo;
			this.radioNo = source.radioNo;
			this.runName = source.runName;
			this.runStartTime = source.runStartTime;
			this.runStartTimeFormat = source.runStartTimeFormat;
			this.runEndTime = source.runEndTime;
			this.runEndTimeFormat = source.runEndTimeFormat;
			
			this.imageSource = source.imageSource;
		}
	}
}