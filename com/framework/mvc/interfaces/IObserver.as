package com.framework.mvc.interfaces
{
	/**
	 * 观察者接口
	 * @author nos(liupengpeng)
	 * 
	 */	
	public interface IObserver
	{
		/**
		 * 设置调用函数
		 * @param notifyMethod
		 * 
		 */		
		function setNotifyMethod( notifyMethod:Function ):void;
		/**
		 * 设置函数的宿主 
		 * @param notifyContext
		 * 
		 */		
		function setNotifyContext( notifyContext:Object ):void;
		/**
		 * 通知观察者
		 * @param notification
		 * 
		 */		
		function notifyObserver( notification:INotification ):void;
		/**
		 * 对比观察者的宿主 
		 * @param object
		 * @return 
		 * 
		 */		
		function compareNotifyContext( object:Object ):Boolean;
	}
}