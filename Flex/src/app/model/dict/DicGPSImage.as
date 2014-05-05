package app.model.dict
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
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
				//var trans:Boolean = (hasGun == 0);
				//var backColor:uint = (hasGun == 0)?0x0:0xFF0000;
				var wOff:Number = hasGun?10:0;
				var hOff:Number = hasGun?10:0;
				
				if(type == DicPoliceType.VEHICLE.id)
				{
					dict[key] = new BitmapData(VEHICLE_W + wOff,VEHICLE_H + hOff,true,0x0);
				}
				else if(type == STATUS)
				{
					dict[key] = new BitmapData(STATUS_W + wOff,STATUS_H + hOff,true,0x0);
				}
				else
				{
					dict[key] = new BitmapData(PEOPLE_W + wOff,PEOPLE_H + hOff,true,0x0);
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
				
				if(hasGun)
				{					
					var scale:Number = Math.min(
						(bitmapData.width - 10)/source.width
						,(bitmapData.height - 10)/source.height
					);
					var tx:Number = (bitmapData.width - source.width*scale)/2;
					var ty:Number = (bitmapData.height - source.height*scale)/2;
					
					var matrix:Matrix = new Matrix(scale,0,0,scale,tx,ty);
					
					bitmapData.draw(source,matrix,null,null,null,true);
					
					miaobian(bitmapData,0x88FF0000);
					miaobian(bitmapData,0x88FF0000);
					miaobian(bitmapData,0x88FF0000);
					miaobian(bitmapData,0x44FF0000);
				}
				else
				{
					scale = Math.min(bitmapData.width/source.width,bitmapData.height/source.height);
					tx = (bitmapData.width - source.width*scale)/2;
					ty = (bitmapData.height - source.height*scale)/2;
					matrix = new Matrix(scale,0,0,scale,tx,ty);
					bitmapData.draw(source,matrix,null,null,null,true);					
				}
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
		
		private static function isTrans(c:uint):Boolean
		{			
			var a:uint = c >>> 24;
			var r:uint = (c & 0xFF0000) >>> 16;
			var g:uint = (c & 0xFF00) >>> 8;
			var b:uint = c & 0xFF;
			return (a == 0) || ((r > 250) && (g > 250) && (b > 250));
		}
		
		private static function miaobian(bitmapData:BitmapData,color:uint):void
		{
			var bound:Array = [];
			
			for(var j:int=0;j<bitmapData.height;j++)
			{
				for(var i:int=0;i<bitmapData.width;i++)
				{
					if(!isTrans(bitmapData.getPixel32(i,j)))
					{
						bound.push([i-1,j]);	
						bound.push([i,j-1]);
					}
										
					if(bound.length > 0)
						break;
				}
				
				if(bound.length > 0)
					break;
			}
			
			if(bound.length == 0)
				return;
			
			var ds:int = 1;			
			var de:int = 0;
			
			do
			{
				ds = de + 1;
				
				var ps:Array = bound[bound.length - 1];
				var pe:Array = [0,0];
				
				for(i=8;i>0;i--)
				{
					de = (ds + i) % 8;
					switch(de)
					{
						case 0:
							pe[0] = ps[0] + 1;
							pe[1] = ps[1] - 1;
							break;
						case 1:
							pe[0] = ps[0] + 1;
							pe[1] = ps[1];
							break;
						case 2:
							pe[0] = ps[0] + 1;
							pe[1] = ps[1] + 1;
							break;
						case 3:
							pe[0] = ps[0];
							pe[1] = ps[1] + 1;
							break;
						case 4:
							pe[0] = ps[0] - 1;
							pe[1] = ps[1] + 1;
							break;
						case 5:
							pe[0] = ps[0] - 1;
							pe[1] = ps[1];
							break;
						case 6:
							pe[0] = ps[0] - 1;
							pe[1] = ps[1] - 1;
							break;
						case 7:
							pe[0] = ps[0];
							pe[1] = ps[1] - 1;
							break;
					}
					
					if((pe[0] >= 0) && (pe[0] < bitmapData.width)
						&& (pe[1] >= 0) && (pe[1] < bitmapData.height))
					{
						if(isTrans(bitmapData.getPixel32(pe[0],pe[1])))
							break;
					}
					else
					{
						break;
					}
				}
				
				if((pe[0] == bound[0][0]) && (pe[1] == bound[0][1]))
					break;
				else
					bound.push(pe);
				
			}while(true);
						
			bitmapData.lock();
			for each(var p:Array in bound)
			{
				if((p[0] >= 0) && (p[0] < bitmapData.width)
					&& (p[1] >= 0) && (p[1] < bitmapData.height))
				{
					bitmapData.setPixel32(p[0],p[1],color);
				}
			}
			bitmapData.unlock();
		}
	}
}