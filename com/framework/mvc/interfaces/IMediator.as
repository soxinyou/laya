package com.framework.mvc.interfaces
{
	/**
	 * 显示中介器接口
	 * @author nos(liupengpeng)
	 * 
	 */	
	public interface IMediator
	{
		/**获得中介器id*/
		function getMediatorId():String;
		/**获得显示类的对象*/
		function getViewComponent():Object;
		/**设置得显示类的对象*/
		function setViewComponent( viewComponent:Object ):void;
		/**效应信件id列表*/
		function listNotificationInterests( ):Array;
		/**对于的信件id的处理函数*/
		function handleNotification( notification:INotification ):void;
		/**注册时，执行函数*/
		function onRegister():void;
		/**移除时，执行函数*/
		function onRemove():void;
		
	}
}