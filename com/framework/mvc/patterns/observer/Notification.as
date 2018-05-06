package com.framework.mvc.patterns.observer
{
	import com.framework.mvc.interfaces.INotification;

	/**
	 *@描述：消息类
	 *@author: nos(liupengpeng)
	 *@date  : 2018-5-6
	 **/	
	public class Notification implements INotification
	{
		private var id:String;
		private var action:String;
		private var body:Object;
		
		public function Notification(nId:String, body:Object=null, nAction:String=null )
		{
			this.id = nId;
			this.body = body;
			this.action = action;
		}
		
		public function getId():String
		{
			return id;
		}
		
		public function setBody( body:Object ):void
		{
			this.body = body;
		}
		
		public function getBody():Object
		{
			return body;
		}
		
		public function setAction( act:String ):void
		{
			this.action = act;
		}
		
		public function getAction():String
		{
			return action;
		}
		public function toString():String
		{
			var msg:String = "notification id: "+getId();
			msg += "\nbody:"+(( body == null )?"null":body.toString());
			msg += "\naction:"+(( action == null )?"null":action);
			return msg;
		}
	}
}