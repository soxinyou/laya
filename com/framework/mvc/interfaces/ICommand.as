package com.framework.mvc.interfaces
{
	/**
	 * 执行者接口 
	 * @author nos(liupengpeng)
	 * 
	 */	
	public interface ICommand
	{
		/**
		 * 执行函数 
		 * @param notification
		 * 
		 */		
		function execute( notification:INotification ) : void;
	}
}