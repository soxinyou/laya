package com.framework.utils
{
	public class ClassUtil
	{
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