//
//  NotificationService.m
//  XGService
//
//  Created by uwei on 09/08/2017.
//  Copyright © 2017 tyzual. All rights reserved.
//

#import "NotificationService.h"
#import "XGExtension.h"
#import <UIKit/UIKit.h>

@interface NotificationService ()

/// content handler
@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
/// notification content
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

/// An object that modifies the content of a remote notification before it's delivered to the user.
@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent *_Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    /// 非广州集群，请开启对应集群配置（广州集群无需使用）
    //    [XGExtension defaultManager].reportDomainName = @"tpns.hk.tencent.com"; /// 香港集群
    //    [XGExtension defaultManager].reportDomainName = @"tpns.sgp.tencent.com";  /// 新加坡集群
    //    [XGExtension defaultManager].reportDomainName = @"tpns.sh.tencent.com";  /// 上海集群

    /// 此处的app配置信息需要与主target保持一致
    [[XGExtension defaultManager] handleNotificationRequest:request
                                                   accessID:1600007893
                                                  accessKey:@"IX4BGYYG8L4L"
                                             contentHandler:^(NSArray<UNNotificationAttachment *> *_Nullable attachments, NSError *_Nullable error) {
                                                 self.bestAttemptContent.attachments = attachments;
                                                 self.contentHandler(self.bestAttemptContent);
                                             }];
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
