//
//  SDLFakeViewControllerPresenter.m
//  SmartDeviceLink-iOS
//
//  Created by Joel Fischer on 7/18/16.
//  Copyright © 2016 smartdevicelink. All rights reserved.
//

#import "SDLFakeViewControllerPresenter.h"


@interface SDLFakeViewControllerPresenter ()

@property (assign, nonatomic, readwrite) BOOL presented;

@end


@implementation SDLFakeViewControllerPresenter

- (void)present {
    if (!self.viewController) { return; }
    
    _presented = YES;
}

- (void)dismiss {
    if (!self.viewController) { return; }
    
    _presented = NO;
}

@end
