# HYBLoopScrollView
A strong and convenience control for ad loop scroll

First, thank you for gsdios, I learn some important 
thought from gsdios.His github is https://github.com/gsdios.

Author: huangyibiao 

Email: huangyibiao520@qq.com

github：https://github.com/632840804

CSDN Blog: http://blog.csdn.net/woaifen3344/

Any quetion? send me an email. Thank you in advance!

![image](https://github.com/632840804/HYBLoopScrollView/blob/master/screen.png)

##HOW TO INSTALL
Use cocopods:
```
platform :ios, "6.0"
pod "HYBLoopScrollView", '~> 1.2'
```
or you can download the zip file and drag the HYBLoopScrollView folder to your project.

##Features
For the property imageUrls, you can contain url strings, image names from main bundle and 
UIImage objects.</br>
When load image finish, it will show animated with fade in and out defaut.

##NOTE
In fact, I don't know how to add a dynamic image which can show the features of my code.
So if you really want to see the effect, fork, clone to desktop and run with Xcode or download
the zip file and run with Xcode.

It is easy to use, you can use it like below.It support three kind of objects in the imageUrls.
imageUrls can be mix with an UIImage object, a image name from main bundle, and an absolute url
string to download from network.

##HOW TO USE
```Objective-C
  NSString *url = @"http://test.meirongzongjian.com/imageServer/user/3/42ccb9c75ccf5e910cd6f5aaf0cd1200.jpg";
  NSArray *images = @[@"h1.jpg",
                      [UIImage imageNamed:@"h2.jpg"],
                      [UIImage imageNamed:@"h3.jpg"],
                      url
                      ];
  
  NSArray *titles = @[@"Thank you for your support!",
                      @"Contact me if any quetion.",
                      @"Email me huangyibiao520@163.com.",
                      @"Thank you again."
                      ];
  
  HYBLoopScrollView *loop = [HYBLoopScrollView loopScrollViewWithFrame:CGRectMake(0, 40, 320, 120) imageUrls:images];
  loop.timeInterval = 1;
  loop.placeholder = [UIImage imageNamed:@"h1.jpg"];
  loop.didSelectItemBlock = ^(NSInteger atIndex) {
    NSLog(@"clicked item at index: %ld", atIndex);
  };
  loop.didScrollBlock = ^(NSInteger atIndex) {
    NSLog(@"scroll to index: %ld", atIndex);
  };
  loop.alignment = kPageControlAlignRight;
  loop.adTitles = titles;

  [self.view addSubview:loop];
```

Or you can use like this:
```Objective-C
  HYBLoopScrollView *loop1 = [HYBLoopScrollView loopScrollViewWithFrame:CGRectMake(0, loop.bottomY + 100, 320, 120) imageUrls:images];
  loop1.timeInterval = 1;
  loop1.didSelectItemBlock = ^(NSInteger atIndex) {
    NSLog(@"clicked item at index: %ld", atIndex);
  };
  loop1.didScrollBlock = ^(NSInteger atIndex) {
    NSLog(@"scroll to index: %ld", atIndex);
  };
  [self.view addSubview:loop1];
```

Your can set a place holder image:
```
/**
 *  The holder image for the image view. Default is nil
 */
@property (nonatomic, strong) UIImage *placeholder;
```

I support auto scroll with timer, so you also specify a time interval:
```
/**
 *  The interval time for the timer call. It means that you can
 *  specify a real time for the interval of ad.
 *
 *  @note The default time interval is 5.0
 */
@property (nonatomic, assign) NSTimeInterval timeInterval;
```

You also can easily pause and start action to control timer:
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

##Thanks
Thanks to github, I learn a lot from friends in github.<br/>
Thanks to AFNetworking author.<br/>
If there is any bug, contact me huangyibiao520@163.com.


##Knowledge
If your app adopts my lib, hope you can send me an email,just make me know who uses it.<br/>

Thanks in advance!!!

