//
//  TabViewController.m
//  TPNS-Demo-Cloud
//
//  Created by boblv on 2020/5/7.
//  Copyright © 2020 XG of Tencent. All rights reserved.
//

#import "TabViewController.h"

/// TabViewController
@interface TabViewController ()

@end

/// TabViewController
@implementation TabViewController

/// Called after the controller's view is loaded into memory.
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITabBar *tabBar = self.tabBar;
    NSArray *itemsArr = tabBar.items;
    NSArray *nameArr = @[ @"feature", @"message", @"more" ];
    for (UITabBarItem *tabBarItem in itemsArr) {
        NSInteger index = [itemsArr indexOfObject:tabBarItem];
        UITabBarItem *featureTabBarItem = [itemsArr objectAtIndex:index];
        NSString *nameString = [nameArr objectAtIndex:index];
        featureTabBarItem.title = NSLocalizedString(nameString, nil);
        featureTabBarItem.image = [UIImage imageNamed:nameString];
    }
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
