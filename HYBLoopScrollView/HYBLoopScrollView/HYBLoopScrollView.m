//
//  HYBLoopScrollView.m
//  HYBLoopScrollView
//
//  Created by huangyibiao on 15/4/1.
//  Copyright (c) 2015年 huangyibiao. All rights reserved.
//

#import "HYBLoopScrollView.h"

NSString * const kCellIdentifier = @"ReuseCellIdentifier";

/**
 *  CollectionView for ad.
 */
@interface HYBCollectionCell : UICollectionViewCell

@property (nonatomic, strong) HYBLoadImageView *imageView;
@property (nonatomic, strong) UILabel          *titleLabel;

@end

@implementation HYBCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.imageView = [[HYBLoadImageView alloc] init];
    [self addSubview:self.imageView];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.titleLabel.hidden = YES;
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont systemFontOfSize:13];
    [self addSubview:self.titleLabel];
  }
  
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  self.imageView.frame = self.bounds;
  self.titleLabel.frame = CGRectMake(0, self.height - 30, self.width, 30);
  self.titleLabel.hidden = self.titleLabel.text.length > 0 ? NO : YES;
}

@end

@interface HYBLoopScrollView () <UICollectionViewDataSource, UICollectionViewDelegate> {
  HYBPageControl *_pageControl;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger totalPageCount;
// Record the previous page index, for we need to update to another page when
// it is clicked at some point.
@property (nonatomic, assign) NSInteger previousPageIndex;

@end

@implementation HYBLoopScrollView

- (void)pauseTimer {
  if (self.timer) {
    [self.timer setFireDate:[NSDate distantFuture]];
  }
}

- (void)startTimer {
  if (self.timer) {
    [self.timer setFireDate:[NSDate distantPast]];
  }
}

- (HYBPageControl *)pageControl {
  return _pageControl;
}

+ (instancetype)loopScrollViewWithFrame:(CGRect)frame imageUrls:(NSArray *)imageUrls {
  HYBLoopScrollView *loopView = [[HYBLoopScrollView alloc] initWithFrame:frame];
  loopView.imageUrls = imageUrls;
  
  return loopView;
}

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.timeInterval = 5.0;
    self.alignment = kPageControlAlignCenter;
    [self configCollectionView];
  }
  return self;
}

- (void)setFrame:(CGRect)frame {
  [super setFrame:frame];
  
  self.layout.itemSize = frame.size;
}

- (void)configCollectionView {
  self.layout = [[UICollectionViewFlowLayout alloc] init];
  self.layout .itemSize = self.bounds.size;
  self.layout .minimumLineSpacing = 0;
  self.layout .scrollDirection = UICollectionViewScrollDirectionHorizontal;
  
  self.collectionView = [[UICollectionView alloc] initWithFrame:self.frame
                                           collectionViewLayout:self.layout];
  self.collectionView.backgroundColor = [UIColor lightGrayColor];
  self.collectionView.pagingEnabled = YES;
  self.collectionView.showsHorizontalScrollIndicator = NO;
  self.collectionView.showsVerticalScrollIndicator = NO;
  [self.collectionView  registerClass:[HYBCollectionCell class]
           forCellWithReuseIdentifier:kCellIdentifier];
  self.collectionView.dataSource = self;
  self.collectionView.delegate = self;
  [self addSubview:self.collectionView];
}

- (void)configTimer {
  [_timer invalidate];
  _timer = nil;
  
  if (self.imageUrls.count <= 1) {
    return;
  }
  
  _timer = [NSTimer scheduledTimerWithTimeInterval:_timeInterval
                                            target:self
                                          selector:@selector(autoScroll)
                                          userInfo:nil
                                           repeats:YES];
  [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)setPageControlEnabled:(BOOL)pageControlEnabled {
  if (_pageControlEnabled != pageControlEnabled) {
    _pageControlEnabled = pageControlEnabled;
    
    if (_pageControlEnabled) {
      __weak typeof(self) weakSelf = self;
      self.pageControl.valueChangedBlock = ^(NSInteger clickedAtIndex) {
              NSInteger curIndex = (weakSelf.collectionView.contentOffset.x
                                    + weakSelf.layout.itemSize.width * 0.5) / weakSelf.layout.itemSize.width;
        NSInteger toIndex = curIndex + (clickedAtIndex > weakSelf.previousPageIndex ? clickedAtIndex : -clickedAtIndex);
        [weakSelf.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:toIndex inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionNone
                                            animated:YES];

      };
    } else {
      self.pageControl.valueChangedBlock = nil;
    }
  }
}

- (void)configPageControl {
  if (self.pageControl == nil) {
    _pageControl = [[HYBPageControl alloc] init];
    self.pageControl.hidesForSinglePage = YES;
    [self addSubview:self.pageControl];
    self.pageControlEnabled = YES;
  }
  
  [self bringSubviewToFront:self.pageControl];
  self.pageControl.numberOfPages = self.imageUrls.count;
 CGSize size = [self.pageControl sizeForNumberOfPages:self.imageUrls.count];
  self.pageControl.size = size;
  
  if (self.alignment == kPageControlAlignCenter) {
    self.pageControl.originX = (self.width - self.pageControl.width) / 2.0;
  } else if (self.alignment == kPageControlAlignRight) {
    self.pageControl.rightX = self.width - 10;
  }
  self.pageControl.originY = self.height - self.pageControl.height + 5;
}

- (void)setTimeInterval:(NSTimeInterval)timeInterval {
  _timeInterval = timeInterval;
  
  [self configTimer];
}

- (void)autoScroll {
  NSInteger curIndex = (self.collectionView.contentOffset.x + self.layout.itemSize.width * 0.5) / self.layout.itemSize.width;
  NSInteger toIndex = curIndex + 1;
  
  NSIndexPath *indexPath = nil;
  if (toIndex == self.totalPageCount) {
    toIndex = self.totalPageCount * 0.5;
  
    // scroll to the middle without animation, and scroll to middle with animation, so that it scrolls
    // more smoothly.
    indexPath = [NSIndexPath indexPathForItem:toIndex inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath
                                atScrollPosition:UICollectionViewScrollPositionNone
                                        animated:NO];
  } else {
    indexPath = [NSIndexPath indexPathForItem:toIndex inSection:0];
  }
  
  [self.collectionView scrollToItemAtIndexPath:indexPath
                              atScrollPosition:UICollectionViewScrollPositionNone
                                      animated:YES];
}

- (void)setImageUrls:(NSArray *)imageUrls {
  if (_imageUrls != imageUrls) {
    _imageUrls = imageUrls;
    
    if (imageUrls.count > 1) {
      self.totalPageCount = imageUrls.count * 50;
      [self configTimer];
      [self configPageControl];
      self.collectionView.scrollEnabled = YES;
    } else {
      // If there is only one page, stop the timer and make scroll enabled to be NO.
      [_timer invalidate];
      _timer = nil;
      self.totalPageCount = 1;
      [self configPageControl];
      self.collectionView.scrollEnabled = NO;
    }
    [self.collectionView reloadData];
  }
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  self.collectionView.frame = self.bounds;
  if (self.collectionView.contentOffset.x == 0) {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.totalPageCount * 0.5
                                                 inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath
                                atScrollPosition:UICollectionViewScrollPositionNone
                                        animated:NO];
  }
  
  [self configPageControl];
}

- (void)setAlignment:(HYBPageControlAlignment)alignment {
  if (_alignment != alignment) {
    _alignment = alignment;
    
    [self configPageControl];
    [self.collectionView reloadData];
  }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return self.totalPageCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  HYBCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier
                                                                      forIndexPath:indexPath];
  
  NSInteger itemIndex = indexPath.item % self.imageUrls.count;
  if (itemIndex < self.imageUrls.count) {
    NSString *urlString = self.imageUrls[itemIndex];
    if ([urlString isKindOfClass:[UIImage class]]) {
      cell.imageView.image = (UIImage *)urlString;
    } else if ([urlString hasPrefix:@"http://"]
               || [urlString hasPrefix:@"https://"]
               || [urlString containsString:@"/"]) {
      [cell.imageView setImageWithURLString:urlString placeholder:self.placeholder];
    } else {
      cell.imageView.image = [UIImage imageNamed:urlString];
    }
  }
  
  if (self.alignment == kPageControlAlignRight && itemIndex < self.adTitles.count) {
    cell.titleLabel.text = [NSString stringWithFormat:@"   %@", self.adTitles[itemIndex]];
  }
  
  return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  if (self.didSelectItemBlock) {
    HYBCollectionCell *cell = (HYBCollectionCell *)[self collectionView:collectionView cellForItemAtIndexPath:indexPath];
    self.didSelectItemBlock(indexPath.item % self.imageUrls.count, cell.imageView);
  }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  int itemIndex = (scrollView.contentOffset.x + self.collectionView.width * 0.5) / self.collectionView.width;
  itemIndex = itemIndex % self.imageUrls.count;
  _pageControl.currentPage = itemIndex;
  
  // record
  self.previousPageIndex = itemIndex;
  
  CGFloat x = scrollView.contentOffset.x - self.collectionView.width;
  NSUInteger index = fabs(x) / self.collectionView.width;
  CGFloat fIndex = fabs(x) / self.collectionView.width;
  
  if (self.didScrollBlock && fabs(fIndex - (CGFloat)index) <= 0.00001) {
    HYBCollectionCell *cell = (HYBCollectionCell *)[self collectionView:self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:itemIndex inSection:0]];
    self.didScrollBlock(itemIndex, cell.imageView);
  }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  [_timer invalidate];
  _timer = nil;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  [self configTimer];
}

@end


/**
 *  UIView category
 */
@implementation UIView (Ext)

- (CGFloat)originX {
  return self.frame.origin.x;
}

- (void)setOriginX:(CGFloat)originX {
  CGRect frame = self.frame;
  frame.origin.x = originX;
  self.frame = frame;
  return;
}

- (CGFloat)originY {
  return self.frame.origin.y;
}

- (void)setOriginY:(CGFloat)originY {
  CGRect frame = self.frame;
  frame.origin.y = originY;
  self.frame = frame;
  return;
}

- (CGFloat)rightX {
  return [self originX] + [self width];
}

- (void)setRightX:(CGFloat)rightX {
  CGRect frame = self.frame;
  frame.origin.x = rightX - [self width];
  self.frame = frame;
  return;
}

- (CGFloat)bottomY {
  return [self originY] + [self height];
}

- (void)setBottomY:(CGFloat)bottomY {
  CGRect frame = self.frame;
  frame.origin.y = bottomY - [self height];
  self.frame = frame;
  return;
}

- (CGFloat)centerX {
  return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX {
  self.center = CGPointMake(centerX, self.center.y);
  return;
}

- (CGFloat)centerY {
  return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY {
  self.center = CGPointMake(self.center.x, centerY);
  return;
}

- (CGFloat)width {
  return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
  CGRect frame = self.frame;
  frame.size.width = width;
  self.frame = frame;
  return;
}

- (CGFloat)height {
  return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
  CGRect frame = self.frame;
  frame.size.height = height;
  self.frame = frame;
  return;
}

- (CGPoint)origin {
  return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin {
  CGRect frame = self.frame;
  frame.origin = origin;
  self.frame = frame;
  return;
}

- (CGSize)size {
  return self.frame.size;
}

- (void)setSize:(CGSize)size {
  CGRect frame = self.frame;
  frame.size = size;
  self.frame = frame;
  return;
}

@end
