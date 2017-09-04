//
//  SDLFakeViewControllerPresenter.h
//  SmartDeviceLink-iOS
//
//  Created by Joel Fischer on 7/18/16.
//  Copyright © 2016 smartdevicelink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SDLViewControllerPresentable.h"

@interface SDLFakeViewControllerPresenter : NSObject <SDLViewControllerPresentable>

@property (strong, nonatomic) UIViewController *viewController;
@property (assign, nonatomic, readonly) BOOL presented;

@end
