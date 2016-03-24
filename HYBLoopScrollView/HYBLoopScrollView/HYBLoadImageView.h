//
//  HYBLoadImageView.h
//
//  Created by 黄仪标 on 14/11/17.
//  Copyright (c) 2014年 黄仪标. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HYBLoadImageView;

typedef void (^HYBTapImageViewBlock)(HYBLoadImageView *imageView);
typedef void (^HYBImageBlock)(UIImage *image);

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
@interface HYBLoadImageView : UIImageView

/**
 *  Set to YES and it will be animated when image is loaded from network.
 *  If it it loaded from disk, it will be ignored.
 *  Default is YES.
 */
@property (nonatomic, assign) BOOL animated;

/**
 *  Set the control to be circle.
 *  Default is NO.
 */
@property (nonatomic, assign) BOOL isCircle;

/**
 *  Get/Set the callback block when download the image finished.
 *
 *  @param image The image object from network or from disk.
 */
@property (nonatomic, copy) HYBImageBlock completion;

/**
 *  Get/Set the call back block when the image view is tapped.
 *  
 *  @note Only when property tapImageViewBlock is setted, will it add a tap gesture.
 *        When set it to be nil, the tap gesture will be removed automatically.
 *
 *  @param imageView The event receiver.
 */
@property (nonatomic, copy) HYBTapImageViewBlock tapImageViewBlock;

/**
 *	@author 黄仪标
 *
 *	指定URL下载图片失败时，重试的次数，默认为2次
 */
@property (nonatomic, assign) NSUInteger attemptToReloadTimesForFailedURL;

/**
 *	@author 黄仪标
 *
 *	是否自动将下载到的图片裁剪为UIImageView的size。默认为NO。
 *  若设置为YES，则在下载成功后只存储裁剪后的image
 */
@property (nonatomic, assign) BOOL shouldAutoClipImageToViewSize;

/**
 *  Use these methods to download image async.
 */
- (void)setImageWithURLString:(NSString *)url placeholderImage:(NSString *)placeholderImage;
- (void)setImageWithURLString:(NSString *)url placeholder:(UIImage *)placeholderImage;
- (void)setImageWithURLString:(NSString *)url
                  placeholder:(UIImage *)placeholderImage
                   completion:(void (^)(UIImage *image))completion;
- (void)setImageWithURLString:(NSString *)url
             placeholderImage:(NSString *)placeholderImage
                   completion:(void (^)(UIImage *image))completion;

- (void)cancelRequest;

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

@end
