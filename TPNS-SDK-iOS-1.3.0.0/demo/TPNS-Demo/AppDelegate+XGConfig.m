//
//  AppDelegate+XGConfig.m
//  TPNS-Demo-Cloud
//
//  Created by rockzuo on 2019/12/3.
//  Copyright © 2019 XG of Tencent. All rights reserved.
//

/********提供TPNS启动示例及XGPushDelegate代理********/

#import "AppDelegate+XGConfig.h"
#import "TPNSCommonMethod.h"
#import "ViewController.h"
#import "XGPushPrivate.h" /// 非广州集群需要导入此头文件（域名配置）

@interface AppDelegate () <XGPushDelegate>

@end

/// The centralized point of control and coordination for apps running in iOS. TPNS SDK start。
@implementation AppDelegate (XGConfig)

/// 启动TPNS
- (void)xgStart {
    /// 控制台打印TPNS日志，开发调试建议开启
    [[XGPush defaultManager] setEnableDebug:YES];

    /// 自定义通知栏消息行为，有自定义消息行为需要使用
    //    [self setNotificationConfigure];

    /// 非广州集群，请开启对应集群配置（广州集群无需使用），此函数需要在startXGWithAccessID函数之前调用
    //    [self configHost];

    /// 启动TPNS服务
    [[XGPush defaultManager] startXGWithAccessID:TPNS_ACCESS_ID accessKey:TPNS_ACCESS_KEY delegate:self];

    /// 角标数目清零,通知中心清空
    if ([XGPush defaultManager].xgApplicationBadgeNumber > 0) {
        TPNS_DISPATCH_MAIN_SYNC_SAFE(^{
            [XGPush defaultManager].xgApplicationBadgeNumber = 0;
        });
    }
}

/// 自定义通知栏消息行为（无自定义需求无需使用）
- (void)setNotificationConfigure {
    XGNotificationAction *action1 = [XGNotificationAction actionWithIdentifier:@"xgaction001"
                                                                         title:@"xgAction1"
                                                                       options:XGNotificationActionOptionNone];
    XGNotificationAction *action2 = [XGNotificationAction actionWithIdentifier:@"xgaction002"
                                                                         title:@"xgAction2"
                                                                       options:XGNotificationActionOptionDestructive];
    if (action1 && action2) {
        XGNotificationCategory *category = [XGNotificationCategory categoryWithIdentifier:@"xgCategory"
                                                                                  actions:@[ action1, action2 ]
                                                                        intentIdentifiers:@[]
                                                                                  options:XGNotificationCategoryOptionNone];

        XGNotificationConfigure *configure = [XGNotificationConfigure
            configureNotificationWithCategories:[NSSet setWithObject:category]
                                          types:XGUserNotificationTypeAlert | XGUserNotificationTypeBadge | XGUserNotificationTypeSound];
        if (configure) {
            [[XGPush defaultManager] setNotificationConfigure:configure];
        }
    }
}

/// 非广州集群，请开启对应集群配置（广州集群无需使用）
- (void)configHost {
    /// 香港集群
    //    [[XGPush defaultManager] configureClusterDomainName:@"tpns.hk.tencent.com"];
    /// 新加坡集群
    //    [[XGPush defaultManager] configureClusterDomainName:@"tpns.sgp.tencent.com"];
    /// 上海集群
    //    [[XGPush defaultManager] configureClusterDomainName:@"tpns.sh.tencent.com"];
}

/********XGPush代理，提供注册机反注册结果回调，消息接收机消息点击回调，清除角标回调********/

#pragma mark *** XGPushDelegate ***

/// 注册推送服务成功回调
/// @param deviceToken APNs 生成的Device Token
/// @param xgToken TPNS 生成的 Token，推送消息时需要使用此值。TPNS 维护此值与APNs 的 Device Token的映射关系
/// @param error 错误信息，若error为nil则注册推送服务成功
- (void)xgPushDidRegisteredDeviceToken:(nullable NSString *)deviceToken xgToken:(nullable NSString *)xgToken error:(nullable NSError *)error {
    NSLog(@"%s, result %@, error %@", __FUNCTION__, error ? @"NO" : @"OK", error);
    NSString *errorStr = !error ? NSLocalizedString(@"success", nil) : NSLocalizedString(@"failed", nil);
    NSString *message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"register_app", nil), errorStr];
    [TPNSCommonMethod showAlertViewWithText:message];
    //在注册完成后上报角标数目
    if (!error) {
        //重置服务端自动+1基数
        [[XGPush defaultManager] setBadge:0];
    }
    //设置是否注册成功
    self.isTPNSRegistSuccess = error ? false : true;
}

/// 注册推送服务失败回调
/// @param error 注册失败错误信息
- (void)xgPushDidFailToRegisterDeviceTokenWithError:(nullable NSError *)error {
    NSLog(@"%s, errorCode:%ld, errMsg:%@", __FUNCTION__, (long)error.code, error.localizedDescription);
    [TPNSCommonMethod showAlertViewWithText:error.localizedDescription];
}

/// 注销推送服务回调
- (void)xgPushDidFinishStop:(BOOL)isSuccess error:(nullable NSError *)error {
    NSString *errorStr = !error ? NSLocalizedString(@"success", nil) : NSLocalizedString(@"failed", nil);
    NSString *message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"unregister_app", nil), errorStr];
    [TPNSCommonMethod showAlertViewWithText:message];
    //设置是否注册成功
    if (!error) {
        self.isTPNSRegistSuccess = false;
    }
}

/// 统一接收消息的回调
/// @param notification 消息对象(有2种类型NSDictionary和UNNotification具体解析参考示例代码)
/// @note 此回调为前台收到通知消息及所有状态下收到静默消息的回调（消息点击需使用统一点击回调）
/// 区分消息类型说明：xg字段里的msgtype为1则代表通知消息,msgtype为2则代表静默消息,msgtype为9则代表本地通知
- (void)xgPushDidReceiveRemoteNotification:(nonnull id)notification withCompletionHandler:(nullable void (^)(NSUInteger))completionHandler {
    NSDictionary *notificationDic = nil;
    if ([notification isKindOfClass:[UNNotification class]]) {
        notificationDic = ((UNNotification *)notification).request.content.userInfo;
        completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
    } else if ([notification isKindOfClass:[NSDictionary class]]) {
        notificationDic = notification;
        completionHandler(UIBackgroundFetchResultNewData);
    }
    NSLog(@"receive notification dic: %@", notificationDic);
}

/// 统一点击回调
/// @param response 如果iOS 10+/macOS 10.14+则为UNNotificationResponse，低于目标版本则为NSDictionary
/// 区分消息类型说明：xg字段里的msgtype为1则代表通知消息,msgtype为9则代表本地通知
- (void)xgPushDidReceiveNotificationResponse:(nonnull id)response withCompletionHandler:(nonnull void (^)(void))completionHandler {
    NSLog(@"[TPNS Demo] click notification");
    if ([response isKindOfClass:[UNNotificationResponse class]]) {
        /// iOS10+消息体获取
        NSLog(@"notification dic: %@", ((UNNotificationResponse *)response).notification.request.content.userInfo);
    } else if ([response isKindOfClass:[NSDictionary class]]) {
        /// <IOS10消息体获取
        NSLog(@"notification dic: %@", response);
    }
    completionHandler();
}

/// 角标设置成功回调
/// @param isSuccess 设置角标是否成功
/// @param error 错误标识，若设置不成功会返回
- (void)xgPushDidSetBadge:(BOOL)isSuccess error:(nullable NSError *)error {
    NSLog(@"%s, result %@, error %@", __FUNCTION__, error ? @"NO" : @"OK", error);
}

@end
