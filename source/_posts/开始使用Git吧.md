---

title: 开始使用Git吧

date: 2017-10-18 00:00:00

categories: 杂学

---

既然说``开始使用Git吧``，那Git相对于SVN来说肯定还是有一定的好处的。
大家可以看一下[评《GIT和SVN之间的五个基本区别》](https://my.oschina.net/u/1580062/blog/214850)这篇文章，虽然文章时间有点久远，但是我很认同里边的说法，特别是Git对分支和合并有更好的支持。

虽然评论区还是有很多使用SVN的用户不是很赞同他的观点，认为Git的权限问题是一个很大的问题，但是现在公司搭一个Gitlab就可以将权限问题完全搞定了。

### Git的基本使用
Git相对于SVN来说命令确实多了一些，大家可以通过[Git基础](https://git-scm.com/book/zh/v1/Git-%E5%9F%BA%E7%A1%80)来学习一下Git的常用命令。

但是个人推荐直接使用[Sourcetree](https://www.sourcetreeapp.com/)来进行日常的开发使用，简单方便可视化。当然命令还是要了解一下的，以防万一啊！

### Git远程仓库
了解了Git的简单命令，以及[Sourcetree](https://www.sourcetreeapp.com/)的使用，大家就可以``开始使用Git``了。

但是，只使用本地仓库的话，那就丧失了Git的真正意义。
这里介绍几款Git远程仓库：
1. [GItHub](https://github.com/)，相信这个大家都知道的，但是在``GItHub``上使用私有仓库是收费的
2. [码云](https://gitee.com/)，很屌的名字，支持私用仓库创建
3. [GitLab](https://about.gitlab.com/)，可搭建在自己的服务器上，适合公司使用，有完善的权限系统

### Git工作流程
当在团队开发中使用版本控制系统时，商定一个统一的工作流程是至关重要的。Git 的确可以在各个方面做很多事情，然而，如果在你的团队中还没有能形成一个特定有效的工作流程，那么混乱就将是不可避免的。

Git工作流程有各式各样的用法，但也正因此使得在实际工作中如何上手使用变得很头大。这里介绍几种公司最常用的Git工作流程：
1. [集中式工作流](http://blog.jobbole.com/76847/)，适合开发团队成员已经很熟悉SVN，无需去适应一个全新流程
2. [功能分支工作流](http://blog.jobbole.com/76857/)，以集中式工作流为基础，不同的是为各个新功能分配一个专门的分支来开发
3. [Gitflow工作流](http://blog.jobbole.com/76867/)，通过为功能开发、发布准备和维护分配独立的分支，让发布迭代过程更流畅。最早诞生、并得到广泛采用的一种工作流程，推荐的流程
4. [Forking工作流](http://blog.jobbole.com/76861/)，分布式工作流，充分利用了Git在分支和克隆上的优势。可以安全可靠地管理大团队的开发者（developer），并能接受不信任贡献者（contributor）的提交

个人推荐使用[Gitflow工作流](http://blog.jobbole.com/76867/)，而且[Sourcetree](https://www.sourcetreeapp.com/)也天然支持Gitflow，并把这个模型的各种操作通过菜单命令的形式提供了出来，大大减轻了使用人员的学习使用成本。

---

相信大家使用Git后，会渐渐的爱上他的！
