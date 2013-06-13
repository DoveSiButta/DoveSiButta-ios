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
#import "LoginViewController.h"


//#import "SHK.h"

@implementation AppDelegate

@synthesize window = _window;
//@synthesize navigationController = _navigationController;
@synthesize tabBarController = _tabBarController;
@synthesize noConnectionViewController = _noConnectionViewController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //questo è un buon momento per spedire tutti gli elementi sharati che la app non è riuscita a spedire se era senza connettività. http://getsharekit.com/install/
    //    [SHK flushOfflineQueue];
    
    [Flurry startSession:kFLURRY_APIKEY];
    //your code
    
    //AirBrake Notifier
    [ABNotifier startNotifierWithAPIKey:kABNOTIFIER_APIKEY
	                    environmentName:ABNotifierAutomaticEnvironment
	                             useSSL:NO
	                           delegate:self];
    //TEST
//    [ABNotifier writeTestNotice];
    
    
    //DEFAULTS SETUP START
    //Imposto l'URL del servizio una volta sola nella app
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
#if TARGET_IPHONE_SIMULATOR
//    NSString *storedVal = @"http://192.168.138.2/Services/OData.svc/"; 
//    NSString *key = @"serviceURI"; // the key for the data
//    [defaults setObject:storedVal forKey:key];
//    storedVal = @"192.168.138.2";  //@"http://192.168.138.2/Services/OData.svc/"; 
//    key = @"serviceHost"; // the key for the data
//    [defaults setObject:storedVal forKey:key];
//    storedVal = @"http://192.168.138.2";
//    key = @"appURI"; // the key for the base app uri
//    [defaults setObject:storedVal forKey:key];
//    storedVal = @"http://192.168.138.2/Pictures/";
//    key = @"picturesURI"; // the key for the pictures path
//    [defaults setObject:storedVal forKey:key];
    NSString *storedVal = @"http://www.dovesibutta.com/Services/OData.svc/";  //@"http://192.168.138.2/Services/OData.svc/"; 
    NSString *key = @"serviceURI"; // the key for the data
    [defaults setObject:storedVal forKey:key];
    storedVal = @"www.dovesibutta.com";  //@"http://192.168.138.2/Services/OData.svc/"; 
    key = @"serviceHost"; // the key for the data
    [defaults setObject:storedVal forKey:key];
    storedVal = @"http://www.dovesibutta.com"; //@"http://192.168.138.2";
    key = @"appURI"; // the key for the base app uri
    [defaults setObject:storedVal forKey:key];    
    storedVal = @"http://www.dovesibutta.com/Pictures/";
    key = @"picturesURI"; // the key for the pictures path
    [defaults setObject:storedVal forKey:key];
#else
    NSString *storedVal = @"http://www.dovesibutta.com/Services/OData.svc/";  //@"http://192.168.138.2/Services/OData.svc/"; 
    NSString *key = @"serviceURI"; // the key for the data
    [defaults setObject:storedVal forKey:key];
    storedVal = @"www.dovesibutta.com";  //@"http://192.168.138.2/Services/OData.svc/"; 
    key = @"serviceHost"; // the key for the data
    [defaults setObject:storedVal forKey:key];
    storedVal = @"http://www.dovesibutta.com"; //@"http://192.168.138.2";
    key = @"appURI"; // the key for the base app uri
    [defaults setObject:storedVal forKey:key];    
    storedVal = @"http://www.dovesibutta.com/Pictures/";
    key = @"picturesURI"; // the key for the pictures path
    [defaults setObject:storedVal forKey:key];
#endif
    
    [defaults synchronize]; // this method is optional
    //DEFAULTS SETUP END    
    
//#if !TARGET_IPHONE_SIMULATOR    
    // Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the
    // method "reachabilityChanged" will be called. 
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    hostReach = [Reachability reachabilityWithHostName: [defaults objectForKey:@"serviceHost"]];
    NSLog(@"serviceHost %@ ",[defaults objectForKey:@"serviceHost"]);
    [hostReach startNotifier];
//    NetworkStatus netStatus = [hostReach currentReachabilityStatus];
//    BOOL isReachable = [hostReach isReachable];
    
//#else
//    NetworkStatus netStatus = ReachableViaWiFi;
//    BOOL isReachable = YES;
//#endif

    
    self.noConnectionViewController = [[NoConnectionViewController alloc] initWithNibName:@"NoConnectionViewController" bundle:nil];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // Override point for customization after application launch.
    MasterViewController *viewController1 = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController1];
    UIViewController *viewController2 = [[MapAddViewController alloc] initWithNibName:@"MapAddViewController" bundle:nil];
    UINavigationController *navigationControllerAdd = [[UINavigationController alloc] initWithRootViewController:viewController2];
    ChiSiamoViewController *viewController3 = [[ChiSiamoViewController alloc] initWithNibName:@"ChiSiamoViewController" bundle:nil];
    LoginViewController *viewController4 = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];

//#TODO: viewController4 to check if I can login to ASP.NET
    
    self.tabBarController = [[UITabBarController alloc] init];
#if TARGET_IPHONE_SIMULATOR

//    self.tabBarController.viewControllers = [NSArray arrayWithObjects:navigationController, navigationControllerAdd, viewController3, nil];

    self.tabBarController.viewControllers = [NSArray arrayWithObjects:navigationController, navigationControllerAdd, viewController3, viewController4, nil];
#else
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera ])
    {
//        self.tabBarController.viewControllers = [NSArray arrayWithObjects:navigationController, navigationControllerAdd, viewController3, nil];

        self.tabBarController.viewControllers = [NSArray arrayWithObjects:navigationController, navigationControllerAdd, viewController3, viewController4, nil];
    }
    else {
//        self.tabBarController.viewControllers = [NSArray arrayWithObjects:navigationController, viewController3, nil];

        self.tabBarController.viewControllers = [NSArray arrayWithObjects:navigationController, viewController3, viewController4, nil];
    }
#endif
    

//    if(netStatus == NotReachable || !isReachable )
//    {
//        self.window.rootViewController = self.noConnectionViewController;
//    }
//    else {
//        self.window.rootViewController = self.tabBarController;
//    }
    
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    return YES;
}



- (void) updateInterfaceWithReachability: (Reachability*) curReach
{
    if(curReach == hostReach)
	{
//		[self configureTextField: remoteHostStatusField imageView: remoteHostIcon reachability: curReach];
//        NetworkStatus netStatus = [curReach currentReachabilityStatus];
//        BOOL connectionRequired= [curReach connectionRequired];
//        
//        summaryLabel.hidden = (netStatus != ReachableViaWWAN);
//        NSString* baseLabel=  @"";
//        if(connectionRequired)
//        {
//            baseLabel=  @"Cellular data network is available.\n  Internet traffic will be routed through it after a connection is established.";
//        }
//        else
//        {
//            baseLabel=  @"Cellular data network is active.\n  Internet traffic will be routed through it.";
//        }
//        summaryLabel.text= baseLabel;
        
        NetworkStatus netStatus = [curReach currentReachabilityStatus];
        BOOL connectionRequired= [curReach connectionRequired];

        switch (netStatus)
        {
            case NotReachable:
            {
//                statusString = @"Access Not Available";
//                imageView.image = [UIImage imageNamed: @"stop-32.png"] ;
//                //Minor interface detail- connectionRequired may return yes, even when the host is unreachable.  We cover that up here...
//                connectionRequired= NO;  
                
                self.window.rootViewController = self.noConnectionViewController;
                [self.window makeKeyAndVisible];
                break;
            }
                
            default:
                self.window.rootViewController = self.tabBarController;
                [self.window makeKeyAndVisible];
                break;
        }
        if(connectionRequired)
        {
            self.window.rootViewController = self.noConnectionViewController;
            [self.window makeKeyAndVisible];
        }
        
    }
//	if(curReach == internetReach)
//	{	
//		[self configureTextField: internetConnectionStatusField imageView: internetConnectionIcon reachability: curReach];
//	}
//	if(curReach == wifiReach)
//	{	
//		[self configureTextField: localWiFiConnectionStatusField imageView: localWiFiConnectionIcon reachability: curReach];
//	}
	
}

//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	[self updateInterfaceWithReachability: curReach];
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

#pragma mark -- Network Activity Indicator

- (void)setNetworkActivityIndicatorVisible:(BOOL)setVisible {
    static NSInteger NumberOfCallsToSetVisible = 0;
    if (setVisible)
        NumberOfCallsToSetVisible++;
    else
        NumberOfCallsToSetVisible--;
    
    // The assertion helps to find programmer errors in activity indicator management.
    // Since a negative NumberOfCallsToSetVisible is not a fatal error,
    // it should probably be removed from production code.
    NSAssert(NumberOfCallsToSetVisible >= 0, @"Network Activity Indicator was asked to hide more often than shown");
    
    // Display the indicator as long as our static counter is > 0.
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:(NumberOfCallsToSetVisible > 0)];
}

@end
