//
//  NLAppDelegate.h
//  LetterpressSolver
//
//  Created by Nick Lauer on 12-11-04.
//  Copyright (c) 2012 Nick Lauer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NLMainScreenViewController;

@interface NLAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NLMainScreenViewController *viewController;

@end
