//
//  LogTableViewController.m
//  SmartDeviceLink-iOS
//
//  Created by WuLeilei on 17/1/20.
//  Copyright © 2017年 smartdevicelink. All rights reserved.
//

#import "LogTableViewController.h"

@interface LogTableViewController ()
{
    NSMutableArray *_dataArray;
}
@end

@implementation LogTableViewController

- (instancetype)init {
    if (self = [super init]) {
        self.title = @"LOG";
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Clean" style:UIBarButtonItemStylePlain target:self action:@selector(clean)];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLog:) name:@"ShowLogNotification" object:nil];
        
        _dataArray = @[].mutableCopy;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.estimatedRowHeight = 60;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ShowLogNotification" object:nil];
}

- (void)clean {
    [_dataArray removeAllObjects];
    [self.tableView reloadData];
}

- (void)showLog:(NSNotification *)notification {
    NSString *message = [notification object];
    [_dataArray addObject:message];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    cell.textLabel.text = [_dataArray objectAtIndex:indexPath.row];
    cell.textLabel.numberOfLines = 0;
    return cell;
}

@end
