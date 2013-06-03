package app.view
{
	import app.AppNotification;
	import app.event.AppEvent;
	import app.model.GPSRealTimeInfoProxy;
	import app.model.dict.DicDepartment;
	import app.model.dict.DicElePolice;
	import app.model.dict.DicLayer;
	import app.model.dict.DicPatrolZone;
	import app.model.dict.DicPoliceType;
	import app.model.dict.DicRoad;
	import app.model.vo.AlleyVO;
	import app.model.vo.AppConfigVO;
	import app.model.vo.GPSNewVO;
	import app.view.components.MainMenu;
	import app.view.components.MainTool;
	import app.view.components.RightPanelServiceSearchFX;
	
	import com.esri.ags.FeatureSet;
	import com.esri.ags.Graphic;
	import com.esri.ags.SpatialReference;
	import com.esri.ags.events.GeometryServiceEvent;
	import com.esri.ags.geometry.Extent;
	import com.esri.ags.geometry.Geometry;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.geometry.Polygon;
	import com.esri.ags.geometry.Polyline;
	import com.esri.ags.tasks.GeometryService;
	import com.esri.ags.tasks.QueryTask;
	import com.esri.ags.tasks.supportClasses.BufferParameters;
	import com.esri.ags.tasks.supportClasses.FindParameters;
	import com.esri.ags.tasks.supportClasses.FindResult;
	import com.esri.ags.tasks.supportClasses.Query;
	import com.esri.ags.tools.DrawTool;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.engine.SpaceJustifier;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.charts.renderers.CrossItemRenderer;
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.MenuBar;
	import mx.events.CollectionEvent;
	import mx.events.FlexEvent;
	import mx.events.IndexChangedEvent;
	import mx.rpc.AsyncResponder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.soap.WebService;
	import mx.utils.StringUtil;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.collections.Sort;
	import spark.components.ButtonBar;
	import spark.components.ComboBox;
	import spark.components.TextInput;
	import spark.components.ToggleButton;
	import spark.events.GridEvent;
	import spark.events.IndexChangeEvent;
	import spark.events.TextOperationEvent;
	import spark.skins.spark.ComboBoxSkin;
	
	public class RightPanelServiceSearchFXMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "RightPanelServiceSearchFXMediator";
				
		//private var listOriginRoad:ArrayCollection = null;
		
		public function RightPanelServiceSearchFXMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			
			rightPanelServiceSearch.addEventListener(RightPanelServiceSearchFX.COMBOTEXTCHANGE,onComboTextChange);
			
			//rightPanelServiceSearch.addEventListener(RightPanelServiceSearch.ROAD2TEXTCHANGE,onComboTextChange);			
			rightPanelServiceSearch.addEventListener(RightPanelServiceSearchFX.CROSSROADCHANGE,onCrossRoadChange);			
			//rightPanelServiceSearch.addEventListener(RightPanelServiceSearch.CROSSROADTEXTCHANGE,onComboTextChange);
			
			//rightPanelServiceSearch.addEventListener(RightPanelServiceSearch.ROAD3TEXTCHANGE,onComboTextChange);
			
			rightPanelServiceSearch.addEventListener(RightPanelServiceSearchFX.ADDRESSTEXTCHANGE,onAddressTextChange);
			rightPanelServiceSearch.addEventListener(RightPanelServiceSearchFX.RADIOCUSTOMCHANGE,onRadioCustomChange);
						
			rightPanelServiceSearch.addEventListener(RightPanelServiceSearchFX.MAPLOCATE,onMapOperator);
			rightPanelServiceSearch.addEventListener(RightPanelServiceSearchFX.MAPSEARCH,onMapOperator);
			
			rightPanelServiceSearch.addEventListener(RightPanelServiceSearchFX.GRAPHICCHANGE,onBarGraphicChange);
									
			rightPanelServiceSearch.addEventListener(RightPanelServiceSearchFX.SEARCH,onSearchPolice);
			rightPanelServiceSearch.addEventListener(RightPanelServiceSearchFX.SEARCHELE,onSearchElePolice);
			
			rightPanelServiceSearch.addEventListener(RightPanelServiceSearchFX.FLASHELE,onFlashEle);
			rightPanelServiceSearch.addEventListener(RightPanelServiceSearchFX.LOCATEELE,onLocateEle);			
		}
		
		protected function get rightPanelServiceSearch():RightPanelServiceSearchFX
		{
			return viewComponent as RightPanelServiceSearchFX;
		}
		
		/*private function compareFunction(a:Object, b:Object, fields:Array = null):int
		{
			var roadA:DicRoad = a as DicRoad;
			var roadB:DicRoad = b as DicRoad;
			if((roadA == null) || (roadB == null))
			{				
				return 0;
			}
			
			if(roadA.locateName < roadB.locateName)
			{
				return -1;
			}
			else if(roadA.locateName == roadB.locateName)
			{
				return 0;
			}
			else
			{
				return 1;
			}
		}*/
		
		private function patrolZoneFilterFunction(item:DicPatrolZone):Boolean
		{
			if(item == DicPatrolZone.ALL)
				return true;
			else 
				return (item.depid == rightPanelServiceSearch.listDeptItem.id);
		}
				
		private function searchByPolygon(polygon:Polygon):void
		{						
			rightPanelServiceSearch.listPolice.removeAll();
			
			var gpsRealTimeInfoProxy:GPSRealTimeInfoProxy = facade.retrieveProxy(GPSRealTimeInfoProxy.NAME) as GPSRealTimeInfoProxy;
			for each(var gps:GPSNewVO in gpsRealTimeInfoProxy.listGPS)
			{				
				if((gps.isMapShow) && (polygon != null) && (polygon.contains(gps.mapPoint)))
				{
					rightPanelServiceSearch.listPolice.addItem(gps);
				}
			}
			
			rightPanelServiceSearch.listElePolice.removeAll();
			
			for each(var elePolice:DicElePolice in DicElePolice.dict)
			{
				if(elePolice.layer.selected
					&& polygon.contains(elePolice.mapPoint))
					rightPanelServiceSearch.listElePolice.addItem(elePolice);
			}
		}
				
		private function onMapOperator(event:Event):void
		{
			switch(Number(rightPanelServiceSearch.viewLocator.selectedIndex))
			{
				case 0:
					locateRoad(event.type);
					break;
				case 1:
					locateCrossRoad(event.type);
					break;
				case 2:
					locateDoorPlate(event.type);
					break;
				case 3:
					locateAddress(event.type);
					break;
			}
		}
		
		private function onComboTextChange(event:AppEvent):void
		{					
			var combo:ComboBox = event.data as ComboBox;
			
			var arr:ArrayCollection = combo.dataProvider as ArrayCollection;
						
			combo.dataProvider = null;
			
			var roadName:String = combo.textInput.text;
			if(roadName != "")
			{
				arr.filterFunction = roadFilterFunction;
				//this.listOriginRoad.filterFunction = roadFilterFunction;
			}
			else
			{
				arr.filterFunction = null;
				//this.listOriginRoad.filterFunction = null;
			}
			arr.refresh();
			//this.listOriginRoad.refresh();
			
			//var arr:ArrayCollection = new ArrayCollection;			
			//arr.addAll(this.listOriginRoad);			
			combo.dataProvider = arr;
			
			function roadFilterFunction(item:Object):Boolean
			{
				return (item.roadName.toUpperCase().indexOf(roadName.toUpperCase()) == 0)
					|| (item.firstName.toUpperCase().indexOf(roadName.toUpperCase())==0)
					|| (item.locateName.toUpperCase().indexOf(roadName.toUpperCase())==0);
			}
		}
		
		private function onCrossRoadChange(event:Event):void
		{
			var road:DicRoad = rightPanelServiceSearch.comboRoad2.selectedItem as DicRoad;
			
			if(road != null)
			{
				sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
					["getCrossRoad",queryResultHandle,[road.roadName],true]);
				
				/*sendNotification(AppNotification.NOTIFY_LAYERTILE_QUERY,
					[
						"道路中心线",
						"交叉道路1 + 交叉道路2 LIKE '%" + road.roadName + "%'",
						['名称','全名首拼','拼音全称 ','类别']
						,queryResultHandle,true,true
					]);*/
			}
			else
			{
				rightPanelServiceSearch.comboCrossRoad.enabled = false;
				rightPanelServiceSearch.comboCrossRoad.selectedIndex = -1;
				//rightPanelServiceSearch.comboCrossRoad.dataProvider = null;
			}
			
			function queryResultHandle(result:ArrayCollection):void
			{
				var arr:Array = new Array;
				/*for each(var graphic:Graphic in featureSet.features)
				{
					var crossRoad:DicRoad = new DicRoad(graphic);
					if(crossRoad.roadName != road.roadName)
					{
						arr.push(crossRoad);
					}
				}*/
				for each(var row:Object in result)
				{
					arr.push({roadName:row.名称,firstName:row.全名首拼,locateName:row.拼音全称,type:row.类别});
				}
				
				arr.sort(compareFunction);
				
				//rightPanelServiceSearch.listCrossRoad = new ArrayCollection(arr);
				
				rightPanelServiceSearch.comboCrossRoad.dataProvider = new ArrayCollection(arr);
				rightPanelServiceSearch.comboCrossRoad.selectedIndex = 0;
				
				rightPanelServiceSearch.comboCrossRoad.enabled = true;
			}
			
			function compareFunction(roadA:Object, roadB:Object, fields:Array = null):int
			{
				//var roadA:DicRoad = a as DicRoad;
				//var roadB:DicRoad = b as DicRoad;
				if((roadA == null) || (roadB == null))
				{				
					return 0;
				}
				
				if(roadA.locateName < roadB.locateName)
				{
					return -1;
				}
				else if(roadA.locateName == roadB.locateName)
				{
					return 0;
				}
				else
				{
					return 1;
				}
			}
		}
				
		private function locateRoad(type:String):void
		{						
			if(rightPanelServiceSearch.comboRoad1.textInput.text != "")
			{
				var road:DicRoad = null;
				if(rightPanelServiceSearch.comboRoad1.selectedIndex >= 0)
				{
					road = rightPanelServiceSearch.comboRoad1.selectedItem as DicRoad;
				}
				else if((rightPanelServiceSearch.comboRoad1.dataProvider != null)
					&& (rightPanelServiceSearch.comboRoad1.dataProvider.length > 0))
				{
					road = rightPanelServiceSearch.comboRoad1.dataProvider[0];
				}
				
				if(road != null)
				{
					/*if(type == RightPanelServiceSearch.MAPLOCATE)
					{
						sendNotification(AppNotification.NOTIFY_SEARCH_LOCATEROAD,road);
					}
					else
					{
						sendNotification(AppNotification.NOTIFY_GEOMETRY_BUFF,
							[
								[road.polyline],
								[rightPanelServiceSearch.radius],
								buffResultHandle
							]);
					}*/
					sendNotification(AppNotification.NOTIFY_LAYERTILE_QUERY,
						[
							"道路中心线",
							"名称 = '" + road.roadName + "'",
							['名称','首拼','全名首拼','拼音全称 ','类别','左起门牌','左止门牌','右起门牌','右止门牌']
							,queryResultHandle,true,true,AppConfigVO.districtGeometry
						]);
				}
				else
				{
					sendNotification(AppNotification.NOTIFY_APP_ALERTERROR,"请选择道路。");	
				}
			}
			else
			{				
				sendNotification(AppNotification.NOTIFY_APP_ALERTERROR,"请输入道路名。");	
			}
			
			function queryResultHandle(featureSet:FeatureSet):void
			{
				if(featureSet.features.length == 0)
				{
					sendNotification(AppNotification.NOTIFY_APP_ALERTERROR,"请输入正确的道路名。");
				}
				else
				{			
					var road:DicRoad = new DicRoad(featureSet.features[0]);
					if(type == RightPanelServiceSearchFX.MAPLOCATE)
					{
						sendNotification(AppNotification.NOTIFY_SEARCH_LOCATEROAD,road);
					}
					else
					{
						sendNotification(AppNotification.NOTIFY_GEOMETRY_BUFF,
							[
								[road.polyline],
								[rightPanelServiceSearch.radius],
								buffResultHandle
							]);
					}
				}
				
				function buffResultHandle(geometrys:Array):void
				{
					var polygon:Polygon = geometrys[0] as Polygon;
					
					searchByPolygon(polygon);
					
					sendNotification(AppNotification.NOTIFY_SEARCH_SEARCHROAD,[road,polygon]);
				}
			}
		}
				
		private function locateCrossRoad(type:String):void
		{			
			var road:DicRoad = rightPanelServiceSearch.comboRoad2.selectedItem as DicRoad;
			var crossroad:Object = rightPanelServiceSearch.comboCrossRoad.selectedItem;
			
			
			if(road == null)
			{
				sendNotification(AppNotification.NOTIFY_APP_ALERTERROR,"请先选择道路。");	
			}
			else if(crossroad == null)
			{
				sendNotification(AppNotification.NOTIFY_APP_ALERTERROR,"请先选择交叉路。");	
			}
			else
			{
				sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
					["getCrossPoint",queryResultHandle,[road.roadName,crossroad.roadName],true]);
				
				/*var where:String = "名称 = '" + road.roadName 
					+ "' AND (交叉道路1 LIKE '%" + crossroad.roadName + "%'"
					+ " OR 交叉道路2 LIKE '%" + crossroad.roadName + "%'"
					+ " OR 交叉道路3 LIKE '%" + crossroad.roadName + "%'"
					+ " OR 交叉道路4 LIKE '%" + crossroad.roadName + "%'"
					+ " OR 交叉道路5 LIKE '%" + crossroad.roadName + "%')";
				
				sendNotification(AppNotification.NOTIFY_LAYERTILE_QUERY,
					[
						"交叉路口",
						where,
						[]
						,queryResultHandle
					]);*/
			}
			
			function queryResultHandle(result:ArrayCollection):void
			{
				if(result.length == 0)
				{
					sendNotification(AppNotification.NOTIFY_APP_ALERTERROR,"请输入正确的道路名。");
				}
				else
				{							
					var mapPoint:MapPoint = new MapPoint(Number(result[0].X),Number(result[0].Y),new SpatialReference(102100));
					var mapPointName:String = result[0].Label;
					if(type == RightPanelServiceSearchFX.MAPLOCATE)
					{
						sendNotification(AppNotification.NOTIFY_SEARCH_LOCATEPOINT, [mapPoint ,mapPointName]);						
					}
					else
					{						
						sendNotification(AppNotification.NOTIFY_GEOMETRY_BUFF, [[mapPoint],[rightPanelServiceSearch.radius],buffResultHandle]);
					}				
				}
				
				function buffResultHandle(geometrys:Array):void
				{
					var polygon:Polygon = geometrys[0] as Polygon;
					
					searchByPolygon(polygon);
					
					sendNotification(AppNotification.NOTIFY_SEARCH_SEARCHPOINT,[mapPoint,mapPointName,polygon]);
				}
			}	
		}
				
		private function locateDoorPlate(type:String):void
		{						
			var road:DicRoad = rightPanelServiceSearch.comboRoad3.selectedItem  as DicRoad;
						
			var doorplate:String = rightPanelServiceSearch.comboAlleyDoor.text;
			var address:String = "";
			
			var alleyName:String = rightPanelServiceSearch.comboAlley.text;
			if(alleyName == "")
			{
				if(road == null)
				{
					sendNotification(AppNotification.NOTIFY_APP_ALERTERROR,"请先选择道路。");
					return;
				}
				
				address = road.roadName + doorplate + "号";
			}
			else if(!isNaN(Number(alleyName)))
			{
				if(road == null)
				{
					sendNotification(AppNotification.NOTIFY_APP_ALERTERROR,"请先选择道路。");
					return;
				}
				
				address = road.roadName + alleyName + '弄' + doorplate + "号";
			}
			else
			{
				if(road == null)
				{
					address = alleyName + doorplate + "号";
				}
				else
				{
					address = road.roadName + alleyName + doorplate + "号";					
				}
			}
			
			var layerMediator:LayerTileMediator = facade.retrieveMediator(LayerTileMediator.NAME) as LayerTileMediator;
			
			sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
				["addressLocator",onAddressLocatorResult,[address],true]);
			
			function onAddressLocatorResult(result:ArrayCollection):void
			{
				if (result.length > 0)
				{
					var object:Object = result[0];
					var point:MapPoint = new MapPoint(
						object.X,
						object.Y,
						new SpatialReference(102100));
										
					if(type == RightPanelServiceSearchFX.MAPLOCATE)
					{
						sendNotification(AppNotification.NOTIFY_SEARCH_LOCATEPOINT, [point ,object.Label]);						
					}
					else
					{					
						sendNotification(AppNotification.NOTIFY_GEOMETRY_BUFF, [[point],[rightPanelServiceSearch.radius],buffResultHandle]);
					}			
				}						
				else
				{
					sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"未找到相应地址，请更改地址查询！");
				}
								
				function buffResultHandle(geometrys:Array):void
				{
					var polygon:Polygon = geometrys[0] as Polygon;
					
					searchByPolygon(polygon);
					
					sendNotification(AppNotification.NOTIFY_SEARCH_SEARCHPOINT,[point,object.Label,polygon]);
				}
			}		
		}
		
		private function locateAddress(type:String):void
		{					
			var addressName:String = StringUtil.trim(rightPanelServiceSearch.comboAddress.textInput.text);
			var address:Object = null;
			
			if(rightPanelServiceSearch.comboAddress.selectedIndex >= 0)
			{
				address = rightPanelServiceSearch.comboAddress.dataProvider[rightPanelServiceSearch.comboAddress.selectedIndex];
			}
			
			if((address != null) && (address.name == addressName))
			{
				if(type == RightPanelServiceSearchFX.MAPLOCATE)
				{
					sendNotification(AppNotification.NOTIFY_SEARCH_LOCATEPOINT, [address.mapPoint ,address.name]);						
				}
				else
				{					
					sendNotification(AppNotification.NOTIFY_GEOMETRY_BUFF, [[address.mapPoint],[rightPanelServiceSearch.radius],buffResultHandle]);
				}		
				
				function buffResultHandle(geometrys:Array):void
				{
					var polygon:Polygon = geometrys[0] as Polygon;
					
					searchByPolygon(polygon);
					
					sendNotification(AppNotification.NOTIFY_SEARCH_SEARCHPOINT,[address.mapPoint,address.name,polygon]);
				}
			}
			else
			{
				onAddressTextChange(null);
			}
		}
					
		private function onRadioCustomChange(event:Event):void
		{
			
		}
		
		private function onAddressTextChange(event:Event):void
		{
			//rightPanelServiceSearch.comboAddress.dataProvider = new ArrayCollection;
			
			var addressName:String = StringUtil.trim(rightPanelServiceSearch.comboAddress.textInput.text);
			
			if(addressName != "")
			{
				var layerNames:Array = new Array;
				switch(rightPanelServiceSearch.radioGroupCustom.selectedValue)
				{
					//case "小区":
					case "学校":
					case "医院":
					case "政府机关":
						layerNames.push(rightPanelServiceSearch.radioGroupCustom.selectedValue);
						
						sendNotification(AppNotification.NOTIFY_LAYERTILE_FIND,[layerNames,addressName,queryResultHandle]);
						break;
					default:
						/*layerNames.push("主要大厦");
						layerNames.push("火车站");
						layerNames.push("金融单位");
						layerNames.push("娱乐场所");
						layerNames.push("学校");
						layerNames.push("小区");
						layerNames.push("政府机关");
						layerNames.push("派出所");
						layerNames.push("消防中队");
						layerNames.push("公交站点");
						layerNames.push("加油站");
						layerNames.push("医院");
						layerNames.push("区公安局");
						layerNames.push("地铁车站");*/
						
						sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
							["addressLocator",onAddressLocatorResult,[addressName],true]);
						break;
				}
			}
			
			function queryResultHandle(findResultArray:Array):void
			{
				/*if(addressName != StringUtil.trim(rightPanelServiceSearch.comboAddress.textInput.text))
				{
					return;
				}*/
			
				var newArr:ArrayCollection = new ArrayCollection;	
				
				for each(var findResult:FindResult in findResultArray)
				{					
					var graphic:Graphic = findResult.feature;
					var point:MapPoint = graphic.geometry as MapPoint;
					var name:String = graphic.attributes["名称"];
					
					var polygon:Polygon = AppConfigVO.districtGeometry as Polygon;
					if(polygon.contains(point))
					{
						newArr.addItem({mapPoint:point,name:name});
					}
				}
				
				if(newArr.length > 0)
				{
					rightPanelServiceSearch.comboAddress.dataProvider = newArr;
					
					rightPanelServiceSearch.comboAddress.openDropDown();	
					
					rightPanelServiceSearch.comboAddress.selectedItem = addressName;
					
					sendNotification(AppNotification.NOTIFY_SEARCH_LOCATEPOINT, [newArr[0].mapPoint ,newArr[0].name]);						
				}
				/*else if(rightPanelServiceSearch.radioGroupCustom.selectedValue == "所有")
				{
					var layerMediator:LayerTileMediator = facade.retrieveMediator(LayerTileMediator.NAME) as LayerTileMediator;
					
					sendNotification(AppNotification.NOTIFY_WEBSERVICE_SEND,
						["addressLocator",onAddressLocatorResult,[addressName],true]);
				}*/
				else
				{
					sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"未找到相应地址，请更改地址查询！");
				}
			}
						
			function onAddressLocatorResult(result:ArrayCollection):void
			{
				var newArr:ArrayCollection = new ArrayCollection;
				
				for each(var item:Object in result)
				{
					var point:MapPoint = new MapPoint(
						item.X,
						item.Y,
						new SpatialReference(102100));
					var name:String = item.Label;
					
					var polygon:Polygon = AppConfigVO.districtGeometry as Polygon;
					if(polygon.contains(point))
					{
						newArr.addItem({mapPoint:point,name:name});
					}
				}
							
				if(newArr.length > 0)
				{
					rightPanelServiceSearch.comboAddress.dataProvider = newArr;	
					
					rightPanelServiceSearch.comboAddress.openDropDown();	
										
					rightPanelServiceSearch.comboAddress.selectedItem = addressName;
					
					sendNotification(AppNotification.NOTIFY_SEARCH_LOCATEPOINT, [newArr[0].mapPoint ,newArr[0].name]);
				}
				else
				{
					var pattern:RegExp = /(\W+?[路道街])/;
					var value:* = pattern.exec(addressName);
					var locator:Boolean = false;
					
					if(value != null)
					{
						for each(var road:DicRoad in DicRoad.dict)
						{
							if(value[1] == road.roadName)
							{
								sendNotification(AppNotification.NOTIFY_LAYERTILE_QUERY,
									[
										"道路中心线",
										"名称 = '" + road.roadName + "'",
										['名称','首拼','全名首拼','拼音全称 ','类别','左起门牌','左止门牌','右起门牌','右止门牌']
										,queryRoadResultHandle,true,true
									]);
								
								locator = true;
								break;
							}
						}
					}
					
					if(!locator)
						sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"未找到相应地址，请更改地址查询！");
				}
			}
			
			function queryRoadResultHandle(featureSet:FeatureSet):void
			{
				if(featureSet.features.length == 0)
				{
					sendNotification(AppNotification.NOTIFY_APP_ALERTALARM,"未找到相应地址，请更改地址查询！");
				}
				else
				{			
					var road:DicRoad = new DicRoad(featureSet.features[0]);
					sendNotification(AppNotification.NOTIFY_SEARCH_LOCATEROAD,road);
				}
			}
		}
		
		private function onBarGraphicChange(event:Event):void
		{
			if(rightPanelServiceSearch.graphicIndex == 0)
			{
				sendNotification(AppNotification.NOTIFY_SEARCH_GRAPHICSTART,[rightPanelServiceSearch.radius,DrawTool.CIRCLE,drawResultHandle]);
			}
			else if(rightPanelServiceSearch.graphicIndex == 1)
			{
				sendNotification(AppNotification.NOTIFY_SEARCH_GRAPHICSTART,[rightPanelServiceSearch.radius,DrawTool.EXTENT,drawResultHandle]);
			}
			else if(rightPanelServiceSearch.graphicIndex == 2)
			{
				sendNotification(AppNotification.NOTIFY_SEARCH_GRAPHICSTART,[rightPanelServiceSearch.radius,DrawTool.POLYGON,drawResultHandle]);
			}
			else
			{
				sendNotification(AppNotification.NOTIFY_SEARCH_GRAPHICSTOP);
			}
			
			function drawResultHandle(geometry:Geometry):void
			{
				if(geometry is Extent)
				{
					searchByPolygon((geometry as Extent).toPolygon());
				}
				else if(geometry is Polygon)
				{
					searchByPolygon((geometry as Polygon));	
				}	
			}
		}
								
		private function onSearchPolice(event:Event = null):void
		{			
			rightPanelServiceSearch.listPolice.removeAll();
			
			var gpsRealTimeInfoProxy:GPSRealTimeInfoProxy = facade.retrieveProxy(GPSRealTimeInfoProxy.NAME) as GPSRealTimeInfoProxy;
						
			for each(var gps:GPSNewVO in gpsRealTimeInfoProxy.listGPS)
			{
				if(
					(
						(gps.policeNo.indexOf(rightPanelServiceSearch.textPoliceNo) != -1) 
						|| (gps.gpsName.indexOf(rightPanelServiceSearch.textPoliceNo) != -1)
						|| (gps.radioNo.indexOf(rightPanelServiceSearch.textPoliceNo) != -1)
						|| (gps.callNo.indexOf(rightPanelServiceSearch.textPoliceNo) != -1)
					)
					&& 
					(
						(rightPanelServiceSearch.listDeptItem == DicDepartment.ALL) 
						|| ((rightPanelServiceSearch.listDeptItem == DicDepartment.TRAFFIC) && (gps.department != null) && (gps.department.ZB == 125))
						|| (gps.department == rightPanelServiceSearch.listDeptItem)
					)
					&& 
					(gps.patrolZoneName.indexOf(rightPanelServiceSearch.patrolZoneName) != -1)
					&&
					(
						(rightPanelServiceSearch.policeSex == "")
						|| (gps.policeSex == rightPanelServiceSearch.policeSex)
					)
				)
				{
					rightPanelServiceSearch.listPolice.addItem(gps);
				}
			}
			
			sendNotification(AppNotification.NOTIFY_SEARCH_ATTRIBUTE);
		}
		
		private function onSearchElePolice(event:Event = null):void
		{			
			rightPanelServiceSearch.listElePolice.removeAll();
			
			for each(var elePolice:DicElePolice in DicElePolice.dict)
			{
				if(
					/*(elePolice.layer.layerName == "摄像头")
					&&*/
					(elePolice.layer.selected)
					&&
					(
						(elePolice.code.indexOf(rightPanelServiceSearch.textElePoliceNo) != -1) 
						|| (elePolice.name.indexOf(rightPanelServiceSearch.textElePoliceNo) != -1)
					)
					&& 
					(
						(rightPanelServiceSearch.listEleDeptItem == DicDepartment.ALL) 
						|| (elePolice.department == rightPanelServiceSearch.listEleDeptItem)
					)
				)
				{
					rightPanelServiceSearch.listElePolice.addItem(elePolice);
				}
			}
			
			sendNotification(AppNotification.NOTIFY_SEARCH_ATTRIBUTE);
		}
		
		private function onFlashEle(event:Event):void
		{
			var elePolice:DicElePolice = rightPanelServiceSearch.gridElePolice.selectedItem as DicElePolice;
			if(elePolice != null)
			{
				sendNotification(AppNotification.NOTIFY_LAYERELEPOLICE_FLASH,elePolice);
			}
		}
		
		private function onLocateEle(event:Event):void
		{			
			var elePolice:DicElePolice = rightPanelServiceSearch.gridElePolice.selectedItem as DicElePolice;
			if(elePolice != null)
			{
				sendNotification(AppNotification.NOTIFY_MAP_LOCATE,elePolice.mapPoint);
			}
		}
		
		override public function listNotificationInterests():Array
		{
			return [	
				//AppNotification.NOTIFY_MAP_INIT,
				AppNotification.NOTIFY_APP_INIT,
				
				AppNotification.NOTIFY_MENUBAR,
				AppNotification.NOTIFY_TOOLBAR
				];
		}
		
		override public function handleNotification(notification:INotification):void
		{
			switch(notification.getName())
			{
				//case AppNotification.NOTIFY_MAP_INIT:					
				//	initRoad();
				//	break;
				
				case AppNotification.NOTIFY_APP_INIT:
					rightPanelServiceSearch.listDept = DicDepartment.listOverview;
					
					if(AppConfigVO.Auth == "1")
					{
						rightPanelServiceSearch.listDeptItem = DicDepartment.ALL;
						rightPanelServiceSearch.listEleDeptItem = DicDepartment.ALL;
					}
					else
					{
						rightPanelServiceSearch.listDeptItem = AppConfigVO.user.department;
						rightPanelServiceSearch.listEleDeptItem = AppConfigVO.user.department;
					}
					
					rightPanelServiceSearch.listPatrolZone = DicPatrolZone.listAll;
					rightPanelServiceSearch.listPatrolZone.filterFunction = patrolZoneFilterFunction;
					rightPanelServiceSearch.listPatrolZone.refresh();
							
					rightPanelServiceSearch.listRoad1 = DicRoad.list;
					rightPanelServiceSearch.listRoad2 = DicRoad.list;
					rightPanelServiceSearch.listRoad3 = DicRoad.list;
					
					//this.listOriginRoad = DicRoad.list;
					break;
								
				case AppNotification.NOTIFY_MENUBAR:
					if(notification.getType() == MainMenu.SERVICESEARCH)
					{
						rightPanelServiceSearch.graphicIndex = -1;
						
						onSearchPolice();
					}
					break;
					
				case AppNotification.NOTIFY_TOOLBAR:	
					switch(notification.getType())
					{
						case MainTool.PAN:
						case MainTool.ZOOMIN:
						case MainTool.ZOOMOUT:
						case MainTool.MEASURELENGTH:	
						case MainTool.MEASUREAREA:
							rightPanelServiceSearch.graphicIndex = -1;
							break;
					}
					break;
			}
		}
	}
}