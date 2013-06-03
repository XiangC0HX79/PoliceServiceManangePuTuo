package app.controller
{
	import app.AppNotification;
	import app.model.AlarmInfoProxy;
	import app.model.vo.AppConfigVO;
	import app.model.GPSRealTimeInfoProxy;
	import app.model.TrackHistoryProxy;
	import app.model.TrackLinebackProxy;
	import app.model.TrackRealtimeProxy;
	
	import mx.messaging.AbstractConsumer;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	import spark.components.Application;
	
	public class ModelPreCommand extends SimpleCommand
	{
		override public function execute(note:INotification):void
		{
			facade.registerProxy(new AlarmInfoProxy);			
			facade.registerProxy(new GPSRealTimeInfoProxy);
			facade.registerProxy(new TrackRealtimeProxy);
			facade.registerProxy(new TrackHistoryProxy);
			facade.registerProxy(new TrackLinebackProxy);
			
			var application:Application = note.getBody() as Application;
			if(application.parameters.userid != "")
			{
				AppConfigVO.userid = application.parameters.userid;
			}
			
			if(application.parameters.Auth != "")
			{
				AppConfigVO.Auth = application.parameters.Auth;
			}
		}
	}
}