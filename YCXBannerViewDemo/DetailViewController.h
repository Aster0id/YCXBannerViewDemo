//
//  DetailViewController.h
//  YCXBannerViewDemo
//
//  Created by 牛萌 on 15/12/16.
//  Copyright © 2015年 self.Aster0id. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, YCXType) {
    YCXTypeLocal,
    YCXTypeNetwork,
};

@interface DetailViewController : UIViewController

@property (nonatomic, assign) YCXType type;

@end
