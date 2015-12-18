# YCXBannerViewDemo

![CocoaPods Version](https://img.shields.io/cocoapods/v/YCXBannerView.svg?style=flat)
[![License](https://img.shields.io/github/license/aster0id/YCXBannerViewDemo.svg?style=flat)](https://github.com/Aster0id/YCXBannerViewDemo/blob/master/LICENSE)

很好用的轮播控件, 可以加载本地图片资源, 可以通过URL链接加载网络图片. 同时可以为图片添加描述文字.


## 效果

### Gif

<img src="https://github.com/Aster0id/YCXBannerViewDemo/blob/master/Assets/YCXBannerView-record.gif" width="320">

### 录制视频

<iframe src="https://vid.me/e/qVJw" frameborder="0" allowfullscreen webkitallowfullscreen mozallowfullscreen scrolling="no" height="480" width="268"></iframe>

[YCXBannerView-record](https://vid.me/qVJw)


## 安装

### 通过CocoaPods

```ruby

	# Your Podfile
	platform :ios, '7.0'
	pod 'YCXBannerView'
	
```


## 使用

```objc


	images = @[
              [YCXBannerPhoto initWithURL:@"https://raw.githubusercontent.com/Aster0id/TestData/master/img1.jpg" andCaption:nil],
              [YCXBannerPhoto initWithURL:@"https://raw.githubusercontent.com/Aster0id/TestData/master/img2.jpg" andCaption:@"好风景"],
              [YCXBannerPhoto initWithURL:@"https://raw.githubusercontent.com/Aster0id/TestData/master/img3.jpg" andCaption:nil],
              [[YCXBannerPhoto alloc] initWithURL:@"https://raw.githubusercontent.com/Aster0id/TestData/master/img4.jpg"]
              ];
              
    YCXBannerView *banner = [[YCXBannerView alloc] init];
    banner.photosArray = [self randomPhotoArray];
    banner.delegate = images;
    banner.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width/2);
    [self.view addSubview:banner];

    [banner reloadData];
    

```


## TODO

* BannerView可以设置更多的属性
* 添加图片加载中的处理
* 添加图片加载失败的处理


## 作者

Aster0id, aster0id@sina.com


## License

MIT License


