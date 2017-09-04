//
//  BaseTableViewController.h
//  SmartDeviceLink-iOS
//
//  Created by WuLeilei on 17/2/6.
//  Copyright © 2017年 smartdevicelink. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseTableViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_tableView;
}

@property (nonatomic, assign) BOOL keyboardAvoidingTableView;

- (instancetype)initWithStyle:(UITableViewStyle)style;

@end
