//
//  ShowViewController.m
//  SmartDeviceLink-iOS
//
//  Created by WuLeilei on 17/2/6.
//  Copyright © 2017年 smartdevicelink. All rights reserved.
//

#import "ShowViewController.h"

#import "SDLShow.h"

@interface ShowViewController ()
{
    UITextField *_mainField1;
    UISegmentedControl *_alignSegmentedControl;
}
@end

@implementation ShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showUI {
    UILabel *preLabel;
    NSArray *array = @[@"mainField1", @"alignment"];
    for (NSInteger i = 0; i < array.count; i++) {
        UILabel *keyLabel = [[UILabel alloc] init];
        keyLabel.textAlignment = NSTextAlignmentRight;
        keyLabel.text = [array objectAtIndex:i];
        [_contentView addSubview:keyLabel];
        [keyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.width.equalTo(@100);
            make.height.equalTo(@30);
            if (preLabel) {
                make.top.equalTo(preLabel.mas_bottom).offset(20);
            } else {
                make.top.equalTo(@100);
            }
        }];
        preLabel = keyLabel;
        
        if (i == 0) {
            _mainField1 = [[UITextField alloc] init];
            _mainField1.borderStyle = UITextBorderStyleRoundedRect;
            [_contentView addSubview:_mainField1];
            [_mainField1 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(keyLabel.mas_right).offset(20);
                make.top.bottom.equalTo(keyLabel);
                make.right.equalTo(@-20);
            }];
        } else if (i == 1) {
            _alignSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"LEFT", @"CENTER", @"RIGHT"]];
            _alignSegmentedControl.selectedSegmentIndex = 0;
            [_contentView addSubview:_alignSegmentedControl];
            [_alignSegmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.height.equalTo(_mainField1);
                make.top.equalTo(keyLabel);
            }];
        }
    }
}

- (void)submitRPC {
    NSString *mainField1 = _mainField1.text;
    if (mainField1.length == 0) {
        return;
    }
    
    [self.view endEditing:YES];
    
    SDLTextAlignment *align;
    switch (_alignSegmentedControl.selectedSegmentIndex) {
        case 0:
            align = [SDLTextAlignment LEFT_ALIGNED];
            break;
            
        case 1:
            align = [SDLTextAlignment CENTERED];
            break;
            
        case 2:
            align = [SDLTextAlignment RIGHT_ALIGNED];
            break;
            
        default:
            break;
    }
    
    SDLShow *show = [[SDLShow alloc] init];
    show.mainField1 = mainField1;
    show.alignment = align;
    show.correlationID = @(101);
    [[ProxyManager sharedManager].sdlManager.proxy sendRPC:show];
}

@end
