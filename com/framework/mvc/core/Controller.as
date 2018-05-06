package com.framework.mvc.core
{
	import com.framework.mvc.interfaces.ICommand;
	import com.framework.mvc.interfaces.IController;
	import com.framework.mvc.interfaces.INotification;
	import com.framework.mvc.interfaces.IView;
	import com.framework.mvc.patterns.observer.Observer;

	/**
	 * 逻辑控制类
	 * @author nos(liupengpeng)
	 * 
	 */	
	public class Controller implements IController
	{
		/*视图对象*/
		protected var view:IView;
		/*存储注册的执行者的变量*/
		protected var commandMap:Object;
		/**单例*/
		protected static var instance:IController;
		
		protected const SINGLETON_MSG : String = "Controller already instanced!";
		public function Controller( )
		{
			if (instance != null) throw Error(SINGLETON_MSG);
			instance = this;
			commandMap = new Object();	
			initializeController();	
		}
		/**
		 *初始化 
		 * 
		 */		
		protected function initializeController(  ) : void 
		{
			view = View.getInstance();
		}
		
		/**单例*/
		public static function getInstance() : IController
		{
			if ( instance == null ) instance = new Controller( );
			return instance;
		}
		
		/**
		 * 通知执行者 
		 * @param note
		 * 
		 */		
		public function executeCommand( note : INotification ) : void
		{
			var commandClassRef : Class = commandMap[ note.getId() ];
			if ( commandClassRef == null ) return;

			var commandInstance : ICommand = new commandClassRef();
			commandInstance.execute( note );
		}

		/**
		 * 注册执行者 
		 * @param notificationId
		 * @param commandClassRef
		 * 
		 */		
		public function registerCommand( notificationId : String, commandClassRef : Class ) : void
		{
			if ( commandMap[ notificationId ] == null ) {
				view.registerObserver( notificationId, new Observer( executeCommand, this ) );
			}
			commandMap[ notificationId ] = commandClassRef;
		}
		/**
		 * 是否注册指定执行者 
		 * @param notificationId
		 * @return 
		 * 
		 */		
		public function hasCommand( notificationId:String ) : Boolean
		{
			return commandMap[ notificationId ] != null;
		}

		/**
		 * 移除指定执行者 
		 * @param notificationId
		 * 
		 */		
		public function removeCommand( notificationId : String ) : void
		{
			if ( hasCommand( notificationId ) )
			{
				view.removeObserver( notificationId, this );
							
				commandMap[ notificationId ] = null;
			}
		}

	}
}