package com.framework.logger
{
	/**
	 * 打印信息的显示对象继承接口 
	 * @author nos(liupengpeng)
	 * 
	 */	
	public interface ILoggerTarget
	{
		/**显示对象的信息等级*/
		function get showLevel():int;
		/**追加信息*/
		function appendLog(msg:String,level:int=0):void;
		/**增加到logger系统时，设置以前的等级的信息*/
		function setAllMsg(list:Array):void;
	}
}