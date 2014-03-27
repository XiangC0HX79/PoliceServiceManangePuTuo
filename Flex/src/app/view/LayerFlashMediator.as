package app.view
{
	import app.AppNotification;
	import app.model.dict.DicElePolice;
	import app.model.dict.DicLayer;
	
	import com.esri.ags.Graphic;
	import com.esri.ags.events.GraphicEvent;
	import com.esri.ags.events.ZoomEvent;
	import com.esri.ags.layers.GraphicsLayer;
	import com.esri.ags.layers.supportClasses.LOD;
	import com.esri.ags.symbols.CompositeSymbol;
	import com.esri.ags.symbols.PictureMarkerSymbol;
	import com.esri.ags.symbols.SimpleMarkerSymbol;
	import com.esri.ags.symbols.TextSymbol;
	
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	
	import mx.collections.ArrayCollection;
	import mx.effects.Fade;
	import mx.effects.Sequence;
	import mx.events.EffectEvent;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class LayerFlashMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "LayerFlashMediator";
		
		private var flashMovie:Sequence;
		
		public function LayerFlashMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
						
			flashMovie = new Sequence;
			
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
		
		private function get layerFlashMediator():GraphicsLayer
		{
			return viewComponent as GraphicsLayer;
		}
		
		override public function listNotificationInterests():Array
		{
			return [
				AppNotification.NOTIFY_LAYERFLASH_FLASH,
				AppNotification.NOTIFY_LAYERFLASH_FLASH_SOURCE
			];
		}
		
		override public function handleNotification(notification:INotification):void
		{			
			switch(notification.getName())
			{				
				case AppNotification.NOTIFY_LAYERFLASH_FLASH:
					flash(notification.getBody() as Array);
					break;
				
				case AppNotification.NOTIFY_LAYERFLASH_FLASH_SOURCE:
					flashSource(notification.getBody() as Array);
					break;
			}
		}
		
		private function flashSource(arr:Array,alpha:Number = 1):void
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
				
		private function flash(arr:Array,alpha:Number = 1):void
		{			
			if(flashMovie.isPlaying)
			{
				flashMovie.end();
			}
			
			for each(var graphic:Graphic in arr)
				layerFlashMediator.add(graphic);
			
			var fade2:Fade = flashMovie.children[0];
			fade2.alphaFrom = alpha;
			
			var fade1:Fade = flashMovie.children[1];
			fade1.alphaTo = alpha;
			
			flashMovie.addEventListener(EffectEvent.EFFECT_END,onEffectEnd);
			flashMovie.play(arr);
		}
		
		private function onEffectEnd(event:EffectEvent):void
		{			
			flashMovie.removeEventListener(EffectEvent.EFFECT_END,onEffectEnd);
			
			layerFlashMediator.clear();
		}
	}
}