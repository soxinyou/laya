package com.framework.net
{
	import com.framework.logger.GameLog;
	
	import laya.events.Event;
	import laya.events.EventDispatcher;
	import laya.net.Socket;
	import laya.utils.Byte;
	import laya.utils.Handler;

	/**
	 * 自定义laya，socket套接字类 
	 * @author nos(liupengpeng)
	 * 
	 */	
	public class CustomSocket extends EventDispatcher
	{
		protected var m_socket:Socket=null;
		
		protected var m_ip:String=null;
		protected var m_port:int=0;
		
		protected var m_connect_status:int=0;
		protected var m_try_times:int=0;
		
		protected const INIT_CONNECT:int=0;
		protected const READY_CONNECT:int=1;
		protected const RUNNING_CONNECT:int=2;
		protected const ERROR_CONNECT:int=3;
		protected const CLOSED_CONNECT:int=4;
		
		protected var receiveFun:Handler;
		
		public function CustomSocket()
		{
			initSocket();
		}
		
		private function initSocket():void{
			m_socket=new Socket();
			m_socket.disableInput=true;
			m_socket.endian = Byte.BIG_ENDIAN;//这里我们采用大端；
			m_socket.on(Event.OPEN,this,onConnected);
			m_socket.on(Event.MESSAGE,this,OnReceive);
			m_socket.on(Event.CLOSE,this,onClosed);
			m_socket.on(Event.ERROR,this,errorHandler);
			
			m_connect_status=INIT_CONNECT;
			
			m_try_times=0;
			
			m_ip=null;
			m_port=0;
		}
		
		public function setAddress(ip:String,port:int):void{
			m_ip=ip;
			m_port=port;
			
			m_connect_status=READY_CONNECT;
		}
		
		/**
		 * 是否正常链接 
		 * @return 
		 * 
		 */		
		public function connected():Boolean{
			return m_socket&&m_socket.connected;
		}
		
		public function connect():void{
			
			if(!m_ip){
				GameLog.debug("ip is no defind");
			}
			if(m_port<=0||m_port >=65535){
				GameLog.debug("port is error,now value:"+m_port);
			}
			
			if(m_connect_status==RUNNING_CONNECT){
				GameLog.debug("socket is running");
				return;
			}
			
			GameLog.debug("connect address（ip:"+m_ip+",port:"+m_port+")");
			
			m_socket.connect(m_ip,m_port);
			
//			m_socket.connectByUrl("ws://" + m_ip + ":" + m_port);//建立连接；
		}
		
		public function dispose():void{
			if(m_socket){
				m_socket.off(Event.OPEN,this,onConnected);
				m_socket.off(Event.MESSAGE,this,OnReceive);
				m_socket.off(Event.CLOSE,this,onClosed);
				m_socket.off(Event.ERROR,this,errorHandler);
				m_socket=null;
			}
			
			m_connect_status=INIT_CONNECT;
			
			m_try_times=0;
			
			m_ip=null;
			m_port=0;
			
		}
		
		public var disableHead:Boolean=false;
		
		private var m_packHead:String="20180622";
		/**
		 *  4个字节长度的字符组
		 * @param val
		 */		
		public function set packHead(val:String):void{
			if(!val){
				GameLog.error("please words is empty");
				return
			}
			if(val.length>8){
				GameLog.error("please words is too length");
				return
			}
			var list:Array=val.match(/[^0-9a-f]/ig);
			if(list&&list.length>0){
				GameLog.error("please only use words:0-9，a-f ");
				return;
			}
			m_packHead=val;
		}
		
		private function encodePack(body:Byte):Byte{
			var pack:Byte=new Byte();
			if(disableHead==false){
				for (var i:int = 0; i <8; i+=2) 
				{
					pack.writeByte(parseInt(m_packHead.slice(i,i+2)));
				}
			}
			
			body.pos=0;
			pack.writeInt32(body.length+pack.length);
			pack.writeArrayBuffer(body.buffer);
			return pack;
		}
		
		public function sendPack(body:Byte):Boolean{
			if(!body||body.length<=0){
				GameLog.debug("send package is empty");
				return false;
			}
			
			if(m_socket&&m_socket.connected){
				
				var pack:Byte=encodePack(body);
				pack.pos=0;
				m_socket.output.writeArrayBuffer(pack.buffer);
				m_socket.flush();
				return true;
			}
			
			return false;
		}
		
		
		private function OnReceive(msg:* = null):void
		{
			///接收到数据触发函数
			GameLog.debug("receive data by socket ");
			if(receiveFun){
				receiveFun.runWith(msg);
			}
			event(Event.MESSAGE,msg);
		}
			
		private function onConnected(event:Object = null):void
		{
			//正确建立连接；
			GameLog.debug("socket is connected");
			
			m_connect_status=RUNNING_CONNECT;
			event(Event.OPEN);
		}
		
		private function onClosed(e:Object= null):void
		{
			//关闭事件
			
			if(m_socket&&m_socket.connected){
				m_socket.close();
			}
			
			GameLog.debug("socket is closed");
			
			m_connect_status=CLOSED_CONNECT;
			event(Event.CLOSE);
		}
		private function errorHandler(e:Object = null):void
		{
			//连接出错
			GameLog.debug("errorHandler");
			
			m_try_times++;
			
			if(m_try_times<4){
				GameLog.debug("try to reconnect address（ip:"+m_ip+",port:"+m_port+"),times:"+m_try_times);
				
				m_socket.connect(m_ip,m_port);
//				m_socket.connectByUrl("ws://" + m_ip + ":" + m_port);//建立连接；
			}else{
				m_connect_status=ERROR_CONNECT;
				event(Event.ERROR);
			}
		}
		
		
	}
}