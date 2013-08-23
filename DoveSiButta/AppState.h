//
//  AppState.h
//  DoveSiButta
//
//  Created by Giovanni on 6/13/13.
//  Copyright (c) 2013 Giovanni Maggini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

extern NSString* const kLocationServicesFailure;
extern NSString* const kLocationServicesGotBestAccuracyLocation;


@interface AppState : NSObject <CLLocationManagerDelegate>


//Location
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;

+(AppState *)sharedInstance;

-(NSString*)uniqueIdentifier;

//Location
- (void) startLocationServices;
- (void) stopLocationServices;

@end
