package app.controller
{
	import mx.messaging.AbstractConsumer;
	
	import spark.components.Application;
	
	import app.AppNotification;
	import app.model.AlarmInfoProxy;
	import app.model.GPSRealTimeInfoProxy;
	import app.model.QWPointProxy;
	import app.model.TrackHistoryProxy;
	import app.model.TrackLinebackProxy;
	import app.model.TrackRealtimeProxy;
	import app.model.vo.AppConfigVO;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	public class ModelPreCommand extends SimpleCommand
	{
		override public function execute(note:INotification):void
		{
			facade.registerProxy(new AlarmInfoProxy);			
			facade.registerProxy(new GPSRealTimeInfoProxy);
			facade.registerProxy(new TrackRealtimeProxy);
			facade.registerProxy(new TrackHistoryProxy);
			facade.registerProxy(new TrackLinebackProxy);
			facade.registerProxy(new QWPointProxy);
			
			var application:Application = note.getBody() as Application;
			if(application.parameters.userid != "")
			{
				AppConfigVO.userid = application.parameters.userid;
			}
			
			if(application.parameters.Auth != "")
			{
				AppConfigVO.Auth = application.parameters.Auth;
			}
			
			IFDEF::Debug{
				AppConfigVO.userid = "1462";
				AppConfigVO.Auth = "1";
			}
		}
	}
}