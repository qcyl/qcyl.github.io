---
title: 《Objective-C高级编程 iOS与OS X多线程和内存管理》读书笔记 Block篇

date: 2017-06-29

categories: 读书笔记

---
由于block部分内容还是比较多的，如果全部都细讲的话，篇幅会非常的长。强烈建议大家去看[本书](https://item.jd.com/11258970.html)（[PDF版](https://pan.baidu.com/s/1jHNOboq)）。

所以本文重点讲述 **Block存储域** 部分的内容。

## 1.Block的实质

> 要说各种Block相关内容的话，一定要先了解Block的实质。

首先，我们通过[clang](https://zh.wikipedia.org/wiki/Clang)转换Block语法。(源码太多，所以截图，请见谅)

![](http://upload-images.jianshu.io/upload_images/1787055-4d74e021c947bec2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

此源码的Block语法最为简单，该源码通过[clang](https://zh.wikipedia.org/wiki/Clang)可变换为以下形式：

![](http://upload-images.jianshu.io/upload_images/1787055-1a4dec8ed13c898e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

我们目前需要重点关心的为红色圈出的部分。

## 2.Block存储域

![](http://upload-images.jianshu.io/upload_images/1787055-92df46c39f580f29.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

上述源码通过`impl.isa = &_NSConcreteStackBlcok;`我们可以看出，该Block的类为_NSConcreteStackBlcok，设置在栈上。

下面我们再来看看设置在数据区域的Block：

```
void (^blk)(void) = ^{printf("Global Block\n");};
int main()
{
```
此源代码通过声明全局变量blk来使用Block语法。如果转换该源代码，Block用结构体的成员变量isa的初始化如下：

```
impl.isa = &_NSConcreteGlobalBlcok;
```
该Block的类为_NSConcreteGlobalBlcok类。因为在使用全局变量的地方不能使用自动变量没所以不存在对自动变量进行截获。

所以只要Block不截获自动变量，就可以将Block用结构体实例设置在程序的数据区域。

配置在全局变量上的Block，从变量作用域外也可以通过指针安全的使用。但设置在栈上的Block，如果其所属的变量作用于结束，该Block就被废弃。由于__blcok变量也配置在栈上，同样的，如果其所属的作用域结束，则该__block变量也会被废弃。

![](http://upload-images.jianshu.io/upload_images/1787055-9dc8a736878353ff.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

Block提供了将Block和__block变量从栈上复制到堆上的方法来解决这个问题。将配置在栈上的Block复制到堆上，这样即使Block语法所属的变量作用域结束，堆上的Block还可以继续存在。

![](http://upload-images.jianshu.io/upload_images/1787055-355a3424f29d8f22.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

复制到堆上的Block将_NSConcreteMallocBlcok类对象写入Block用结构体实例的成员变量isa。

```
impl.isa = & _NSConcreteMallocBlcok;
```

那么Blcok提供的复制方法究竟是什么呢？实际上当ARC有效时，大多数情形下编译器会恰当地进行判断，自动生成将Block从栈上复制到堆上的代码。

例如：将Blcok作为函数返回值返回时，编译器会自动生成复制到堆上的代码。

前面讲到过“大多数情况下编译器会恰当地进行判断”，不过在此之外的情况下需要手动生成代码，将Block从栈上复制到堆上。此时我们使用“copy实例方法”。那么编译器不能进行判断的究竟是什么样的状况呢？如下所示：

* 向方法或函数的参数中传递Block时

但是如果在方法或函数中恰当地复制了传递过来的参数，那么就不必再调用该方法或函数前手动复制了。以下方法或函数不用手动复制。

* Cocoa框架的方法且方法名中含有usingBlock等时
* GCD的API

举个具体例子，在使用NSArray类的enumerateObjectsUsingBlock实例方法以及dispatch_async函数时，不用手动复制。相反地，在NSArray类的initWithObjects实例方法上传递Block时需要手动复制。下面我们来看看源代码。

```
- (id)getBlockArray 
{
	int val = 10;
	return [[NSArray alloc] initWithObjects:
			^{NSLog(@"blk0:%d", val)},
			^{NSLog(@"blk1:%d", val)}, nil];
}
```
getBlockArray方法在栈上生成两个Block，并传递给NSArray类的initWithObjects实例方法。下面，在getBlockArray方法调用方，从NSArray对象中取出Block并执行。

```
id obj = getBlockArray();
typedef void (^blk_t)(void);
blk_t blk = (blk_t)[obj objectAtIndex:0];
blk();
```
该源代码的blk()，即Block在执行时发生异常，应用程序强制结束。这是由于在getBlockArray函数执行结束时，栈上的Block被废弃的缘故。可惜此时编译器不能判断是否需要复制。也可以不让编译器进行判断，而使其在所有情况下都能复制。但将Block从栈上复制到堆上是相当消耗CPU的。当Block设置在栈上也能使用时，将Block从栈上复制到堆上只是在浪费CPU资源。因此只在此情形下让编程人员手动进行复制。

该源代码像下面这样修改一下即可正常运行。

```
{
	int val = 10;
	return [[NSArray alloc] initWithObjects:
			[^{NSLog(@"blk0:%d", val)} copy],
			[^{NSLog(@"blk1:%d", val)} copy], nil];
}
```

另外，对于已配置在堆上的Block以及配置在程序的数据区域上的Blcok，调用copy方法又会如何呢？

![](http://upload-images.jianshu.io/upload_images/1787055-d05dc12aae560c11.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

不管Block配置在何处，用copy方法复制都不会引起任何问题。
