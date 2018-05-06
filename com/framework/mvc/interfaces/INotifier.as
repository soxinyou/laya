package com.framework.mvc.interfaces
{
	/**
	 * 邮递员接口
	 * @author nos(liupengpeng)
	 * 
	 */	
	public interface INotifier
	{
		/**
		 * 设置信件信息 
		 * @param nId
		 * @param body
		 * @param act
		 * 
		 */		
		function sendNotification( nId:String, body:Object=null, act:String=null ):void; 
		
	}
}