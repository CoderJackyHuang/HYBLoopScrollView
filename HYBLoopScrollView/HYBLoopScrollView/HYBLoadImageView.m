//
//  HYBLoadImageView.m
//  CoreImageFaceDectection
//
//  Created by 黄仪标 on 14/11/17.
//  Copyright (c) 2014年 黄仪标. All rights reserved.
//

#import "UIView+HYBUIViewCommon.h"
#import "HYBLoadImageView.h"
#import "HYBLoopScrollView.h"
#import <objc/runtime.h>
#import <CommonCrypto/CommonDigest.h>

// 内部调试用
//#define kDebugLog

typedef void (^HYBDownLoadDataCallBack)(NSData *data, NSError *error);
typedef void (^HYBDownloadProgressBlock)(unsigned long long total, unsigned long long current);

/**
 *	图片下载器，没有直接使用NSURLSession之类的，是因为希望这套库可以支持iOS6
 */
@interface HYBImageDownloader : NSObject<NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDownloadTask *task;

@property (nonatomic, assign) unsigned long long totalLength;
@property (nonatomic, assign) unsigned long long currentLength;

@property (nonatomic, copy) HYBDownloadProgressBlock progressBlock;
@property (nonatomic, copy) HYBDownLoadDataCallBack callbackOnFinished;

- (void)startDownloadImageWithUrl:(NSString *)url
                         progress:(HYBDownloadProgressBlock)progress
                         finished:(HYBDownLoadDataCallBack)finished;

@end

@implementation HYBImageDownloader

- (void)startDownloadImageWithUrl:(NSString *)url
                         progress:(HYBDownloadProgressBlock)progress
                         finished:(HYBDownLoadDataCallBack)finished {
  self.progressBlock = progress;
  self.callbackOnFinished = finished;
  
  if ([NSURL URLWithString:url] == nil) {
    if (finished) {
      finished(nil, [NSError errorWithDomain:@"henishuo.com"
                                        code:101
                                    userInfo:@{@"errorMessage": @"URL不正确"}]);
    }
    return;
  }
  
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                         cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                     timeoutInterval:60];
  [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
  NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSOperationQueue *queue = [[NSOperationQueue alloc]init];
  self.session = [NSURLSession sessionWithConfiguration:config
                                               delegate:self
                                          delegateQueue:queue];
  NSURLSessionDownloadTask *task = [self.session downloadTaskWithRequest:request];
  [task resume];
  self.task = task;
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
  NSData *data = [NSData dataWithContentsOfURL:location];
  
  if (self.progressBlock) {
    self.progressBlock(self.totalLength, self.currentLength);
  }
  
  if (self.callbackOnFinished) {
    self.callbackOnFinished(data, nil);
    
    // 防止重复调用
    self.callbackOnFinished = nil;
  }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
  self.currentLength = totalBytesWritten;
  self.totalLength = totalBytesExpectedToWrite;
  
  if (self.progressBlock) {
    self.progressBlock(self.totalLength, self.currentLength);
  }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
  if ([error code] != NSURLErrorCancelled) {
    if (self.callbackOnFinished) {
      self.callbackOnFinished(nil, error);
    }
    
    self.callbackOnFinished = nil;
  }
}

@end

@interface NSString (md5)

+ (NSString *)hyb_md5:(NSString *)string;
+ (NSString *)hyb_cachePath;
+ (NSString *)hyb_keyForRequest:(NSURLRequest *)request;

@end

@implementation NSString (md5)

+ (NSString *)hyb_keyForRequest:(NSURLRequest *)request {
  BOOL portait = NO;
  if (UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation])) {
    portait = YES;
  }
  
  return [NSString stringWithFormat:@"%@%@",
          request.URL.absoluteString,
          portait ? @"portait" : @"lanscape"];
}

+ (NSString *)hyb_cachePath {
  return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/HYBLoopScollViewImages"];
}

+ (NSString *)hyb_md5:(NSString *)string {
  if (string == nil || [string length] == 0) {
    return nil;
  }
  
  unsigned char digest[CC_MD5_DIGEST_LENGTH], i;
  CC_MD5([string UTF8String], (int)[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding], digest);
  NSMutableString *ms = [NSMutableString string];
  
  for (i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
    [ms appendFormat:@"%02x", (int)(digest[i])];
  }
  
  return [ms copy];
}

@end

@interface UIApplication (HYBCacheImage)

@property (nonatomic, strong, readonly) NSMutableDictionary *hyb_cacheFaileTimes;

- (UIImage *)hyb_cacheImageForRequest:(NSURLRequest *)request;
- (void)hyb_cacheImage:(UIImage *)image forRequest:(NSURLRequest *)request;
- (void)hyb_cacheFailRequest:(NSURLRequest *)request;
- (NSUInteger)hyb_failTimesForRequest:(NSURLRequest *)request;

@end

static char *s_hyb_cacheFaileTimesKeys = "hyb_cacheFaileTimesKeys";

@implementation UIApplication (HYBCacheImage)

- (NSMutableDictionary *)hyb_cacheFaileTimes {
  NSMutableDictionary *dict = objc_getAssociatedObject(self, s_hyb_cacheFaileTimesKeys);
  
  if (!dict) {
    dict = [[NSMutableDictionary alloc] init];
    objc_setAssociatedObject(self, s_hyb_cacheFaileTimesKeys, dict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
  
  return dict;
}

- (void)hyb_clearCache {
  [self.hyb_cacheFaileTimes removeAllObjects];
  
  objc_setAssociatedObject(self, s_hyb_cacheFaileTimesKeys, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)hyb_clearDiskCaches {
  NSString *directoryPath = [NSString hyb_cachePath];
  
  if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:nil]) {
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:directoryPath error:&error];
    
#ifdef kDebugLog
    if (error) {
      NSLog(@"clear caches error: %@", error);
    } else {
      NSLog(@"clear caches ok");
    }
#endif
  }
  
  [self hyb_clearCache];
}

- (UIImage *)hyb_cacheImageForRequest:(NSURLRequest *)request {
  if (request) {
    NSString *directoryPath = [NSString hyb_cachePath];
    NSString *path = [NSString stringWithFormat:@"%@/%@",
                      directoryPath,
                      [NSString hyb_md5:[NSString hyb_keyForRequest:request]]];
    return [UIImage imageWithContentsOfFile:path];
  }
  
  return nil;
}

- (NSUInteger)hyb_failTimesForRequest:(NSURLRequest *)request {
  NSNumber *faileTimes = [self.hyb_cacheFaileTimes objectForKey:[NSString hyb_md5:[NSString hyb_keyForRequest:request]]];
  
  if (faileTimes && [faileTimes respondsToSelector:@selector(integerValue)]) {
    return faileTimes.integerValue;
  }
  
  return 0;
}

- (void)hyb_cacheFailRequest:(NSURLRequest *)request {
  NSNumber *faileTimes = [self.hyb_cacheFaileTimes objectForKey:[NSString hyb_md5:[NSString hyb_keyForRequest:request]]];
  NSUInteger times = 0;
  if (faileTimes && [faileTimes respondsToSelector:@selector(integerValue)]) {
    times = [faileTimes integerValue];
  }
  
  times++;
  
  [self.hyb_cacheFaileTimes setObject:@(times) forKey:[NSString hyb_md5:[NSString hyb_keyForRequest:request]]];
}

- (void)hyb_cacheImage:(UIImage *)image forRequest:(NSURLRequest *)request {
  if (image == nil || request == nil) {
    return;
  }
  
  NSString *directoryPath = [NSString hyb_cachePath];
  
  if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:nil]) {
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    if (error) {
#ifdef kDebugLog
      NSLog(@"create cache dir error: %@", error);
#endif
      return;
    }
  }
  
  NSString *path = [NSString stringWithFormat:@"%@/%@",
                    directoryPath,
                    [NSString hyb_md5:[NSString hyb_keyForRequest:request]]];
  NSData *data = UIImagePNGRepresentation(image);
  if (data) {
    BOOL isOk = [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
    
    if (isOk) {
#ifdef kDebugLog
      NSLog(@"cache file ok for request: %@", [NSString hyb_md5:[NSString hyb_keyForRequest:request]]);
#endif
    } else {
#ifdef kDebugLog
      NSLog(@"cache file error for request: %@", [NSString hyb_md5:[NSString hyb_keyForRequest:request]]);
#endif
    }
  }
}

@end

#define kAnimationDuration 1.0

@interface HYBLoadImageView () {
@private
  BOOL                     _isAnimated;
  UITapGestureRecognizer   *_tap;
  __weak HYBImageDownloader *_imageDownloader;
}

@end

@implementation HYBLoadImageView

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self configureLayout];
  }
  return self;
}

- (instancetype)init {
  return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithImage:(UIImage *)image {
  if (self = [super initWithImage:image]) {
    [self configureLayout];
  }
  return self;
}

- (void)configureLayout {
  self.contentMode = UIViewContentModeScaleToFill;
  self.animated = YES;
  self.hyb_borderColor = [UIColor lightGrayColor];
  self.hyb_borderWidth = 0.0;
  self.hyb_corneradus = 0.0;
  self.isCircle = NO;
  
  self.attemptToReloadTimesForFailedURL = 2;
  self.shouldAutoClipImageToViewSize = NO;
}

- (void)setImage:(UIImage *)image isFromCache:(BOOL)isFromCache {
  self.image = image;
  
  if (!isFromCache && _isAnimated) {
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.65f];
    [animation setType:kCATransitionFade];
    animation.removedOnCompletion = YES;
    [self.layer addAnimation:animation forKey:@"transition"];
  }
}

- (void)setAnimated:(BOOL)animated {
  _isAnimated = animated;
  return;
}

- (BOOL)animated {
  return _isAnimated;
}

- (void)setIsCircle:(BOOL)isCircle {
  _isCircle = isCircle;
  
  if (_isCircle) {
    CGFloat w = MIN(self.hyb_width, self.hyb_height);
    self.hyb_size = CGSizeMake(w, w);
    self.hyb_corneradus = w / 2;
    self.clipsToBounds = YES;
  } else {
    self.clipsToBounds = NO;
  }
}

- (void)setTapImageViewBlock:(HYBTapImageViewBlock)tapImageViewBlock {
  if (_tapImageViewBlock != tapImageViewBlock) {
    _tapImageViewBlock = [tapImageViewBlock copy];
  }
  
  if (_tapImageViewBlock == nil) {
    if (_tap != nil) {
      [self removeGestureRecognizer:_tap];
      self.userInteractionEnabled = NO;
    }
  } else {
    if (_tap == nil) {
      _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
      [self addGestureRecognizer:_tap];
      self.userInteractionEnabled = YES;
    }
  }
}

- (void)onTap:(UITapGestureRecognizer *)tap {
  if (self.tapImageViewBlock) {
    self.tapImageViewBlock((HYBLoadImageView *)tap.view);
  }
}

- (void)setImageWithURLString:(NSString *)url
             placeholderImage:(NSString *)placeholderImage {
  return [self setImageWithURLString:url placeholderImage:placeholderImage completion:nil];
}

- (void)setImageWithURLString:(NSString *)url placeholder:(UIImage *)placeholderImage {
  return [self setImageWithURLString:url placeholder:placeholderImage completion:nil];
}

- (void)setImageWithURLString:(NSString *)url
                  placeholder:(UIImage *)placeholderImage
                   completion:(void (^)(UIImage *image))completion {
  [self.layer removeAllAnimations];
  self.completion = completion;
  
  
  if (url == nil
      || [url isKindOfClass:[NSNull class]]
      || (![url hasPrefix:@"http://"] && ![url hasPrefix:@"https://"])) {
    [self setImage:placeholderImage isFromCache:YES];
    
    if (completion) {
      self.completion(self.image);
    }
    return;
  }
  
  NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
  [self downloadWithReqeust:request holder:placeholderImage];
}

- (void)downloadWithReqeust:(NSURLRequest *)theRequest holder:(UIImage *)holder {
  UIImage *cachedImage = [[UIApplication sharedApplication] hyb_cacheImageForRequest:theRequest];
  
  if (cachedImage) {
    [self setImage:cachedImage isFromCache:YES];
    
    if (self.completion) {
      self.completion(cachedImage);
    }
    return;
  }
  
  [self setImage:holder isFromCache:YES];
  
  if ([[UIApplication sharedApplication] hyb_failTimesForRequest:theRequest] >= self.attemptToReloadTimesForFailedURL) {
    return;
  }
  
  [self cancelRequest];
  _imageDownloader = nil;
  
  __weak __typeof(self) weakSelf = self;
  
  HYBImageDownloader *downloader = [[HYBImageDownloader alloc] init];
  _imageDownloader = downloader;
  [downloader startDownloadImageWithUrl:theRequest.URL.absoluteString progress:nil finished:^(NSData *data, NSError *error) {
    // 成功
    if (data != nil && error == nil) {
      dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *image = [UIImage imageWithData:data];
        UIImage *finalImage = image;
        
        if (image) {
          if (weakSelf.shouldAutoClipImageToViewSize) {
            // 剪裁
            if (fabs(weakSelf.frame.size.width - image.size.width) != 0
                && fabs(weakSelf.frame.size.height - image.size.height) != 0) {
              finalImage = [HYBLoadImageView clipImage:image toSize:weakSelf.frame.size isScaleToMax:YES];
            }
          }
          
          [[UIApplication sharedApplication] hyb_cacheImage:finalImage forRequest:theRequest];
        } else {
          [[UIApplication sharedApplication] hyb_cacheFailRequest:theRequest];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
          if (finalImage) {
            [weakSelf setImage:finalImage isFromCache:NO];
            
            if (weakSelf.completion) {
              weakSelf.completion(weakSelf.image);
            }
          } else {// error data
            if (weakSelf.completion) {
              weakSelf.completion(weakSelf.image);
            }
          }
        });
      });
    } else { // error
      [[UIApplication sharedApplication] hyb_cacheFailRequest:theRequest];
      
      if (weakSelf.completion) {
        weakSelf.completion(weakSelf.image);
      }
    }
  }];
}

- (void)setImageWithURLString:(NSString *)url
             placeholderImage:(NSString *)placeholderImage
                   completion:(void (^)(UIImage *image))completion {
  NSString *path = [[NSBundle mainBundle] pathForResource:placeholderImage ofType:nil];
  UIImage *image = [UIImage imageWithContentsOfFile:path];
  if (image == nil) {
    image = [UIImage imageNamed:placeholderImage];
  }
  
  [self setImageWithURLString:url placeholder:image completion:completion];
}

- (void)cancelRequest {
  [_imageDownloader.task cancel];
}

+ (UIImage *)clipImage:(UIImage *)image toSize:(CGSize)size isScaleToMax:(BOOL)isScaleToMax {
  CGFloat scale =  [UIScreen mainScreen].scale;
  
  UIGraphicsBeginImageContextWithOptions(size, NO, scale);
  
  CGSize aspectFitSize = CGSizeZero;
  if (image.size.width != 0 && image.size.height != 0) {
    CGFloat rateWidth = size.width / image.size.width;
    CGFloat rateHeight = size.height / image.size.height;
    
    CGFloat rate = isScaleToMax ? MAX(rateHeight, rateWidth) : MIN(rateHeight, rateWidth);
    aspectFitSize = CGSizeMake(image.size.width * rate, image.size.height * rate);
  }
  
  [image drawInRect:CGRectMake(0, 0, aspectFitSize.width, aspectFitSize.height)];
  UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return finalImage;
}

@end
