---
title: 《Objective-C高级编程 iOS与OS X多线程和内存管理》读书笔记 GCD篇

categories: 读书笔记

---

这篇文章主要给大家讲解一下GCD的平时不太常用的API，以及文末会贴出GCD定时器的一个小例子。

## 1.GCD的API

### 1.1 Dispatch Queue

要谈GCD，就一定要了解`Dispatch Queue`（执行处理的等待队列）。
`Dispatch Queue`按照追加的顺序（先进先出FIFO，First-In-First-Out）执行处理。
另外在执行处理是存在两种`Dispatch Queue`，一种是等待现在执行中处理的`Serial Dispatch Queue`，另一种是不等待现在执行中处理的`Concurrent Dispatch Queue`。

![](http://ocga9x543.bkt.clouddn.com/WX20170703-111143.png)

### 1.2 dispatch\_queue\_create
由于平时在使用时，我们大部分都是使用系统提供的`Main Dispatch Queue`和`Global Dispatch Queue`。
所以关于`dispatch_queue_create`API，这里只说两点：

* 通过`dispatch_queue_create`函数生成的`Dispatch Queue`在使用结束后要通过`dispatch_release`函数释放。
* 如果生成过多的线程，就会消耗大量内存，大幅度降低系统的响应性能。而使用系统提供的`Global Dispatch Queue`则不用担心这个问题。所以除非必要，其他情况建议使用系统提供的`Dispatch Queue`。

### 1.3 dispatch\_set\_target\_queue

使用`dispatch_queue_create`函数生成的`Dispatch Queue`，都使用的是与系统提供的`Global Dispatch Queue`的默认优先级相同的优先级。而要变更生成的执行优先级的话就要使用`dispatch_set_target_queue`函数。

在后台执行动作处理的`Serial Dispatch Queue`的生成方法如下:

```
	dispatch_queue_t mySerialDispatchQueue = dispatch_queue_create("com.example.gcd.mySerialDispatchQueue", NULL);
    dispatch_queue_t globalDispatchQueueBackground = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_set_target_queue(mySerialDispatchQueue, globalDispatchQueueBackground);
```

### 1.3 dispatch\_after
`dispatch_after`这里只说一点，`dispatch_after`函数并不是在指定时间后执行处理，而只是在指定时间追加处理到`Dispatch Queue`。

因为`Main Dispatch Queue`在主线程的`RunLoop`中执行，所以在比如每隔1/60秒执行的`RunLoop`中，Block最快在 3 秒后执行，最慢在 3 秒 + 1/60 秒后执行，并且在`Main Dispatch Queue`有大量处理追加或主线程的处理本身有延迟时，这个时间会更长。

所以该函数在有严格时间要求的情况下使用会出现问题，但是只是想大致延迟执行处理，该函数是非常有效的。

### 1.4 dispatch\_barrier\_async
在访问数据库或文件时，使用多线程可能会产生数据竞争的问题，当然使用`Serial Dispatch Queue`可避免数据竞争。

但是如果读取处理只是与读取处理并行执行，那么多个并行执行就不会发生问题。也就是说为了高效率的进行访问，读取处理追加到`Concurrent Dispatch Queue`，写入处理在任一读取处理没有执行的状态下，追加到`Serial Dispatch Queue`中即可（在写入处理结束之前，读取处理不可执行）。

使用`dispatch_barrier_async`便可解决这个问题。`dispatch_barrier_async`函数会等待追加到`Concurrent Dispatch Queue`上的并行执行的处理全部结束后，再将制定的处理追加到该`Concurrent Dispatch Queue`中。然后在由`dispatch_barrier_async`函数追加的处理执行完毕后，`Concurrent Dispatch Queue`才恢复为一般的动作，追加到该`Concurrent Dispatch Queue`的处理又开始并行执行。

```
    dispatch_async(queue, blk0_for_reading);
    dispatch_async(queue, blk1_for_reading);
    dispatch_async(queue, blk2_for_reading);
    dispatch_async(queue, blk3_for_reading);
    dispatch_barrier_async(queue, blk_for_writing);
    dispatch_async(queue, blk4_for_reading);
    dispatch_async(queue, blk5_for_reading);
    dispatch_async(queue, blk6_for_reading);
    dispatch_async(queue, blk7_for_reading);
```
如上所示，使用方法非常简单。仅使用`dispatch_barrier_async`函数代替`dispatch_async`函数即可。

![](http://ocga9x543.bkt.clouddn.com/WX20170703-115939.png)

### 1.5 dispatch\_apply
`dispatch_apply`函数是`dispatch_sync`函数和`Dispatch Group`的关联API。该函数按指定的次数将指定的Block追加到指定的`Dispatch Queue`中，并等待全部处理执行结束。

```
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply(10, queue, ^(size_t index) {
        NSLog(@"%zu", index);
    });
    NSLog(@"done");
```
例如，该源代码的执行结果为：

```
4
1
0
3
5
2
6
8
9
7
done
```
因为在`Global Dispatch Queue`中执行处理，所以各个处理的执行时间不定。但是输出结果中最后的done必定在最后的位置上。这是因为`dispatch_apply`函数会等待全部处理执行结束。

### 1.6 Dispatch I/O
大家可能想过，在读取较大文件时，如果将文件分成合适的大小并使用`Global Dispatch Queue`并列读取的话，应该会比一般的读取速度快不少。能实现这一功能的就是`Dispatch I/O`和`Dispatch Data`。

![](http://ocga9x543.bkt.clouddn.com/WX20170703-140234.png)

如果想提高文件读取速度，可以尝试使用`Dispatch I/O`。

### 1.7 Dispatch Source
GCD中出了主要的`Dispatch Queue`外，还有不太引人注目的`Dispatch Source`。它是BSD系内核惯有功能`kqueue`的包装。
`kqueue`是在XNU内核中发生各种事件时，在应用程序编程方执行处理的技术。其CPU负荷非常小，尽量不占用资源。`kqueue`可以说是应用程序处理XNU内核中发生的各种事件的方法中最优秀的一种。

`Dispatch Source`可以处理一下事件。

![](http://ocga9x543.bkt.clouddn.com/WX20170703-141244.png)


在使用NSTimer做定时器的时候，大家应该都知道如果使用不当，会出现内存泄漏的问题。
而如果作为一个封装的组件来说，就需要将NSTimer属性暴露出来，在控制器销毁时，调用NSTimer的invalidate方法。如果忘记的话就会内存泄漏！

但是使用`DISPATCH_SOUTCE_TYPE_TIMER`的话就不需要担心这个问题了。

[此处](https://github.com/qcyl/GCD-Timer-Demo)为使用了`DISPATCH_SOUTCE_TYPE_TIMER`的定时器的小demo。
