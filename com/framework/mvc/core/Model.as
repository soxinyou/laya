package com.framework.mvc.core
{
	import com.framework.mvc.interfaces.IModel;
	import com.framework.mvc.interfaces.IProxy;

	/**
	 * 数据模型类
	 * @author nos(liupengpeng)
	 * 
	 */	
	public class Model implements IModel
	{
		
		protected var proxyMap : Object;
		protected static var instance : IModel;
		protected const SINGLETON_MSG	: String = "Model already instanced !";
		public function Model( )
		{
			if (instance != null) throw Error(SINGLETON_MSG);
			instance = this;
			proxyMap = new Object();	
			initializeModel();	
		}
		/**
		 *初始化数据模型 
		 * 
		 */		
		protected function initializeModel(  ) : void 
		{
		}
		/**单例*/	
		public static function getInstance() : IModel 
		{
			if (instance == null) instance = new Model( );
			return instance;
		}

		/**
		 *注册数据代理 
		 * @param proxy
		 * 
		 */		
		public function registerProxy( proxy:IProxy ) : void
		{
			proxyMap[ proxy.getProxyId() ] = proxy;
			proxy.onRegister();
		}

		/**
		 * 获取指定数据代理 
		 * @param proxyId
		 * @return 
		 * 
		 */		
		public function retrieveProxy( proxyId:String ) : IProxy
		{
			return proxyMap[ proxyId ];
		}

		/**
		 *是否注册指定数据代理
		 * @param proxyId
		 * @return 
		 * 
		 */		
		public function hasProxy( proxyId:String ) : Boolean
		{
			return proxyMap[ proxyId ] != null;
		}

		/**
		 * 移除数据代理 
		 * @param proxyId
		 * @return 
		 * 
		 */		
		public function removeProxy( proxyId:String ) : IProxy
		{
			var proxy:IProxy = proxyMap [ proxyId ] as IProxy;
			if ( proxy ) 
			{
				proxyMap[ proxyId ] = null;
				proxy.onRemove();
			}
			return proxy;
		}
	}
}