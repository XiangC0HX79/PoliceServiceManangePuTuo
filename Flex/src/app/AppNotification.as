package app
{
	import app.model.vo.GPSNewVO;

	public final class AppNotification
	{
		/**
		 *访问WebService
		 */		
		public static const NOTIFY_WEBSERVICE_SEND:String			= "WebServiceSend";
		
		public static const NOTIFY_APP_RESIZE:String				= "AppResize";
		
		/**
		 *弹出错误提示框 
		 */		
		public static const NOTIFY_APP_ALERTERROR:String			= "AppAlertError";
		
		/**
		 *弹出警告提示框 
		 */		
		public static const NOTIFY_APP_ALERTALARM:String			= "AppAlertAlarm";
		
		/**
		 *弹出信息提示框 
		 */		
		public static const NOTIFY_APP_ALERTINFO:String				= "AppAlertInfo";
				
		
		
		/**
		 *程序控制-显示Loading
		 */		
		public static const NOTIFY_APP_LOADINGSHOW:String			= "AppLoadingShow";
		
		/**
		 *程序控制-隐藏Loading
		 */		
		public static const NOTIFY_APP_LOADINGHIDE:String			= "AppLoadingHide";
		
		
		
		
		/**
		 *本地设置
		 */		
		//public static const NOTIFY_INIT_LOCALECONFIG:String			= "InitLocaleConfig";
				
		/**
		 *地图初始化完成
		 */		
		public static const NOTIFY_INIT_MAP:String					= "InitMap";
		
		/**
		 *权限验证成功
		 */		
		//public static const NOTIFY_INIT_AUTH:String					= "InitAuth";
		
		/**
		 *远程系统设置初始化
		 */		
		//public static const NOTIFY_INIT_REMOTECONFIG:String			= "InitRemoteConfig";
		
		/**
		 *系统字典表初始化
		 */		
		//public static const NOTIFY_INIT_SYSDIC:String				= "InitSysDic";
		
		/**
		 *勤务类型字典初始化
		 */		
		//public static const NOTIFY_INIT_SERVICE:String				= "InitService";
		
		/**
		 *单位信息初始化
		 */		
		//public static const NOTIFY_INIT_DEPARTMENT:String			= "InitDepartment";
				
		/**
		 *巡区信息初始化
		 */		
		//public static const NOTIFY_INIT_PATROLZONE:String			= "InitPatrolZone";
		
		/**
		 *必到点信息初始化
		 */		
		//public static const NOTIFY_INIT_PATROLPOINT:String			= "InitPatrolPoint";
		
		/**
		 *GPS信息初始化
		 */		
		//public static const NOTIFY_INIT_GPS:String					= "InitGPS";
		
		/**
		 *程序初始化完成
		 */		
		public static const NOTIFY_APP_INIT:String					= "APP_INIT";
			
		
		
		/**
		 *工具栏事件 
		 */			
		public static const NOTIFY_TOOLBAR:String					= "Toolbar";
		
		/**
		 *菜单 事件 
		 */			
		public static const NOTIFY_MENUBAR:String					= "Menubar";
		
		
		
		/**
		 * GeometryService-Buff
		 */		
		public static const NOTIFY_GEOMETRY_BUFF:String				= "GeometryBuff";
		
		/**
		 * GeometryService-Length
		 */		
		public static const NOTIFY_GEOMETRY_LEGHTN:String			= "GeometryLength";
		
		/**
		 * GeometryService-Area
		 */		
		public static const NOTIFY_GEOMETRY_AREA:String				= "GeometryArea";
		
		/**
		 * GeometryService-Relation
		 */		
		public static const NOTIFY_GEOMETRY_RELATION:String			= "GeometryRelation";
		
		/**
		 * AddressLocatorService
		 */		
		public static const NOTIFY_ADDRESSLOCATOR:String			= "AddressLocator";
				
		/**
		 * 图层-鼠标选中
		 */		
		public static const NOTIFY_LAYER_MOUSEOVER:String				= "LayerMouseOver";
		
		/**
		 * 图层-鼠标擦除
		 */		
		public static const NOTIFY_LAYER_MOUSEOUT:String				= "LayerMouseOut";
		
		/**
		 *地图-操作变更
		 */		
		public static const NOTIFY_MAP_OPREATOR:String				= "MapOperator";
		
		/**
		 *地图-闪烁
		 */		
		public static const NOTIFY_MAP_FLASH:String					= "MapFlash";
		
		/**
		 *地图-定位
		 */		
		public static const NOTIFY_MAP_LOCATE:String 				= "MapLocate";
		
		/**
		 *地图-鼠标事件
		 */		
		//public static const NOTIFY_MAP_STATICLAYEROVER:String		= "MapStaticLayerOver";
		
		/**
		 *地图-鼠标事件
		 */		
		//public static const NOTIFY_MAP_STATICLAYEROUT:String		= "MapStaticLayerOut";
		
		
		/**
		 *GPS信息刷新
		 */		
		public static const NOTIFY_GPS_RECEIVE:String				= "GPSReceive";
		
		/**
		 *GPS更新勤务状态
		 */		
		public static const NOTIFY_GPS_CHANGESTATE:String			= "GPSChangeState";
		
		
		/**
		 *弹出面板-历史轨迹
		 */		
		public static const NOTIFY_INFOWINDOW_TRACKHISTORY:String	= "InfoWindowTrackHistory";
				
		/**
		 *弹出面板-警员信息-点名
		 */		
		public static const NOTIFY_INFOPOLICE_CALL:String			= "InfoPoliceCall";
		
		
		/**
		 * 勤务概览-设置
		 */		
		public static const NOTIFY_OVERVIEW_SET:String				= "OverviewSet";
		
		/**
		 * 勤务搜索-定位道路
		 */		
		public static const NOTIFY_SEARCH_LOCATEROAD:String			= "SearchLocateRoad";
		
		/**
		 * 勤务搜索-搜索道路
		 */		
		public static const NOTIFY_SEARCH_SEARCHROAD:String			= "SearchSearchRoad";
		
		/**
		 * 勤务搜索-定位点
		 */		
		public static const NOTIFY_SEARCH_LOCATEPOINT:String 		= "SearchLocatePoint";
		
		/**
		 * 勤务搜索-搜索点
		 */		
		public static const NOTIFY_SEARCH_SEARCHPOINT:String 		= "SearchSearchPoint";
				
		/**
		 * 勤务搜索-图形搜索开始
		 */		
		public static const NOTIFY_SEARCH_GRAPHICSTART:String		= "SearchGraphicStart";
		
		/**
		 * 勤务搜索-图形搜索停止
		 */		
		public static const NOTIFY_SEARCH_GRAPHICSTOP:String		= "SearchGraphicStop";
		
		/**
		 * 勤务搜索-属性搜索
		 */		
		public static const NOTIFY_SEARCH_ATTRIBUTE:String			= "SearchAttribute";
		
		/**
		 * 执勤跟踪-刷新
		 */		
		public static const NOTIFY_TRACKREALTIME_REFRESH:String		= "TrackRealtimeRefresh";
		
		/**
		 * 历史轨迹-清空
		 */		
		public static const NOTIFY_TRACKHISTORY_CLEAR:String		= "TrackHistoryClear";
		
		/**
		 * 历史轨迹-查询人员列表
		 */		
		public static const NOTIFY_TRACKHISTORY_GETLIST:String		= "TrackHistoryGetList";
		
		/**
		 * 历史轨迹-查询人员列表（弹出窗口-历史轨迹）
		 */		
		//public static const NOTIFY_TRACKHISTORY_INFOWINDOWGETLIST:String		= "TrackHistoryInfoWindowGetList";
		
		/**
		 * 历史轨迹-查询结果（单条轨迹）
		 */		
		//public static const NOTIFY_TRACKHISTORY_GET:String			= "TrackHistoryGet";
				
		/**
		 * 历史轨迹-选择更新
		 */		
		public static const NOTIFY_TRACKHISTORY_CHANGE:String		= "TrackHistoryChange";
		
		/**
		 * 历史轨迹-地图闪烁轨迹
		 */		
		public static const NOTIFY_TRACKHISTORY_FLASH:String		= "TrackHistoryFlash";
		
		/**
		 * 历史轨迹-地图定位轨迹
		 */		
		public static const NOTIFY_TRACKHISTORY_LOCATE:String		= "TrackHistoryLocate";
		
		/**
		 * 历史轨迹-播放轨迹动画
		 */		
		public static const NOTIFY_TRACKHISTORY_PLAY:String			= "TrackHistoryPlay";
		
		/**
		 * 历史轨迹-暂停轨迹动画
		 */		
		public static const NOTIFY_TRACKHISTORY_PAUSE:String		= "TrackHistoryPause";
		
		/**
		 * 历史轨迹-拖动轨迹动画
		 */		
		public static const NOTIFY_TRACKHISTORY_SLIDE:String		= "TrackHistorySlide";
		
		/**
		 * 历史轨迹-停止轨迹动画
		 */		
		public static const NOTIFY_TRACKHISTORY_STOP:String			= "TrackHistoryStop";
		
		/**
		 * 历史轨迹-动画速度设置
		 */		
		public static const NOTIFY_TRACKHISTORY_SPEED:String		= "TrackHistorySpeed";
				
		/**
		 * 路线回溯-返回查询结果
		 */		
		public static const NOTIFY_TRACKLINEBACK_GET:String				= "TrackLinebackGet";
		
		/**
		 * 路线回溯-闪烁轨迹
		 */		
		public static const NOTIFY_TRACKLINEBACK_FLASH:String			= "TrackLinebackFlash";
		
		/**
		 * 路线回溯-闪烁Path
		 */		
		public static const NOTIFY_TRACKLINEBACK_FLASHPATH:String		= "TrackLinebackFlashPath";
				
		/**
		 * 警情信息-实时警情初始化
		 */		
		public static const NOTIFY_ALARM_INIT:String					= "AlarmInit";
		
		/**
		 * 警情信息-历史警情
		 */		
		public static const NOTIFY_ALARM_HISTORY:String					= "AlarmHistory";
		
		/**
		 * 警情信息-选择警情
		 */		
		public static const NOTIFY_ALARM_SELECT:String					= "AlarmSelect";
		
		/**
		 * 警情信息-实时警情
		 */		
		public static const NOTIFY_ALARM_REALTIME:String				= "AlarmRealtime";
		
		/**
		 * 警情信息-闪烁警情
		 */		
		public static const NOTIFY_ALARM_FLASH:String					= "AlarmFlash";
		
		/**
		 * 警情信息-获得警情处理警员信息
		 */		
		//public static const NOTIFY_ALARM_GETPOLICE:String				= "AlarmGetPolice";
		
		/**
		 * 警情信息-设置处理警员
		 */		
		public static const NOTIFY_ALARM_SETPOLICE:String				= "AlarmSetPolice";
		
		/**
		 * 警情信息-删除处理警员
		 */		
		public static const NOTIFY_ALARM_DELPOLICE:String				= "AlarmDeletePolice";
		
		/**
		 * 警情信息-变更警员处理警情状态
		 */		
		public static const NOTIFY_ALARM_SETPOLICETYPE:String			= "AlarmSetPoliceType";
		
		/**
		 * 警情信息-选择警情
		 */		
		public static const NOTIFY_ALARM_SELECTCHANGE:String			= "AlarmSelectChange";
		
		/**
		 * 警情信息-修正位置
		 */		
		public static const NOTIFY_ALARM_CORRECT:String					= "AlarmCorrect";
		
		/**
		 * 警情信息-关注警情
		 */		
		public static const NOTIFY_ALARM_FOCUS:String					= "AlarmFocus";
		
		/**
		 * 警情信息-隐藏警情
		 */		
		public static const NOTIFY_ALARM_HIDE:String					= "AlarmHide";
		
		/**
		 * 警情信息-警员到场
		 */		
		public static const NOTIFY_ALARM_POLICEARRIVE:String			= "AlarmPoliceArrive";
				
		/**
		 * 警情统计
		 */		
		public static const NOTIFY_ALARM_STATIS:String					= "AlarmStatis";
		
		/**
		 * 警情统计
		 */		
		public static const NOTIFY_ALARM_STATISCLICK:String				= "AlarmStatisClick";
		
		/**
		 * 警情统计
		 */		
		public static const NOTIFY_ALARM_STATISDIS:String				= "AlarmStatisDis";
		
		/**
		 * 异常勤务-闪烁
		 */		
		public static const NOTIFY_TRACKEXCEPT_FLASH:String				= "TrackExceptFlash";
		
		/**
		 * 异常勤务-定位
		 */		
		public static const NOTIFY_TRACKEXCEPT_LOCATE:String			= "TrackExceptLocate";
		
		/**
		 * 分色预警-闪烁
		 */		
		public static const NOTIFY_WARNINGAREA_FLASH:String				= "WarningAreaFlash";
		
		/**
		 * 卡点-闪烁
		 */		
		public static const NOTIFY_QWPOINT_FLASH:String					= "QwPointFlash";
		
		/**
		 * 分色预警-更新
		 */		
		public static const NOTIFY_WARNINGAREA_REFRESH:String			= "WarningAreaRefresh";
		
		/**
		 * 巡线-刷新
		 */		
		public static const NOTIFY_PATROL_LINE_UPDATE:String			= "PatrolLineUpdate";
		
		/**
		 * 巡线-闪烁
		 */		
		public static const NOTIFY_PATROL_LINE_FLASH:String			= "PatrolLineFlash";
				
		/**
		 * 图层-基础图层-QUERY
		 * layerName,where,outFields,resultFunction,returnGeometry,showLoading
		 */		
		public static const NOTIFY_LAYERTILE_QUERY:String			= "LayerTileQuery";
		
		/**
		 * 图层-基础图层-FIND
		 */		
		public static const NOTIFY_LAYERTILE_FIND:String			= "LayerTileFind";
		
		/**
		 * 图层-GPS-点击人员
		 */		
		public static const NOTIFY_LAYERGPS_POLICECLICK:String		= "LayerGPSPoliceClick";
		
		/**
		 * 图层-GPS-点击人员(非勤务)
		 */		
		//public static const NOTIFY_LAYERGPS_PEOPLECLICK:String		= "LayerGPSPeopleClick";
		
		/**
		 * 图层-GPS-点击车辆
		 */		
		public static const NOTIFY_LAYERGPS_VEHICLECLICK:String		= "LayerGPSVehicleClick";
		
		/**
		 * 图层-GPS-闪烁
		 */		
		public static const NOTIFY_LAYERGPS_FLASH:String				= "LayerGPSFlash";
		
		/**
		 *图层-GPS-定位
		 */		
		public static const NOTIFY_LAYERGPS_LOCATE:String				= "LayerGPSLocate";
		
		/**
		 *图层-GPS-刷新
		 */		
		public static const NOTIFY_LAYERGPS_REFRESH:String				= "LayerGPSRefresh";
		
		/**
		 * 图层-警情-点击警情
		 */		
		public static const NOTIFY_LAYERALARM_GRAPHICCLICK:String		= "LayerAlarmGraphicClick";
		
		/**
		 * 图层-警情-鼠标移入
		 */				
		//public static const NOTIFY_LAYERALARM_GRAPHICMOUSEOVER:String	= "LayerAlarmGraphicMouseOver";
		
		/**
		 * 图层-警情-鼠标移出
		 */		
		//public static const NOTIFY_LAYERALARM_GRAPHICMOUSEOUT:String	= "LayerAlarmGraphicMouseOut";
				
		/**
		 * 图层-历史轨迹-显示轨迹点提示
		 */		
		public static const NOTIFY_LAYERTRACK_POINTMOUSEOVER:String		= "LayerTrackPointMouseOver";
		
		/**
		 * 图层-历史轨迹-隐藏轨迹点提示
		 */		
		public static const NOTIFY_LAYERTRACK_POINTMOUSEOUT:String		= "LayerTrackPointMouseOut";
						
		/**
		 * 图层-历史轨迹-动画更新
		 */		
		public static const NOTIFY_LAYERTRACK_MOVEUPDATE:String			= "LayerTrackMoveUpdate";
						
		/**
		 * 图层-画图
		 */		
		public static const NOTIFY_DRAW_GEOMETRY:String					= "LayerDrawGeometry";
		
		/**
		 * 图层-画临时GPS
		 */		
		//public static const NOTIFY_DRAW_GPS:String						= "LayerDrawGPS";		
		
		/**
		 * 图层-异常-点击异常
		 */		
		public static const NOTIFY_LAYEREXCEPT_GRAPHICCLICK:String		= "LayerExceptGraphicClick";
		
		/**
		 * 图层-电子警察-点击
		 */		
		public static const NOTIFY_LAYERELEPOLICE_GRAPHICCLICK:String	= "LayerElePoliceGraphicClick";
		
		/**
		 * 图层-必到点-点击
		 */		
		public static const NOTIFY_LAYERPATROPOINT_GRAPHICCLICK:String	= "LayerPatrolPointGraphicClick";
		
		/**
		 * 图层-电子警察-闪烁
		 */		
		public static const NOTIFY_LAYERELEPOLICE_FLASH:String			= "LayerElePoliceFlash";
		
		/**
		 * 图层-电子警察-定位
		 */		
		//public static const NOTIFY_LAYERELEPOLICE_LOCATE:String			= "LayerElePoliceLocate";
		
		/**
		 * 图层-闪烁
		 */		
		public static const NOTIFY_LAYERFLASH_FLASH:String				= "LayerFlashFlash";
		
		/**
		 * 图层-闪烁2
		 */		
		public static const NOTIFY_LAYERFLASH_FLASH_SOURCE:String		= "LayerFlashFlashSource";
		
		/**
		 * 图层-卡点-刷新
		 */		
		public static const NOTIFY_LAYER_QWPOINT_REFRESH:String			= "LayerQwPointRefresh";
		
		/**
		 * 图层-卡点-点击
		 */		
		public static const NOTIFY_LAYER_QWPOINT_CLICK:String			= "LayerQwPointClick";
				
		/**
		 *地图操作-InfoPolice关闭
		 */		
		public static const NOTIFY_MAP_INFOPOLICEHIDE:String			= "MapInfoPoliceHide";
		
		/**
		 *地图操作-InfoAlarm关闭
		 */		
		public static const NOTIFY_MAP_INFOALARMHIDE:String				= "MapInfoAlarmHide";
		
		/**
		 *地图操作-警情闪烁
		 */		
		//public static const NOTIFY_MAP_ALARMFLASH:String		= "MapAlarmFlash";
		
		/**
		 *地图操作-警情定位
		 */		
		//public static const NOTIFY_MAP_ALARMLOCATE:String		= "MapAlarmLocate";
				
		/**
		 *数据-点名历史 
		 */		
		//public static const NOTIFY_CALL_HISTORY:String			= "CallHistory";								
	}
}