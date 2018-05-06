package com.framework.mvc.interfaces
{
	/**
	 * 逻辑处理中心接口
	 * @author nos(liupengpeng)
	 * 
	 */	
	public interface IFacade extends INotifier
	{
		/**
		 * 注册数据代理 
		 * @param proxy
		 * 
		 */		
		function registerProxy( proxy:IProxy ) : void;
		/**
		 * 获取数据代理 
		 * @param proxyId
		 * @return 
		 * 
		 */		
		function retrieveProxy( proxyId:String ) : IProxy;
		/**
		 * 移除数据代理 
		 * @param proxyId
		 * @return 
		 * 
		 */		
		function removeProxy( proxyId:String ) : IProxy;
		/**
		 * 是否注册了数据代理 
		 * @param proxyId
		 * @return 
		 * 
		 */		
		function hasProxy( proxyId:String ) : Boolean;
		/**
		 * 注册执行类
		 * @param notificationId
		 * @param commandClassRef
		 * 
		 */		
		function registerCommand( notificationId : String, commandClassRef : Class ) : void;
		/**
		 * 移除执行类 
		 * @param notificationId
		 * 
		 */		
		function removeCommand( notificationId:String ): void;
		/**
		 * 是否注册了执行类 
		 * @param notificationId
		 * @return 
		 * 
		 */		
		function hasCommand( notificationId:String ) : Boolean;
		/**
		 * 注册显示中介器 
		 * @param mediator
		 * 
		 */		
		function registerMediator( mediator:IMediator ) : void;
		/**
		 * 注册显示中介器 
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
		 * 是否含有显示中介器 
		 * @param mediatorId
		 * @return 
		 * 
		 */		
		function hasMediator( mediatorId:String ) : Boolean;
		/**
		 * 通知观察者 
		 * @param note
		 * 
		 */		
		function notifyObservers( note:INotification ) : void;
	}
}