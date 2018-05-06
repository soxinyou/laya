package com.framework.mvc.patterns.command
{
	import com.framework.mvc.interfaces.ICommand;
	import com.framework.mvc.interfaces.INotification;
	import com.framework.mvc.interfaces.INotifier;
	import com.framework.mvc.patterns.observer.Notifier;
	
	/**
	 * 多个执行者类
	 * @author nos(liupengpeng)
	 * 
	 */	
	public class MacroCommand extends Notifier implements ICommand, INotifier
	{
		/*子执行者的列表*/
		private var subCommands:Array;
		public function MacroCommand()
		{
			subCommands = new Array();
			initializeMacroCommand();			
		}
		/**
		 * 
		 * 初始化
		 */		
		protected function initializeMacroCommand():void
		{
		}
		
		/**
		 * 注册该类的子执行者
		 * @param commandClassRef
		 * 
		 */		
		protected function addSubCommand( commandClassRef:Class ): void
		{
			subCommands.push(commandClassRef);
		}
		
		/**
		 * 执行函数 
		 * @param notification
		 * 
		 */		
		public final function execute( notification:INotification ) : void
		{
			while ( subCommands.length > 0) {
				var commandClassRef : Class = subCommands.shift();
				var commandInstance : ICommand = new commandClassRef();
				commandInstance.execute( notification );
			}
		}
								
	}
}