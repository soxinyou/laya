package com.framework.logger
{
	
	public class traceLogger implements ILogger
	{
		public function traceLogger()
		{
		}
		
		public function get showLevel():int
		{
			return 0;
		}
		
		public function appendLog(msg:String, level:int=0):void
		{
			if(level>=showLevel){
				log(msg);
			}
		}
		
		public function setAllMsg(list:Array):void
		{
			for (var i:int = 0; i < list.length; i++) 
			{
				log(list[i]);
			}
			
		}
		
		public function log(msg:String):void{
			trace(msg);
		}
	}
}