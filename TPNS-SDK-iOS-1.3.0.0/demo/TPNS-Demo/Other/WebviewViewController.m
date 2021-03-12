//
//  WebviewViewController.m
//  TPNS-Demo-Cloud
//
//  Created by boblv on 2020/5/10.
//  Copyright © 2020 TPNS of Tencent. All rights reserved.
//

#import "WebviewViewController.h"
#import "TPNSCommonMethod.h"
#import <WebKit/WebKit.h>

@interface WebviewViewController () <WKUIDelegate, WKNavigationDelegate>

@end

/// UIViewController contain  WKWebView to Display web page
@implementation WebviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    /// hide tabBarController
    self.tabBarController.tabBar.hidden = true;

    // WKWebView init
    // config为创建好的配置对象
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, TPNS_SCREEN_WIDTH, TPNS_SCREEN_HEIGHT) configuration:config];
    // UI代理
    webView.UIDelegate = self;
    //导航代理
    webView.navigationDelegate = self;
    [self.view addSubview:webView];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:_url];
    [webView loadRequest:request];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
