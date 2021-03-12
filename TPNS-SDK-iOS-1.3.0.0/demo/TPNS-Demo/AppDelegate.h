//
//  AppDelegate.h
//  TPNS-Demo
//
//  Created by tyzual on 28/10/2016.
//  Copyright © 2016 tyzual. All rights reserved.
//

#import <UIKit/UIKit.h>

/// The centralized point of control and coordination for apps running in iOS.
@interface AppDelegate : UIResponder <UIApplicationDelegate>

/// apps window
@property (strong, nonatomic) UIWindow *window;
/// 是否成功注册TPNS
@property (nonatomic, assign) BOOL isTPNSRegistSuccess;

@end
