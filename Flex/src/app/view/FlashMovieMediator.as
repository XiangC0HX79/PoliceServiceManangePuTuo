package app.view
{
	import app.AppNotification;
	
	import com.esri.ags.Graphic;
	
	import mx.effects.Sequence;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.effects.Fade;
	
	public class FlashMovieMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "FlashGraphicMediator";
				
		public function FlashMovieMediator()
		{
			super(NAME, new Sequence);
			
			var fade2:Fade = new Fade;
			fade2.alphaFrom = 1;
			fade2.alphaTo = 0;
			flashMovie.addChild(fade2);
			
			var fade1:Fade = new Fade;
			fade1.alphaFrom = 0;
			fade1.alphaTo = 1;
			flashMovie.addChild(fade1);
			
			flashMovie.duration = 500;
			flashMovie.repeatCount = 3;
		}
		
		private function get flashMovie():Sequence
		{
			return viewComponent as Sequence;
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_MAP_FLASH	
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{			
			switch(notification.getName())
			{
				case AppNotification.NOTIFY_MAP_FLASH:
					var arr:Array = notification.getBody() as Array;
					if(arr[0] is Array)
					{
						if(arr.length > 1)
						{
							flash(arr[0],arr[1]);
						}
						else
						{
							flash(arr[0]);
						}
					}
					else
					{
						flash(arr);
					}					
					break;
			}
		}
		
		private function flash(arr:Array,alpha:Number = 1):void
		{			
			if(flashMovie.isPlaying)
			{
				flashMovie.end();
			}
						
			var fade2:Fade = flashMovie.children[0];
			fade2.alphaFrom = alpha;
			
			var fade1:Fade = flashMovie.children[1];
			fade1.alphaTo = alpha;
			
			flashMovie.play(arr);
		}
	}
}