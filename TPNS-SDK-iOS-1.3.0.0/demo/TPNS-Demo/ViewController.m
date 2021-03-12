//
//  ViewController.m
//  TPNS-Demo
//
//  Created by tyzual on 28/10/2016.
//  Copyright © 2016 tyzual. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate+XGConfig.h"
#import "TPNSCommonMethod.h"
#import "XGLocalNotification.h"

#pragma mark - ********账号类型枚举，用于账号操作时区分账号类型********

/**
  @brief 账号类型，用以细分账号类别,可以在TPNS控制台中修改
 */

typedef NS_ENUM(NSUInteger, XGPushTokenAccountType) {
    XGPushTokenAccountTypeUNKNOWN = (0),         // 未知类型，单账号绑定默认使用
    XGPushTokenAccountTypeCUSTOM = (1),          // 自定义
    XGPushTokenAccountTypeIDFA = (1001),         // 广告唯一标识 IDFA
    XGPushTokenAccountTypePHONE_NUMBER = (1002), // 手机号码
    XGPushTokenAccountTypeWX_OPEN_ID = (1003),   // 微信 OPENID
    XGPushTokenAccountTypeQQ_OPEN_ID = (1004),   // QQ OPENID
    XGPushTokenAccountTypeEMAIL = (1005),        // 邮箱
    XGPushTokenAccountTypeSINA_WEIBO = (1006),   // 新浪微博
    XGPushTokenAccountTypeALIPAY = (1007),       // 支付宝
    XGPushTokenAccountTypeTAOBAO = (1008),       // 淘宝
    XGPushTokenAccountTypeDOUBAN = (1009),       // 豆瓣
    XGPushTokenAccountTypeFACEBOOK = (1010),     // FACEBOOK
    XGPushTokenAccountTypeTWITTER = (1011),      // TWITTER
    XGPushTokenAccountTypeGOOGLE = (1012),       // GOOGLE
    XGPushTokenAccountTypeBAIDU = (1013),        // 百度
    XGPushTokenAccountTypeJINGDONG = (1014),     // 京东
    XGPushTokenAccountTypeLINKEDIN = (1015)      // LINKEDIN
};

typedef NS_ENUM(NSInteger, TagOperationType) { Add = 0, Delete = 1, Update = 2, Clear = 3 };
typedef NS_ENUM(NSInteger, AccountOperationType) { AccountAdd = 0, AccountDelete = 1, AccountClear = 2 };
typedef NS_ENUM(NSInteger, AttributeOperationType) { AttributeAdd = 0, AttributeDelete = 1, AttributeUpdate = 2, AttributeClear = 3 };
static NSString *const cellID = @"xgdemoCellID";

/// TPNS features ViewController
@interface ViewController () <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, XGPushTokenManagerDelegate> {
    // input account title
    NSString *inputAccountTitle;
    // input tag title
    NSString *inputTagTitle;
    // input attribute title
    NSString *inputAttributeTitle;
    // input badge title
    NSString *inputBadgeTitle;
    // account type title
    NSString *accountTypeTitle;
}
/// tableview
@property (weak, nonatomic) IBOutlet UITableView *APITableView;
/// source arrary
@property (strong, nonatomic) NSArray *apiLists;
/// source arrary of api types
@property (strong, nonatomic) NSArray *apiKindLists;
/// source arrary of account types
@property (nonatomic, strong) NSMutableArray *accoutTypesMutArray;
/// source arrary of  action value
@property (nonatomic, strong) NSArray *actionValuesArray;
/// account type
@property (nonatomic, assign) XGPushTokenAccountType accountType;
@end

/// TPNS features ViewController
@implementation ViewController

/// Called after the controller's view is loaded into memory.
- (void)viewDidLoad {
    [super viewDidLoad];

    inputAccountTitle = NSLocalizedString(@"account_title", nil);
    inputTagTitle = NSLocalizedString(@"tag_title", nil);
    inputAttributeTitle = NSLocalizedString(@"attributes_title", nil);
    inputBadgeTitle = NSLocalizedString(@"badge_title", nil);
    //账号类型名称
    NSArray *actionTitlesArray = @[
        @"account_type_unknow", @"account_type_custom", @"account_type_idfa", @"account_type_phone_number", @"account_type_wechat",
        @"account_type_qq", @"account_type_email", @"account_type_sina_webo", @"account_type_alipay", @"account_type_taobao", @"account_type_douban",
        @"account_type_facebook", @"account_type_twitter", @"account_type_google", @"account_type_baidu", @"account_type_jd", @"account_type_linkin"
    ];
    //账号类型
    _actionValuesArray = @[
        @(XGPushTokenAccountTypeUNKNOWN), @(XGPushTokenAccountTypeCUSTOM), @(XGPushTokenAccountTypeIDFA), @(XGPushTokenAccountTypePHONE_NUMBER),
        @(XGPushTokenAccountTypeWX_OPEN_ID), @(XGPushTokenAccountTypeQQ_OPEN_ID), @(XGPushTokenAccountTypeEMAIL), @(XGPushTokenAccountTypeSINA_WEIBO),
        @(XGPushTokenAccountTypeALIPAY), @(XGPushTokenAccountTypeTAOBAO), @(XGPushTokenAccountTypeDOUBAN), @(XGPushTokenAccountTypeFACEBOOK),
        @(XGPushTokenAccountTypeTWITTER), @(XGPushTokenAccountTypeGOOGLE), @(XGPushTokenAccountTypeBAIDU), @(XGPushTokenAccountTypeJINGDONG),
        @(XGPushTokenAccountTypeLINKEDIN)
    ];

    _accoutTypesMutArray = [NSMutableArray arrayWithCapacity:0];
    for (NSString *title in actionTitlesArray) {
        NSString *accoutTypeString = NSLocalizedString(title, nil);
        [_accoutTypesMutArray addObject:accoutTypeString];
    }
    _accountType = XGPushTokenAccountTypeUNKNOWN;

    self.apiKindLists = @[
        NSLocalizedString(@"account_section", nil), NSLocalizedString(@"tag_section", nil), NSLocalizedString(@"attributes_section", nil),
        NSLocalizedString(@"app_section", nil), NSLocalizedString(@"local_notification_section", nil)
    ];
    self.apiLists = @[
        @[
            NSLocalizedString(@"bind_account", nil), NSLocalizedString(@"unbind_account", nil),
            NSLocalizedString(@"clear_account", nil)
        ],
        @[
            NSLocalizedString(@"bind_tag", nil), NSLocalizedString(@"unbind_tag", nil), NSLocalizedString(@"update_tag", nil),
            NSLocalizedString(@"clear_tag", nil)
        ],
        @[
            NSLocalizedString(@"bind_attributes", nil), NSLocalizedString(@"unbind_attributes", nil), NSLocalizedString(@"update_attributes", nil),
            NSLocalizedString(@"clear_attributes", nil)
        ],
        @[
            NSLocalizedString(@"register_app", nil), NSLocalizedString(@"unregister_app", nil), NSLocalizedString(@"device_token", nil),
            NSLocalizedString(@"set_badge", nil), NSLocalizedString(@"upload_log", nil)
        ],
        @[
            NSLocalizedString(@"add_notification", nil), NSLocalizedString(@"remove_notification", nil),
            NSLocalizedString(@"search_notification", nil)
        ]
    ];
    [self.APITableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellID];
    self.APITableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.APITableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [XGPushTokenManager defaultTokenManager].delegate = self;
}

/// Sent to the view controller when the app receives a memory warning.
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableView相关操作

/// Asks the data source to return the number of sections in the table view.
/// @param tableView An object representing the table view requesting this information.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.apiLists.count;
}

/// Asks the delegate for a view object to display in the header of the specified section of the table view.
/// @param tableView The table-view object asking for the view object.
/// @param section The index number of the section containing the header view.
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *titleString = self.apiKindLists[section];
    UIView *customSectionView = [[UIView alloc] init];
    customSectionView.backgroundColor = UIColor.lightGrayColor;
    customSectionView.frame = CGRectMake(0, 0, TPNS_SCREEN_WIDTH, 44.0);

    UILabel *titleLable = [[UILabel alloc] init];
    titleLable.frame = CGRectMake(20, 0, TPNS_SCREEN_WIDTH - 20, 44.0);
    titleLable.text = titleString;
    titleLable.backgroundColor = UIColor.lightGrayColor;
    [customSectionView addSubview:titleLable];

    if (!section) {
        UIButton *btn = [[UIButton alloc] init];
        btn.tag = section;
        [btn setTitle:accountTypeTitle ? accountTypeTitle : NSLocalizedString(@"account_type_chose", nil) forState:UIControlStateNormal];
        [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:12.0];
        btn.backgroundColor = UIColor.grayColor;
        btn.frame = CGRectMake(TPNS_SCREEN_WIDTH - 120, 0, 100, 44.0);
        [btn addTarget:self action:@selector(choseAccountType:) forControlEvents:UIControlEventTouchUpInside];
        [customSectionView addSubview:btn];
    }

    return customSectionView;
}

/// Tells the data source to return the number of rows in a given section of a table view.
/// @param tableView The table-view object requesting this information.
/// @param section An index number identifying a section in tableView.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSArray *)self.apiLists[section]).count;
}

/// Asks the data source for a cell to insert in a particular location of the table view.
/// @param tableView A table-view object requesting the cell.
/// @param indexPath An index path locating a row in tableView.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.textLabel.text = ((NSArray *)self.apiLists[indexPath.section])[indexPath.row];

    return cell;
}

/// Asks the delegate for the height to use for the header of a particular section.
/// @param tableView The table-view object requesting this information.
/// @param section An index number identifying a section of tableView .
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0f;
}

/// Tells the delegate that the specified row is now selected.
/// @param tableView A table-view object informing the delegate about the new row selection.
/// @param indexPath An index path locating the new selected row in tableView.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == AccountClear) {
            [self accountOperationType:AccountClear alertController:nil];
        } else if (indexPath.row == AccountDelete) {
            [self accountOperationType:AccountDelete alertController:nil];
        } else {
            [self showAlert:inputAccountTitle inputTextTitles:@[ @"" ] indexPath:indexPath];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == Clear) {
            [self tagOperationType:Clear alertController:nil];
        } else {
            [self showAlert:inputTagTitle inputTextTitles:@[ @"" ] indexPath:indexPath];
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == AttributeClear) {
            [self attributeOperationType:AttributeClear alertController:nil];
        } else if ((indexPath.row == AttributeDelete)) {
            [self showAlert:inputAttributeTitle inputTextTitles:@[ NSLocalizedString(@"key", nil) ] indexPath:indexPath];
        } else {
            [self showAlert:inputAttributeTitle
                inputTextTitles:@[ NSLocalizedString(@"key", nil), NSLocalizedString(@"value", nil) ]
                      indexPath:indexPath];
        }
    } else if (indexPath.section == 3) {
        if (indexPath.row == 3) {
            [self showAlert:inputBadgeTitle inputTextTitles:@[ @"" ] indexPath:indexPath];
        } else {
            [self otherOperationAtIndexPath:indexPath alertController:nil];
        }
    } else if (indexPath.section == 4) {
        [self localNotificationOperationAtIndexPath:indexPath];
    }
}

#pragma mark - 账号相关操作
//账号相关操作
- (void)accountOperationType:(AccountOperationType)type alertController:(UIAlertController *)alertController {
    switch (type) {
        case AccountAdd: {
            NSString *inputStr = alertController.textFields.firstObject.text;
            [[XGPushTokenManager defaultTokenManager] upsertAccountsByDict:@{ @(_accountType) : inputStr }];
        } break;
        case AccountDelete: {
            NSSet *accountsKeys = [[NSSet alloc] initWithObjects:@(_accountType), nil];
            [[XGPushTokenManager defaultTokenManager] delAccountsByKeys:accountsKeys];
        } break;
        case AccountClear: {
            [[XGPushTokenManager defaultTokenManager] clearAccounts];
        } break;
        default:
            break;
    }
}

#pragma mark - 标签相关操作
//标签相关操作
- (void)tagOperationType:(TagOperationType)type alertController:(UIAlertController *)alertController {
    switch (type) {
        case Add: {
            NSString *inputStr = alertController.textFields.firstObject.text;
            [[XGPushTokenManager defaultTokenManager] appendTags:@[ inputStr ]];
        } break;
        case Delete: {
            NSString *inputStr = alertController.textFields.firstObject.text;
            [[XGPushTokenManager defaultTokenManager] delTags:@[ inputStr ]];
        } break;
        case Update: {
            NSString *inputStr = alertController.textFields.firstObject.text;
            [[XGPushTokenManager defaultTokenManager] clearAndAppendTags:@[ inputStr ]];
        } break;
        case Clear: {
            [[XGPushTokenManager defaultTokenManager] clearTags];
        } break;
        default:
            break;
    }
}

#pragma mark - 用户属性方法调用，支持个性化推送
//用户属性相关操作
- (void)attributeOperationType:(AttributeOperationType)type alertController:(UIAlertController *)alertController {
    switch (type) {
        case AttributeAdd: {
            NSDictionary *attributes = @{ alertController.textFields[0].text : alertController.textFields[1].text };
            [[XGPushTokenManager defaultTokenManager] upsertAttributes:attributes];
        } break;
        case AttributeDelete: {
            NSSet *attributeKeys = [[NSSet alloc] initWithObjects:alertController.textFields[0].text, nil];
            [[XGPushTokenManager defaultTokenManager] delAttributes:attributeKeys];
        } break;
        case AttributeUpdate: {
            NSDictionary *attributes = @{ alertController.textFields[0].text : alertController.textFields[1].text };
            [[XGPushTokenManager defaultTokenManager] clearAndAppendAttributes:attributes];
        } break;
        case AttributeClear: {
            [[XGPushTokenManager defaultTokenManager] clearAttributes];
        } break;
        default:
            break;
    }
}

#pragma mark - 注册、注销、设置badge、获取token、日志上传
//其他相关操作
- (void)otherOperationAtIndexPath:(NSIndexPath *)indexPath alertController:(UIAlertController *)alertController {
    switch (indexPath.row) {
        case 0: {
            [self registerPush];
        } break;
        case 1: {
            [self unRegister:nil];
        } break;
        case 2: {
            [self onGetDeviceToken:nil];
        } break;
        case 3: {
            NSString *inputStr = alertController.textFields.firstObject.text;
            [[XGPush defaultManager] setBadge:[inputStr integerValue]];
        } break;
        case 4: {
            [[XGPush defaultManager] uploadLogCompletionHandler:nil];
        } break;
        default:
            break;
    }
}

//其他相关操作
- (void)localNotificationOperationAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            [self addLocalNotification];
        } break;
        case 1: {
            [self removePendingLocalNotification];
        } break;
        case 2: {
            [self searchPendingLocalNotification];
        } break;
        default:
            break;
    }
}

#pragma mark - 本地通知
/// 新建本地通知示例
- (void)addLocalNotification {
    XGNotificationContent *content = [[XGNotificationContent alloc] init];
    content.body = @"这是一条本地通知";
    /// 本地通知图片iOS10+会显示，低于iOS10显示普通通知
    content.mediaUrl = @"https://tpns-1259470370.cos.ap-guangzhou.myqcloud.com/frontpng/iOS.png";
    /// 通知自定义key-value
    /// 注意：您如果需要通过TPNS统一接收消息回调及点击回调做业务处理，请通过xg字段msgtype为9去区分。
    content.userInfo = @{ @"key1" : @"value1", @"key2" : @"value2" };

    /// 通知展示时机类
    XGNotificationTrigger *trigger = [[XGNotificationTrigger alloc] init];
    trigger.timeInterval = 5;                                   /// iOS10+设置,也可通过dateComponents来进行设置
    trigger.fireDate = [NSDate dateWithTimeIntervalSinceNow:5]; /// 低于iOS10设置

    /// 通知请求类
    XGNotificationRequest *request = [[XGNotificationRequest alloc] init];
    /// 通知标识必须赋值
    request.requestIdentifier = @"test";
    request.content = content;
    request.trigger = trigger;
    [XGLocalNotification addNotification:request];
    [TPNSCommonMethod showAlertViewWithText:@"添加本地通知"];
}

/// 移除本地通知示例
- (void)removePendingLocalNotification {
    /// 通过标识移除本地通知
    [XGLocalNotification removePendingLocalNotification:@[ @"test" ]];
    [TPNSCommonMethod showAlertViewWithText:@"移除本地通知"];
}

/// 查询本地通知示例
- (void)searchPendingLocalNotification {
    [XGLocalNotification getPendingNotificationRequestsWithCompletionHandler:^(NSArray *requests) {
        [TPNSCommonMethod showAlertViewWithText:[NSString stringWithFormat:@"%@", requests]];
    }];
}

/// 点击注册TPNS选项
- (void)registerPush {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.isTPNSRegistSuccess) {
        //已经注册成功，避免重复注册；如需重新注册，先注销，后注册。
        NSString *message = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"register_app", nil), NSLocalizedString(@"success", nil)];
        [TPNSCommonMethod showAlertViewWithText:message];
        return;
    }
    [[XGPush defaultManager] startXGWithAccessID:TPNS_ACCESS_ID accessKey:TPNS_ACCESS_KEY delegate:(id<XGPushDelegate>)appDelegate];
}

///点击获取TPNS Token选项
- (void)onGetDeviceToken:(id)sender {
    NSString *token = [[XGPushTokenManager defaultTokenManager] xgTokenString];
    NSString *title = (!token || token.length == 0) ? NSLocalizedString(@"token_error", nil) : NSLocalizedString(@"token_info", nil);
    if (token.length > 0) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = token;
    }
    [TPNSCommonMethod showAlert:title message:token viewController:self completion:nil];
}

/// unregister
/// @param sender sender
- (void)unRegister:(id)sender {
    [[XGPush defaultManager] stopXGNotification];
}

#pragma mark - XGPushTokenManagerDelegate 账号回调
- (void)xgPushDidUpsertAccountsByDict:(NSDictionary *)accountsDict error:(NSError *)error {
    [self showAlertString:@"bind_account" error:error];
    NSLog(@"%s, accounts %@, error %@", __FUNCTION__, accountsDict, error);
}
- (void)xgPushDidDelAccountsByKeys:(NSSet<NSNumber *> *)accountsKeys error:(NSError *)error {
    [self showAlertString:@"unbind_account" error:error];
    NSLog(@"%s, accounts %@, error %@", __FUNCTION__, accountsKeys, error);
}
- (void)xgPushDidClearAccountsError:(NSError *)error {
    [self showAlertString:@"clear_account" error:error];
    NSLog(@"%s, accounts %lu, error %@", __FUNCTION__, (unsigned long)XGPushTokenBindTypeAccount, error);
}

#pragma mark - XGPushTokenManagerDelegate 标签回调
- (void)xgPushDidAppendTags:(NSArray<NSString *> *)tags error:(NSError *)error {
    [self showAlertString:@"bind_tag" error:error];
    NSLog(@"%s, tags %@, error %@", __FUNCTION__, tags, error);
}
- (void)xgPushDidDelTags:(NSArray<NSString *> *)tags error:(NSError *)error {
    [self showAlertString:@"unbind_tag" error:error];
    NSLog(@"%s, tags %@, error %@", __FUNCTION__, tags, error);
}
- (void)xgPushDidClearAndAppendTags:(NSArray<NSString *> *)tags error:(NSError *)error {
    [self showAlertString:@"update_tag" error:error];
    NSLog(@"%s, tags %@, error %@", __FUNCTION__, tags, error);
}
- (void)xgPushDidClearTagsError:(NSError *)error {
    [self showAlertString:@"clear_tag" error:error];
    NSLog(@"%s, tags %lu, error %@", __FUNCTION__, (unsigned long)XGPushTokenBindTypeTag, error);
}

#pragma mark - XGPushTokenManagerDelegate 用户属性方法回调，支持个性化推送
- (void)xgPushDidUpsertAttributes:(NSDictionary *)attributes invalidKeys:(NSArray *)keys error:(NSError *)error {
    [self showAlertString:@"bind_attributes" invalidKeys:keys error:error];
    NSLog(@"%s, attributes %@, error %@", __FUNCTION__, attributes, error);
}
- (void)xgPushDidDelAttributeKeys:(NSSet *)attributeKeys invalidKeys:(NSArray *)keys error:(NSError *)error {
    [self showAlertString:@"unbind_attributes" invalidKeys:keys error:error];
    NSLog(@"%s, attributeKeys %@, error %@", __FUNCTION__, attributeKeys, error);
}
- (void)xgPushDidClearAndAppendAttributes:(NSDictionary *)attributes invalidKeys:(NSArray *)keys error:(NSError *)error {
    [self showAlertString:@"update_attributes" invalidKeys:keys error:error];
    NSLog(@"%s, attributes %@, error %@", __FUNCTION__, attributes, error);
}
- (void)xgPushDidClearAttributesWithError:(NSError *)error {
    [self showAlertString:@"clear_attributes" invalidKeys:nil error:error];
    NSLog(@"%s, error %@", __FUNCTION__, error);
}

#pragma mark - AccountTypeChoseAlertController
///选择账号类型
- (void)choseAccountType:(id)sender {
    UIButton *btn = (UIButton *)sender;
    NSString *titleString = self.apiKindLists[btn.tag];
    TPNS_WEAKIFY(self);
    [TPNSCommonMethod showAlert:titleString
                        message:NSLocalizedString(@"account_type_description", nil)
                inputTextTitles:nil
              otherButtonTitles:_accoutTypesMutArray
                 viewController:self
                          block:^(UIAlertController *alertController, NSInteger buttonIndex) {
                              TPNS_STRONGIFY(self);
                              NSNumber *number = [self.actionValuesArray objectAtIndex:buttonIndex];
                              self.accountType = number.longValue;
                              self->accountTypeTitle = self->_accoutTypesMutArray[buttonIndex];
                              [self.APITableView reloadData];
                          }
                     completion:nil];
}

#pragma mark - 账号、标签、用户属性输入弹窗

/// 账号、标签、用户属性弹窗
- (void)showAlert:(NSString *)tittle inputTextTitles:(NSArray *)inputTextTitles indexPath:(NSIndexPath *)indexPath {
    [TPNSCommonMethod showAlert:tittle
                        message:nil
                inputTextTitles:inputTextTitles
              otherButtonTitles:nil
                 viewController:self
                          block:^(UIAlertController *alertController, NSInteger buttonIndex) {
                              switch (indexPath.section) {
                                  case 0:
                                      [self accountOperationType:indexPath.row alertController:alertController];
                                      break;
                                  case 1:
                                      [self tagOperationType:indexPath.row alertController:alertController];
                                      break;
                                  case 2:
                                      [self attributeOperationType:indexPath.row alertController:alertController];
                                      break;
                                  case 3:
                                      [self otherOperationAtIndexPath:indexPath alertController:alertController];
                                      break;
                                  default:
                                      break;
                              }
                          }
                     completion:nil];
}

#pragma mark - 其他
- (void)showAlertString:(NSString *)string error:(NSError *)error {
    [self showAlertString:string invalidKeys:nil error:error];
}

/// 展示账号、标签返回结果
- (void)showAlertString:(NSString *)attribute invalidKeys:(NSArray *)result error:(NSError *)error {
    NSString *title = [NSString stringWithFormat:@"%@%@", NSLocalizedString(attribute, nil),
                                                 ((error == nil) ? NSLocalizedString(@"success", nil) : NSLocalizedString(@"failed", nil))];
    NSMutableString *message = [[NSMutableString alloc] init];
    if (error)
        [message appendFormat:@"error:%@", error];
    //无效key无法设置成功，需要先调用Rest API中的增加有效的用户属性
    if (result)
        [message appendFormat:@"return invalid keys:%@", result];
    [TPNSCommonMethod showAlert:title message:message viewController:self completion:nil];
}

///展示弹窗
- (void)presentAlertController:(UIAlertController *)alertController {
    [TPNSCommonMethod presentAlertController:alertController fromViewController:self completion:nil];
}

@end
