//
//  YCXBannerView.m
//  YCXBannerViewDemo
//
//  Created by 牛萌 on 15/12/16.
//  Copyright © 2015年 self.Aster0id. All rights reserved.
//

#import "YCXBannerView.h"
#import "UIImageView+WebCache.h"
#import "DDPageControl.h"
#import "YCXBannerPhotoView.h"


/// 循环滚动的时间
static const NSTimeInterval kTimeInterval = 3.0;
/// 描述视图的高度
static const float kDescriptionViewHeight = 31.0;
/// 描述文字的左边距
static const float kDescriptionLabelLeft = 8.0;
/// pageControl的外边距
static const float kPageControlMargin = 8.0;

@interface YCXBannerView ()
<UIScrollViewDelegate>

// 描述文字视图
@property (nonatomic, strong) UIView *descriptionView;

// 页码指示器
@property (nonatomic, strong) DDPageControl *pageControl;

// 描述文字标签
@property (nonatomic, strong) UILabel *descriptionLabel;

// 图片滚动视图
@property (nonatomic, strong) UIScrollView *photoViewScrollView;

// 容器视图
@property (nonatomic, strong) UIView *containerView;

@end

@implementation YCXBannerView {
    
    // 图片总数
    NSUInteger _imagesCount;
    // 是否为单张图片, 如果是单张图片不能滑动
    BOOL _isSinglePhoto;
    // 自动播放定时器
    NSTimer *_autoplayTimer;
    // PhotoView的集合
    NSMutableArray *_visiblePages;
    
}


#pragma mark - System Methods

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initialization];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        [self initialization];
    }
    return self;
}

- (void)initialization {
    
    self.autoplay = YES;
    _visiblePages = [NSMutableArray array];
    self.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.descriptionView.frame = CGRectMake(0, self.bounds.size.height-31, self.bounds.size.width, kDescriptionViewHeight);
    
    self.pageControl.frame = CGRectMake(self.descriptionView.frame.size.width - (_pageControl.frame.size.width), (self.descriptionView.frame.size.height - _pageControl.frame.size.height)/2, _pageControl.frame.size.width, _pageControl.frame.size.height);
    
    _descriptionLabel.frame = CGRectMake(kDescriptionLabelLeft, 0,  self.pageControl.frame.origin.x, self.descriptionView.frame.size.height);

    
    self.containerView.frame = CGRectMake(0, 0, self.bounds.size.width*(_imagesCount+2), self.bounds.size.height);
    
    self.photoViewScrollView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [self.photoViewScrollView setContentSize:self.containerView.bounds.size];
    [self.photoViewScrollView setContentOffset:CGPointMake(0, 0)];
    [self.photoViewScrollView scrollRectToVisible:CGRectMake(self.photoViewScrollView.frame.size.width, 0, self.photoViewScrollView.frame.size.width, self.photoViewScrollView.frame.size.height) animated:NO];
}


#pragma mark - Publice Methods

-(void)reloadData {
    
    [self reduction];
    
    // _imagesCount赋值
    _imagesCount = self.photosArray.count;
    
    NSAssert(_imagesCount > 0, @"图片数组不能为空");
    _isSinglePhoto = (_imagesCount == 1);
    
    [self configPhotoViewScrollView];
    [self configDescriptionView];
    
    // 初始化描述文字显示内容
    // YCXBannerPhoto *photo = self.photosArray[0];
    // self.descriptionLabel.text = photo.caption;
    
    // 设置计时器重新开始计时
    [self performAutoPlayTimer];
}


#pragma mark - Private Methods

- (void)reduction {
    // 销毁控件上的所有视图
    [self.photoViewScrollView removeFromSuperview];
    self.photoViewScrollView = nil;
    [self.descriptionView removeFromSuperview];
    self.descriptionView = nil;
    self.pageControl = nil;
    self.containerView = nil;
    self.descriptionLabel = nil;
    
    [_visiblePages removeAllObjects];
}

/**
 *	@brief	创建底部视图
 */
-(void)configDescriptionView {
    
    [self addSubview:self.descriptionView];
    
    NSArray *descriptionViewHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[descriptionView]-0-|" options:0 metrics:nil views:@{@"descriptionView":self.descriptionView}];
    NSArray *descriptionViewVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[descriptionView(==height)]-0-|" options:0 metrics:@{@"height":@(kDescriptionViewHeight)} views:@{@"descriptionView":self.descriptionView}];
    [self addConstraints:descriptionViewHorizontalConstraints];
    [self addConstraints:descriptionViewVerticalConstraints];
    
    //设置pageControl
    [self.descriptionView addSubview:self.pageControl];
    
    
    CGSize pageControlSize = [self.pageControl sizeForNumberOfPages:_imagesCount];
    NSArray *pageControlHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[pageControl(==width)]-margin-|" options:0 metrics:@{@"width":@(pageControlSize.width),@"margin":@(-22+kPageControlMargin)} views:@{@"pageControl":self.pageControl}];
    [self.descriptionView addConstraints:pageControlHorizontalConstraints];


    NSLayoutConstraint *pageControlHeight = [NSLayoutConstraint constraintWithItem:self.pageControl attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:self.pageControl.frame.size.height];
    [self.pageControl addConstraint:pageControlHeight];
    
    NSLayoutConstraint *pageControlVerticalCenterY = [NSLayoutConstraint constraintWithItem:self.pageControl attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.descriptionView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    [self.descriptionView addConstraint:pageControlVerticalCenterY];
    
    
    // 设置描述文字标签
    [self.descriptionView addSubview:self.descriptionLabel];
    
    NSArray *descriptionLabelVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[descriptionLabel]-0-|" options:0 metrics:nil views:@{@"descriptionLabel":self.descriptionLabel}];
    [self.descriptionView addConstraints:descriptionLabelVerticalConstraints];
    
    NSLayoutConstraint *descriptionLabelLeft = [NSLayoutConstraint constraintWithItem:self.descriptionLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.descriptionView attribute:NSLayoutAttributeLeft multiplier:1 constant:kDescriptionLabelLeft];
    [self.descriptionView addConstraint:descriptionLabelLeft];
    
    NSLayoutConstraint *descriptionLabelRight = [NSLayoutConstraint constraintWithItem:self.descriptionLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.pageControl attribute:NSLayoutAttributeLeft multiplier:1 constant:22-kPageControlMargin];
    [self.descriptionView addConstraint:descriptionLabelRight];
    
}

/**
 * @brief 创建图片滚动视图
 */
- (void)configPhotoViewScrollView {
    
    [self addSubview:self.photoViewScrollView];
    
    NSArray *photoViewScrollViewHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[scrollView]-0-|" options:0 metrics:nil views:@{@"scrollView":self.photoViewScrollView}];
    NSArray *photoViewScrollViewVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[scrollView]-0-|" options:0 metrics:nil views:@{@"scrollView":self.photoViewScrollView}];
    [self addConstraints:photoViewScrollViewHorizontalConstraints];
    [self addConstraints:photoViewScrollViewVerticalConstraints];
    
    [self.photoViewScrollView addSubview:self.containerView];
    
    NSLayoutConstraint *containerViewWidth = [NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.photoViewScrollView attribute:NSLayoutAttributeWidth multiplier:_imagesCount + 2 constant:0];
    NSLayoutConstraint *containerViewHeight = [NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.photoViewScrollView attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    [self.photoViewScrollView addConstraint:containerViewWidth];
    [self.photoViewScrollView addConstraint:containerViewHeight];
    
    NSArray *photoViewHorizontalConstraints =
    [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[containerView]-0-|" options:0 metrics:nil views:@{@"containerView":self.containerView}];
    NSArray *photoViewVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[containerView]-0-|" options:0 metrics:nil views:@{@"containerView":self.containerView}];
    [self.photoViewScrollView addConstraints:photoViewHorizontalConstraints];
    [self.photoViewScrollView addConstraints:photoViewVerticalConstraints];
    
    
    NSMutableArray *mPhotoArray = [self.photosArray mutableCopy];
    
    YCXBannerPhoto *lastPhoto = [self.photosArray lastObject];
    [mPhotoArray insertObject:lastPhoto atIndex:0];
    
    NSString *firstPhoto = [self.photosArray firstObject];
    [mPhotoArray insertObject:firstPhoto atIndex:_imagesCount+1];
    
    
    for (NSInteger i = 0; i<mPhotoArray.count; i++) {
        
        YCXBannerPhotoView *photoView = [[YCXBannerPhotoView alloc] init];
        photoView.photo = mPhotoArray[i];
        
        photoView.frame = CGRectMake(i * self.photoViewScrollView.bounds.size.width, 0, self.photoViewScrollView.bounds.size.width, self.photoViewScrollView.bounds.size.height);
        photoView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.containerView addSubview:photoView];
        [_visiblePages addObject:photoView];
        
        NSArray *photoViewVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[photoView]-0-|" options:0 metrics:nil views:@{@"photoView":photoView}];
        [self.photoViewScrollView addConstraints:photoViewVerticalConstraints];
        
        NSLayoutConstraint *photoViewWidth = [NSLayoutConstraint constraintWithItem:photoView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.photoViewScrollView attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
        [self.photoViewScrollView addConstraint:photoViewWidth];
        
        if (i == 0) {
            NSLayoutConstraint *photoViewLeft = [NSLayoutConstraint constraintWithItem:photoView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
            [self.containerView addConstraint:photoViewLeft];
        } else {
            UIView *priorView = [self.containerView.subviews objectAtIndex:i-1];
            NSLayoutConstraint *photoViewLeft = [NSLayoutConstraint constraintWithItem:photoView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:priorView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
            [self.photoViewScrollView addConstraint:photoViewLeft];
        }
        
        photoView.tag = i;
        photoView.index = (i == 0 ? (_imagesCount - 1) : (i== _imagesCount+1 ? 0 : i - 1));
        
        [photoView setTapPhotoView:^(YCXBannerPhotoView *photoView){
            if (self.delegate && [self.delegate respondsToSelector:@selector(bannerView:clickAtIndex:)]) {
                [self.delegate bannerView:self clickAtIndex:photoView.index];
            }
        }];
    }
}

- (void)performAutoPlayTimer {
    if (self.isAutoplay && !_isSinglePhoto) {
        [self autoPlayScrollView];
    } else {
        [_autoplayTimer invalidate];
        _autoplayTimer = nil;
    }
}

/// 自动循环滚动
- (void) autoPlayScrollView {
    [_autoplayTimer invalidate];
    _autoplayTimer = nil;
    _autoplayTimer = [NSTimer scheduledTimerWithTimeInterval:kTimeInterval target:self selector:@selector(handleImagesScrollViewTimer:) userInfo: nil repeats:YES];
}


- (void)handleImagesScrollViewTimer:(NSTimer*)theTimer {
    CGPoint pt = self.photoViewScrollView.contentOffset;
    if(pt.x == self.frame.size.width * _imagesCount) {
        // 如果当前显示的图片为可变数组中的最后一张图片,
        // 则将图片滚动视图的 contentOffset 设置为原点,重新滚动
        [self.photoViewScrollView setContentOffset:CGPointMake(0, 0)];
        pt = self.photoViewScrollView.contentOffset;
    }
    // 滚动视图
    [self.photoViewScrollView scrollRectToVisible:CGRectMake(pt.x + self.frame.size.width, 0, self.frame.size.width, self.frame.size.height) animated:YES];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int currentPage = self.photoViewScrollView.contentOffset.x/self.photoViewScrollView.frame.size.width;
    
    if (currentPage == 0) {
        // 如果是最前-1,也就是要开始循环的最后一个
        [self.photoViewScrollView scrollRectToVisible:CGRectMake(self.frame.size.width * _imagesCount, 0, self.frame.size.width, self.frame.size.height) animated:NO];
    }
    else if (currentPage == (_imagesCount+1)) {
        // 如果是最后+1,也就是要开始循环的第一个
        [self.photoViewScrollView scrollRectToVisible:CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height) animated:NO];
    }
    
    // 设置计时器重新开始计时
    [self performAutoPlayTimer];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // roundf() 四舍五入取整
    int imageIndex = (int)roundf(scrollView.contentOffset.x / scrollView.frame.size.width);
    // 设置pageControl.currentPage
    YCXBannerPhotoView *photoView = _visiblePages[imageIndex];
    NSInteger index = photoView.index;
    self.pageControl.currentPage = index;
    if (self.delegate && [self.delegate respondsToSelector:@selector(bannerView:scrollToPage:)]) {
        [self.delegate bannerView:self scrollToPage:index];
    }
    
    // 设置描述文字
    self.descriptionLabel.text = photoView.photo.caption;
}


#pragma mark - setter/getter

- (UIView *)descriptionView {
    if (!_descriptionView) {
        _descriptionView = [[UIView alloc] init];
        _descriptionView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.65];
        
        _descriptionView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _descriptionView;
}

- (DDPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[DDPageControl alloc] init];
        [_pageControl setType:DDPageControlTypeOnFullOffFull];
        [_pageControl setOnColor:[UIColor redColor]];
        [_pageControl setOffColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8]];
        _pageControl.indicatorDiameter = 6.0;
        _pageControl.indicatorSpace = 8.0;
        [_pageControl setNumberOfPages:_imagesCount];
        _pageControl.currentPage = 0;
        
        _pageControl.translatesAutoresizingMaskIntoConstraints = NO;
        
    }
    return _pageControl;
}

- (UIView *)descriptionLabel {
    
    if (!_descriptionLabel) {
        _descriptionLabel = [[UILabel alloc] init];
        _descriptionLabel.textColor = [UIColor whiteColor];
        _descriptionLabel.font = [UIFont systemFontOfSize:16.0f];
        
        _descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _descriptionLabel;
}

- (UIScrollView *)photoViewScrollView {
    if (!_photoViewScrollView) {
        // 设置图片滚动视图
        _photoViewScrollView = [[UIScrollView alloc] init];
        _photoViewScrollView.bounces = NO;
        _photoViewScrollView.pagingEnabled = YES;
        _photoViewScrollView.userInteractionEnabled = YES;
        _photoViewScrollView.showsHorizontalScrollIndicator = NO;
        _photoViewScrollView.showsVerticalScrollIndicator = NO;
        _photoViewScrollView.clipsToBounds = YES;
        _photoViewScrollView.translatesAutoresizingMaskIntoConstraints = NO;
        _photoViewScrollView.scrollEnabled = !_isSinglePhoto;
        [_photoViewScrollView setDelegate:self];
        
    }
    return _photoViewScrollView;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView  = [[UIView alloc] init];
        _containerView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _containerView;
}

- (void)setAutoplay:(BOOL)autoplay {
    _autoplay = autoplay;
    
    [self performAutoPlayTimer];
}

@end

