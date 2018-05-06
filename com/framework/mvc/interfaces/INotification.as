package com.framework.mvc.interfaces
{
	/**
	 * 信件接口
	 * @author nos(liupengpeng)
	 * 
	 */	
	public interface INotification
	{
		/**
		 * 获取唯一标识 
		 * @return 
		 * 
		 */		
		function getId():String;
		/**
		 * 获取信息体 
		 * @param body
		 * 
		 */		
		function setBody( body:Object ):void;
		/**
		 * 设置消息体 
		 * @return 
		 * 
		 */		
		function getBody():Object;
		/**
		 * 设置行为字符串 
		 * @param act
		 * 
		 */		
		function setAction( act:String ):void;
		/**
		 * 获取行为字符串 
		 * @return 
		 * 
		 */		
		function getAction():String;
		/**
		 * 字符串化 
		 * @return 
		 * 
		 */		
		function toString():String;
		
	}
}