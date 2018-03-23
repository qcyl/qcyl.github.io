---

title: 多Target、组件化实践

date: 2017-07-07 00:00:00

categories: iOS

---

## 前言
因为公司项目的特性：每个城市对应一个APP，每个APP又有着或多或少的区别；

所以开发人员面临的问题是：开发多个相似APP。

## 解决方案
### 先说一下之前的解决方案：
将所有APP整合为一个大的项目，通过修改配置文件，调用不同APP所需代码。

这样确实是解决了问题，但是方案肯定是不好的。

这样做的缺点：

1. 任何一个APP都需要加载所有APP的文件，资源
2. 每次查看不同城市的APP都需要修改配置文件，同时还要修改服务器地址，很容易发生遗漏
3. 所有APP的icon，名称无法单独设置

### 下面是本文的解决方案：
1. 通过Target管理不同城市的APP

	![](http://ocga9x543.bkt.clouddn.com/WX20170707-113040.png)
2. 通过cocoapods私有库将项目组件化

	大家可使用[cocoapods私有库制作脚本](https://github.com/qcyl/module_config)进行私有库制作。更多cocoapods私有库制作请[点击](http://www.jianshu.com/p/0c640821b36f)。
3. 不同的Target导入不同的cocoapods私有仓库

```sh
project 'SXC.xcodeproj'

platform :ios, '8.0'
use_frameworks!

pod 'QCRouter', :path => '../QCRouter'

target 'SXC_GX' do
  # Pods for SXC-GX
  pod 'SSQ/GX', :path => '../SSQ'
  
end

target 'SXC_HLJ' do
  # Pods for SXC-HLJ
  pod 'SSQ/HLJ', :path => '../SSQ'
  
end

target 'SXC_NX' do
  # Pods for SXC-NX
  pod 'SSQ/NX', :path => '../SSQ'
  
end

target 'SXC_TJ' do
  # Pods for SXC-TJ
  pod 'SSQ/TJ', :path => '../SSQ'

end

target 'SXC_ZJ' do
  # Pods for SXC-ZJ
  pod 'SSQ/ZJ', :path => '../SSQ'

end
```

## 注意事项
1. 多Target使用预定义宏问题

	![](http://ocga9x543.bkt.clouddn.com/WX20170707-150056.png)
	
	![](http://ocga9x543.bkt.clouddn.com/WX20170707-150127.png)
	
	由于本项目为Swift项目，所以如下使用预定义宏
	
	```
	#if SXC_TJ
    	let scheme = "sxc-tj"
	#elseif SXC_NX
	    let scheme = "sxc-nx"
	#elseif SXC_GX
	    let scheme = "sxc-gx"
	#elseif SXC_HLJ
	    let scheme = "sxc-hlj"
	#elseif SXC_ZJ
	    let scheme = "sxc-zj"
	#else
	    let scheme = ""
	#endif
	```
2. 组件化的话，使用了自己开发的[QCRouter](https://github.com/qcyl/QCRouter)来进行解耦，思路不知道对不对，大家有什么好的建议可以提一下。
3. 创建类的时候要注意选择正确的Target

	![](http://ocga9x543.bkt.clouddn.com/WX20170707-152510.png)

---

本文[demo](https://github.com/qcyl/SXC_demo)地址

## 参考文章
1. [iOS项目中多target的配置](http://ibloodline.com/articles/2016/06/16/multiple-targets.html)
2. [CocoaPods 私有仓库的创建（超详细）](http://www.jianshu.com/p/0c640821b36f)
