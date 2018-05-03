package com.framework.logger
{
	import com.framework.utils.ClassUtil;
	
	import avmplus.getQualifiedClassName;
	
	import laya.utils.ClassUtils;

	/**
	 * 游戏中的打印信息系统 
	 * @author nos(liupengpeng)
	 * 
	 */	
	public class GameLog
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
		private static var m_categoryTargets:Vector.<ILogger>=new Vector.<ILogger>();
		/**日期时间*/
		private static var m_date:Date=new Date();
		/**默认打印器*/
		private static var m_logger:ILogger=new traceLogger();
		/**
		 *当前打印等级 
		 */		
		private static var m_loggerLv:int=0;
		public function GameLog()
		{
			
		}
		
		/**
		 * 设置默认打印器 
		 * @param value
		 * 
		 */		
		public static function set defaultLogger(value:ILogger):void{
			m_logger=value;
		}
		
		/**
		 * 设置默认打印级别 
		 * @param value
		 * 
		 */		
		public static function set loggerlevel(value:int):void{
			m_loggerLv=value;
		}
		
		/**
		 * 设置系统时间 
		 * @param value
		 * 
		 */		
		public static function set timer(value:Number):void{
			m_date.setTime(value);
		}
		
		/**
		 * 增加打印信息的显示对象 
		 * @param loggerTarget
		 * 
		 */		
		public static function addLogger(tempLogger:ILogger):void{
			
			if(m_categoryTargets.indexOf(tempLogger)<0){
				m_categoryTargets.push(tempLogger);
				var list:Array=m_msgMap[keywords+tempLogger.showLevel];
				var bool:Boolean=false;
				if(list&&list.length>0){
					bool=true;
				}else{
					bool=false;
				}
					
				tempLogger.setAllMsg(bool?list:[]);
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
		public static function message(msg:String,level:int=0):void{
			var list:Array=m_msgMap[keywords+level];
			if(list==null){
				list=[];
			}
			if(list.length>m_maxLen){
				list.shift();
			}
			
			if(showCategoryFilters()==false) return;
			
			msg=m_date.toUTCString()+": "+msg;
			
			list.push(msg);
			
			if(level!=LoggerLevel.ALL){
				list=m_msgMap["msg0"];
				if(list&&list.length>m_maxLen){
					list.shift();
				}else if(!list){
					list=[];
				}
				list.push(msg);
			}
			
			//默认打印信息
			if(m_logger){
				if(level>=m_loggerLv){
					m_logger.appendLog(msg,level);
				}
			}
			
			//各打印器增加打印信息
			for (var i:int = 0; i < m_categoryTargets.length; i++) 
			{
				var tempLogger:ILogger=m_categoryTargets[i];
				if(tempLogger.showLevel==LoggerLevel.ALL){
					tempLogger.appendLog(msg,level);
				}else if(tempLogger.showLevel==level){
					tempLogger.appendLog(msg,level);
				}
			}
			
		}
		
		/**
		 *  打印普通级别信息 
		 * @param msg
		 * 
		 */		
		public static function log(msg:String):void{
			message(msg,LoggerLevel.LOG);
		}
		
		/**
		 * 打印调试级别信息 
		 * @param msg
		 * @param level
		 * 
		 */		
		public static function debug(msg:String):void{
			message(msg,LoggerLevel.DEBUG);
		}
		/**
		 * 打印警告级别信息 
		 * @param msg
		 * @param level
		 * 
		 */		
		public static function warn(msg:String):void{
			message(msg,LoggerLevel.WARN);
		}
		/**
		 * 打印错误级别信息 
		 * @param msg
		 * @param level
		 * 
		 */		
		public static function error(msg:String):void{
			message(msg,LoggerLevel.ERROR);
		}
		
		/**
		 * 详细描述 
		 * @param msg
		 * @param level
		 * 
		 */		
		public static function detail(hoster:*,msg:String,level:int=0):void{
			var words:String="";
			if(hoster is String){
				words+=hoster;
			}else{
				words+=ClassUtil.getQualifiedClassName(hoster);
			}
			words+=":: "+msg;
			message(words,level);
		}
		
		/**
		 *  打印跟踪
		 * @param arg
		 * 
		 */		
		public static function traceLog(...arg):void{
			var words:String="";
			for (var i:int = 0; i < arg.length; i++) 
			{
				var item:*=arg[i];
				if(item is String){
					words+=item+" ";
				}else{
					words+=item+" ";
				}
			}
			message(words);
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