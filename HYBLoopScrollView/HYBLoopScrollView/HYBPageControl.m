//
//  HYBPageControl.m
//  HYBLoopScrollView
//
//  Created by huangyibiao on 15/4/1.
//  Copyright (c) 2015年 huangyibiao. All rights reserved.
//

#import "HYBPageControl.h"

@implementation HYBPageControl

- (instancetype)init {
  if (self = [super init]) {
    self.defersCurrentPageDisplay = YES;
  }
  
  return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
CGPoint p =    [touch locationInView:self];
  
  CGFloat px = p.x;
  CGFloat pw = self.frame.size.width / self.numberOfPages;
  NSInteger index = px / pw;
  
  if (self.valueChangedBlock && index != self.currentPage) {
    self.valueChangedBlock(index);
  } else {
    [self updateCurrentPageDisplay];
  }
}

@end
