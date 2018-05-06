package com.framework.mvc.interfaces
{
	/**
	 * 控制器接口
	 * @author nos(liupengpeng)
	 * 
	 */	
	public interface IController
	{
		/**
		 * 注册执行类 
		 * @param notificationId
		 * @param commandClassRef
		 * 
		 */		
		function registerCommand( notificationId : String, commandClassRef : Class ) : void;
		/**
		 * 通知执行类 
		 * @param notification
		 * 
		 */		
		function executeCommand( notification : INotification ) : void;
		/**
		 * 移除执行类 
		 * @param notificationId
		 * 
		 */		
		function removeCommand( notificationId : String ):void;
		/**
		 * 是否注册这个执行类 
		 * @param notificationId
		 * @return 
		 * 
		 */		
		function hasCommand( notificationId:String ) : Boolean;
	}
}