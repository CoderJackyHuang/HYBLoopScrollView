#概述

**开源项目名称**：HYBLoopScrollView  
**开源项目目标**：一键式集成轮播组件
**当前版本**：3.2.1

App中不可或缺的广告轮播图组件，现在开源出来了，希望对大家有帮助！使用过程中有出现任何bug，都会很快帮助解决！

![image](http://www.henishuo.com/wp-content/uploads/2016/03/screen.gif)


#Version3.2.1

* 更新至IPV6 only支持！

#有什么特性

用一个第三方库，首先需要了解这个三方库有什么特性，为什么值得使用它！看看下面的说明紧！

##特性1：无缝无限循环滚动

我相信每一个想要自己写这个无限滚动显示广告图片的开发者，都会遇到这么个问题：滚动到最后一张后，再切换到第一张时怎么动画效果这么难看呢？根本就是到末尾后就直接切换到第一张，因此效果很不友好。

`HYBLoopScrollView`就很好地解决了这个问题。这个库使用了`UICollectionView`的特性，很巧妙地实现了这个无限滚动的效果。

##特性2：直接使用block版本API

原来我也想使用别人的开源库，但是使用起来很困难，一大堆的`API`，维护起来太麻烦。因此，才决定自己写一套库来解决这个麻烦。

这里提供了唯一地创建控件的方法：

```
+ (instancetype)loopScrollViewWithFrame:(CGRect)frame
                              imageUrls:(NSArray *)imageUrls
                           timeInterval:(NSTimeInterval)timeInterval
                              didSelect:(HYBLoopScrollViewDidSelectItemBlock)didSelect
                              didScroll:(HYBLoopScrollViewDidScrollBlock)didScroll;
```

看到连同`didSelect`参数和`didScroll`参数了吗？前者就是点击某个广告图片时的回调`block`，而后者就是滚动到某个广告时的回调，是不是很简单？

###支持定时器的控制

另外，还封装了定时器的`api`，可方便地暂停或继续开启：

```
/**
 *  Pause the timer. Usually you need to pause the timer when the view disappear.
 */
- (void)pauseTimer;

/**
 *  Start the timer immediately. If you has pause the timer, you may need to start 
 *  the timer again when the view appear.
 */
- (void)startTimer;
```

###特性3：提供图片切换的淡入淡出效果

HYBLoadImageView类是继承于UIImageView，提供了下载图片及缓存的功能，包括获取缓存的大小、清空缓存、支持自动设置显示成圆形头像。

####提供了公开的裁剪图片的API：

```
/**
 *	@author 黄仪标
 *
 *	此处公开此API，是方便大家可以在别的地方使用。等比例剪裁图片大小到指定的size
 *
 *	@param image 剪裁前的图片
 *	@param size	最终图片大小
 *  @param isScaleToMax 是取最大比例还是最小比例，YES表示取最大比例
 *
 *	@return 裁剪后的图片
 */
+ (UIImage *)clipImage:(UIImage *)image toSize:(CGSize)size isScaleToMax:(BOOL)isScaleToMax;
```

####支持自动处理图片大小并缓存

如果希望将下载的图片等比例缩放为imageView的大小，则可以设置为YES：

```
/**
 *	@author 黄仪标
 *
 *	是否自动将下载到的图片裁剪为UIImageView的size。默认为NO。
 *  若设置为YES，则在下载成功后只存储裁剪后的image
 */
@property (nonatomic, assign) BOOL shouldAutoClipImageToViewSize;
```

####支持下载失败重试

对于一个链接，如果下载失败了，下一次再请求时，可以再去下载一次。默认为重试2次，如果超过2次，则不会再去下载：

```
/**
 *	@author 黄仪标
 *
 *	指定URL下载图片失败时，重试的次数，默认为2次
 */
@property (nonatomic, assign) NSUInteger attemptToReloadTimesForFailedURL;
```

##特性4：自带下载、缓存

内部自带了图片下载功能及图片缓存功能，并且在收到内存警告时，也会清理掉图片缓存。

##特性5：支持cocoapods

说到第三方库，怎么能少了对`cocoapods`的支持呢？

当前维护的版本已经到了`version 3.0.0`，可通过下面的方法添加到`Podfile`中：

```
pod "HYBLoopScrollView", '~> 3.0.0'
```

#版本变化

前一版本是2.2.5，依赖着AFNetworking这个第三方库，为了让本组件更加通用，在3.0.0版本去掉了第三方的依赖。而且在API上更加简化了，去掉了一些不必要的API。使用起来更简单，有多简单，请看下面：

```
HYBLoopScrollView *loop = [HYBLoopScrollView loopScrollViewWithFrame:CGRectMake(0, 40, 320, 120) imageUrls:images timeInterval:5 didSelect:^(NSInteger atIndex) {
    
} didScroll:^(NSInteger toIndex) {
    
}];

loop.shouldAutoClipImageToViewSize = YES;
loop.placeholder = [UIImage imageNamed:@"default.png"];
  
loop.alignment = kPageControlAlignRight;
loop.adTitles = titles;

[self.view addSubview:loop];
```

另外，3.0.0版本在点击轮播图和切换轮播图时不会将图片控制传回来了。只是返回图片位置。

#注意事项

有朋友说什么内存得不到释放的，请注意使用。看下面在block回调处，对Self是使用弱引用的，不然内存是得不到释放的。这是基本的内存循环引用问题，请大家注意：

```
// 请使用weakSelf，不然内存得不到释放
__weak __typeof(self) weakSelf = self;
HYBLoopScrollView *loop = [HYBLoopScrollView loopScrollViewWithFrame:CGRectMake(0, 40, 320, 120) imageUrls:images timeInterval:5 didSelect:^(NSInteger atIndex) {
	[weakSelf dismissViewControllerAnimated:YES completion:NULL];
} didScroll:^(NSInteger toIndex) {
    
}];
```

如果下载得到的图片的宽、高比与imageview的宽、高比不同，请不要设置下面的属性，或者设置为NO（默认就是NO）：

```
loop.shouldAutoClipImageToViewSize = NO;
```

如果在调试过程中，设置了YES，发现图片未铺满整个imageview，就去掉上面设置的属性，或者设置为NO。然后记得调用清空缓存才能看到效果：

```
[loop clearImagesCache];
```

#致谢


该开源库至今已经得到不少朋友的邮件反馈，才有了今天的版本。感谢所有支持我的朋友！！！

#源代码


如果不想使用`cocoapods`来安装，可以到github下载源代码，直接将`HYBLoopScrollView`文件夹拖到工程，不需要做任何配置！！！

下载地址：[HYBLoopScrollView](https://github.com/CoderJackyHuang/HYBLoopScrollView)

###喜欢就给个Star吧！

#版本历史

* 3.2.1
  - 更新至IPV6 only支持！

* 3.2.0
  - 由于有些小伙伴不太会用，导致图片不占满，所以此版本修改图片默认缩放模式为填充满
  - 增加page control小圆点大小可自由调整设置的功能
  - Demo中增加有导航条时，增加高度没有占满时的设置

* 3.1.3
  - 优化内存，采用用完即释放的方式加载缓存图片，可降低内存的使用！
  - 去掉内存缓存，当同一个界面使用很多个轮播控件时，就不会内存暴涨

* 3.1.2
  - 处理page control 点击后跳转不正常的问题

* 3.1.1
  - fix timer bug, use core foundation timer add/remove from run loop

* 3.1.0
  - 支持横屏、竖屏
  - 支持autolayout
  - 支持外部设置图片缩放参数contentMode
  - 分别缓存横屏、竖屏图片大小
* 3.0.0
  - 去掉AFNetworking依赖
  - 增加自带图片下载及缓存功能
  - 增加图片自动剪裁功能
  - 简化API

#License

**MIT LICENSE**
