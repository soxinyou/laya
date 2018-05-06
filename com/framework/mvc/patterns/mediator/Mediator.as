package com.framework.mvc.patterns.mediator
{
	import com.framework.mvc.interfaces.IMediator;
	import com.framework.mvc.interfaces.INotification;
	import com.framework.mvc.interfaces.INotifier;
	import com.framework.mvc.patterns.observer.Notifier;

	/**
	 * 界面显示中介类
	 * @author nos(liupengpeng)
	 * 
	 */	
	public class Mediator extends Notifier implements IMediator, INotifier
	{

		public static const ID:String = 'Mediator';
		/**
		 *唯一id 
		 */		
		protected var mediatorId:String;
		
		protected var viewComponent:Object;
		public function Mediator( mediatorId:String=null, viewComponent:Object=null ) {
			this.mediatorId = (mediatorId != null)?mediatorId:ID; 
			this.viewComponent = viewComponent;	
		}
		public function getMediatorId():String 
		{	
			return mediatorId;
		}

		public function setViewComponent( viewComponent:Object ):void 
		{
			this.viewComponent = viewComponent;
		}

		public function getViewComponent():Object
		{	
			return viewComponent;
		}

		public function listNotificationInterests():Array 
		{
			return [ ];
		}
		public function handleNotification( notification:INotification ):void {}
		
		public function onRegister( ):void {}

		public function onRemove( ):void {}
	}
}