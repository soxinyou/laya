package com.framework.mvc.patterns.observer
{
	import com.framework.mvc.interfaces.IFacade;
	import com.framework.mvc.interfaces.INotifier;
	import com.framework.mvc.patterns.facade.Facade;

	/**
	 * 邮递员类
	 * @author nos(liupengpeng)
	 * 
	 */	
	public class Notifier implements INotifier
	{
		public function sendNotification( notificationId:String, body:Object=null, act:String=null ):void 
		{
			facade.sendNotification( notificationId, body, act );
		}
		
		protected var facade:IFacade = Facade.getInstance();
	}
}