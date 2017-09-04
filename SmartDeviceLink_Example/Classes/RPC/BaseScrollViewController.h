//
//  BaseScrollViewController.h
//  SmartDeviceLink-iOS
//
//  Created by WuLeilei on 17/2/6.
//  Copyright © 2017年 smartdevicelink. All rights reserved.
//

#import "BaseViewController.h"

#import "ProxyManager.h"
#import "SDLTextAlignment.h"
#import "SDLProxy.h"

@interface BaseScrollViewController : BaseViewController
{
    UIScrollView *_scrollView;
    UIView *_contentView;
}

@end
