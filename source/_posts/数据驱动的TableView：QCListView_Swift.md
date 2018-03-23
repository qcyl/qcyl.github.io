---

title: 数据驱动的TableView：QCListView_Swift

date: 2017-07-28 00:00:00

categories: iOS

---
## 前言
`UITableView`可以说是iOS开发中最常用的一个控件了，那么对`UITableView`的使用以及封装就可以说是重中之重了。今天就介绍一个自己封装的由数据进行驱动的`UITableView`的封装[QCListView_Swift](https://github.com/qcyl/QCListView_Swift)。

## 数据驱动
何为数据驱动？
就是只关心数据的处理，数据改变，cell改变。不需要实现`UITableView`那些繁杂的协议方法。

只是这么说的话，相信大家还都是比较懵的状态，下面看源码：

```
// 我需要TableView展示两种cell, 并且每隔一行换一种，我只需要将对应的model拼接成一个数组，
// 那么UI会自动根据数组中的model找到对应的cell进行展示

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tableView = TableView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height), style: .plain)
        tableView.qcDataSource = dataSource
        tableView.qcDelegate = self
        tableView.register(cell: DemoCell())
        tableView.register(cell: Demo2Cell())
        view.addSubview(tableView)
    }
    
    let dataSource: TableViewDataSource = {
        let dataSource = TableViewDataSource()
        
        var section = SectionObject()
        section.items = {
            var items: [TableViewBaseItem] = []
            
            for i in 0..<20 {
                let model = DemoModel()
                model.count = i
                items.append(model)
                let model2 = Demo2Model()
                model2.count2 = i
                items.append(model2)
            }

            return items
        }()
        dataSource.sections = [section]
        
        return dataSource
    }()

}

extension ViewController: TableViewDelegate {
    func tableView(_ tableView: TableView, didSelectedObject object: TableViewBaseItem, atIndexPath indexPatn: IndexPath) {
        print("点击")
    }
}

```

## 整体思路
由于`UITableView`的数据源实际上就是一个二维数组，所以将每组封装成一个`SectionObject`对象，对象内又包含每行的对象数组`items`。这样外部按照这个格式来拼接对象就确定了`UITableView`的数据源。

数据源确定了，还需要确定返回的cell，这里我将每行数据的model与cell之间制定了一个规则（规则说明请看文末），这样就可以通过对应的model找到cell，并返回。

在Model类的父类中`TableViewBaseItem`，有两个属性`cellHeight`和`itemIdentifier`。`cellHeight`存储cell的高度，在Cell类中实现`TableViewCellDelegate`协议返回；`itemIdentifier`根据Model类名转换，并使用这个`itemIdentifier`注册cell。
注：一般情况下，这两个属性都无需关心。

另外`UITableView`的代理协议中包含非常多的协议方法，[QCListView_Swift](https://github.com/qcyl/QCListView_Swift)中的`TableView`不可能将每个协议方法都进行实现，这就需要用到[协议分发](http://www.olinone.com/?p=643),通过使用[HJProtocolDispatcher](https://github.com/panghaijiao/HJProtocolDispatcher)实现协议的分发。

## 优点
1. 只需要关心数据的处理，无需每次都实现协议
2. 更好的职责划分，cell的样式，高度由cell内部自己处理
3. 更好的处理多cell的TableView
4. 注册cell时无需区分xib还是class

## TODO
1. `SectionObject`完善
2. `TableViewBaseItem`支持泛型处理
3. `UITableViewDataSource`的协议分发
4. 支持自动高度计算（也有可能不会支持）

## 规则说明
本库会自动将Model类（每行对应的对象）后的`Model或Item`转换成`Cell`，然后去寻找对应的Cell。

> 例如：
> Model类（DemoModel）会自动去找对应的Cell类（DemoCell）
> Model类（DemoItem）会自动去找对应的Cell类（DemoCell）

如果你的个人习惯或者项目要求导致Model类不会以`Model或Item`结尾，还可创建`cellIDRule.plist`文件（根结构为数组），在文件内填写需要转换的结尾字符串。

> 例如需要转换以`Etity`结尾的Model类：
> 则在`cellIDRule.plist`文件中添加一项`Etity`
> 
> 注意：创建`cellIDRule.plist`文件后，默认的`Model或Item`将不再支持


---

更细致的内容还请大家去看[demo](https://github.com/qcyl/QCListView_Swift)。
