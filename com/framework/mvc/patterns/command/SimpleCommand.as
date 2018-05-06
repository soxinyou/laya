package com.framework.mvc.patterns.command
{
	import com.framework.mvc.interfaces.ICommand;
	import com.framework.mvc.interfaces.INotification;
	import com.framework.mvc.interfaces.INotifier;
	import com.framework.mvc.patterns.observer.Notifier;
	
	/**
	 * 单个执行者的类
	 * @author nos(liupengpeng)
	 * 
	 */	
	public class SimpleCommand extends Notifier implements ICommand, INotifier 
	{
		/**
		 * 执行函数 
		 * @param notification
		 * 
		 */		
		public function execute( notification:INotification) : void
		{
			
		}
								
	}
}