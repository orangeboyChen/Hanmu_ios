//
//  MoreViewController.h
//  TPNS-Demo-Cloud
//
//  Created by boblv on 2020/5/7.
//  Copyright © 2020 TPNS of Tencent. All rights reserved.
//

#import "WebviewViewController.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// More modules UIViewController
@interface MoreViewController : UIViewController
/// More modules  UITableView
@property (weak, nonatomic) IBOutlet UITableView *tableView;
/// More modules  UITableView DataSource NSArray
@property (strong, nonatomic) NSArray *apiKindLists;

@end

NS_ASSUME_NONNULL_END
