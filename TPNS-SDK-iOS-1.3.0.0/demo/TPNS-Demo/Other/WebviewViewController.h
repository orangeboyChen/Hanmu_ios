//
//  WebviewViewController.h
//  TPNS-Demo-Cloud
//
//  Created by boblv on 2020/5/10.
//  Copyright © 2020 TPNS of Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// UIViewController contain  WKWebView to Display web page
@interface WebviewViewController : UIViewController

/// Web address
@property (nonatomic, strong) NSURL *url;

@end

NS_ASSUME_NONNULL_END
