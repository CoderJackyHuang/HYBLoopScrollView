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

typedef void (^HYBDownLoadDataCallBack)(NSData *data, NSError *error);
typedef void (^HYBDownloadProgressBlock)(unsigned long long total, unsigned long long current);

/**
 *	图片下载器，没有直接使用NSURLSession之类的，是因为希望这套库可以支持iOS6
 */
@interface HYBImageDownloader : NSObject<NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *data;

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
  
  self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark - NSURLConnectionDataDelegate
- (NSMutableData *)data {
  if (_data == nil) {
    _data = [[NSMutableData alloc] init];
  }
  
  return _data;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  [self.data setLength:0];
  self.totalLength = response.expectedContentLength;
  self.currentLength = 0;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  [self.data appendData:data];
  self.currentLength += data.length;
  
  if (self.progressBlock) {
    self.progressBlock(self.totalLength, self.currentLength);
  }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  if (self.progressBlock) {
    self.progressBlock(self.totalLength, self.currentLength);
  }
  
  if (self.callbackOnFinished) {
    self.callbackOnFinished([self.data copy], nil);
    
    // 防止重复调用
    self.callbackOnFinished = nil;
  }
  NSLog(@"%s %@   %p", __FUNCTION__, connection.currentRequest.URL.absoluteString, self);
  
  [self.data setLength:0];
  self.data = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  if ([error code] != NSURLErrorCancelled) {
    if (self.callbackOnFinished) {
      self.callbackOnFinished(nil, error);
    }
    
    self.callbackOnFinished = nil;
  }
  
  [self.data setLength:0];
  self.data = nil;
  NSLog(@"%s", __FUNCTION__);
}

@end

@interface NSString (md5)

+ (NSString *)hyb_md5:(NSString *)string;

@end

@implementation NSString (md5)

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

@interface HYBImageCache : NSCache

@property (nonatomic, assign) NSUInteger failTimes;

- (BOOL)cacheImage:(UIImage *)image forRequest:(NSURLRequest *)request;
- (BOOL)cacheImage:(UIImage *)image forUrl:(NSString *)url;
- (UIImage *)cacheImageForRequest:(NSURLRequest *)request;

@end

@implementation HYBImageCache

- (UIImage *)cacheImageForRequest:(NSURLRequest *)request {
  if (request == nil || ![request isKindOfClass:[NSURLRequest class]]) {
    return nil;
  }
  
  return [self objectForKey:[NSString hyb_md5:request.URL.absoluteString]];
}

- (BOOL)cacheImage:(UIImage *)image forUrl:(NSString *)url {
  if (image != nil && ![image isKindOfClass:[NSNull class]]) {
    [self setObject:image forKey:url];
    return YES;
  }
  
  return NO;
}

- (BOOL)cacheImage:(UIImage *)image forRequest:(NSURLRequest *)request {
  if (request) {
    NSString *url = [NSString hyb_md5:request.URL.absoluteString];
    return [self cacheImage:image forUrl:url];
  }
  
  return NO;
}

@end

@interface UIApplication (HYBCacheImage)

@property (nonatomic, strong, readonly) NSMutableDictionary *hyb_cacheImages;

- (UIImage *)hyb_cacheImageForRequest:(NSURLRequest *)request;
- (void)hyb_cacheImage:(UIImage *)image forRequest:(NSURLRequest *)request;
- (void)hyb_cacheFailRequest:(NSURLRequest *)request;
- (NSUInteger)hyb_failTimesForRequest:(NSURLRequest *)request;

@end

static char *s_hyb_cacheimages = "s_hyb_cacheimages";

@implementation UIApplication (HYBCacheImage)

- (void)hyb_clearCache {
  [self.hyb_cacheImages removeAllObjects];
  
  objc_setAssociatedObject(self, s_hyb_cacheimages, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)hyb_clearDiskCaches {
  NSString *directoryPath = [NSHomeDirectory() stringByAppendingString:@"/Documents/HYBLoopScollViewImages"];
  
  if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:nil]) {
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:directoryPath error:&error];
    
    if (error) {
      NSLog(@"clear caches error: %@", error);
    } else {
      NSLog(@"clear caches ok");
    }
  }
  
  [self hyb_clearCache];
}

- (UIImage *)hyb_cacheImageForRequest:(NSURLRequest *)request {
  HYBImageCache *cache = [self.hyb_cacheImages objectForKey:[NSString hyb_md5:request.URL.absoluteString]];
  if (cache) {
    return [cache cacheImageForRequest:request];
  }
  
  return nil;
}

- (NSUInteger)hyb_failTimesForRequest:(NSURLRequest *)request {
  HYBImageCache *cache = [self.hyb_cacheImages objectForKey:[NSString hyb_md5:request.URL.absoluteString]];
  
  if (cache) {
    return cache.failTimes;
  }
  
  return 0;
}

- (void)hyb_cacheFailRequest:(NSURLRequest *)request {
  HYBImageCache *cache = [self.hyb_cacheImages objectForKey:[NSString hyb_md5:request.URL.absoluteString]];
  if (!cache) {
    cache = [[HYBImageCache alloc] init];
  }
  
  cache.failTimes += 1;
  [self.hyb_cacheImages setObject:cache forKey:[NSString hyb_md5:request.URL.absoluteString]];
}

- (void)hyb_cacheImage:(UIImage *)image forRequest:(NSURLRequest *)request {
    [self hyb_cacheImage:image forKey:[NSString hyb_md5:request.URL.absoluteString]];
  [self hyb_cacheToDiskForData:UIImagePNGRepresentation(image) request:request];
}

- (void)hyb_cacheImage:(UIImage *)image forKey:(NSString *)key {
  if (self.hyb_cacheImages[key]) {
    return;
  }
  
  HYBImageCache *cache = [[HYBImageCache alloc] init];
  [cache cacheImage:image forUrl:key];
  [self.hyb_cacheImages setObject:cache forKey:key];
}

- (NSMutableDictionary *)hyb_cacheImages {
  NSMutableDictionary *caches = objc_getAssociatedObject(self, s_hyb_cacheimages);
  
  if (caches == nil) {
    caches = [[NSMutableDictionary alloc] init];
    
    // Try to get datas from disk
    NSString *directoryPath = [NSHomeDirectory() stringByAppendingString:@"/Documents/HYBLoopScollViewImages"];
    BOOL isDir = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:&isDir]) {
      if (isDir) {
        NSError *error = nil;
        NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:&error];

        if (error == nil) {
          for (NSString *subpath in array) {
            NSData *data = [[NSFileManager defaultManager] contentsAtPath:[directoryPath stringByAppendingPathComponent:subpath]];
            if (data) {
              UIImage *image = [UIImage imageWithData:data];
              if (image) {
                HYBImageCache *cache = [[HYBImageCache alloc] init];
                [cache cacheImage:image forUrl:subpath];
                [caches setObject:cache forKey:subpath];
              }
            }
          }
        }
      }
    }
    
    objc_setAssociatedObject(self, s_hyb_cacheimages, caches, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
  
  return caches;
}

- (void)hyb_cacheToDiskForData:(NSData *)data request:(NSURLRequest *)request {
  if (data == nil || request == nil) {
    return;
  }
  
  NSString *directoryPath = [NSHomeDirectory() stringByAppendingString:@"/Documents/HYBLoopScollViewImages"];
  
  if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath isDirectory:nil]) {
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    if (error) {
      NSLog(@"create cache dir error: %@", error);
      return;
    }
  }
  
  NSString *path = [NSString stringWithFormat:@"%@/%@",
                    directoryPath,
                    [NSString hyb_md5:request.URL.absoluteString]];
  BOOL isOk = [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
  if (isOk) {
    NSLog(@"cache file ok for request: %@", [NSString hyb_md5:request.URL.absoluteString]);
  } else {
    NSLog(@"cache file error for request: %@", [NSString hyb_md5:request.URL.absoluteString]);
  }
}

@end

#define kImageWithName(Name) ([UIImage imageNamed:Name])
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
  self.contentMode = UIViewContentModeScaleAspectFill;
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
              finalImage = [HYBLoadImageView clipImage:image toSize:weakSelf.frame.size isScaleToMax:NO];
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
  [self setImageWithURLString:url placeholder:kImageWithName(placeholderImage) completion:completion];
}

- (void)cancelRequest {
  [_imageDownloader.connection cancel];
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
