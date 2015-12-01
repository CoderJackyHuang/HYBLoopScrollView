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
  self.titleLabel.frame = CGRectMake(0, self.hyb_height - 30, self.hyb_width, 30);
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

- (void)dealloc {
  NSLog(@"hybloopscrollview dealloc");
}

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

- (void)removeFromSuperview {
  [self.timer invalidate];
  self.timer = nil;
  
  [super removeFromSuperview];
}

+ (instancetype)loopScrollViewWithFrame:(CGRect)frame imageUrls:(NSArray *)imageUrls {
  return [self loopScrollViewWithFrame:frame
                             imageUrls:imageUrls
                          timeInterval:5.0
                             didSelect:nil
                             didScroll:nil];
}

+ (instancetype)loopScrollViewWithFrame:(CGRect)frame
                              imageUrls:(NSArray *)imageUrls
                           timeInterval:(NSTimeInterval)timeInterval
                              didSelect:(HYBLoopScrollViewDidSelectItemBlock)didSelect
                              didScroll:(HYBLoopScrollViewDidScrollBlock)didScroll {
  HYBLoopScrollView *loopView = [[HYBLoopScrollView alloc] initWithFrame:frame];
  loopView.imageUrls = imageUrls;
  loopView.timeInterval = timeInterval;
  loopView.didScrollBlock = didScroll;
  loopView.didSelectItemBlock = didSelect;
  
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
  if (self.imageUrls.count <= 1) {
    return;
  }
  
  if (self.timer != nil) {
    [self startTimer];
    return;
  }
  
  self.timer = [NSTimer scheduledTimerWithTimeInterval:_timeInterval
                                                target:self
                                              selector:@selector(autoScroll)
                                              userInfo:nil
                                               repeats:YES];
}

- (void)setPageControlEnabled:(BOOL)pageControlEnabled {
  if (_pageControlEnabled != pageControlEnabled) {
    _pageControlEnabled = pageControlEnabled;
    
    if (_pageControlEnabled) {
      __weak __typeof(self) weakSelf = self;
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
  self.pageControl.hyb_size = size;
  
  if (self.alignment == kPageControlAlignCenter) {
    self.pageControl.hyb_originX = (self.hyb_width - self.pageControl.hyb_width) / 2.0;
  } else if (self.alignment == kPageControlAlignRight) {
    self.pageControl.hyb_rightX = self.hyb_width - 10;
  }
  self.pageControl.hyb_originY = self.hyb_height - self.pageControl.hyb_height + 5;
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
      [self pauseTimer];
      
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
  
  // 先取消之前的请求
  HYBLoadImageView *preImageView = cell.imageView;
  if ([preImageView isKindOfClass:[HYBLoadImageView class]]) {
    [preImageView cancelRequest];
  }
  
  NSInteger itemIndex = indexPath.item % self.imageUrls.count;
  if (itemIndex < self.imageUrls.count) {
    NSString *urlString = self.imageUrls[itemIndex];
    if ([urlString isKindOfClass:[UIImage class]]) {
      cell.imageView.image = (UIImage *)urlString;
    } else if ([urlString hasPrefix:@"http://"]
               || [urlString hasPrefix:@"https://"]
               || [urlString rangeOfString:@"/"].location != NSNotFound) {
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
  int itemIndex = (scrollView.contentOffset.x +
                   self.collectionView.hyb_width * 0.5) / self.collectionView.hyb_width;
  itemIndex = itemIndex % self.imageUrls.count;
  _pageControl.currentPage = itemIndex;
  
  // record
  self.previousPageIndex = itemIndex;
  
  CGFloat x = scrollView.contentOffset.x - self.collectionView.hyb_width;
  NSUInteger index = fabs(x) / self.collectionView.hyb_width;
  CGFloat fIndex = fabs(x) / self.collectionView.hyb_width;
  
  if (self.didScrollBlock && fabs(fIndex - (CGFloat)index) <= 0.00001) {
    HYBCollectionCell *cell = (HYBCollectionCell *)[self collectionView:self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:itemIndex inSection:0]];
    self.didScrollBlock(itemIndex, cell.imageView);
  }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  [self pauseTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  [self configTimer];
}

@end
