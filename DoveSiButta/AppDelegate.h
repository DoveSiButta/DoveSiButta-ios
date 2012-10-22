//
//  AppDelegate.h
//  DoveSiButta
//
//  Created by Giovanni Maggini on 22/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoConnectionViewController.h"
#import "ABNotifier.h"
#import "Flurry.h"

@class Reachability;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate,ABNotifierDelegate>
{
    Reachability* hostReach;
}
/*  For LLVM 3.0
@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navigationController;
*/

@property (strong, nonatomic) UIWindow *window;

//@property (nonatomic, retain) UINavigationController *navigationController;

@property (strong, nonatomic) UITabBarController *tabBarController;

@property (strong, nonatomic) NoConnectionViewController *noConnectionViewController;

@end
