package com 
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.html.HTMLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	/**
	 * ...
	 * @author Gamba
	 */
	public class WidgetLoader extends Sprite
	{
		
		public function WidgetLoader(_width:Number = 120,_height:Number = 120,_color:uint = 0xff0000,_alpha:Number = 1) 
		{
			trace("\nWidgetLoader CONSTRUCTING...\n");
			//绘制背景
			graphics.beginFill(_color, _alpha);
			graphics.drawRoundRect(0, 0, _width, _height, 12, 12);
			graphics.endFill();
			//载入HTML
			var htmlloader:HTMLLoader = new HTMLLoader();
			htmlloader.load(new URLRequest("google.html"));
			htmlloader.addEventListener(Event.COMPLETE, function(e:Event):void { 
				addChild(htmlloader);
				htmlloader.width = e.target.parent.width;
				htmlloader.height = e.target.parent.height;
			} );
		}
		
	}

}