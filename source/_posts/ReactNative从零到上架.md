---

title: ReactNative从零到上架

date: 2017-12-18 00:00:00

categories: 杂学

---

首先，向大家介绍一下这款RN开发的上架项目：[淘优惠](http://a.app.qq.com/o/simple.jsp?pkgname=com.qc.taoyouhui)，一款免费领取天猫淘宝购物优惠券的软件。
下载链接： [http://a.app.qq.com/o/simple.jsp?pkgname=com.qc.taoyouhui](http://a.app.qq.com/o/simple.jsp?pkgname=com.qc.taoyouhui)
![](http://ocga9x543.bkt.clouddn.com/1513588944.png)

## 前言
我个人本身是一位iOS开发者，最开始开发[淘优惠](http://a.app.qq.com/o/simple.jsp?pkgname=com.qc.taoyouhui)时，是iOS和Android各写了一套代码；由于对Android的了解还是有限，所以开发出来的版本不是很好，于是就打算用ReactNative再开发一个版本出来。
这篇文章主要介绍我是如何使用ReactNative将[淘优惠2.0](http://a.app.qq.com/o/simple.jsp?pkgname=com.qc.taoyouhui)从零到上架的。

## 开发环境搭建
搭建开发环境应该说是最基础的问题了，ReactNative的环境搭建还是很简单的，一般照着[文档](https://reactnative.cn/docs/0.51/getting-started.html)来都不会出什么错的。

## Hello World
开发环境搭建完成之后，要先大概了解一下项目的运行路径，可以先按照[文档](https://reactnative.cn/docs/0.51/getting-started.html)敲一下Hello World，以及后边的一些简单示例。

## 源码学习
大概了解了之后，我又在GitHub上找了很多的开源项目，找一些简单的，再找一些稍微大一点的，去慢慢学习他们的编程方式，以及架构上的一些设计。学习学习再学习，期间可以修改一下他们的代码，然后看运行效果，可以更方便的了解代码。

## 项目开发
然后就要自己动手开发了，可以选一个简单的项目，比如说我的[淘优惠2.0](http://a.app.qq.com/o/simple.jsp?pkgname=com.qc.taoyouhui)，这就是一个很简单的项目了。开发前要确定一下自己项目整体的架构，要尽量保持项目代码的整洁，防止项目开发后期代码混乱不堪，这会减少我们学习的激情，甚至有可能放弃。

我最开始开发[淘优惠2.0](http://a.app.qq.com/o/simple.jsp?pkgname=com.qc.taoyouhui)时，在项目中使用了redux来管理状态，也许是我对redux的理解还不够，也许是我的项目确实不适合redux，导致了开发到后期项目代码有些混乱，所以我又不得不推倒重新来过。

确定了项目之后就要进入开发了，开发过程中，难免会遇到各种问题，这时候就要多看[文档](https://reactnative.cn/docs/0.51/getting-started.html)了，[文档](https://reactnative.cn/docs/0.51/getting-started.html)可以帮你解决绝大多数的问题，解决不了的就要学会百度、谷歌了。要是实在解决不了也可以发到这里，让大家一起交流一下。

如果你只会iOS或者Android，你可以只先开发一端的，最后再去适配另一端。相信我，你修改的东西不会很多，只需要简单的适配一下页面，集成一些第三方的SDK，向RN暴露一些原生方法。而这些东西，都是简单的照着对应的文档操作即可。

## 总结
个人认为ReactNative的体验还是可以接受的，如果项目没有过于复杂的界面层级，严格的原生交互方式，并且开发人员不足的情况下，推荐大家试试ReactNative！对了，还支持热更新哦（不会被拒的那种）！


---

最后，在打一波广告！
[淘优惠](http://a.app.qq.com/o/simple.jsp?pkgname=com.qc.taoyouhui)，一款免费领取天猫淘宝购物优惠券的软件。
下载链接： [http://a.app.qq.com/o/simple.jsp?pkgname=com.qc.taoyouhui](http://a.app.qq.com/o/simple.jsp?pkgname=com.qc.taoyouhui)
![](http://ocga9x543.bkt.clouddn.com/1513588944.png)