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


static const NSTimeInterval kTimeInterval = 5.0f;

@interface YCXBannerView ()
<UIScrollViewDelegate>

@end

@implementation YCXBannerView {
    // 图片的滚动视图
    UIScrollView *_imagesScrollView;
    // 页码
    DDPageControl *_pageControl;
    // 标题
    UILabel *_title;
    // 图片总数
    NSUInteger _imagesTotal;
    // 自动播放定时器
    NSTimer *_autoplayTimer;
}


#pragma mark - Publice Methods
-(void)reloadData {
    // 移除本控件上的所有视图
    for (UIView *view in self.subviews) [view removeFromSuperview];
    
    // _imagesTotal赋值
    _imagesTotal = _imagesArray.count;
    
    if (_imagesTotal>0) {
        
        [self createImagesScrollView];
        [self createBottomView];
        
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
 *
 */
-(void)createBottomView
{
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-31, self.bounds.size.width, 31)];
    bottomView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    [self addSubview:bottomView];
    
    //设置pageControl
    _pageControl = [[DDPageControl alloc] init];
    [_pageControl setType:DDPageControlTypeOnFullOffFull];
    [_pageControl setOnColor:[UIColor redColor]];
    [_pageControl setOffColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8]];
    [_pageControl setIndicatorDiameter:6.0f];
    [_pageControl setIndicatorSpace:8.0f];
    [_pageControl setNumberOfPages:_imagesTotal];
    [_pageControl setCurrentPage:0];
    [_pageControl setCenter:CGPointMake(bottomView.frame.size.width-_pageControl.frame.size.width/2,bottomView.frame.size.height/2)];
    [bottomView addSubview:_pageControl];
    
    _title = [[UILabel alloc] initWithFrame:CGRectMake(12, 0,  _pageControl.frame.origin.x-12, bottomView.frame.size.height)];
    _title.textColor = [UIColor whiteColor];
    _title.font = [UIFont systemFontOfSize:16.0f];
    if (_titleArray.count>0) {
        _title.text = _titleArray[0];
    }
    [bottomView addSubview:_title];
}

/**
 * @brief 创建图片滚动视图
 *
 */
- (void)createImagesScrollView
{
    // 设置图片滚动视图
    _imagesScrollView = [[UIScrollView alloc] init];
    [_imagesScrollView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [_imagesScrollView setBounces:YES];
    [_imagesScrollView setPagingEnabled:YES];
    [_imagesScrollView setDelegate:self];
    [_imagesScrollView setUserInteractionEnabled:YES];
    [_imagesScrollView setShowsHorizontalScrollIndicator:NO];
    [_imagesScrollView setShowsVerticalScrollIndicator:NO];
    
    [_imagesScrollView setContentSize:CGSizeMake((_imagesTotal+2) * self.bounds.size.width,
                                                 self.bounds.size.height)];
    _imagesScrollView.clipsToBounds = YES;
    [_imagesScrollView setContentOffset:CGPointMake(0, 0)];
    [_imagesScrollView scrollRectToVisible:CGRectMake(self.frame.size.width,
                                                      0,
                                                      self.frame.size.width,
                                                      self.frame.size.height)
                                  animated:NO];
    [self addSubview:_imagesScrollView];
    
    
    NSMutableArray *mArray = [_imagesArray mutableCopy];
    
    NSString *lastURL = [_imagesArray lastObject]?[_imagesArray lastObject]:@"";
    [mArray insertObject:lastURL atIndex:0];
    
    NSString *firstURL = [_imagesArray firstObject]?[_imagesArray firstObject]:@"";
    [mArray insertObject:firstURL atIndex:_imagesTotal+1];
    
    for (int i = 0; i<mArray.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(i * self.frame.size.width,
                                     0,
                                     self.frame.size.width,
                                     self.frame.size.height);
        imageView.clipsToBounds = YES;
        imageView.tag = (i == 0 ? (_imagesTotal - 1) : (i== _imagesTotal+1 ? 0 : i - 1));
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        [imageView sd_setImageWithURL:[NSURL URLWithString:mArray[i]]];
        
        
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewWasTapped:)];
        [imageView addGestureRecognizer:singleTap1];

        [_imagesScrollView addSubview:imageView];
        
        
        /*
         UIButton *imgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
         imgBtn.frame = CGRectMake(i * self.frame.size.width,
         0,
         self.frame.size.width,
         self.frame.size.height);
         imgBtn.clipsToBounds = YES;
         imgBtn.tag = i==0 ? 0 : (i==_imagesTotal+1 ? _imagesTotal : i-1);
         [imgBtn sd_setImageWithURL:[NSURL URLWithString:mArray[i]] forState:UIControlStateNormal];
         
         [_imagesScrollView addSubview:imgBtn];
         
         [imgBtn addTarget:self
         action:@selector(clickImage:)
         forControlEvents:UIControlEventTouchUpInside];
         */
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
    _autoplayTimer = [NSTimer scheduledTimerWithTimeInterval:kTimeInterval target:self
                                                    selector:@selector(handleImagesScrollViewTimer:)
                                                    userInfo: nil
                                                     repeats:YES];
}


- (void)handleImagesScrollViewTimer:(NSTimer*)theTimer
{
    CGPoint pt = _imagesScrollView.contentOffset;
    if(pt.x == self.frame.size.width * _imagesTotal) {
        // 如果当前显示的图片为可变数组中的最后一张图片,
        // 则将图片滚动视图的 contentOffset 设置为原点,重新滚动
        [_imagesScrollView setContentOffset:CGPointMake(0, 0)];
        pt = _imagesScrollView.contentOffset;
    }
    //滚动视图
    [_imagesScrollView scrollRectToVisible:CGRectMake(pt.x+self.frame.size.width,
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
    int currentPage = _imagesScrollView.contentOffset.x/_imagesScrollView.frame.size.width;
    
    if (currentPage == 0) {
        // 如果是最前-1,也就是要开始循环的最后一个
        [_imagesScrollView scrollRectToVisible:CGRectMake(self.frame.size.width * _imagesTotal,
                                                          0,
                                                          self.frame.size.width,
                                                          self.frame.size.height)
                                      animated:NO];
    }
    else if (currentPage == (_imagesTotal+1)) {
        // 如果是最后+1,也就是要开始循环的第一个
        [_imagesScrollView scrollRectToVisible:CGRectMake(self.frame.size.width,
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
                       _imagesTotal-1:
                       (imageIndex == _imagesTotal +1?0:imageIndex - 1));
    _pageControl.currentPage = index;
    if (_titleArray.count>index) {
        _title.text = self.titleArray[index];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_imagesTotal>0) {
        [self reloadData];
//        [self createImagesScrollView];
//        [self createBottomView];
    }
}

@end

