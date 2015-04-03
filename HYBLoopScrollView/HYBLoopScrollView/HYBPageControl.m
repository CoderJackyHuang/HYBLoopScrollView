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
    // To Do:
    // set any default properties here
    [self addTarget:self
             action:@selector(onPageControlValueChanged:)
   forControlEvents:UIControlEventValueChanged];
  }
  
  return self;
}

- (void)onPageControlValueChanged:(HYBPageControl *)sender {
  if (self.valueChangedBlock) {
    self.valueChangedBlock(sender.currentPage);
  }
}

@end
