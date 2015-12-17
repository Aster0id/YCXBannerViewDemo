//
//  YCXBannerView.h
//  YCXBannerViewDemo
//
//  Created by 牛萌 on 15/12/16.
//  Copyright © 2015年 self.Aster0id. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YCXBannerPhoto.h"


@class YCXBannerView;


@protocol YCXBannerViewDelegate <NSObject>

/**
 *	@brief	点击图片后, 获取被点击图片在图片数组中的位置
 *
 *  @param  bannerView YCXBannerView控件
 *	@param 	index 被点击图片在图片数组中的位置
 *
 */
- (void)bannerView:(YCXBannerView *)bannerView clickAtIndex:(NSInteger)index;

@end


@interface YCXBannerView : UIView

/// 图片数组
@property (nonatomic, strong) NSArray *imagesArray;

/// 标题数组
@property (nonatomic, strong) NSArray *titleArray;

/// 是否自动循环滚动, 默认不自动循环
@property (nonatomic, assign, getter = isAutoplay) BOOL autoplay;

/// BannerView控件的委托
@property (nonatomic, weak) IBOutlet id<YCXBannerViewDelegate> delegate;


/**
 *  @brief 重新加载数据
 */
- (void)reloadData;


/**
 *	@brief	重新加载数据
 *
 *	@param 	imagesArray   图片数组
 *	@param 	isAutoplay 	是否自动循环滚动
 *
 *  @see  - (void)reloadData;
 */
- (void)resetBannerViewWithImagesArray:(NSArray *)imagesArray andAutoplay:(BOOL)autoplay;

@end
