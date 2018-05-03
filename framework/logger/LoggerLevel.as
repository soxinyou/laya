package com.framework.logger
{
	/**
	 * 打印信息的等级 
	 * @author nos(liupengpeng)
	 * 
	 */	
	public class LoggerLevel
	{
		/**
		 * 打印全部，等级：0 
		 */		
		public static const ALL:int=0;
		/**
		 * 打印普通，等级：1
		 */	
		public static const LOG:int=1;
		/**
		 * 打印调试，等级：2
		 */		
		public static const DEBUG:int=2;
		/**
		 * 打印警告，等级：3 
		 */	
		public static const WARN:int=3;
		/**
		 * 打印错误，等级：4
		 */	
		public static const ERROR:int=4;
	}
}