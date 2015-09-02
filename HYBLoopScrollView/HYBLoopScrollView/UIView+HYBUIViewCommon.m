//
//  UIView+HYBUIViewCommon.m
//  HYBLoopScrollView
//
//  Created by huangyibiao on 15/9/2.
//  Copyright © 2015年 huangyibiao. All rights reserved.
//

#import "UIView+HYBUIViewCommon.h"

@implementation UIView (HYBUIViewCommon)

- (void)setHyb_origin:(CGPoint)hyb_origin {
  CGRect frame = self.frame;
  frame.origin = hyb_origin;
  self.frame = frame;
}

- (CGPoint)hyb_origin {
  return self.frame.origin;
}

- (void)setHyb_originX:(CGFloat)hyb_originX {
  self.hyb_origin = CGPointMake(hyb_originX, self.hyb_originY);
}

- (CGFloat)hyb_originX {
  return self.hyb_origin.x;
}

- (void)setHyb_originY:(CGFloat)hyb_originY {
  self.hyb_origin = CGPointMake(self.hyb_originX, hyb_originY);
}

- (CGFloat)hyb_originY {
  return self.hyb_origin.y;
}

- (void)setHyb_rightX:(CGFloat)hyb_rightX {
  CGRect frame = self.frame;
  frame.origin.x = hyb_rightX - frame.size.width;
  self.frame = frame;
}

- (CGFloat)hyb_rightX {
  return self.hyb_width + self.hyb_originX;
}

- (void)setHyb_width:(CGFloat)hyb_width {
  CGRect frame = self.frame;
  frame.size.width = hyb_width;
  self.frame = frame;
}

- (CGFloat)hyb_width {
  return self.frame.size.width;
}

- (void)setHyb_size:(CGSize)hyb_size {
  CGRect frame = self.frame;
  frame.size = hyb_size;
  self.frame = frame;
}

- (CGSize)hyb_size {
  return self.frame.size;
}

- (void)setHyb_height:(CGFloat)hyb_height {
  CGRect frame = self.frame;
  frame.size.height = hyb_height;
  self.frame = frame;
}

- (CGFloat)hyb_height {
  return self.frame.size.height;
}

- (void)setHyb_bottomY:(CGFloat)hyb_bottomY {
  CGRect frame = self.frame;
  frame.origin.y = hyb_bottomY - frame.size.height;
  self.frame = frame;
}

- (CGFloat)hyb_bottomY {
  return self.frame.size.height + self.frame.origin.y;
}

- (void)setHyb_centerX:(CGFloat)hyb_centerX {
  self.center = CGPointMake(hyb_centerX, self.center.y);
}

- (CGFloat)hyb_centerX {
  return self.center.x;
}

- (void)setHyb_centerY:(CGFloat)hyb_centerY {
  self.center = CGPointMake(self.center.x, hyb_centerY);
}

- (CGFloat)hyb_centerY {
  return self.center.y;
}

- (void)setHyb_corneradus:(CGFloat)hyb_corneradus {
  self.layer.cornerRadius = hyb_corneradus;
}

- (CGFloat)hyb_corneradus {
  return self.layer.cornerRadius;
}

- (void)setHyb_borderColor:(UIColor *)hyb_borderColor {
  self.layer.borderColor = hyb_borderColor.CGColor;
}

- (UIColor *)hyb_borderColor {
  return [UIColor colorWithCGColor:self.layer.borderColor];
}

- (void)setHyb_borderWidth:(CGFloat)hyb_borderWidth {
  self.layer.borderWidth = hyb_borderWidth;
}

- (CGFloat)hyb_borderWidth {
  return self.layer.borderWidth;
}

@end
