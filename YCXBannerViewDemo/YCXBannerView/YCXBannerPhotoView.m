//
//  YCXBannerPhotoView.m
//  YCXBannerViewDemo
//
//  Created by 牛萌 on 15/12/16.
//  Copyright © 2015年 self.Aster0id. All rights reserved.
//

#import "YCXBannerPhotoView.h"

@interface YCXBannerPhotoView ()

@property (nonatomic, strong) UIImageView *imageView;

@end


@implementation YCXBannerPhotoView


#pragma mark - System Methods

- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.index = 0;
        
        [self addSubview:self.imageView];
        
        NSArray *photoViewScrollViewHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imageView]-0-|" options:0 metrics:nil views:@{@"imageView":self.imageView}];
        NSArray *photoViewScrollViewVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[imageView]-0-|" options:0 metrics:nil views:@{@"imageView":self.imageView}];
        [self addConstraints:photoViewScrollViewHorizontalConstraints];
        [self addConstraints:photoViewScrollViewVerticalConstraints];
        
        // 监听图片加载中的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setProgressFromNotification:) name:kYCXBannerPhotoProgressNotification object:nil];
        
        // 监听图片加载完成的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePhotoLoadingDidEndNotification:) name:kYCXBannerPhotoLoadingDidEndNotification object:nil];
        
        // 添加点击事件
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewWasTapped:)];
        [self addGestureRecognizer:singleTap];
        
    }
    return self;
}


- (void)dealloc {
    // 移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Private Methods

- (void)viewWasTapped:(UITapGestureRecognizer *)gesture {
    // 点击视图, 触发Block
    if (self.tapPhotoView) {
        self.tapPhotoView(self);
    }
}


#pragma mark - Photo Load Did End

// 收到图片加载完成通知后的执行方法
- (void)handlePhotoLoadingDidEndNotification:(NSNotification *)notification {
    // 声明通知对应的对象
    YCXBannerPhoto *photo = [notification object];
    
    // 如果对象对应的是当前控件的Photo
    if (photo == self.photo) {
        // 并且Photo的最终显示图片存在
        if ([photo underlyingImage]) {
            // 那么, 在控件中显示图片
            [self displayImage];
        } else {
            // 否则, 显示图片加载失败
            [self displayImageFailure];
        }
    }
}

// 在控件中显示图片
- (void)displayImage {
    [self.imageView setImage:[self.photo underlyingImage]];
}

// 在控件中显示图片加载失败
- (void)displayImageFailure {
    //TODO
}


#pragma mark - Loading Photo

/// 收到图片加载中通知后的执行方法
- (void)setProgressFromNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *dict = [notification object];
        YCXBannerPhoto *photoWithProgress = [dict objectForKey:@"photo"];
        if (photoWithProgress == _photo) {
            //TODO
            // NSLog(@"%f", [[dict valueForKey:@"progress"] floatValue]);
            // float progress = [[dict valueForKey:@"progress"] floatValue];
            // _loadingIndicator.progress = MAX(MIN(1, progress), 0);
        }
    });
}

/// 显示加载中的指示器
- (void)showLoadingIndicator {
    // TODO
}


#pragma mark - setter/getter

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.translatesAutoresizingMaskIntoConstraints = YES;
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _imageView;
}

- (void)setPhoto:(YCXBannerPhoto *)photo {
    if (_photo && photo != _photo) {
        if ([_photo respondsToSelector:@selector(cancelAnyLoading)]) {
            [_photo cancelAnyLoading];
        }
    }
    _photo = photo;
    
    UIImage *image = [_photo underlyingImage];
    // 如果最终显示图片存在, 直接显示图片
    if (image) {
        [self displayImage];
    } else {
        // 否则, Photo加载图片并发送通知
        [_photo loadUnderlyingImageAndNotify];
        // 同时显示加载中的指示器
        [self showLoadingIndicator];
    }
}


@end
