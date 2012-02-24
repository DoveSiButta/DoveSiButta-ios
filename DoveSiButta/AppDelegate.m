//
//  AppDelegate.m
//  DoveSiButta
//
//  Created by Giovanni Maggini on 22/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "MasterViewController.h"
#import "MapAddViewController.h"
#import "ChiSiamoViewController.h"

//#import "SHK.h"

@implementation AppDelegate

@synthesize window = _window;
//@synthesize navigationController = _navigationController;
@synthesize tabBarController = _tabBarController;

- (void)dealloc
{
    [_window release];
//    [_navigationController release];
    [_tabBarController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.

//    MasterViewController *masterViewController = [[[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil] autorelease];
//    self.navigationController = [[[UINavigationController alloc] initWithRootViewController:masterViewController] autorelease];
//    self.window.rootViewController = self.navigationController;
//    [self.window makeKeyAndVisible];

    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    MasterViewController *viewController1 = [[[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil] autorelease];
    UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:viewController1] autorelease];
    UIViewController *viewController2 = [[[MapAddViewController alloc] initWithNibName:@"MapAddViewController" bundle:nil] autorelease];
    ChiSiamoViewController *viewController3 = [[ChiSiamoViewController alloc] initWithNibName:@"ChiSiamoViewController" bundle:nil];
    self.tabBarController = [[[UITabBarController alloc] init] autorelease];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:navigationController, viewController2, viewController3, nil];
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    return YES;
    
    
    //questo è un buon momento per spedire tutti gli elementi sharati che la app non è riuscita a spedire se era senza connettività. http://getsharekit.com/install/
//    [SHK flushOfflineQueue];
    
    //Imposto l'URL del servizio una volta sola nella app
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
#if TARGET_IPHONE_SIMULATOR
    NSString *storedVal = @"http://192.168.138.2/Services/OData.svc/"; 
    NSString *key = @"serviceURI"; // the key for the data
    [defaults setObject:storedVal forKey:key];
    storedVal = @"http://192.168.138.2";
    key = @"appURI"; // the key for the base app uri
    [defaults setObject:storedVal forKey:key];
    storedVal = @"http://192.168.138.2/Pictures/";
    key = @"picturesURI"; // the key for the pictures path
    [defaults setObject:storedVal forKey:key];
#else
    NSString *storedVal = @"http://www.dovesibutta.com/Services/OData.svc/";  //@"http://192.168.138.2/Services/OData.svc/"; 
    NSString *key = @"serviceURI"; // the key for the data
    [defaults setObject:storedVal forKey:key];
    storedVal = @"http://www.dovesibutta.com"; //@"http://192.168.138.2";
    key = @"appURI"; // the key for the base app uri
    [defaults setObject:storedVal forKey:key];    
    storedVal = @"http://www.dovesibutta.com/Pictures/";
    key = @"picturesURI"; // the key for the pictures path
    [defaults setObject:storedVal forKey:key];
#endif
    
    [defaults synchronize]; // this method is optional

    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
