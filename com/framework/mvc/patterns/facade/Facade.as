package com.framework.mvc.patterns.facade
{
	import com.framework.mvc.core.Controller;
	import com.framework.mvc.core.Model;
	import com.framework.mvc.core.View;
	import com.framework.mvc.interfaces.IController;
	import com.framework.mvc.interfaces.IFacade;
	import com.framework.mvc.interfaces.IMediator;
	import com.framework.mvc.interfaces.IModel;
	import com.framework.mvc.interfaces.INotification;
	import com.framework.mvc.interfaces.IProxy;
	import com.framework.mvc.interfaces.IView;
	import com.framework.mvc.patterns.observer.Notification;

	/**
	 * 外部操作类
	 * @author nos(liupengpeng)
	 * 
	 */	
	public class Facade implements IFacade
	{
		
		/**逻辑对象*/
		protected var controller : IController;
		/**
		 *数据对象 
		 */		
		protected var model		 : IModel;
		/**
		 * 视图对象 
		 */		
		protected var view		 : IView;
		
		protected static var instance : IFacade; 
		
		protected const SINGLETON_MSG	: String = "Facade already instanced !";
		public function Facade( ) {
			if (instance != null) throw Error(SINGLETON_MSG);
			instance = this;
			initializeFacade();	
		}
		
		/**
		 * 
		 * 初始化函数
		 */		
		protected function initializeFacade(  ):void {
			initializeModel();
			initializeController();
			initializeView();
		}

		/**
		 * 单例
		 * @return 
		 * 
		 */		
		public static function getInstance():IFacade {
			if (instance == null) instance = new Facade( );
			return instance;
		}
		
		/**
		 * 初始化逻辑控制类
		 * 
		 */		
		protected function initializeController( ):void {
			if ( controller != null ) return;
			controller = Controller.getInstance();
		}
		
		/**
		 *初始化数据模型 
		 * 
		 */		
		protected function initializeModel( ):void {
			if ( model != null ) return;
			model = Model.getInstance();
		}
		
		/**
		 *初始化显示对象 
		 * 
		 */		
		protected function initializeView( ):void {
			if ( view != null ) return;
			view = View.getInstance();
		}

		/**
		 * 注册逻辑执行者 
		 * @param notificationId
		 * @param commandClassRef
		 * 
		 */		
		public function registerCommand( notificationId:String, commandClassRef:Class ):void 
		{
			controller.registerCommand( notificationId, commandClassRef );
		}
		
		/**
		 * 移除逻辑执行者 
		 * @param notificationId
		 * 
		 */		
		public function removeCommand( notificationId:String ):void 
		{
			controller.removeCommand( notificationId );
		}
		
		/**
		 * 指定Id是否被注册
		 * @param notificationId
		 * @return 
		 * 
		 */		
		public function hasCommand( notificationId:String ) : Boolean
		{
			return controller.hasCommand(notificationId);
		}
		
		/**
		 * 注册数据代理类
		 * @param proxy
		 * 
		 */		
		public function registerProxy ( proxy:IProxy ):void	
		{
			model.registerProxy ( proxy );	
		}
		
		/**
		 * 获取指定的数据代理
		 * @param proxyId
		 * @return 
		 * 
		 */		
		public function retrieveProxy ( proxyId:String ):IProxy 
		{
			return model.retrieveProxy ( proxyId );	
		}
		
		/**
		 * 移除指定的数据代理 
		 * @param proxyId
		 * @return 
		 * 
		 */		
		public function removeProxy ( proxyId:String ):IProxy 
		{
			var proxy:IProxy;
			if ( model != null ) proxy = model.removeProxy ( proxyId );	
			return proxy
		}
		
		/**
		 *  是否id被注册
		 * @param proxyId
		 * @return 
		 * 
		 */		
		public function hasProxy( proxyId:String ) : Boolean
		{
			return model.hasProxy( proxyId );
		}

		/**
		 * 注册显示中介器 
		 * @param mediator
		 * 
		 */		
		public function registerMediator( mediator:IMediator ):void 
		{
			if ( view != null ) view.registerMediator( mediator );
		}

		/**
		 * 获取显示中介器 
		 * @param mediatorId
		 * @return 
		 * 
		 */		
		public function retrieveMediator( mediatorId:String ):IMediator 
		{
			return view.retrieveMediator( mediatorId ) as IMediator;
		}
		
		/**
		 * 移除显示中介器
		 * @param mediatorId
		 * @return 
		 * 
		 */		
		public function removeMediator( mediatorId:String ) : IMediator 
		{
			var mediator:IMediator;
			if ( view != null ) mediator = view.removeMediator( mediatorId );			
			return mediator;
		}

		/**
		 * 是否注册显示中介器 
		 * @param mediatorId
		 * @return 
		 * 
		 */		
		public function hasMediator( mediatorId:String ) : Boolean
		{
			return view.hasMediator( mediatorId );
		}

		/**
		 * 发送通知消息体 
		 * @param notificationId
		 * @param body
		 * @param type
		 * 
		 */		
		public function sendNotification( notificationId:String, body:Object=null, action:String=null ):void 
		{
			notifyObservers( new Notification( notificationId, body, action ) );
		}
		
		/**
		 * 通知观察者 
		 * @param notification
		 * 
		 */		
		public function notifyObservers ( notification:INotification ):void {
			if ( view != null ) view.notifyObservers( notification );
		}
	}
}