//
//  HYBPageControl.h
//  HYBLoopScrollView
//
//  Created by huangyibiao on 15/4/1.
//  Copyright (c) 2015年 huangyibiao. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  If you want to design a very beautiful page control, you can change it.
 *  Or you can send your require to my email, and I will try my best to add
 *  what you want.
 *
 *  Contact me if you want some kind of animation, I will try my best to update.
 *
 *  @author huangyibiao
 *  @email  huangyibiao520@163.com
 *  @github https://github.com/CoderJackyHuang
 *  @blog   http://www.henishuo.com/ios-open-source-hybloopscrollview/
 *
 */@interface HYBPageControl : UIPageControl

/**
 *  The call back when click a page control to switch to another page.
 *
 *  @param clickAtIndex The index clicked
 */
typedef void (^HYBPageControlValueChangedBlock)(NSInteger clickAtIndex);

// 若>0，则重写小圆点的大小
@property (nonatomic, assign) CGFloat size;

/**
 *  It is not required. If you don't want to handle it, just ignore.
 */
@property (nonatomic, copy) HYBPageControlValueChangedBlock valueChangedBlock;

@end
