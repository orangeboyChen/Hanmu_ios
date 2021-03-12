//
//  AppDelegate+XGConfig.h
//  TPNS-Demo-Cloud
//
//  Created by rockzuo on 2019/12/3.
//  Copyright © 2019 XG of Tencent. All rights reserved.
//

#import "AppDelegate.h"
#import "XGPush.h"

NS_ASSUME_NONNULL_BEGIN

#define TPNS_ACCESS_ID 1600007893
#define TPNS_ACCESS_KEY @"IX4BGYYG8L4L"
/// The centralized point of control and coordination for apps running in iOS. TPNS SDK start。
@interface AppDelegate (XGConfig)

/// start TPNS SDK
- (void)xgStart;

@end

NS_ASSUME_NONNULL_END
