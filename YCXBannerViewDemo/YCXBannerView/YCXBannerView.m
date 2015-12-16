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


static const NSTimeInterval kTimeInterval = 3.0f;
static const float kDescriptionViewHeight = 31;


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
    
    // 自动播放定时器
    NSTimer *_autoplayTimer;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        self.autoplay = YES;
    }
    return self;
}

#pragma mark - Publice Methods

-(void)reloadData {
    
    // 移除本控件上的所有视图
    for (UIView *view in self.subviews) [view removeFromSuperview];
    self.descriptionView = nil;
    self.photoViewScrollView = nil;
    self.pageControl = nil;
    self.containerView = nil;
    self.descriptionLabel = nil;
    
    // _imagesCount赋值
    _imagesCount = _imagesArray.count;
    
    if (_imagesCount > 0) {
        [self configPhotoViewScrollView];
        [self configDescriptionView];
    }
}

- (void)resetBannerViewWithImagesArray:(NSArray *)imagesArray andAutoplay:(BOOL)autoplay {
    _imagesArray = imagesArray;
    _autoplay = autoplay;
    
    [self reloadData];
}

#pragma mark - Private Methods

/**
 *	@brief	创建底部视图
 */
-(void)configDescriptionView {
    
    [self addSubview:self.descriptionView];
    
    NSArray *descriptionViewHorizontalConstraints =
    [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[descriptionView]-0-|"
                                            options:0
                                            metrics:nil
                                              views:@{@"descriptionView":self.descriptionView}];
    NSArray *descriptionViewVerticalConstraints =
    [NSLayoutConstraint constraintsWithVisualFormat:@"V:[descriptionView(==height)]-0-|"
                                            options:0
                                            metrics:@{@"height":@(kDescriptionViewHeight)}
                                              views:@{@"descriptionView":self.descriptionView}];
    
    [self addConstraints:descriptionViewHorizontalConstraints];
    [self addConstraints:descriptionViewVerticalConstraints];
    
    //设置pageControl
    [self.descriptionView addSubview:self.pageControl];
    
    // 设置描述文字标签
    [self.descriptionView addSubview:self.descriptionLabel];
    
    
    if (_titleArray.count>0) {
        self.descriptionLabel.text = _titleArray[0];
    }
}

/**
 * @brief 创建图片滚动视图
 */
- (void)configPhotoViewScrollView {
    
    [self addSubview:self.photoViewScrollView];
    
    NSArray *photoViewScrollViewHorizontalConstraints =
    [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[photoViewScrollView]-0-|"
                                            options:0
                                            metrics:nil
                                              views:@{@"photoViewScrollView":self.photoViewScrollView}];
    NSArray *photoViewScrollViewVerticalConstraints =
    [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[photoViewScrollView]-0-|"
                                            options:0
                                            metrics:nil
                                              views:@{@"photoViewScrollView":self.photoViewScrollView}];
    
    
    [self addConstraints:photoViewScrollViewHorizontalConstraints];
    [self addConstraints:photoViewScrollViewVerticalConstraints];
    
    [self.photoViewScrollView addSubview:self.containerView];
    
    NSLayoutConstraint *containerViewWidth = [NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.photoViewScrollView attribute:NSLayoutAttributeWidth multiplier:_imagesCount + 2 constant:0];
    NSLayoutConstraint *containerViewHeight = [NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.photoViewScrollView attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    [self.photoViewScrollView addConstraint:containerViewWidth];
    [self.photoViewScrollView addConstraint:containerViewHeight];
    
    

    
    NSArray *photoViewHorizontalConstraints =
    [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[containerView]-0-|"
                                            options:0
                                            metrics:nil
                                              views:@{@"containerView":self.containerView}];
    NSArray *photoViewVerticalConstraints =
    [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[containerView]-0-|"
                                            options:0
                                            metrics:nil
                                              views:@{@"containerView":self.containerView}];
    
    
    [self.photoViewScrollView addConstraints:photoViewHorizontalConstraints];
    [self.photoViewScrollView addConstraints:photoViewVerticalConstraints];
    
    //[self layoutSubviews];
    
    
    NSMutableArray *mArray = [_imagesArray mutableCopy];
    
    NSString *lastURL = [_imagesArray lastObject]?[_imagesArray lastObject]:@"";
    [mArray insertObject:lastURL atIndex:0];
    
    NSString *firstURL = [_imagesArray firstObject]?[_imagesArray firstObject]:@"";
    [mArray insertObject:firstURL atIndex:_imagesCount+1];
    
    for (int i = 0; i<mArray.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.clipsToBounds = YES;
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        
        imageView.frame = CGRectMake(i * self.photoViewScrollView.bounds.size.width, 0, self.photoViewScrollView.bounds.size.width, self.photoViewScrollView.bounds.size.height);
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.containerView addSubview:imageView];
        
        
        NSArray *photoViewVerticalConstraints =
        [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[imageView]-0-|"
                                                options:0
                                                metrics:nil
                                                  views:@{@"imageView":imageView}];
        [self.photoViewScrollView addConstraints:photoViewVerticalConstraints];
        
        NSLayoutConstraint *photoViewWidth = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.photoViewScrollView attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
        [self.photoViewScrollView addConstraint:photoViewWidth];
        
        if (i == 0) {
            NSLayoutConstraint *photoViewLeft = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
            [self.containerView addConstraint:photoViewLeft];
        } else {
            UIView *priorView = [self.containerView.subviews objectAtIndex:i-1];
            NSLayoutConstraint *photoViewLeft = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:priorView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
            [self.photoViewScrollView addConstraint:photoViewLeft];
        }
        
        imageView.tag = (i == 0 ? (_imagesCount - 1) : (i== _imagesCount+1 ? 0 : i - 1));
        [imageView sd_setImageWithURL:[NSURL URLWithString:mArray[i]]];
        
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewWasTapped:)];
        [imageView addGestureRecognizer:singleTap1];
        
        
    }
    
    if (self.isAutoplay) {
        [self performSelector:@selector(autoPlayScrollView) withObject:nil afterDelay:0.0f];
    }
}


- (void)viewWasTapped:(UITapGestureRecognizer *)gesture {
    UIView *view = gesture.view;
    [self clickImage:view];
}

/// 自动循环滚动
- (void) autoPlayScrollView
{
    [_autoplayTimer invalidate];
    _autoplayTimer = nil;
    _autoplayTimer = [NSTimer scheduledTimerWithTimeInterval:kTimeInterval target:self selector:@selector(handleImagesScrollViewTimer:) userInfo: nil repeats:YES];
}


- (void)handleImagesScrollViewTimer:(NSTimer*)theTimer
{
    CGPoint pt = self.photoViewScrollView.contentOffset;
    if(pt.x == self.frame.size.width * _imagesCount) {
        // 如果当前显示的图片为可变数组中的最后一张图片,
        // 则将图片滚动视图的 contentOffset 设置为原点,重新滚动
        [self.photoViewScrollView setContentOffset:CGPointMake(0, 0)];
        pt = self.photoViewScrollView.contentOffset;
    }
    //滚动视图
    [self.photoViewScrollView scrollRectToVisible:CGRectMake(pt.x+self.frame.size.width,
                                                             0,
                                                             self.frame.size.width,
                                                             self.frame.size.height)
                                         animated:YES];
}

- (void)clickImage:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)sender;
        if (self.delegate && [self.delegate respondsToSelector:@selector(bannerView:clickAtIndex:)]) {
            [self.delegate bannerView:self clickAtIndex:btn.tag];
        }
    } else if  ([sender isKindOfClass:[UIImageView class]]) {
        UIImageView *img = (UIImageView *)sender;
        if (self.delegate && [self.delegate respondsToSelector:@selector(bannerView:clickAtIndex:)]) {
            [self.delegate bannerView:self clickAtIndex:img.tag];
        }
    }
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int currentPage = self.photoViewScrollView.contentOffset.x/self.photoViewScrollView.frame.size.width;
    
    if (currentPage == 0) {
        // 如果是最前-1,也就是要开始循环的最后一个
        [self.photoViewScrollView scrollRectToVisible:CGRectMake(self.frame.size.width * _imagesCount,
                                                                 0,
                                                                 self.frame.size.width,
                                                                 self.frame.size.height)
                                             animated:NO];
    }
    else if (currentPage == (_imagesCount+1)) {
        // 如果是最后+1,也就是要开始循环的第一个
        [self.photoViewScrollView scrollRectToVisible:CGRectMake(self.frame.size.width,
                                                                 0,
                                                                 self.frame.size.width,
                                                                 self.frame.size.height)
                                             animated:NO];
    }
    
    if (self.isAutoplay) {
        [self autoPlayScrollView];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 设置pageControl.currentPage
    // roundf() 四舍五入取整
    int imageIndex = (int)roundf(scrollView.contentOffset.x / scrollView.frame.size.width);
    NSInteger index = (imageIndex == 0?
                       _imagesCount-1:
                       (imageIndex == _imagesCount +1?0:imageIndex - 1));
    self.pageControl.currentPage = index;
    if (_titleArray.count>index) {
        self.descriptionLabel.text = self.titleArray[index];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.descriptionView.frame = CGRectMake(0, self.bounds.size.height-31, self.bounds.size.width, kDescriptionViewHeight);

    self.containerView.frame = CGRectMake(0, 0, self.bounds.size.width*(_imagesCount+2), self.bounds.size.height);

    self.photoViewScrollView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [self.photoViewScrollView setContentSize:self.containerView.bounds.size];
    [self.photoViewScrollView setContentOffset:CGPointMake(0, 0)];
    [self.photoViewScrollView scrollRectToVisible:CGRectMake(self.photoViewScrollView.frame.size.width, 0, self.photoViewScrollView.frame.size.width, self.photoViewScrollView.frame.size.height) animated:NO];
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
        [_pageControl setIndicatorDiameter:6.0f];
        [_pageControl setIndicatorSpace:8.0f];
        [_pageControl setNumberOfPages:_imagesCount];
        [_pageControl setCurrentPage:0];
        
        [_pageControl setFrame:CGRectMake(self.descriptionView.frame.size.width - (_pageControl.frame.size.width), (self.descriptionView.frame.size.height - _pageControl.frame.size.height)/2, _pageControl.frame.size.width, _pageControl.frame.size.height)];
        
        _pageControl.autoresizingMask =
        UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleRightMargin|
        UIViewAutoresizingFlexibleBottomMargin;
        
    }
    return _pageControl;
}

- (UIView *)descriptionLabel {
    
    if (!_descriptionLabel) {
        _descriptionLabel = [[UILabel alloc] init];
        _descriptionLabel.textColor = [UIColor whiteColor];
        _descriptionLabel.font = [UIFont systemFontOfSize:16.0f];
        
        _descriptionLabel.frame = CGRectMake(12, 0,  self.pageControl.frame.origin.x, self.descriptionView.frame.size.height);
        
        _descriptionLabel.autoresizingMask =
        UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleBottomMargin;
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

@end

