---

title: GitLab搭建及汉化

categories: 杂学

---

### 前言
[上一篇文章](http://blog.qczyl.club/2017/10/18/%E5%BC%80%E5%A7%8B%E4%BD%BF%E7%94%A8Git%E5%90%A7/)简单介绍了Git的优点以及使用。这一篇就来介绍一下GitLab的搭建。

---

作为公司的话，肯定不希望自己的代码放在别人的网站上，所以搭建一个自己的Git仓库就显得十分必要了（当然，如果你的公司不在意的话，那也是没有问题的）。[GitLab](https://about.gitlab.com/)就是一款可以搭建在自己服务器上的Git仓库。

而且GitLab的搭建非常简单，只需三四步的操作即可。

1. 首先，需要一台服务器，这是最基本的。
	* 但是有几点需要注意的：
	* GitLab官网上强烈推荐承载 GitLab 运行的服务器 至少分配4GB的内存 给 GitLab 。
	* 推荐使用以下几种操作系统的服务器，可以使用Omnibus包安装方法，操作简单。![](http://ocga9x543.bkt.clouddn.com/WX20171101-141806.png)
	
2. 打开[GitLab](https://about.gitlab.com/installation/)或[GitLab中文网](https://www.gitlab.cc/installation/)，选择对应的操作系统，按照提示进行安装。推荐使用``Omnibus包安装方法``进行安装！
	* 这里也有一些注意点：
	* 选择对应的操作系统后，会有两种版本的安装方法。
	* ``Community Edition``: 社区版（免费）
	* ``Enterprise Edition``: 企业版（收费）
	* 但是这里推荐安装``企业版``的。``企业版``未付费的话，和``社区版``功能是一样的，付费后可直接使用``企业版``的功能。而``社区版``要升级为``企业版``的话需要重新部署。
	
3. 配置SMTP
	* 进入``/etc/gitlab/gitlab.rb``文件，将以下配置的注释取消并修改
	
	```
	gitlab_rails['smtp_enable'] = true
	gitlab_rails['smtp_address'] = "smtp.server"
	gitlab_rails['smtp_port'] = 465
	gitlab_rails['smtp_user_name'] = "smtp user"
	gitlab_rails['smtp_password'] = "smtp password"
	gitlab_rails['smtp_domain'] = "example.com"
	gitlab_rails['smtp_authentication'] = "login"
	gitlab_rails['smtp_enable_starttls_auto'] = true
	gitlab_rails['smtp_openssl_verify_mode'] = 'peer'
	
	# 如果你使用的SMTP服务是默认的 'From:gitlab@localhost'
	# 你可以修改这里的 'From' 的值。
	gitlab_rails['gitlab_email_from'] = 'gitlab@example.com'
	gitlab_rails['gitlab_email_reply_to'] = 'noreply@example.com'
	
	```
	
	* 注：上面只是一个例子，具体的SMTP配置还需要自己根据实际情况修改（修改完配置后记得执行``sudo gitlab-ctl reconfigure``使配置生效）
	* 常用的SMTP配置示例可以去[这里](https://docs.gitlab.com.cn/omnibus/settings/smtp.html)查看。
	* 配置完成后可以用Rails控制台验证邮件是否能发送成功。 在GitLab服务器上，执行``gitlab-rails console``进入控制台。 然后在控制台提示符后输入下面的命令 发送一封测试邮件：
	
	```
	irb(main):003:0> Notify.test_email('destination_email@address.com', 'Message Subject', 'Message Body').deliver_now
# 示例
Notify.test_email('收件人邮箱', '邮件标题', '邮件正文').deliver_now
	```
	
如果你的测试邮件发送成功了的话，那么恭喜你，GitLab已经搭建完成了，可以尽情的使用了。

---

下面要介绍的就是GitLab的汉化，个人感觉汉化的也不是很完整，导致部分页面是中文英文混杂着的，当然，大部分已经汉化了。

首先确认版本：

```
sudo cat /opt/gitlab/embedded/service/gitlab-rails/VERSION
```

 v7 ~ v8.8版本clone以下仓库到本地：
 
```
git clone https://gitlab.com/larryli/gitlab.git
```

 v8.9以后版本clone以下仓库到本地：
  
```
git clone https://gitlab.com/xhang/gitlab.git
```
 
 clone仓库成功后，比较汉化分支和原分支，导出 patch 用的 diff 文件：
 
```
// ${gitlab_version}替换为你上面确定的版本
git diff v${gitlab_version} v${gitlab_version}-zh > ../${gitlab_version}-zh.diff
```
 
执行完毕后将生成当前版本的补丁文件，如``9.0.0-zh.diff``

导入汉化补丁：

```
# 停止 gitlab
sudo gitlab-ctl stop
sudo patch -d /opt/gitlab/embedded/service/gitlab-rails -p1 < 9.0.0-zh.diff
```

确定没有 .rej 文件，重启 GitLab 即可。

```
sudo gitlab-ctl start
```
