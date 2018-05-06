package com.framework.mvc.patterns.proxy
{
	import com.framework.mvc.interfaces.INotifier;
	import com.framework.mvc.interfaces.IProxy;
	import com.framework.mvc.patterns.observer.Notifier;

	/**
	 * 数据代理
	 * @author nos(liupengpeng)
	 * 
	 */	
	public class Proxy extends Notifier implements IProxy, INotifier
	{

		public static var ID:String = 'Proxy';
		
		protected var proxyId:String;
		
		protected var data:Object;
		public function Proxy( proxyId:String=null, data:Object=null ) 
		{
			
			this.proxyId = (proxyId != null)?proxyId:ID; 
			if (data != null) setData(data);
		}

		public function getProxyId():String 
		{
			return proxyId;
		}		
		
		public function setData( data:Object ):void 
		{
			this.data = data;
		}
		
		public function getData():Object 
		{
			return data;
		}		

		public function onRegister( ):void {}

		public function onRemove( ):void {}
		
	}
}