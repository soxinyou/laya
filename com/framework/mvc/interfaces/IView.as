package com.framework.mvc.interfaces
{
	/**
	 * 视图接口
	 * @author nos(liupengpeng)
	 * 
	 */	
	public interface IView 
	{
		/**
		 * 注册观察者 
		 * @param notificationId
		 * @param observer
		 * 
		 */		
		function registerObserver( notificationId:String, observer:IObserver ) : void;
		/**
		 * 移除 观察者
		 * @param notificationId
		 * @param notifyContext
		 * 
		 */		
		function removeObserver( notificationId:String, notifyContext:Object ):void;
		/**
		 * 通知观察者 
		 * @param note
		 * 
		 */		
		function notifyObservers( note:INotification ) : void;
		/**
		 * 注册显示中介器 
		 * @param mediator
		 * 
		 */		
		function registerMediator( mediator:IMediator ) : void;
		/**
		 * 获取显示中介器 
		 * @param mediatorId
		 * @return 
		 * 
		 */		
		function retrieveMediator( mediatorId:String ) : IMediator;
		/**
		 * 移除显示中介器 
		 * @param mediatorId
		 * @return 
		 * 
		 */		
		function removeMediator( mediatorId:String ) : IMediator;
		/**
		 * 是否注册显示中介器 
		 * @param mediatorId
		 * @return 
		 * 
		 */		
		function hasMediator( mediatorId:String ) : Boolean;
		
	}
	
}