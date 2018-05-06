package com.framework.mvc.interfaces
{
	/**
	 * 数据代理接口
	 * @author nos(liupengpeng)
	 * 
	 */	
	public interface IProxy
	{
		/**
		 * 获取唯一标示 
		 * @return 
		 * 
		 */		
		function getProxyId():String;
		/**
		 * 设置数据 
		 * @param data
		 * 
		 */		
		function setData( data:Object ):void;
		/**
		 * 获取数据 
		 * @return 
		 * 
		 */		
		function getData():Object; 
		/**
		 *注册时，执行函数 
		 * 
		 */		
		function onRegister( ):void;
		/**
		 *移除时，执行函数 
		 * 
		 */		
		function onRemove( ):void;
	}
}