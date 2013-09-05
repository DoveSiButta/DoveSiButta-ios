//
//  AppState.m
//  DoveSiButta
//
//  Created by Giovanni on 6/13/13.
//  Copyright (c) 2013 Giovanni Maggini. All rights reserved.
//

#import "AppState.h"
#import "SSKeychain.h"
#import "NSString+MD5.h"

NSString* const kLocationServicesFailure = @"kLocationServicesFailure";
NSString* const kLocationServicesGotBestAccuracyLocation = @"kLocationServicesGotBestAccuracyLocation";

@implementation AppState

+(AppState *)sharedInstance {
    static dispatch_once_t pred;
    static AppState *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[AppState alloc] init];
    });
    return shared;
}

#pragma mark - UUID

-(NSString*)uniqueIdentifier
{
    // getting the unique key (if present ) from keychain , assuming "your app identifier" as a key
    NSString *deviceID = [SSKeychain passwordForService:kSERVICENAME_KEYCHAIN account:@"user"];
    if (deviceID == nil) { // if this is the first time app lunching , create key for device
        NSString *uuid  = [self createNewUUID];
        // save newly created key to Keychain
        [SSKeychain setPassword:uuid forService:kSERVICENAME_KEYCHAIN account:@"user"];
        // this is the one time process
        deviceID = uuid;
    }
    return [deviceID md5]; //To be safe that it will be < 32 characters
}

- (NSString *)createNewUUID {
    
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}

#pragma mark - Location Manager

- (void)startLocationServices
{
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"location services are disabled");
        [[NSNotificationCenter defaultCenter] postNotificationName:kLocationServicesFailure object:nil];
        return;
    }
    
    if (nil == _locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = 100;
    
    [_locationManager startUpdatingLocation];
}

- (void)stopLocationServices
{
    [_locationManager stopUpdatingLocation];
}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *currentLocation = [locations lastObject];
    NSDate* eventDate = currentLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0 && currentLocation.horizontalAccuracy >= _locationManager.desiredAccuracy) {
        _currentLocation = currentLocation;
        [[NSNotificationCenter defaultCenter] postNotificationName:kLocationServicesGotBestAccuracyLocation object:nil];
        NSLog(@"_currentLocation: %@", currentLocation);
        
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    if ([error domain] == kCLErrorDomain) {
        
        // We handle CoreLocation-related errors here
        switch ([error code]) {
                // "Don't Allow" on two successive app launches is the same as saying "never allow". The user
                // can reset this for all apps by going to Settings > General > Reset > Reset Location Warnings.
            case kCLErrorDenied:
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kLocationServicesFailure object:nil];
            }
                break;
            case kCLErrorLocationUnknown:

                break;
            default:
                break;
        }
        
    } else {
        // We handle all non-CoreLocation errors here
        NSLog(@"Errore Sconosciuto");
    }
    
}

@end
