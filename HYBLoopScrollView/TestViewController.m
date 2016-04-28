//
//  TestViewController.m
//  HYBLoopScrollView
//
//  Created by huangyibiao on 16/3/24.
//  Copyright © 2016年 huangyibiao. All rights reserved.
//

#import "TestViewController.h"
#import "HYBLoopScrollView.h"

@implementation TestViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor whiteColor];
  self.edgesForExtendedLayout = UIRectEdgeNone;
  
  // 这个图片会找不到，而显示默认图
  NSString *url = @"http://test.meirongzongjian.com/imageServer/user/3/42ccb9c75ccf5e910cd6f5aaf0cd1200.jpg";
  NSArray *images = @[@"http://s0.pimg.cn/group5/M00/5B/6D/wKgBfVaQf0KAMa2vAARnyn5qdf8958.jpg?imageMogr2/strip/thumbnail/1200%3E/quality/95",
                      @"http://7xrs9h.com1.z0.glb.clouddn.com/wp-content/uploads/2016/03/QQ20160322-0@2x.png",
                      @"h1.jpg",
                      [UIImage imageNamed:@"h2.jpg"],
                      @"http://s0.pimg.cn/group6/M00/45/84/wKgBjVZVjYCAEIM4AAKYJZIpvWo152.jpg?imageMogr2/strip/thumbnail/1200%3E/quality/95",
                      url,
                      @"http://7xrs9h.com1.z0.glb.clouddn.com/wp-content/uploads/2016/03/QQ20160322-5@2x-e1458635879420.png"
                      ];
  
  NSArray *titles = @[@"Thank you for your support!",
                      @"Contact me if any quetion.",
                      @"Email me huangyibiao520@163.com.",
                      @"Thank you again.",
                      @"博客：www.henishuo.com",
                      @"github: https://coderJackyHuang",
                      @"微博：weibo.com/huangyibiao520"
                      ];
  
  // 请使用weakSelf，不然内存得不到释放
  __weak __typeof(self) weakSelf = self;
  HYBLoopScrollView *loop = [HYBLoopScrollView loopScrollViewWithFrame:CGRectMake(0, 0, 320, 120) imageUrls:images timeInterval:5  didSelect:^(NSInteger atIndex) {
   [weakSelf dismissViewControllerAnimated:YES completion:NULL];
  } didScroll:^(NSInteger toIndex) {
    
  }];
  loop.shouldAutoClipImageToViewSize = NO;
  loop.placeholder = [UIImage imageNamed:@"default.png"];
  loop.alignment = kPageControlAlignRight;
  loop.adTitles = titles;
  [loop pauseTimer];
//  loop.imageContentMode = UIViewContentModeScaleToFill;
  [self.view addSubview:loop];
}

@end
