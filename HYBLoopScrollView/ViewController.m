//
//  ViewController.m
//  HYBLoopScrollView
//
//  Created by huangyibiao on 15/4/1.
//  Copyright (c) 2015年 huangyibiao. All rights reserved.
//

#import "ViewController.h"
#import "HYBLoopScrollView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
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
  [loop setImageUrls:images];
  loop.adTitles = titles;

  [self.view addSubview:loop];
  
  
  HYBLoopScrollView *loop1 = [HYBLoopScrollView loopScrollViewWithFrame:CGRectMake(0, loop.bottomY + 100, 320, 120) imageUrls:images];
  loop1.timeInterval = 1;
  loop1.didSelectItemBlock = ^(NSInteger atIndex) {
    NSLog(@"clicked item at index: %ld", atIndex);
  };
  loop1.didScrollBlock = ^(NSInteger atIndex) {
    NSLog(@"scroll to index: %ld", atIndex);
  };
  [self.view addSubview:loop1];

}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
