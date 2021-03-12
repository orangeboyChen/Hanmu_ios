//
//  TPNSCommonMethod.m
//  TPNS-Demo-Cloud
//
//  Created by boblv on 2020/4/16.
//  Copyright © 2020 TPNS of Tencent. All rights reserved.
//

#import "TPNSCommonMethod.h"
#import "XGPush.h"
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>
#endif

/// TPNS Common Method
@implementation TPNSCommonMethod

+ (void)showAlertViewWithText:(NSString *)title {
    [TPNSCommonMethod showAlertViewWithText:title message:nil];
}

+ (void)showAlertViewWithText:(NSString *)title message:(nullable NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        UIViewController *rootViewController = appdelegate.window.rootViewController;
        if (rootViewController && [rootViewController isKindOfClass:[UIViewController class]]) {
            [self showAlert:title message:message viewController:rootViewController completion:nil];
        }
    });
}

+ (UIAlertController *)initAlert:(nullable NSString *)title
                         message:(nullable NSString *)message
                 inputTextTitles:(nullable NSArray *)inputTextTitles
               otherButtonTitles:(nullable NSArray *)otherButtonTitles
                  viewController:(UIViewController *)viewController
                           block:(nullable TPNSUIAlertCompletionBlock)block {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {
                                                             if (block) {
                                                                 block(alertController, 0);
                                                             }
                                                         }];
    [alertController addAction:cancleAction];

    int currentIndex = 0;
    for (NSString *inputTextTitle in inputTextTitles) {
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *_Nonnull textField) {
            textField.placeholder = inputTextTitle;
        }];
    }

    currentIndex = 0;
    for (NSString *buttonTitle in otherButtonTitles) {
        int buttonIndex = currentIndex++;
        UIAlertAction *action = [UIAlertAction actionWithTitle:buttonTitle
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {
                                                           if (block) {
                                                               block(alertController, buttonIndex);
                                                           }
                                                       }];
        [alertController addAction:action];
    }

    return alertController;
}

+ (void)showAlert:(nullable NSString *)title
           message:(nullable NSString *)message
    viewController:(UIViewController *)viewController
        completion:(void (^__nullable)(UIAlertController *alertController))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [self initAlert:title
                                                     message:message
                                             inputTextTitles:nil
                                           otherButtonTitles:nil
                                              viewController:viewController
                                                       block:nil];
        [self presentAlertController:alertController fromViewController:viewController completion:completion];
    });
}

+ (void)showAlert:(nullable NSString *)title
              message:(nullable NSString *)message
      inputTextTitles:(nullable NSArray *)inputTextTitles
    otherButtonTitles:(nullable NSArray *)otherButtonTitles
       viewController:(UIViewController *)viewController
                block:(nullable TPNSUIAlertCompletionBlock)block
           completion:(void (^__nullable)(UIAlertController *alertController))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [self initAlert:title
                                                     message:message
                                             inputTextTitles:inputTextTitles
                                           otherButtonTitles:otherButtonTitles
                                              viewController:viewController
                                                       block:block];

        [self presentAlertController:alertController fromViewController:viewController completion:completion];
    });
}

+ (void)presentAlertController:(UIAlertController *)alertController
            fromViewController:(UIViewController *)viewController
                    completion:(void (^__nullable)(UIAlertController *alertController))completion {
    //    if (vc.presentedViewController) {
    //        [vc.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    //    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [viewController presentViewController:alertController
                                     animated:true
                                   completion:^{
                                       if (completion) {
                                           completion(alertController);
                                       }
                                   }];
    });
}

@end
