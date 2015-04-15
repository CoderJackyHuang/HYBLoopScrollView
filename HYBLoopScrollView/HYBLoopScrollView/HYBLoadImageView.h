//
//  HYBLoadImageView.h
//
//  Created by 黄仪标 on 14/11/17.
//  Copyright (c) 2014年 黄仪标. All rights reserved.
//

#import <UIKit/UIKit.h>

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
 *  @github https://github.com/632840804
 *  @blog   http://blog.csdn.net/woaifen3344
 *
 *  @note Make friends with me.
 *        Facebook: huangyibiao520@163.com (Jacky Huang)
 *        QQ:(632840804)
 *        Weixin:(huangyibiao520)
 *        Please tell me your real name when you send message to me.3Q.
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
 *  Get/Set the control's corneradus
 *  Default is 0.0
 */
@property (nonatomic, assign) CGFloat corneradus;

/**
 *  Get/Set the control's border color
 *  Default is [UIColor lightGrayColor]
 */
@property (nonatomic, strong) UIColor *borderColor;

/**
 *  Get/Set the control's border width
 *  Default is 0.0
 */
@property (nonatomic, assign) CGFloat borderWidth;

/**
 *  Get/Set the callback block when download the image finished.
 *
 *  @param image The image object from network or from disk.
 */
typedef void (^HYBImageBlock)(UIImage *image);
@property (nonatomic, copy) HYBImageBlock completion;

/**
 *  Get/Set the call back block when the image view is tapped.
 *  
 *  @note Only when property tapImageViewBlock is setted, will it add a tap gesture.
 *        When set it to be nil, the tap gesture will be removed automatically.
 *
 *  @param imageView The event receiver.
 */
typedef void (^HYBTapImageViewBlock)(HYBLoadImageView *imageView);
@property (nonatomic, copy) HYBTapImageViewBlock tapImageViewBlock;

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
@end
