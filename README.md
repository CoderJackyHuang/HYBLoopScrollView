# HYBLoopScrollView
App中不可或缺的广告轮播图组件，现在开源出来了，希望对大家有帮助。

#效果图

![image](https://github.com/632840804/HYBLoopScrollView/blob/master/screen.gif)

#发生了什么变化
追加了常用的UIView扩展，简化了API的调用。
最重要的是，fix了朋友们反馈的bug，优化了大图加载时，快速滚动的效果

#Version2.1版本
解决了调用8.0api而没有判断处理的bug。

#Version2.2版本
解决了内存得不到释放的bug

#Version2.2.1版本
解决调用暂停定时器仍然不起作用的bug

#Version 2.2.2版本
解决用户反馈的bug

#Version 2.2.3版本
处理定时器从暂停状态进入重新开启状态时，会连续切换的bug。

#Version 2.2.4版本
处理图片数据传nil或者空数组时出现崩溃的bug

#Version 2.2.5版本

fix bugs

#Version 3.0.0

* 去掉AFNetworking依赖
* 增加自带图片下载及缓存功能
* 增加图片自动剪裁功能
* 简化API

#Version 3.1.0

很多朋友反馈说如果能支持横屏就更好了。本版本增加了这个需求。

* 增加横屏支持，且对于数据缓存增加模屏、竖屏图片裁剪缓存
* 增加图片缩放设置，外部可以通过imageContentMode设置
* 增加支持自动布局,内置masonry自动布局例子。支持横屏、竖屏




##安装

Use cocopods:

```
pod "HYBLoopScrollView", '~> 3.0.0'
```
or you can download the zip file and drag the HYBLoopScrollView folder to your project.

##如何使用

简单说明已经放到博客：[http://www.henishuo.com/ios-open-source-hybloopscrollview/](http://www.henishuo.com/ios-open-source-hybloopscrollview/)


##致谢
Thanks to github, I learn a lot from friends in github.<br/>
Thanks to AFNetworking author.<br/>
If there is any bug, contact me huangyibiao520@163.com.

##Knowledge
If your app adopts my lib, hope you can send me an email,just make me know who uses it.<br/>

Thanks in advance!!!

