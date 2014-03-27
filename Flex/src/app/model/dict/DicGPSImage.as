package app.model.dict
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.globalization.NumberFormatter;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import mx.controls.Alert;
	import mx.core.BitmapAsset;
	
	import app.model.vo.AppConfigVO;
	
	public final class DicGPSImage
	{		
		public static const STATUS:String = "0";
		
		//public static const PEOPLE:String = "0";
		
		//public static const TRAFFIC:String = "98";
				
		private static var dict:Dictionary = new Dictionary;
		
		public static var VEHICLE_W:Number = 40;
		public static var VEHICLE_H:Number = 25;
		
		public static var PEOPLE_W:Number = 40;
		public static var PEOPLE_H:Number = 40;
		
		public static var STATUS_W:Number = 20;
		public static var STATUS_H:Number = 20;
		
		public static function getImageClass(type:String,hasGun:int = 0,status:String = "0"):Object
		{			
			var i:Number = Number(type);
			var j:Number = Number(status);
			var k:Number = hasGun;
			if(isNaN(i))i=2;
			if(isNaN(j))j=0;
			
			var t:String = (j < 10)?("0" + j.toString()):j.toString();
			
			var key:String = k.toString() + i.toString() + t;
			
			if(dict[key] == undefined)
			{				
				var trans:Boolean = (hasGun == 0);
				var backColor:uint = (hasGun == 0)?0x0:0xFF0000;
				
				if(type == DicPoliceType.VEHICLE.id)
				{
					dict[key] = new BitmapData(VEHICLE_W,VEHICLE_H,trans,backColor);
				}
				else if(type == STATUS)
				{
					dict[key] = new BitmapData(STATUS_W,STATUS_H,trans,backColor);
				}
				else
				{
					dict[key] = new BitmapData(PEOPLE_W,PEOPLE_H,trans,backColor);
				}
								
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				
				var si:String = i.toString();
				if(si.length == 1)
				{
					si = "0" + si;
				}
				
				var sj:String = j.toString();
				if(sj.length == 1)
				{
					sj = "0" + sj;
				}
				
				var url:String = "assets/image/service/s_"
					+ si + "-" + sj + ".png";
				
				var request:URLRequest = new URLRequest(url);
				
				loader.load(request);
			}
			
			return dict[key];
			
			function completeHandler(event:Event):void 
			{
				var loader:Loader = Loader(event.target.loader);				
				var source:BitmapData = Bitmap(loader.content).bitmapData;
				var bitmapData:BitmapData = dict[key] as BitmapData;
				///var sx:Number =  bitmapData.width/source.width;
				//var sy:Number = bitmapData.height/source.height;
				var scale:Number = Math.min(bitmapData.width/source.width,bitmapData.height/source.height);
				var tx:Number = (bitmapData.width - source.width*scale)/2;
				var ty:Number = (bitmapData.height - source.height*scale)/2;
				var matrix:Matrix = new Matrix(scale,0,0,scale,tx,ty);
				bitmapData.draw(source,matrix,null,null,null,true);
			}
			
			function ioErrorHandler(event:IOErrorEvent):void 
			{
				if(!AppConfigVO.debug)
				{
					var loader:Loader = new Loader();
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
					loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, lastIoErrorHandler);
					
					var request:URLRequest = new URLRequest("assets/image/service/s_02-00.png");	
					
					loader.load(request);
				}
				else
				{
					trace(event.text);
				}
			}
			
			function lastIoErrorHandler(event:IOErrorEvent):void 
			{
				trace(event.text);
			}
		}
	}
}