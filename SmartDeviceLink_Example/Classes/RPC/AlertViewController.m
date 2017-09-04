//
//  AlertViewController.m
//  SmartDeviceLink-iOS
//
//  Created by WuLeilei on 17/2/10.
//  Copyright © 2017年 smartdevicelink. All rights reserved.
//

#import "AlertViewController.h"

#import "SDLAlert.h"

@interface AlertViewController ()
{
    UITextField *_alertText1;
    UITextField *_alertText2;
    UITextField *_duration;
}
@end

@implementation AlertViewController

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
    NSArray *array = @[@"alertText1", @"alertText1"];
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
        
        UITextField *textField = [[UITextField alloc] init];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        [_contentView addSubview:textField];
        [textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(keyLabel.mas_right).offset(20);
            make.top.bottom.equalTo(keyLabel);
            make.right.equalTo(@-20);
        }];
        
        switch (i) {
            case 0: {
                _alertText1 = textField;
                break;
            }
                
            case 1: {
                _alertText2 = textField;
                break;
            }
                
            case 2: {
                _duration = textField;
                _duration.keyboardType = UIKeyboardTypeNumberPad;
                break;
            }
                
            default:
                break;
        }
    }
}

- (void)submitRPC {
    NSString *alertText1 = _alertText1.text;
    NSString *alertText2 = _alertText2.text;
    NSString *duration = @"5000";//_duration.text;
//    if (alertText1.length == 0 ||
//        alertText2.length == 0 ||
//        duration.length == 0) {
//        return;
//    }
    
    [self.view endEditing:YES];
    
    SDLAlert *alert = [[SDLAlert alloc] initWithAlertText1:alertText1 alertText2:alertText2 duration:[duration integerValue]];
    alert.playTone = @(YES);
    alert.correlationID = @(102);
    [[ProxyManager sharedManager].sdlManager.proxy sendRPC:alert];
}

@end
