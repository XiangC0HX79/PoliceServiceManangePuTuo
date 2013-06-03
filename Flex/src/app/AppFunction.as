package app
{
	import app.model.vo.GPSVO;
	
	import flash.utils.ByteArray;
	
	import spark.components.ComboBox;
	import spark.components.gridClasses.GridColumn;
	import spark.formatters.DateTimeFormatter;

	public final class AppFunction
	{
		public static function matchingFunction(comboBox:ComboBox, inputText:String):Vector.<int>
		{
			var matchingItems:Vector.<int> = new Vector.<int>;
			return matchingItems;
		}
		
		public static function labelDateTime(item:Object, column:GridColumn):String
		{
			var dateF:DateTimeFormatter = new DateTimeFormatter;
			dateF.dateTimePattern = "yyyy-MM-dd HH:mm:ss";
			
			return dateF.format(item[column.dataField] as Date);
		}
		
		public static function compareFunction(a:GPSVO, b:GPSVO, fields:Array = null):int
		{
			for(var i:Number = 0;i < a.gpsName.length;i++)
			{
				if(i >= b.gpsName.length)
				{
					return 1;
				}
				
				var bytesA:ByteArray = new ByteArray;
				bytesA.writeMultiByte(a.gpsName.toUpperCase().charAt(i), "cn-gb");
				var a1:Number = (bytesA.length == 1)?Number(bytesA[0]):Number(bytesA[0] << 8) +  bytesA[1];
				
				var bytesB:ByteArray = new ByteArray;
				bytesB.writeMultiByte(b.gpsName.toUpperCase().charAt(i), "cn-gb");
				var b1:Number = (bytesB.length == 1)?Number(bytesB[0]):Number(bytesB[0] << 8) +  bytesB[1];
				
				if(a1 < b1)
				{
					return -1;
				}
				else if(a1 > b1)
				{
					return 1;
				}
			}
			
			if(a.gpsName.length < b.gpsName.length)
			{
				return -1;
			}
			else 
			{
				return 1;
			}
		}
	}
}