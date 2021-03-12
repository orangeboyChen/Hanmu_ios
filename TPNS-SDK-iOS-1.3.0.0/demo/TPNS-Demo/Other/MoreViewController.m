//
//  MoreViewController.m
//  TPNS-Demo-Cloud
//
//  Created by boblv on 2020/5/7.
//  Copyright © 2020 TPNS of Tencent. All rights reserved.
//

#import "MoreViewController.h"
#import "XGPush.h"
/// More modules UIViewController
@interface MoreViewController () <UITableViewDelegate, UITableViewDataSource>

@end

/// More modules UIViewController
@implementation MoreViewController
/// Called after the controller's view is loaded into memory.
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"more", nil);
    // init apiKindLists
    self.apiKindLists = @[ NSLocalizedString(@"about", nil) ];
    // init tableView
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

/// Notifies the view controller that its view is about to be added to a view hierarchy.
/// @param animated If YES, the view is being added to the window using an animation.
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    /// hide tabBarController
    self.tabBarController.tabBar.hidden = false;
}

/*
 #pragma mark - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
/// Tells the data source to return the number of rows in a given section of a table view.
/// @param tableView The table-view object requesting this information.
/// @param section An index number identifying a section in tableView.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.apiKindLists.count;
}
/// Asks the data source for a cell to insert in a particular location of the table view.
/// @param tableView A table-view object requesting the cell.
/// @param indexPath An index path locating a row in tableView.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const tpnsMoreCellID = @"TPNSMoreCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tpnsMoreCellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:tpnsMoreCellID];
    }
    cell.accessoryType = (indexPath.row != 1 && indexPath.row != 3) ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    cell.detailTextLabel.text = indexPath.row ? @"" : [XGPush defaultManager].sdkVersion;
    cell.textLabel.text = _apiKindLists[indexPath.row];

    return cell;
}
/// Tells the delegate that the specified row is now selected.
/// @param tableView A table-view object informing the delegate about the new row selection.
/// @param indexPath An index path locating the new selected row in tableView.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            // Open URL address
            WebviewViewController *webCV = [[WebviewViewController alloc] init];
            webCV.title = _apiKindLists[indexPath.row];
            webCV.url = [[NSURL alloc] initWithString:@"https://cloud.tencent.com/document/product/548/36645"];
            [self.navigationController pushViewController:webCV animated:YES];
        } break;

        default:
            break;
    }
}

@end
