//
//  AppDelegate.h
//  DoveSiButta
//
//  Created by Giovanni Maggini on 22/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

/*  For LLVM 3.0
@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navigationController;
*/

@property (nonatomic, retain) UIWindow *window;

//@property (nonatomic, retain) UINavigationController *navigationController;

@property (nonatomic, retain) UITabBarController *tabBarController;

@end
