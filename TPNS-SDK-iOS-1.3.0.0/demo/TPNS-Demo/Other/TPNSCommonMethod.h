//
//  TPNSCommonMethod.h
//  TPNS-Demo-Cloud
//
//  Created by boblv on 2020/4/16.
//  Copyright © 2020 TPNS of Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

#ifndef TPNS_DISPATCH_MAIN_SYNC_SAFE
#define TPNS_DISPATCH_MAIN_SYNC_SAFE(block)              \
    if ([NSThread isMainThread]) {                       \
        block();                                         \
    } else {                                             \
        dispatch_sync(dispatch_get_main_queue(), block); \
    }
#endif

#define TPNS_WEAKIFY(var) __weak typeof(var) XYWeak_##var = var;
#define TPNS_STRONGIFY(var)                                                                                                    \
    _Pragma("clang diagnostic push") _Pragma("clang diagnostic ignored \"-Wshadow\"") __strong typeof(var) var = XYWeak_##var; \
    _Pragma("clang diagnostic pop")

#define TPNS_SCREEN_WIDTH UIScreen.mainScreen.bounds.size.width
#define TPNS_SCREEN_HEIGHT UIScreen.mainScreen.bounds.size.height

typedef void (^TPNSUIAlertCompletionBlock)(UIAlertController *alertController, NSInteger buttonIndex);

/// TPNS Common Method
@interface TPNSCommonMethod : NSObject
/// show alert view
/// @param title title of alert
+ (void)showAlertViewWithText:(NSString *)title;
/// show alert view
/// @param title title of alert
/// @param message message of alert
+ (void)showAlertViewWithText:(NSString *)title message:(nullable NSString *)message;
/// show alert view
/// @param title title of alert
/// @param message message of alert
/// @param viewController UIViewController to show alert
/// @param completion The block to execute after the presentation finishes. This block has no return value and takes no parameters. You may specify
/// nil for this parameter.
+ (void)showAlert:(nullable NSString *)title
           message:(nullable NSString *)message
    viewController:(nonnull UIViewController *)viewController
        completion:(void (^__nullable)(UIAlertController *alertController))completion;
/// show alert view
/// @param alertController alertController to show
/// @param viewController UIViewController to show alert
/// @param completion completion
+ (void)presentAlertController:(UIAlertController *)alertController
            fromViewController:(UIViewController *)viewController
                    completion:(void (^__nullable)(UIAlertController *alertController))completion;

+ (void)showAlert:(nullable NSString *)title
              message:(nullable NSString *)message
      inputTextTitles:(nullable NSArray *)inputTextTitles
    otherButtonTitles:(nullable NSArray *)otherButtonTitles
       viewController:(UIViewController *)viewController
                block:(nullable TPNSUIAlertCompletionBlock)block
           completion:(void (^__nullable)(UIAlertController *alertController))completion;

@end

NS_ASSUME_NONNULL_END
