//
//  AppDelegate.m
//  TPNS-Demo
//
//  Created by tyzual on 28/10/2016.
//  Copyright © 2016 tyzual. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate+XGConfig.h"

/// The centralized point of control and coordination for apps running in iOS.
@implementation AppDelegate

#pragma mark - UIApplicationDelegate

/// Tells the delegate that the launch process is almost done and the app is almost ready to run.
/// @param application The singleton app object.
/// @param launchOptions A dictionary indicating the reason the app was launched (if any). The contents of this dictionary may be empty in situations
/// where the user launched the app directly. For information about the possible keys in this dictionary and how to handle them, see Launch Options
/// Keys.
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [XGPush defaultManager].launchOptions = [launchOptions mutableCopy];
    [self xgStart];
    return YES;
}

@end
