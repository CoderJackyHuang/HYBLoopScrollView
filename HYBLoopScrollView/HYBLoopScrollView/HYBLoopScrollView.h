//
//  HYBLoopScrollView.h
//  HYBLoopScrollView
//
//  Created by huangyibiao on 15/4/1.
//  Copyright (c) 2015年 huangyibiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYBPageControl.h"
#import "HYBLoadImageView.h"
#import "UIView+HYBUIViewCommon.h"

/**
 *  The alignment type of page control. Only has two types.
 *  That is: center and right.
 */
typedef NS_ENUM(NSInteger, HYBPageControlAlignment) {
  /**
   *  For the center type, only show the page control without any text
   */
  kPageControlAlignCenter = 1 << 1,
  /**
   *  For the align right type, will show the page control and show the ad text
   */
  kPageControlAlignRight  = 1 << 2
};

@class HYBLoopScrollView;

/**
 *  Call back method when an item was clicked at some time.
 *
 *  @param atIndex  The index of the clicked item in the loop scroll view
 */
typedef void (^HYBLoopScrollViewDidSelectItemBlock)(NSInteger atIndex);

/**
 *  Call back method when scroll to an item at index.
 *
 *  @param toIndex The index of page
 */
typedef void (^HYBLoopScrollViewDidScrollBlock)(NSInteger toIndex);

typedef NS_ENUM(NSUInteger, HYBFlowLayoutType) {
  kHYBFlowLayoutTypeDefault,
  kHYBFlowLayoutTypeScaleHorizontal
};

/**
 *  This is an really useful image loading control, you can use to load image to an
 *  UImageView control, with it, will be more convenience to globally download image
 *  asynchronously. Here there are some useful features, but haven't used. Don't delete
 *  them.
 *
 *  Contact me if you want some kind of animation, I will try my best to update.
 *
 *  @author huangyibiao
 *  @email  huangyibiao520@163.com
 *  @github https://github.com/CoderJackyHuang
 *  @blog   http://www.henishuo.com/ios-open-source-hybloopscrollview/
 *
 */
@interface HYBLoopScrollView : UIView

/**
 *  The holder image for the image view. Default is nil
 */
@property (nonatomic, strong) UIImage *placeholder;

/**
 *	@author 黄仪标
 *
 *	用于指定图片内容的模式，默认为UIViewContentModeScaleToFill。
 *  当shouldAutoClipImageToViewSize设置为YES后，设置内容填充模式没有作用
 */
@property (nonatomic, assign) UIViewContentMode imageContentMode;

/**
 *  Get the page control
 */
@property (nonatomic, strong, readonly) HYBPageControl *pageControl;

/**
 *  The alignment type of the page control.
 * 
 *  @note The default type is kPageControlAlignCenter
 */
@property (nonatomic, assign) HYBPageControlAlignment alignment;

/**
 *  The image urls.It can be absolute urls or main bundle image names, even a real UIImage object.
 */
@property (nonatomic, strong) NSArray *imageUrls;

/**
 *  Get/Set whether page control can handle value changed event.
 * 
 *  @note Set to YES, page control will change to relevant page when clicked.
 *        Set to NO, page control is not enabled.
 *        Default is YES.
 */
@property (nonatomic, assign) BOOL pageControlEnabled;

/**
 *  The ad titles. Only for the alignment kPageControlAlignRight type.
 *
 *  @note If alignment == kPageControlAlignRight, it should be not nil. 
 *        Otherwise it will be ignored whatever it is.
 */
@property (nonatomic, strong) NSArray *adTitles;

/**
 *	@author 黄仪标
 *
 *	是否自动将下载到的图片裁剪为UIImageView的size。默认为NO。
 *  若设置为YES，则在下载成功后只存储裁剪后的image
 */
@property (nonatomic, assign) BOOL shouldAutoClipImageToViewSize;

/**
 *  The only created method for creating an object.
 *
 *  @param frame     The frame for the loop scroll view
 *  @param imageUrls image urls or image names or a real image object, you can mix together.
 *
 *  @return The HYBLoopScrollView object.
 */
+ (instancetype)loopScrollViewWithFrame:(CGRect)frame
                              imageUrls:(NSArray *)imageUrls
                           timeInterval:(NSTimeInterval)timeInterval
                              didSelect:(HYBLoopScrollViewDidSelectItemBlock)didSelect
                              didScroll:(HYBLoopScrollViewDidScrollBlock)didScroll;

/**
 *  Pause the timer. Usually you need to pause the timer when the view disappear.
 */
- (void)pauseTimer;

/**
 *  Start the timer immediately. If you has pause the timer, you may need to start 
 *  the timer again when the view appear.
 */
- (void)startTimer;

/**
 *	@author 黄仪标
 *
 *	清理掉本地缓存
 */
- (void)clearImagesCache;

/**
 *	@author 黄仪标
 *
 *	获取图片缓存的占用的总大小（如果有需要计算缓存大小的需求时，可以调用这个API来获取）
 *
 *	@return 大小/bytes
 */
- (unsigned long long)imagesCacheSize;

@end
