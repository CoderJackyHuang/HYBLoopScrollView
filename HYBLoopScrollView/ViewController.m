//
//  ViewController.m
//  HYBLoopScrollView
//
//  Created by huangyibiao on 15/4/1.
//  Copyright (c) 2015年 huangyibiao. All rights reserved.
//

#import "ViewController.h"
#import "HYBLoopScrollView.h"
#import "TestViewController.h"
#import "Masonry.h"

@interface ViewController ()

@property (nonatomic, weak) HYBLoopScrollView *loop;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor lightGrayColor];
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
  
  HYBLoopScrollView *loop = [HYBLoopScrollView loopScrollViewWithFrame:CGRectMake(0, 40, 320, 120) imageUrls:images timeInterval:5 didSelect:^(NSInteger atIndex) {
    
  } didScroll:^(NSInteger toIndex) {
    
  }];

  loop.shouldAutoClipImageToViewSize = NO;
  loop.placeholder = [UIImage imageNamed:@"default.png"];
  
  loop.alignment = kPageControlAlignRight;
  loop.adTitles = titles;

  [self.view addSubview:loop];
[loop mas_makeConstraints:^(MASConstraintMaker *make) {
  make.left.right.mas_equalTo(0);
  make.height.mas_equalTo(120);
  make.top.mas_equalTo(0);
}];
  self.loop = loop;
  
  // 不希望显示pagecontrol？
//  loop.pageControl.hidden = YES;
  // 或者直接
//  [loop.pageControl removeFromSuperview];
  
  // 默认的是UIViewContentModeScaleAspectFit
//  loop.imageContentMode = UIViewContentModeScaleToFill;
  loop.imageContentMode = UIViewContentModeScaleAspectFill;
  
  NSLog(@"size: %llu", [loop imagesCacheSize]);
  [loop clearImagesCache];
   NSLog(@"size: %llu", [loop imagesCacheSize]); 

  HYBLoadImageView *imageView = [[HYBLoadImageView alloc] init];
  imageView.frame = CGRectMake(20, 200, 100, 100);
  imageView.isCircle = YES;
  imageView.hyb_borderColor = [UIColor redColor];
  imageView.hyb_borderWidth = 1;
  [self.view addSubview:imageView];
  
  [imageView setImageWithURLString:nil placeholderImage:@"h2.jpg"];
  imageView.userInteractionEnabled = YES;
  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)];
  [imageView addGestureRecognizer:tap];
  
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [self.loop startTimer];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  
  [self.loop pauseTimer];
}

- (void)onTap {
// 测试内存是否得到释放
  TestViewController *vc = [[TestViewController alloc] init];
  [self presentViewController:vc animated:YES completion:NULL];
}


@end
