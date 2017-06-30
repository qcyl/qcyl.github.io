---
title: Hexo+GitHub Pages搭建个人博客

date: 2017-06-28 00:00:00

categories: 杂学

---
本文主要记录自己在搭建个人博客的记录，以及工程中遇到的一些问题。
    
废话少说，上干货。
    
#### 1. GitHub仓库
由于本博客的搭建是基于Hexo + GitHub Page的，所以GitHub账号是必不可少的。
相信大家应该也都有自己的账号了，没有的赶紧去注册一个吧！

注：账号的username会影响你的域名哦！


我们需要创建一个仓库来存储我们的博客内容，点击首页任意位置出现的`New repository`按钮创建仓库，Respository name中的`username`.github.io的`username`一定与前面的Owner 一致。

![创建仓库](http://upload-images.jianshu.io/upload_images/1787055-137e556b3f8107e3.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![需要保持username一致](http://upload-images.jianshu.io/upload_images/1787055-b664fcba6dbd2869.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

#### 2. 安装Hexo
> [Hexo](https://hexo.io/zh-cn/docs/index.html) 是一个快速、简洁且高效的博客框架。Hexo 使用 Markdown（或其他渲染引擎）解析文章，在几秒内，即可利用靓丽的主题生成静态网页。

###### 2.1 安装brew（如果已安装，请忽略）

```sh
$ /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```
###### 2.2 安装git

```sh
$ brew install git
```
###### 2.3 安装nodejs

```sh
# 使用brew安装nvm
$ brew install nvm

# vim ~/.bash_profile后增加下面这两行
export NVM_DIR="$HOME/.nvm"
source $(brew --prefix nvm)/nvm.sh

# .bash_profile立即生效
$ source ~/.bash_profile

# 使用nvm安装node.js
$ nvm install node
```

```sh
# 校验（建议重启终端后校验）
$ nvm --version
0.33.2
$ node -v
v8.1.2
$ npm -v
5.0.3
$ nvm list
->       v8.1.2
default -> node (-> v8.1.2)
node -> stable (-> v8.1.2) (default)
stable -> 8.1 (-> v8.1.2) (default)
iojs -> N/A (default)
lts/* -> lts/boron (-> N/A)
lts/argon -> v4.8.3 (-> N/A)
lts/boron -> v6.11.0 (-> N/A)
```

```
如果校验成功，可忽略此步骤！
如果校验失败，则有很大的可能是本地的node，nvm，npm版本出现问题。
可尝试一下方法解决：
1、卸载老版本的node
    如果是从brew安装的, 运行brew uninstall node
    删除~/目录下所有node和node_modules
    删除/usr/local/lib中的所有node和node_modules
    删除/usr/local/lib中的所有node和node_modules的文件夹
    在/usr/local/bin中,删除所有node的可执行文件(node和npm)
    
    手动删除文件，整理成脚本是这个样子:
    sudo rm -rf ~/.npm
    sudo rm -rf ~/node_modules
    sudo rm -rf ~/.node-gyp
    sudo rm /usr/local/bin/node
    sudo rm /usr/local/bin/npm
    sudo rm /usr/local/lib/dtrace/node.d

2、卸载老版本.nvm
    我之前是手动安装的nvm，nvm的目录结构比较简单，删除这三个就可以了
    # 删除后请确认删除干净了
    rm -rf ~/.nvm
    rm -rf ~/.npm
    rm -rf ~/.bower
    
    还需要删除下.bash_profile文件中的配置(用brew安装后还需要重新加上，但不太一样)
    export NVM_DIR="$HOME/.nvm"
    source $(brew --prefix nvm)/nvm.sh

3、清除干净后确认(重启终端后测试)
    "重启终端"后，挨个测试几个命令应该都是找不到，才算是正确的:
    nvm
    node
    npm
    
4、重新从 2.3安装nodejs 开始执行
```

###### 2.4 安装Hexo

```sh
$ npm install -g hexo --no-optional
# 安装hexo-deployer-git自动部署发布工具
$ npm install hexo-deployer-git --save
```

```sh
# 安装Hexo时，不添加--no-optional可能会报如下错误，但不影响使用，建议添加
{ [Error: Cannot find module './build/Release/DTraceProviderBindings'] code: 'MODULE_NOT_FOUND' }
{ [Error: Cannot find module './build/default/DTraceProviderBindings'] code: 'MODULE_NOT_FOUND' }
{ [Error: Cannot find module './build/Debug/DTraceProviderBindings'] code: 'MODULE_NOT_FOUND' }

# 如果添加--no-optional仍报上述错误的话，可以尝试下面的方法，重装 hexo-cli
$ npm uninstall hexo-cli -g
$ npm install hexo-cli -g

```

所有必须工具已经安装完成，下面我们就可以生成博客，上传至我们的Github 仓库了。

#### 3. 编写，发布
> 接下来我们需要用Hexo初始化一个博客，然后更改一些自定义的配置，或者加上自己喜欢的主题，写上第一篇文章，然后发布到自己的个人Github网站(username.github.io)。

###### 3.1 创建博客

```
# 执行成功后，会在当前目录下创建出一个名为 blog 的文件夹。
$ hexo init blog
```

###### 3.2 更改配置
1.主题安装：

```sh
# 为了使博客不太难看，我们需要安装一个主题，切换至刚刚生成的blog目录，安装主题
$ cd blog
$ git clone https://github.com/iissnan/hexo-theme-next themes/next
```
这里有[更多主题](https://hexo.io/themes/)供你选择。喵神的主题在[这里](https://github.com/monniya/hexo-theme-new-vno)。

2.基础配置:

打开文件位置blog/_config.yml修改几个键值对，下面把几个必须设置的列出来按需求修改，记得保存， 还有注意配置的键值之间一定要有空格。[更多设置](https://hexo.io/zh-cn/docs/configuration.html)

```
title: qczyl's club     //你博客的名字
author: qczyl           //你的名字
language: zh-Hans       //语言 中文
theme: next             //刚刚安装的主题名称
deploy:
  type: git             //使用Git 发布
  repo: https://github.com/qcyl/qcyl.github.io.git    // 刚创建的Github仓库
```
3.主题配置:

主题配置文件在blog/themes/next/_config.yml中修改，这里略过。[设置详情](http://theme-next.iissnan.com/getting-started.html#theme-settings)
    
###### 3.3 写文章
所有基础框架都已经创建完成，接下来可以开始写你的第一篇博客了。
在blog/source/_posts下创建你的第一个博客吧，
例如，创建一个名为FirstNight.md的文件，用Markdown大肆发挥吧，注意保存。

```
如：
---
title: First Night
---
> 我有一头**小毛驴**，可是我从来都不骑。
```

###### 3.4 测试

```sh
$ hexo s
```
测试服务启动，你可以在浏览器中输入[https://localhost:4000](https://localhost:4000) 访问了。

###### 3.5 发布

```sh
$ hexo clean && hexo g && hexo d
```
如果这是你的第一次，终端会让你输入Github 的邮箱和密码，正确输入后，骚等片刻，就会把你的博客上传至Github 了。以后在每次把博客写完后，执行一下这个命令就可以直接发布了，灰常苏胡。

#### 到这里，你的博客已经完成了，在浏览器中输入 http://qcyl.github.io 就能够访问了。

---

> 如果你还希望将博客绑定到自己的个人域名下，提升一下逼格，
> 那么请接着往下看，如果暂时不需要的话，以下的内容可暂时忽略。


#### 4.绑定个人域名

###### 4.1 购买域名

如果你还没有个人域名，可前往[万网](https://wanwang.aliyun.com/?utm_content=se_96657&gclid=Cj0KEQjwhMjKBRDjxb31j-aesI4BEiQA7ivN-AkOk2kYl2zH2OJBcrIlT1Zb67lF3zcsOg-tTn5UkjkaAsWb8P8HAQ)进行购买。

###### 4.2 创建 CNAME 文件
1. 创建 CNAME 文件（注意文件名大写，且没有扩展名）
2. 写入需要绑定的域名，例：blog.qczyl.club
3. 将 CNAME 文件放到blog/theme/next/source目录下
4. 执行$ hexo clean && hexo g && hexo d 发布到github

```
注: 1. 域名前不需要添加 http 这样的协议
    2. 如果需要绑定的域名为 ‘www.qczyl.club’,
    可省略www，直接写为 ‘qczyl.club’，
    Github Pages会自动将其重定向到 ‘www.qczyl.club’ 上
    3. CNAME文件需要放到当前使用主题的source目录下
```

###### 4.3 添加 CNAME 记录
登录阿里云管理控制台，选择云解析DNS，给当前域名新增一条CNAME记录。

![云解析DNS](http://upload-images.jianshu.io/upload_images/1787055-f14b3852417588e8.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![添加一条CNAME记录](http://upload-images.jianshu.io/upload_images/1787055-2e58e6931f9f94d0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

    注：1.如果你绑定的域名为www.***,则主机记录为www，我这里为blog
        2.记录值为你个人的github pages地址，即username.github.io

完成以上这些步骤后，登录到你的github仓库，查看GitHub Pages，显示为你绑定的域名，并且打了对勾，则绑定成功，然后就可在浏览器中输入你自己的域名访问了。

![进入仓库，选择settings](http://upload-images.jianshu.io/upload_images/1787055-43ce81f9820358fd.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![查看GitHub Pages](http://upload-images.jianshu.io/upload_images/1787055-24e60c8d9c33c7f3.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


### 参考文章：

1. [5分钟 搭建免费个人博客](http://www.jianshu.com/p/4eaddcbe4d12)
2. [Mac OSX下重装node.js](http://linyehui.me/2016/03/03/reinstall-nodejs-on-osx/)
3. [解决hexo神烦的DTraceProviderBindings MODULE_NOT_FOUND](https://kikoroc.com/2016/05/04/resolve-hexo-DTraceProviderBindings-MODULE-NOT-FOUND.html)
