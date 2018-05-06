package com.framework.utils
{
	/**
	 * 类的辅助类 
	 * @author nos(liupengpeng)
	 * 
	 */	
	public class ClassUtil
	{
		/**
		 * 获取类的路径全名
		 * @param val
		 * @return 
		 * 
		 */		
		public static function getQualifiedClassName(val:*):String{
			
			var className:String=typeof(val);
			if(className.toLocaleLowerCase()=="object"){
				var proto:Object=__JS__("val.__proto__");
				className=proto.__className;
				return className;
			}
			return className;
		}
	}
}