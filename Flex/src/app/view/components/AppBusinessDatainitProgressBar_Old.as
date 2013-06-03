package app.view.components
{
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	import mx.events.FlexEvent;
	
	import spark.components.Group;
	import spark.components.Label;
	import spark.core.SpriteVisualElement;
	
	public class AppBusinessDatainitProgressBar_Old extends Group
	{
		public var currentIndex:Number = 0;
		public const maxCount:Number = 10;
		
		//背景
		private var backgroudSprite:SpriteVisualElement;	
		// 进度条背景
		private var progressSprite:SpriteVisualElement;
		//进度条背景
		private var progressSprite2:SpriteVisualElement;	
		// 进度条
		private var progressBarSprite:SpriteVisualElement;
		// 进度文本
		private var progressText:Label;
		
		private const _width:Number = 300;
		private const _height:Number = 30;
		private const _padding:Number = 4;
		
		public function AppBusinessDatainitProgressBar_Old()
		{
			super();		
			
			//绘制背景
			backgroudSprite = new SpriteVisualElement();
			this.addElement(backgroudSprite);
						
			//绘制进度条背景
			progressSprite = new SpriteVisualElement();
			this.addElement(progressSprite);
			
			//绘制进度条背景
			progressSprite2 = new SpriteVisualElement();
			this.addElement(progressSprite2);
			
			//加载进度条Sprite
			progressBarSprite = new SpriteVisualElement();
			this.addElement(progressBarSprite);	
			
			//加载进度条文字
			progressText = new Label();
			this.addElement(progressText);
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
		}		
		
		private function creationCompleteHandler(event:FlexEvent):void
		{			          
			backgroudSprite.width = this.width;
			backgroudSprite.height = this.height;
			backgroudSprite.graphics.beginFill(0xFFFFFF,0.5);
			backgroudSprite.graphics.drawRect(0, 0, this.width, this.height);  
			backgroudSprite.graphics.endFill();
			
			progressSprite.graphics.lineStyle(1, 0x000000);
			progressSprite.graphics.beginFill(0xFFFFFF);
			progressSprite.graphics.drawRect(this.width/2 - _width / 2 - _padding
				, this.height/2 - _height / 2 - _padding
				, _width + 2*_padding
				, _height + 2*_padding);  
			progressSprite.graphics.endFill();
						
			progressSprite2.graphics.beginFill(0xCCCCCC);
			progressSprite2.graphics.drawRect(this.width/2 - _width / 2
				, this.height/2 - _height / 2
				, _width
				, _height);  
			progressSprite2.graphics.endFill();
			
			progressBarSprite.x = this.width/2 - _width / 2;
			progressBarSprite.y = this.height/2 - _height / 2;
				
			//progressText.con = 0x333333;
			progressText.text = "初始化程序数据：初始化本地配置...";
			progressText.width = _width;
			progressText.height = _height;
			progressText.setStyle("fontSize",12);
			progressText.setStyle("verticalAlign","middle");
			progressText.setStyle("paddingLeft",5);
			progressText.x = progressBarSprite.x;
			progressText.y = progressBarSprite.y;	
		}
		
		//刷新进度条
		public function drawText(text:String):void
		{  
			drawProgressBar(text,currentIndex,maxCount);
		}
		
		//刷新进度条
		public function drawProgressBar(text:String,bytesLoaded:Number, bytesTotal:Number):void
		{  
			progressText.text = text;
			
			var g:Graphics = progressBarSprite.graphics;
			g.clear();
			g.beginFill(0xBBBBBB);
			g.drawRect(0, 0, _width *(bytesLoaded/bytesTotal),_height);
			g.endFill();   
		}
	}
}