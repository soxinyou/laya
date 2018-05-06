package com.framework.mvc.interfaces
{
	/**
	 * 数据模型类
	 * @author nos(liupengpeng)
	 * 
	 */	
	public interface IModel 
	{
		/**
		 *注册数据代理 
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
		 * 是否含有指定数据代理 
		 * @param proxyId
		 * @return 
		 * 
		 */		
		function hasProxy( proxyId:String ) : Boolean;

	}
}