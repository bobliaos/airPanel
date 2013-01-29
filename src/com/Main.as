package com
{
	import air.update.states.HSMEvent;
	import flash.desktop.DockIcon;
	import flash.desktop.NativeApplication;
	import flash.desktop.NativeDragActions;
	import flash.desktop.SystemTrayIcon;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowDisplayState;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.IOErrorEvent;
	import flash.events.NativeDragEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import caurina.transitions.Tweener;
	import flash.display.NativeWindowType;
	import flash.display.NativeWindowInitOptions;
	import flash.filters.DropShadowFilter;
	
	/**
	 * ...
	 * @author Bob
	 */
	public class Main extends MovieClip
	{
		//全局变量
		private var ANCHOR_Y:Number = 24;
		private var NAVMAIN_HEIGHT:Number = 64;
		//主窗口
		private var navMain:Sprite = new Sprite;
		private var iconNumber:int = 0;
		
		private var rightMenu:Sprite = new Sprite;
		
		/**
		 * 构造方法,从config.xml取得配置
		 */
		public function Main():void
		{
			doSystemTrayIcon("icons/main.png");
			configStage();
			configNavMain();
		}
		
		/**
		 * 设置系统托盘图标
		 * @param	iconPath
		 */
		private function doSystemTrayIcon(iconPath:String):void
		{
			var icon:Loader = new Loader();
			var iconMenu:NativeMenu = new NativeMenu();
			var exitCommand:NativeMenuItem = iconMenu.addItem(new NativeMenuItem("Exit"));
			exitCommand.addEventListener(Event.SELECT, function(event:Event):void
				{
					NativeApplication.nativeApplication.icon.bitmaps = [];
					NativeApplication.nativeApplication.exit();
				});
			if (NativeApplication.supportsSystemTrayIcon)
			{
				NativeApplication.nativeApplication.autoExit = false;
				icon.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void
					{
						NativeApplication.nativeApplication.icon.bitmaps = [e.target.content.bitmapData];
					});
				icon.load(new URLRequest(iconPath));
				var systray:SystemTrayIcon = NativeApplication.nativeApplication.icon as SystemTrayIcon;
				systray.tooltip = "airPanel";
				systray.menu = iconMenu;
			}
		
		}
		
		/**
		 * 设置舞台
		 */
		private function configStage():void
		{
			//关闭原窗口
			NativeApplication.nativeApplication.autoExit = false;
			stage.nativeWindow.close();
			//设置无任务栏的新窗口
			var initOptions:NativeWindowInitOptions = new NativeWindowInitOptions();
			initOptions.type = NativeWindowType.UTILITY;
			initOptions.systemChrome = "none";
			initOptions.transparent = true;
			var winMain:NativeWindow = new NativeWindow(initOptions);
			winMain.width = Capabilities.screenResolutionX;
			winMain.height = Capabilities.screenResolutionY;
			winMain.stage.scaleMode = "noScale";
			winMain.stage.align = "TL";
			winMain.x = 0;
			winMain.y = 0;
			winMain.alwaysInFront = true;
			winMain.activate();
			winMain.stage.addChild(navMain);
		}
		
		/**
		 * 设置主导航条
		 */
		private function configNavMain():void
		{
			//建立图标
			var xmlLoader:URLLoader = new URLLoader();
			xmlLoader.addEventListener(Event.COMPLETE, function(e:Event):void
				{
					//构造XML
					var configXML:XML = XML(e.target.data);
					//初始化全局变量
					ANCHOR_Y = configXML.window.@anchor;
					NAVMAIN_HEIGHT = configXML.window.@height;
					iconNumber = configXML.icons.icon.length();
					trace(ANCHOR_Y + " " + iconNumber);
					navMain.graphics.endFill();
					//设置navMain背景
					navMain.graphics.beginFill(0xffffff, 0.8);
					navMain.graphics.drawRoundRect(-1, -1, 52 * iconNumber + 2, NAVMAIN_HEIGHT + 2, 15, 15);
					navMain.graphics.beginFill(configXML.window.@color_bg, configXML.window.@alpha_bg);
					navMain.graphics.drawRoundRect(0, 0, 52 * iconNumber, NAVMAIN_HEIGHT, 15, 15);
					navMain.x = Capabilities.screenResolutionX - 8;
					navMain.y = ANCHOR_Y;
					//根据configXML构造icon并添加到navMain中
					for (var i:String in configXML.icons.icon)
					{
						var icon:IconMain = new IconMain(configXML.icons.icon[i].icon_path, configXML.icons.icon[i].app_path, configXML.icons.icon[i].app_arg, configXML.icons.icon[i].@title);
						trace(configXML.icons.icon[i].@title);
						navMain.addChild(icon);
						icon.x = int(i) * 48 + 2;
						icon.y = 23;
					}
					//添加监听
					navMain.addEventListener(MouseEvent.MOUSE_OVER, doOver);
					navMain.addEventListener(MouseEvent.MOUSE_OUT, doOut);
					navMain.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, doDragEnter);
					//添加效果
					var filter:DropShadowFilter = new DropShadowFilter(2, 90, 0, 0.8, 4, 4);
					var filters:Array = [filter];
					navMain.filters = filters;
				});
			xmlLoader.load(new URLRequest("./config.xml"));
		}

		/**
		 * 文件拖入监听器
		 * @param	e
		 */
		private function doDragEnter(e:NativeDragEvent):void {
			navMain.removeEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, doDragEnter);
			trace(e);
			trace(e.clipboard.getData("air:url") );
			Tweener.addTween(navMain, {x: Capabilities.screenResolutionX - (52 * iconNumber) + (iconNumber * 4), time: 0.6, transition: "easeOutElastic"});
		}
		
		/**
		 * 鼠标移入事件
		 * @param	e
		 */
		private function doOver(e:MouseEvent):void
		{
			Tweener.addTween(navMain, {x: Capabilities.screenResolutionX - (52 * iconNumber) + (iconNumber * 4), time: 0.6, transition: "easeOutElastic"});
		}
		
		/**
		 * 鼠标移出事件
		 * @param	e
		 */
		private function doOut(e:MouseEvent):void
		{
			Tweener.addTween(navMain, {x: Capabilities.screenResolutionX - 8, time: 0.6, transition: "easeOutBounce"});
		}
	}

}

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.SpreadMethod;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.NativeDragEvent;
import flash.filters.BlurFilter;
import flash.filters.DropShadowFilter;
import flash.net.URLRequest;
import flash.filesystem.File;
import flash.desktop.NativeProcessStartupInfo;
import flash.desktop.NativeProcess;
import caurina.transitions.Tweener;
import flash.text.TextField;
import flash.text.TextFormat;

//包外类iconMain
class IconMain extends Sprite
{
	
	private var appPath:String;
	private var arg:String;
	private var iconTitle:Sprite = new Sprite();
	private var fileList:Sprite = new Sprite();
	private var fileListTitle:TextField = new TextField();
	private var LISTLENGTH:Number = 12;
	
	/**
	 * icon类,可接受点击
	 * @param	iconPath
	 * @param	_appPath
	 * @param	_arg
	 * @param	_title
	 */
	public function IconMain(iconPath:String, _appPath:String = "", _arg:String = "", _title:String = ""):void
	{
		//得到这个图标的路径和参数,导入图标
		appPath = _appPath;
		arg = _arg;
		trace("IconMain constructing... \nTO OPEN '" + arg + "' USE '" + appPath + "'");
		var iconLoader:Loader = new Loader();
		this.addChild(iconLoader);
		iconLoader.load(new URLRequest(iconPath));
		this.alpha = 0.6;
		
		//得到标题,导入标题
		var txtformat:TextFormat = new TextFormat("Yahei Consolas Hybrid", 11, 0xdddddd);
		this.addChild(iconTitle);
		iconTitle.y = 32;
		iconTitle.alpha = 0;
		var title:TextField = new TextField();
		title.defaultTextFormat = txtformat;
		iconTitle.addChild(title);
		title.text = _title;
		title.selectable = false;
		title.height = 18;
		title.x = 5;
		title.y = -2;
		iconTitle.graphics.beginFill(0x000000, 0.7);
		iconTitle.graphics.drawRoundRect(4, 0, title.textWidth + 6, 16, 3, 3);
		iconTitle.graphics.endFill();
		
		//列表文件夹中的文件
		addChild(fileList);
		fileList.alpha = 0;
		listFile();
		
		//添加点击监听
		this.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void
			{
				Tweener.addTween(e.target, {y: 2, time: 0.1, transition: "easeInOutCubic"});
			});
		this.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void
			{
				Tweener.addTween(e.target, {y: 0, time: 0.1, transition: "easeInOutCubic"});
			});
		this.addEventListener(MouseEvent.MOUSE_OVER, doMouseOver);
		this.addEventListener(MouseEvent.MOUSE_OUT, doMouseOut);
	}
	
	/**
	 * 将文件夹里面的文件列表出来
	 */
	public function listFile():void
	{
		//有参数直接添加文件夹列表,没有就打开程序
		if (arg)
		{
			var dirPath:String = arg.replace(/\\/g, "\\\\");
			var dir:File = new File(dirPath);
			var list:Array = dir.getDirectoryListing();
			var i:Number = 6;
			var j:Number = 6;
			for each (var item:File in list)
			{
				i += 48;
				if (list.indexOf(item) % LISTLENGTH == 0)
				{
					j += 48;
					i = 6;
				}
				//对列表中每一项执行设置图标,设置标题,绑定点击
				//设置图标
				var icon:Sprite = new Sprite();
				fileList.addChild(icon);
				var bitmap:Bitmap = new Bitmap(item.icon.bitmaps[0], "auto", true);
				icon.addChild(bitmap);
				bitmap.x = i;
				bitmap.y = j;
				icon.alpha = 0.7;
				//设置路径
				var path:String = item.nativePath;
				var txt_path:TextField = new TextField();
				txt_path.selectable = false;
				txt_path.text = path;
				icon.addChild(txt_path);
				txt_path.visible = false;
				//添加绑定
				icon.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void
					{
						Tweener.addTween(e.target, {alpha: 1, time: 0.2});
						var txt:TextField = e.target.getChildAt(1) as TextField;
						var rel_path:String = txt.text.toString();
						fileListTitle.text = rel_path;
					});
				icon.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void
					{
						Tweener.addTween(e.target, {alpha: 0.7, time: 0.2});
						var txt:TextField = e.target.getChildAt(1) as TextField;
						var rel_path:String = txt.text.toString();
						fileListTitle.text = "";
					});
				icon.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void
					{
						Tweener.addTween(e.target, {y: y + 2, time: 0.1, transition: "easeInOutCubic"});
					});
				icon.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void
					{
						Tweener.addTween(e.target, {y: y - 2, time: 0.1, transition: "easeInOutCubic"});
					});
				icon.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
					{
						var rel_path:String = e.target.getChildAt(1).text.toString();
						rel_path = rel_path.replace(/\\/g, "\\\\");
						var tf:File = new File(rel_path);
						tf.openWithDefaultApplication();
					});
			}
			
			//绘制背景
			fileList.graphics.clear();
			fileList.graphics.beginFill(0xFFFFFF, 1);
			fileList.graphics.drawRoundRect(-1, 47, 48 * LISTLENGTH + 2, Math.ceil(list.length / LISTLENGTH) * 48 + 18, 12, 12);
			fileList.graphics.endFill();
			fileList.graphics.beginFill(0, 1);
			fileList.graphics.drawRoundRect(0, 48, 48 * LISTLENGTH, Math.ceil(list.length / LISTLENGTH) * 48, 12, 12);
			fileList.graphics.endFill();
			//设置标题
			var txtformat:TextFormat = new TextFormat("Yahei Consolas Hybrid", 11, 0x222222);
			fileListTitle.defaultTextFormat = txtformat;
			fileList.addChild(fileListTitle);
			fileListTitle.width = fileList.width;
			fileListTitle.height = 18;
			fileListTitle.y = fileList.height - 18;
			fileListTitle.selectable = false;
			//添加效果
			var filter:DropShadowFilter = new DropShadowFilter(2, 90, 0, 0.8, 4, 4);
			var filters:Array = [filter];
			fileList.filters = filters;
		}
		else
		{
			//不是文件夹则直接打开
			this.addEventListener(MouseEvent.CLICK, openPath);
		}
	}
	
	/**
	 * 鼠标覆盖
	 * @param	e
	 */
	public function doMouseOver(e:MouseEvent):void
	{
		e.target.removeEventListener(MouseEvent.MOUSE_OVER, doMouseOver);
		Tweener.addTween(this, {alpha: 1, time: 0.3, transition: "easeOutBounce"});
		Tweener.addTween(iconTitle, {y: -18, alpha: 0.8, time: 0.3, transition: "easeOutBounce"});
		Tweener.addTween(fileList, {x: -48 * (LISTLENGTH - 1), alpha: 0.8, time: 0.6});
	}
	
	/**
	 * 鼠标移除
	 * @param	e
	 */
	public function doMouseOut(e:MouseEvent):void
	{
		e.target.addEventListener(MouseEvent.MOUSE_OVER, doMouseOver);
		Tweener.addTween(this, {alpha: 0.6, time: 0.3, transition: "easeOutBounce"});
		Tweener.addTween(iconTitle, {y: 32, alpha: 0, time: 0.3, transition: "easeOutBounce"});
		Tweener.addTween(fileList, {x: 0, alpha: 0, time: 0.6});
	}
	
	/**
	 * 点击打开路径
	 * @param	e
	 */
	private function openPath(e:MouseEvent):void
	{
		trace("OPEN '" + appPath + " --" + arg + "' NOW!");
		var file:File = new File();
		var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
		var args:Vector.<String> = new Vector.<String>();
		args.push(arg);
		file = file.resolvePath(appPath);
		nativeProcessStartupInfo.arguments = args;
		nativeProcessStartupInfo.executable = file;
		//新建线程并运行
		var process:NativeProcess = new NativeProcess();
		process.start(nativeProcessStartupInfo);
	}

}