---

title: Swift 4.0 新特性

categories: iOS

---

本文主要是基于github上一个Swift 4.0新特性的开源项目[whats-new-in-swift-4](https://github.com/ole/whats-new-in-swift-4)的解读。

## 1.One-sided ranges

```
let numbers = [1,2,3,4,5,6,7,8,9,10]
numbers[5...] // instead of numbers[5..<numbers.endIndex]
```

## 2.Strings
* 更快的字符处理速度
	
	Swift 4 的字符串优化了底层实现，对于英语、法语、德语、西班牙语的处理速度提高了 3.5 倍，对于简体中文、日语的处理速度提高了 2.5 倍
	
* Multi-line string literals 多行字符串字面量

```
// Swift 4 可以把字符串写在一对 """ 中，这样字符串就可以写成多行。
let multilineString = """
    This is a multi-line string.
    You don't have to escape "quotes" in here.
    String interpolation works as expected: 2 + 3 = \(2 + 3)
    The position of the closing delimiter
      controls whitespace stripping.
    """
    
// 当然，也可以使用 \ 来转义换行
let escapedNewline = """
    To omit a line break, \
    add a backslash at the end of a line.
    """
// To omit a line break, add a backslash at the end of a line. 
```

* 去掉 characters

	Swift 3 中的 String 需要通过 characters 去调用的属性方法，在 Swift 4 中可以通过 String 对象本身直接调用，例如：
	
```
let values = "one,two,three..."
var i = values.characters.startIndex
while let comma = values.characters[i...<values.characters.endIndex].index(of: ",") {
    if values.characters[i..<comma] == "two" {
        print("found it!")
    }
    i = values.characters.index(after: comma)
}
```
Swift 4 可以把上面代码中的所有的 characters 都去掉，修改如下：
	
```
let values = "one,two,three..."
var i = values.startIndex
while let comma = values[i...<values.endIndex].index(of: ",") {
    if values[i..<comma] == "two" {
        print("found it!")
    }
    i = values.index(after: comma)
}
```

* String 当做 Collection 来用

```
// 遍历字符串
let greeting = "Hello, 😜!"
greeting.count
for char in greeting {
    print(char)
}

// 翻转字符串
let abc: String = "abc"
print(String(abc.reversed()))

```

* Substring

![](http://ocga9x543.bkt.clouddn.com/QQ20170609-182237@2x.png)

在 Swift 中，String 的背后有个 Owner Object 来跟踪和管理这个 String，String 对象在内存中的存储由内存其实地址、字符数、指向 Owner Object 指针组成。Owner Object 指针指向 Owner Object 对象，Owner Object 对象持有 String Buffer。当对 String 做取子字符串操作时，子字符串的 Owner Object 指针会和原字符串指向同一个对象，因此子字符串的 Owner Object 会持有原 String 的 Buffer。当原字符串销毁时，由于原字符串的 Buffer 被子字符串的 Owner Object 持有了，原字符串 Buffer 并不会释放，造成极大的内存浪费。

在 Swift 4 中，做取子串操作的结果是一个 Substring 类型，它无法直接赋值给需要 String 类型的地方。必须用 String() 包一层，系统会通过复制创建出一个新的字符串对象，这样原字符串在销毁时，原字符串的 Buffer 就可以完全释放了。

```
let big = downloadHugeString()
let small = extractTinyString(from: big)
mainView.titleLabel.text = small // Swift 4 编译报错
mainView.titleLabel.text = String(small) // 编译通过
```

* Unicode

	改善了在计算Unicode字符长度时的正确性。
	在 Unicode 中，有些字符是由几个其它字符组成的，比如 é 这个字符，它可以用 \u{E9} 来表示，也可以用 e 字符和上面一撇字符组合在一起表示 \u{65}\u{301}。

```
var family = "👩"      // "👩"
family += "\u{200D}👩” // "👩‍👩"
family += "\u{200D}👧” //"👩‍👩‍👧"
family += "\u{200D}👦” //"👩‍👩‍👧‍👦"
family.count          //在swift3中，count=4，在swift4中，count=1
```

## 3.Private declarations visible in same-file extensions 修改了Private修饰符的权限范围
private修饰的属性或方法，可以在同文件中的extension中访问到。跟swift3中的fileprivate相似而又不同。相同点是都可以在同一个文件中访问到，不同点是private修饰的只能在当前类型的extension中访问到，而fileprivate修饰的，也可以在其他的类型定义和extension中访问到。

```
struct SortedArray<Element: Comparable> {
    private var storage: [Element] = []
    init(unsorted: [Element]) {
        storage = unsorted.sorted()
    }
}

extension SortedArray {
    mutating func insert(_ element: Element) {
        // storage is visible here
        storage.append(element)
        storage.sort()
    }
}

let array = SortedArray(unsorted: [3,1,2])

// storage is _not_ visible here. It would be if it were fileprivate.
//array.storage // error: 'storage' is inaccessible due to 'private' protection level
```

## 4.Key Paths
类似Objective-C里的KVC，Swift 4.0里的Key Paths是强类型的

```
struct Person {
  var name: String
}
struct Book {
  var title: String
  var authors: [Person]
  var primaryAuthor: Person {
      return authors.first!
  }
}
let abelson = Person(name: "Harold Abelson")
let sussman = Person(name: "Gerald Jay Sussman")
var sicp = Book(title: "Structure and Interpretation of Computer Programs", authors: [abelson, sussman])
```

* 使用key paths获取对象值

```
sicp[keyPath: \Book.title] 
//Structure and Interpretation of Computer Programs
```

* key paths 可以用于计算属性

```
sicp[keyPath: \Book.primaryAuthor.name] 
//Harold Abelson
```

* 使用key paths可以修改值

```
sicp[keyPath: \Book.title] = "Swift 4.0” 
//sicp.title 现在是Swift 4.0
```

* key paths是对象，可以被存储和操纵

```
let authorKeyPath = \Book.primaryAuthor
print(type(of: authorKeyPath)) //KeyPath<Book, Person>
let nameKeyPath = authorKeyPath.appending(path: \.name) // 这个可以省略Book，因为编译器可以推断出类型
sicp[keyPath: nameKeyPath] //Harold Abelson
```

* KeyPath实际上是一个class，它的定义如下：

```
/// A key path from a specific root type to a specific resulting value type.
public class KeyPath<Root, Value> : PartialKeyPath<Root> {
}
```

* key paths暂时还不支持下标操纵

```
//sicp[keyPath: \Book.authors[0].name] //编译失败
```

## 5.Archival and serialization归档和序列化
当需要将一个对象持久化时，需要把这个对象序列化，往常的做法是实现 NSCoding 协议，写过的人应该都知道实现 NSCoding 协议的代码写起来很痛苦，尤其是当属性非常多的时候。

Swift 4 中引入了``Codable``帮我们解决了这个问题。

``Codable``其实是一个组合协议:

```
public typealias Codable = Decodable & Encodable
```

```
struct Card: Codable {
    enum Suit: String, Codable {
        case clubs, spades, hearts, diamonds
    }
    enum Rank: Int, Codable {
        case ace = 1, two, three, four, five, six, seven, eight, nine, ten, jack, queen, king
    }
    var suit: Suit
    var rank: Rank
}
let hand = [Card(suit: .clubs, rank: .ace), Card(suit: .hearts, rank: .queen)]
```

Encode 操作如下：

```
// json
var encoder = JSONEncoder()
let jsonData = try encoder.encode(hand)
String(data: jsonData, encoding: .utf8)

// plist
var encoder2 = PropertyListEncoder()
encoder2.outputFormat = .xml
let propertyData = try encoder2.encode(hand)
String(data: propertyData, encoding: .utf8)
```
Decode 操作如下：

```
// json
let decoder = JSONDecoder()
let decodedHand = try decoder.decode([Card].self, from: jsonData)

// plist
var decoder2 = PropertyListDecoder()
let hand3 = try decoder2.decode([Card].self, from: propertyData)
hand3[0].suit //clubs
```
更全面的JSON解析请查看[Swift 4 JSON 解析指南](https://bignerdcoding.com/archives/37.html)

## 6.Associated type constraints关联类型约束
* protocol中也可以使用``where``语句对关联类型进行约束了

```
protocol SomeProtocol where Self: UICollectionViewCell {
}
// SomeProtocol要求它的实现者必须继承UICollectionViewCell，
// 不是随便一个类型都能实现SomeProtocol
```

* ``Sequence``协议有自己的``Element associatedtype``了，不需要写``Iterator.Element``了

```
extension Sequence where Element: Numeric {
    var sum: Element {
        var result: Element = 0
        for element in self {
            result += element
        }
        return result
    }
}

[1,2,3,4].sum
```

## 7.Dictionary and Set enhancements
* 使用key-value sequence初始化Dictionary

```
let names = ["Cagney", "Lacey", "Bensen”]
let dict = Dictionary(uniqueKeysWithValues: zip(1..., names))
//[2: "Lacey", 3: "Bensen", 1: "Cagney”]
```
* 如果key存在重复的情况，使用：

```
let users = [(1, "Cagney"), (2, "Lacey"), (1, "Bensen”)] 
//zip函数的作用就是把两个Sequence合并成一个key-value元组的Sequence
let dict = Dictionary(users, uniquingKeysWith: {
  (first, second) in
  print(first, second)
  return first
})
//[2: "Lacey", 1: "Cagney”]
```
* merge 合并

```
let defaults = ["foo": false, "bar": false, "baz": false]
var options = ["foo": true, "bar": false]
// 按照merge函数的注释应该是如下写法，但是这种写法会报错error: generic parameter 'S' could not be inferred
//let mergedOptions = options.merge(defaults) { (old, _) in old }
// 需要替换成
options.merge(defaults.map { $0 }) { (old, _) in old }options
//["bar": false, "baz": false, "foo": true]
```
* 带默认值的下标操作

	使用下标取某个key值时，可以传一个default参数作为默认值，当这个key不存在时，会返回这个默认值

```
let source = "how now brown cow"
var frequencies: [Character: Int] = [:]
for c in source {
  frequencies[c, default: 0] += 1
}
print(frequencies)
//["b": 1, "w": 4, "r": 1, "c": 1, "n": 2, "o": 4, " ": 3, "h": 1]
```
* map和filter函数返回值类型是Dictionary，而不是Array

```
let filtered = dict.filter {
  $0.key % 2 == 0
}
filtered //[2: "Lacey"]
let mapped = dict.mapValues { value in
  value.uppercased()
}
mapped //[2: "LACEY", 1: "CAGNEY”]
```
* 对Sequence进行分组

```
let contacts = ["Julia", "Susan", "John", "Alice", "Alex"]
let grouped = Dictionary(grouping: contacts, by: { $0.first! })
print(grouped)
//["J": ["Julia", "John"], "S": ["Susan"], "A": ["Alice", "Alex"]]
```

## 8.MutableCollection.swapAt method
新增的一个方法，用于交换MutableCollection中的两个位置的元素

```
var numbers = [1,2,3,4,5]
numbers.swapAt(0,1) 
//[2, 1, 3, 4, 5]
```

## 9.Generic subscripts泛型下标
有时候会写一些数据容器，Swift 支持通过下标来读写容器中的数据，但是如果容器类中的数据类型定义为泛型，以前的下标语法就只能返回 Any，在取出值后需要用 as? 来转换类型。Swift 4 定义下标也可以使用泛型了。

```
struct GenericDictionary<Key: Hashable, Value> {
    private var data: [Key: Value]
    
    init(data: [Key: Value]) {
        self.data = data
    }
    
    subscript<T>(key: Key) -> T? {
        return data[key] as? T
    }
}
let dictionary = GenericDictionary(data: ["Name": "Xiaoming"])
let name: String? = dictionary["Name"] // 不需要再写 as? String
```

## 10.NSNumber bridging and Numeric types

```
let n = NSNumber(value: 999)
let v = n as? UInt8 // Swift 4: nil, Swift 3: 231
```
在 Swift 4 中，把一个值为 999 的 NSNumber 转换为 UInt8 后，能正确的返回 nil，而在 Swift 3 中会不可预料的返回 231。

## 11.减少隐式 @objc 自动推断
在项目中想把 Swift 写的 API 暴露给 Objective-C 调用，需要增加 @objc。在 Swift 3 中，编译器会在很多地方为我们隐式的加上 @objc，例如当一个类继承于 NSObject，那么这个类的所有方法都会被隐式的加上 @objc。

```
class MyClass: NSObject {
    func print() { ... } // 包含隐式的 @objc
    func show() { ... } // 包含隐式的 @objc
}
```
这样很多并不需要暴露给 Objective-C 也被加上了 @objc。大量 @objc 会导致二进制文件大小的增加。

在 Swift 4 中，隐式 @objc 自动推断只会发生在很少的当必须要使用 @objc 的情况，比如：

1. 复写父类的 Objective-C 方法
2. 符合一个 Objective-C 的协议
其它大多数地方必须手工显示的加上 @objc。

减少了隐式 @objc 自动推断后，Apple Music app 的包大小减少了 5.7%。

## 12.类型和协议的组合类型
协议与协议可以组合，协议与class也可以组合

```
protocol HeaderView {}

class ViewController: UIViewController {
    let header: UIView & HeaderView

    init(header: UIView & HeaderView) {
        self.header = header
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder decoder: NSCoder) {
        fatalError("not implemented")
    }
}

// Can't pass in a simple UIView that doesn't conform to the protocol
//ViewController(header: UIView())
// error: argument type 'UIView' does not conform to expected type 'UIView & HeaderView'

// Must pass in an NSView (subclass) that also conforms to the protocol
extension UIImageView: HeaderView {}

ViewController(header: UIImageView()) // works
```
