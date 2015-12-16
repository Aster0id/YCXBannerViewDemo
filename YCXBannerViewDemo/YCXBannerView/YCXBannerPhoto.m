//
//  YCXBannerPhoto.m
//  YCXBannerViewDemo
//
//  Created by 牛萌 on 15/12/16.
//  Copyright © 2015年 self.Aster0id. All rights reserved.
//

#import "YCXBannerPhoto.h"
#import "SDWebImageManager.h"


@interface YCXBannerPhoto ()
{
    BOOL _loadingInProgress;
    id <SDWebImageOperation> _webImageOperation;
}

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL *photoURL;

@end

@implementation YCXBannerPhoto


#pragma mark - Init

- (id)init {
    if ((self = [super init])) {
    }
    return self;
}

- (id)initWithImage:(UIImage *)image {
    if ((self = [super init])) {
        self.image = image;
    }
    return self;
}

- (id)initWithURL:(NSURL *)url {
    if ((self = [super init])) {
        self.photoURL = url;
    }
    return self;
}


#pragma mark - MWPhoto Protocol Methods

- (UIImage *)underlyingImage {
    return _underlyingImage;
}

- (void)loadUnderlyingImageAndNotify {
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    if (_loadingInProgress) return;
    _loadingInProgress = YES;
    @try {
        if (self.underlyingImage) {
            [self imageLoadingComplete];
        } else {
            [self performLoadUnderlyingImageAndNotify];
        }
    }
    @catch (NSException *exception) {
        self.underlyingImage = nil;
        _loadingInProgress = NO;
        [self imageLoadingComplete];
    }
    @finally {
    }
}

// Set the underlyingImage
- (void)performLoadUnderlyingImageAndNotify {
    
    // Get underlying image
    if (_image) {
        
        // We have UIImage!
        self.underlyingImage = _image;
        [self imageLoadingComplete];
        
    } else if (_photoURL) {
        
        /*
         // Check what type of url it is
         if ([[[_photoURL scheme] lowercaseString] isEqualToString:@"assets-library"]) {
         // Load from assets library
         [self _performLoadUnderlyingImageAndNotifyWithAssetsLibraryURL: _photoURL];
         }
         else if ([_photoURL isFileReferenceURL]) {
         // Load from local file async
         [self _performLoadUnderlyingImageAndNotifyWithLocalFileURL: _photoURL];
         }
         else {
         // Load async from web (using SDWebImage)
         [self _performLoadUnderlyingImageAndNotifyWithWebURL: _photoURL];
         }
         */
        
        [self _performLoadUnderlyingImageAndNotifyWithWebURL: _photoURL];
        
    } else {
        
        // Image is empty
        [self imageLoadingComplete];
        
    }
}


/// 图片加载完成
- (void)imageLoadingComplete {
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    // Complete so notify
    _loadingInProgress = NO;
    // Notify on next run loop
    [self performSelector:@selector(postCompleteNotification) withObject:nil afterDelay:0];
}

- (void)postCompleteNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:MWPHOTO_LOADING_DID_END_NOTIFICATION object:self];
}


#pragma mark - Private Methods

// Load from local file
- (void)_performLoadUnderlyingImageAndNotifyWithWebURL:(NSURL *)url {
    @try {
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        _webImageOperation = [manager downloadImageWithURL:url options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            if (expectedSize > 0) {
                float progress = receivedSize / (float)expectedSize;
                NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithFloat:progress], @"progress",
                                      self, @"photo", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:MWPHOTO_PROGRESS_NOTIFICATION object:dict];
            }
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (error) {
                NSLog(@"SDWebImage failed to download image: %@", error);
            }
            _webImageOperation = nil;
            self.underlyingImage = image;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self imageLoadingComplete];
            });
        }];
    } @catch (NSException *e) {
        NSLog(@"Photo from web: %@", e);
        _webImageOperation = nil;
        [self imageLoadingComplete];
    }
}

/*
 // Load from local file
 - (void)_performLoadUnderlyingImageAndNotifyWithLocalFileURL:(NSURL *)url {
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
 @autoreleasepool {
 @try {
 self.underlyingImage = [UIImage imageWithContentsOfFile:url.path];
 if (!_underlyingImage) {
 MWLog(@"Error loading photo from path: %@", url.path);
 }
 } @finally {
 [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
 }
 }
 });
 }
 
 // Load from asset library async
 - (void)_performLoadUnderlyingImageAndNotifyWithAssetsLibraryURL:(NSURL *)url {
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
 @autoreleasepool {
 @try {
 ALAssetsLibrary *assetslibrary = [[ALAssetsLibrary alloc] init];
 [assetslibrary assetForURL:url
 resultBlock:^(ALAsset *asset){
 ALAssetRepresentation *rep = [asset defaultRepresentation];
 CGImageRef iref = [rep fullScreenImage];
 if (iref) {
 self.underlyingImage = [UIImage imageWithCGImage:iref];
 }
 [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
 }
 failureBlock:^(NSError *error) {
 self.underlyingImage = nil;
 MWLog(@"Photo from asset library error: %@",error);
 [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
 }];
 } @catch (NSException *e) {
 MWLog(@"Photo from asset library error: %@", e);
 [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
 }
 }
 });
 }
 */

@end
