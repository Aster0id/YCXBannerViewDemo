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
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(setProgressFromNotification:)
                                                     name:kYCXBannerPhotoProgressNotification
                                                   object:nil];
        
        // Listen for MWPhoto notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleMWPhotoLoadingDidEndNotification:)
                                                     name:kYCXBannerPhotoLoadingDidEndNotification
                                                   object:nil];
        
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewWasTapped:)];
        [self addGestureRecognizer:singleTap];
        
    }
    return self;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private Methods

- (void)viewWasTapped:(UITapGestureRecognizer *)gesture {
    if (self.tapPhotoView) {
        self.tapPhotoView(self);
    }
}

- (void)handleMWPhotoLoadingDidEndNotification:(NSNotification *)notification {
    YCXBannerPhoto *photo = [notification object];
    if (photo == self.photo) {
        if ([photo underlyingImage]) {
            [self displayImage];
        } else {
            [self displayImageFailure];
        }
    }
}

// Get and display image
- (void)displayImage {
    [self.imageView setImage:[self.photo underlyingImage]];
}

// Image failed so just show black!
- (void)displayImageFailure {
    //TODO
}


#pragma mark - Loading Progress

- (void)setProgressFromNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *dict = [notification object];
        YCXBannerPhoto *photoWithProgress = [dict objectForKey:@"photo"];
        if (photoWithProgress == _photo) {
            NSLog(@"%f", [[dict valueForKey:@"progress"] floatValue]);
            // float progress = [[dict valueForKey:@"progress"] floatValue];
            // _loadingIndicator.progress = MAX(MIN(1, progress), 0);
        }
    });
}

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
//    if (_photo && photo == nil) {
//        if ([_photo respondsToSelector:@selector(cancelAnyLoading)]) {
//            [_photo cancelAnyLoading];
//        }
//    }
    _photo = photo;
    
    UIImage *image = [_photo underlyingImage];
    if (image) {
        [self displayImage];
    } else {
        [_photo loadUnderlyingImageAndNotify];
        [self showLoadingIndicator];
    }
}


@end
