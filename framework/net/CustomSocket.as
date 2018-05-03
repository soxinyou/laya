package com.framework.net
{
	import laya.events.EventDispatcher;
	import laya.net.Socket;
	/**
	 * 自定义laya，socket套接字类 
	 * @author nos(liupengpeng)
	 * 
	 */	
	public class CustomSocket extends EventDispatcher
	{
		protected var m_socket:Socket;
		
		protected var m_ip:String;
		protected var m_port:int;
		public function CustomSocket()
		{
			m_socket=null;	
		}
		
		public function setAddress(ip:String,port:int):void{
			m_ip=ip;
			m_port=port;
		}
		
		public function connect():void{
			
		}
	}
}