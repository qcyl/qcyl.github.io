---
title: 《Objective-C高级编程 iOS与OS X多线程和内存管理》读书笔记 自动引用计数篇

date: 2017-06-28 01:00:00

categories: 读书笔记

---
#### 导语：
> 顾名思义，自动引用计数（ARC，Automatic Reference Counting）是指内存管理中对引用采取自动计数的技术。以下摘自苹果的官方说明。

> 在Objective\-C 中采用Automatic Reference Counting（ARC）机制，让编译器来进行内存管理。在新一代Apple LLVM 编译器中设置ARC 为有效状态，就无需再次键入retain 或者release 代码，这在降低程序崩溃、内存泄漏等风险的同时，很大程度上减少了开发程序的工作量。编译器完全清楚目标对象，并能立刻释放那些不再被使用的对象。如此一来，应用程序将具有可预测性，且能流畅运行，速度也将大幅提升。


### 一、内存管理的思考方式
> 看到"引用计数"这个名称，我们便会不自觉地联想到"某处有某物多少多少"而将注意力放到计数上。但其实，更加客观、正确的思考方式是：
> 
> * 自己生成的对象，自己所持有。
> * 非自己生成的对象，自己也能持有。
> * 不再需要 自己持有的对象 时释放。
> * 非自己持有的对象无法释放。

##### 1. 自己生成的对象，自己所持有
使用"以下名称开头"的方法名意味着自己生成的对象只有自己持有：

* alloc
* new
* copy
* mutableCopy

注："以下名称开头"包括 allocMyObject，但不包括 allocmyobject，需要遵循驼峰式命名规范
    
##### 2. 非自己生成的对象，自己也能持有

```
例：
    // 取得非自己生成的对象
    id obj = [NSMutableArray array];
    // 自己持有
    [obj retain];
```
    
注：一般情况下，调用这类方法无需自己持有，在NSMutableArray的array方法中，
已将生成的对象注册到了自动释放池，所以无需obj持有也不会释放（注释为个人理解，如有错误请指出）

##### 3. 不再需要 自己持有对象 时释放
用 alloc/new/copy/mutableCopy "开头"的方法生成并持有的对象，或者用 retain 方法持有的对象，一旦不再需要，务必要用release方法进行释放。
    
##### 4. 非自己持有的对象无法释放
对于用alloc/new/copy/mutableCopy 方法生成并持有的对象，
或是用retain方法持有的对象，由于持有者是自己，所以在不需要该对象时需要将其释放。
而由此以外所得到的对象绝对不能释放。倘若在应用程序中释放了非自己所持有的对象就会造成崩溃。

### 二、ARC（重点）
> "引用计数式内存管理"的本质部分在ARC中并没有改变。就像"自动引用计数"这个名称表示的那样，ARC只是自动的帮助我们处理"引用计数"的相关部分

#### 2.1 所有权修饰符
* \_\_strong修饰符
* \_\_weak修饰符
* \_\_unsafe\_unretained修饰符
* \_\_autoreleasing修饰符

##### 2.1.1 \_\_strong修饰符
\_\_strong修饰符是id类型和对象类型默认的所有权修饰符。
如"strong"这个名称所示，\_\_strong修饰符表示对对象的"强引用"(持有对象)。
持有强引用的变量在超出其作用域时被废弃，随着强引用的失效，引用的对象会随之释放。

```
{
    /*
     *  自己生成并持有对象
     */
    id __strong obj = [[NSObject alloc] init];
    /*
     *  因为变量obj为强引用，
     *  所以自己持有对象
     */
}
    /*
     *  因为变量obj超出其作用域，强引用失效，
     *  所以自动的释放自己持有的对象。
     *  对象的所有者不存在，因此废弃该对象。
     */
```
##### 2.1.2 \_\_weak修饰符
大家应该都知道，如果只是用\_\_strong修饰符的话必然会发生"循环引用"的问题。
而\_\_weak修饰符就可以避免这一问题。
\_\_weak修饰符与\_\_strong修饰符相反，提供"弱引用"(不持有对象)。

```
{
    /*
     *  自己生成并持有对象
     */
    id __strong obj0 = [[NSObject alloc] init];
    /*
     *  因为变量obj为强引用，
     *  所以自己持有对象
     */
    id __weak obj1 = obj0;
    /*
     *  obj1变量持有生成对象的弱引用
     */
}
    /*
     *  因为变量obj0超出其作用域，强引用失效，
     *  所以自动的释放自己持有的对象。
     *  对象的所有者不存在，因此废弃该对象。
     */
```

\_\_weak修饰符还有一个优点。在持有某对象的弱引用时，
若该对象被废弃，则此弱引用将自动失效且处于nil被赋值的状态。

##### 2.1.3 \_\_unsafe\_unretained修饰符（很少使用）
\_\_unsafe\_unretained修饰符正如其名unsafe所示，是不安全的所有权修饰符。
尽管ARC式的内存管理是编译器的工作，但附有\_\_unsafe\_unretained修饰符
的变量不属于编译器的内存管理对象。这一点在使用时要注意。
附有\_\_unsafe\_unretained修饰符的变量同附有\_\_weak修饰符的变量一样，
因为自己生成并持有的对象不能继续为自己所用，所以生成的对象会立即被释放。
    
注：\_\_unsafe\_unretained修饰符在对象被废弃时不会主动赋值nil，所以会访问到"悬垂指针"，导致系统在个别运行情况下崩溃。
    
##### 2.1.4 \_\_autoreleasing修饰符（虽然很少显式附加，但很多情况下都会使用，所以很重要）
ARC无效时会像下面这样来使用：

```
/* ARC无效 */
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
id obj = [[NSObject alloc] init];
[obj autorelease];
[pool drain];
```
    
ARC有效时，该源码也能写成下面这样：

```
@autoreleasepool {
    id __autoreleasing obj = [[NSObject alloc] init];
}
```
    
但是，显式的附加\_\_autoreleasing修饰符同显式的附加\_\_strong修饰符一样罕见。
    
我们通过实例来看看为什么非显式地使用\_\_autoreleasing修饰符也可以。
    
1、编译器会检查方法名是否以alloc/new/copy/mutableCopy 开始，
如果不是则自动将返回值的对象注册到autoreleasepool。

```
@autoreleasepool {  
/*  
 * 取得非自己生成并持有的对象  
 */  
id __strong obj = [NSMutableArray array];  
/*  
 * 因为变量obj 为强引用，  
 * 所以自己持有对象。  
 *  
 * 并且该对象  
 * 由编译器判断其方法名后  
 * 自动注册到autoreleasepool  
 */  
} 
/*  
 * 因为变量obj 超出其作用域，强引用失效，  
 * 所以自动释放自己持有的对象。  
 *  
 * 同时，随着@autoreleasepool 块的结束，  
 * 注册到autoreleasepool 中的  
 * 所有对象被自动释放。  
 *  
 * 因为对象的所有者不存在，所以废弃对象。  
 */ 
```
 
2、由于return使得对象变量超出其作用域，所以该强引用对应的自己持有的对象会被自动释放，
但该对象作为函数的返回值，编译器会自动将其注册到autoreleasepool。

```
+ (id) array  
{  
	id obj = [[NSMutableArray alloc] init];  
	return obj;  
} 
```
    
3、以下为使用\_\_weak修饰符的例子。虽然\_\_weak修饰符是为了避免循环引用而使用的，
但在访问附有\_\_weak修饰符的变量时，实际上必定要访问注册到autoreleasepool的对象。

```
id __weak obj1 = obj0;  
NSLog(@"class=%@", [obj1 class]); 
```

以下源代码与此相同：

```
id __weak obj1 = obj0;  
id __autoreleasing tmp = obj1;  
NSLog(@"class=%@", [tmp class]); 
```

为什么在访问附有\_\_weak修饰符的变量时必须访问注册到autoreleasepool 的对象呢？
这是因为\_\_weak修饰符只持有对象的弱引用，而在访问引用对象的过程中，该对象有可能被废弃。
如果把要访问的对象注册到autoreleasepool中，那么在@autoreleasepool块结束之前都能确保该对象存在。
因此，在使用附有\_\_weak修饰符的变量时就必定要使用注册到autoreleasepool中的对象。
    
4、最后一个可非显式地使用\_\_autoreleasing修饰符的例子，同前面讲述的id obj 和id \_\_strongobj 完全一样。

那么id 的指针id *obj 又如何呢？可以由id \_\_strong obj 的例子类推出id \_\_strong*obj 吗？

其实，推出来的是id \_\_autoreleasing *obj。
同样地，对象的指针NSObject **obj 便成为了NSObject * \_\_autoreleasing *obj。
例：

```
- (BOOL) performOperationWithError:(NSError **)error; 
```
同前面讲述的一样，id的指针或对象的指针会默认附加上\_\_autoreleasing 修饰符，所以等同于以下源代码。

```
- (BOOL) performOperationWithError:(NSError * __autoreleasing *)error; 
```
    
下面的源代码会产生编译器错误：

```
NSError *error = nil;  
NSError **pError = &error; 
赋值给对象指针时，所有权修饰符必须一致。
error: initializing 'NSError *__autoreleasing *' with an expression  
of type 'NSError *__strong *' changes retain/release properties of pointer  
NSError **pError = &error;  
        ^           ~~~~~~ 
此时，对象指针必须附加__strong 修饰符。
NSError *error = nil;  
NSError * __strong *pError = &error;  
/* 编译正常 */ 
```

#### 2.2 属性
![](http://upload\-images.jianshu.io/upload\_images/1787055\-83eef1a8a0494bb1.jpg?imageMogr2/auto\-orient/strip%7CimageView2/2/w/1240)


## 问题
1.如何防止block的内存泄漏？ 

* 答：使用\_\_weak将self弱引用

2.那为什么又要在block中将self使用\_\_strong强引用呢？

* 答案一：防止self在使用过程中被释放掉。（未读本书前的理解）
* 答案二：既然使用\_\_weak修饰的变量在使用时会自动加入到自动释放池，就保证了在使用过程中不会被释放掉。同时，由于使用\_\_weak修饰的变量在每次使用时都会加入到一个自动释放池中，所以会消耗资源，但是使用\_\_strong强引用一下就不会了。（读本书后的理解，不知道对不对，希望各位大神指点一下）
