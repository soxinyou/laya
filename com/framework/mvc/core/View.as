package com.framework.mvc.core
{
	import com.framework.mvc.interfaces.IMediator;
	import com.framework.mvc.interfaces.INotification;
	import com.framework.mvc.interfaces.IObserver;
	import com.framework.mvc.interfaces.IView;
	import com.framework.mvc.patterns.observer.Observer;
	
	/**
	 * 视图类
	 * @author nos(liupengpeng)
	 * 
	 */	
	public class View implements IView
	{
		// 显示代理类的id与实例的映射
		protected var mediatorMap : Object;
		
		// 所有观察者与信件id的映射
		protected var observerMap	: Object;
		
		// 该类的实例
		protected static var instance	: IView;
		
		// 单列提示
		protected const SINGLETON_MSG	: String = "View already instanced !";
		public function View( )
		{
			if (instance != null) throw Error(SINGLETON_MSG);
			instance = this;
			
			mediatorMap = new Object();
			observerMap = new Object();	
			initializeView();	
		}
		/**
		 *初始化视图 
		 * 
		 */		
		protected function initializeView() : void 
		{
			
		}
		/**单例*/
		public static function getInstance() : IView 
		{
			if ( instance == null ) instance = new View( );
			return instance;
		}
		
		/**
		 * 注册观察者 
		 * @param notificationId
		 * @param observer
		 * 
		 */		
		public function registerObserver ( notificationId:String, observer:IObserver ) : void
		{
			var observers:Array = observerMap[ notificationId ];
			if( observers ) {
				observers.push( observer );
			} else {
				observerMap[ notificationId ] = [ observer ];	
			}
		}
		
		/**
		 * 通知观察者 
		 * @param notification
		 * 
		 */		
		public function notifyObservers( notification:INotification ) : void
		{
			if( observerMap[ notification.getId() ] != null ) {
				
				var observers_ref:Array = observerMap[ notification.getId() ] as Array;

   				var observers:Array = new Array(); 
   				var observer:IObserver;
				for (var i:Number = 0; i < observers_ref.length; i++) { 
					observer = observers_ref[ i ] as IObserver;
					observers.push( observer );
				}
				
				for (i = 0; i < observers.length; i++) {
					observer = observers[ i ] as IObserver;
					observer.notifyObserver( notification );
				}
			}
		}
		
		/**
		 * 移除观察者
		 * @param notificationId
		 * @param notifyContext
		 * 
		 */		
		public function removeObserver( notificationId:String, notifyContext:Object ):void
		{
			var observers:Array = observerMap[ notificationId ] as Array;

			for ( var i:int=0; i<observers.length; i++ ) 
			{
				if ( Observer(observers[i]).compareNotifyContext( notifyContext ) == true ) {
					observers.splice(i,1);
					break;
				}
			}

			if ( observers.length == 0 ) {
				delete observerMap[ notificationId ];		
			}
		} 

		/**
		 * 注册显示类中介器
		 * @param mediator
		 * 
		 */		
		public function registerMediator( mediator:IMediator ) : void
		{
			if ( mediatorMap[ mediator.getMediatorId() ] != null ) return;
			
			mediatorMap[ mediator.getMediatorId() ] = mediator;
			
			var interests:Array = mediator.listNotificationInterests();

			if ( interests.length > 0 ) 
			{
				var observer:Observer = new Observer( mediator.handleNotification, mediator );

				for ( var i:Number=0;  i<interests.length; i++ ) {
					registerObserver( interests[i],  observer );
				}			
			}
			
			mediator.onRegister();
			
		}
		
		/**
		 * 取回显示中介器 
		 * @param mediatorId
		 * @return 
		 * 
		 */		
		public function retrieveMediator( mediatorId:String ) : IMediator
		{
			return mediatorMap[ mediatorId ];
		}
		
		/**
		 * 移除显示中介器 
		 * @param mediatorId
		 * @return 
		 * 
		 */		
		public function removeMediator( mediatorId:String ) : IMediator
		{
			var mediator:IMediator = mediatorMap[ mediatorId ] as IMediator;
			
			if ( mediator ) 
			{
				var interests:Array = mediator.listNotificationInterests();
				for ( var i:Number=0; i<interests.length; i++ ) 
				{
					removeObserver( interests[i], mediator );
				}	
				
				delete mediatorMap[ mediatorId ];
	
				mediator.onRemove();
			}
			
			return mediator;
		}
		/**
		 * 是否注册指定中介器 
		 * @param mediatorId
		 * @return 
		 * 
		 */		
		public function hasMediator( mediatorId:String ) : Boolean
		{
			return mediatorMap[ mediatorId ] != null;
		}

		
	}
}