package com.framework.logger
{
	/**
	 * 游戏中的打印信息系统 
	 * @author nos(liupengpeng)
	 * 
	 */	
	public class Logger
	{
		/**信息存储变量*/
		private static var m_msgMap:Object={};
		/**信息存储长度上限*/
		private static var m_maxLen:int=5000;
		/**过滤显示功能*/
		private static var m_filters:Array=[];
		/**存储关键字符*/
		private static var keywords:String="msg";
		/**分类打印信息的对象数组*/
		private static var m_categoryTargets:Vector.<ILoggerTarget>=new Vector.<ILoggerTarget>();
		public function Logger()
		{
			
		}
		/**
		 * 增加打印信息的显示对象 
		 * @param loggerTarget
		 * 
		 */		
		public static function addLoggerTarget(loggerTarget:ILoggerTarget):void{
			
			if(m_categoryTargets.indexOf(loggerTarget)<0){
				m_categoryTargets.push(loggerTarget);
				loggerTarget.setAllMsg(m_msgMap[keywords+loggerTarget.showLevel]);
			}
		}
		
		/**
		 * 显示过滤的条件格式数组 
		 * @param value
		 * 
		 */		
		public static function set showFilters(value:Array):void{
			m_filters=value;
		}
		
		/**
		 * 打印信息 
		 * @param msg
		 * @param level
		 * 
		 */		
		public static function log(msg:String,level:int=0):void{
			var list:Array=m_msgMap[keywords+level];
			if(list==null){
				list=[];
			}
			if(list.length>m_maxLen){
				list.shift();
			}
			
			if(showCategoryFilters()==false) return;
			
			list.push(msg);
			
			if(level!=0){
				list=m_msgMap["msg0"];
				if(list.length>m_maxLen){
					list.shift();
				}
				list.push(msg);
			}
			for (var i:int = 0; i < m_categoryTargets.length; i++) 
			{
				var tempLogger:ILoggerTarget=m_categoryTargets[i];
				if(tempLogger.showLevel==LoggerLevel.ALL){
					tempLogger.appendLog(msg,level);
				}else if(tempLogger.showLevel==level){
					tempLogger.appendLog(msg,level);
				}
			}
			
		}
		/**
		 * 打印调试级别信息 
		 * @param msg
		 * @param level
		 * 
		 */		
		public static function debug(msg:String,level:int=1):void{
			log(msg,level);
		}
		/**
		 * 打印警告级别信息 
		 * @param msg
		 * @param level
		 * 
		 */		
		public static function warn(msg:String,level:int=2):void{
			log(msg,level);
		}
		/**
		 * 打印错误级别信息 
		 * @param msg
		 * @param level
		 * 
		 */		
		public static function error(msg:String,level:int=3):void{
			log(msg,level);
		}
		
		/**
		 * 甄别可以显示的信息 
		 * @return 
		 * 
		 */		
		private static function showCategoryFilters():Boolean{
			if(m_filters&&m_filters.length>0){
				return true;
			}
			
			return true;
		}
		
	}
}