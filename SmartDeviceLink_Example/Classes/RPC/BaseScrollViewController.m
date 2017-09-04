//
//  BaseScrollViewController.m
//  SmartDeviceLink-iOS
//
//  Created by WuLeilei on 17/2/6.
//  Copyright © 2017年 smartdevicelink. All rights reserved.
//

#import "BaseScrollViewController.h"
#import "TPKeyboardAvoidingScrollView.h"

@interface BaseScrollViewController ()

@end

@implementation BaseScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    TPKeyboardAvoidingScrollView *scrollView = [[TPKeyboardAvoidingScrollView alloc] init];
    scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:scrollView];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    _scrollView = scrollView;
    
    _contentView = [[UIView alloc] init];
    [scrollView addSubview:_contentView];
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(scrollView);
        make.width.equalTo(scrollView);
        make.height.equalTo(scrollView);
    }];
    
    [self showUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showUI {
    
}

@end
