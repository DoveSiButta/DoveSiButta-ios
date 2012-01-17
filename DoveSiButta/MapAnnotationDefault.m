//
//  MapAnnotationDefault.m
//  NerdDinner
//
//  Created by Giovanni Maggini on 23/12/11.
//  Copyright (c) 2011 Giovanni Maggini. All rights reserved.
//

#import "MapAnnotationDefault.h"

@implementation MapAnnotationDefault
@synthesize dinner;


- (CLLocationCoordinate2D)coordinate;
{
    CLLocationCoordinate2D theCoordinate;
    theCoordinate.latitude = [[dinner getLatitude] floatValue] ;
    theCoordinate.longitude = [[dinner getLongitude] floatValue] ;
//    theCoordinate.latitude = 37.786996;
//    theCoordinate.longitude = -122.419281;   
    NSLog(@"Latitude: %f, Longitude: %f", theCoordinate.latitude, theCoordinate.longitude);
    return theCoordinate; 
}

// required if you set the MKPinAnnotationView's "canShowCallout" property to YES
- (NSString *)title
{
    return [dinner getTitle];
}

// optional
- (NSString *)subtitle
{
    return [dinner getDescription];
}

- (NSNumber *)annotationid
{
    return [dinner getDinnerID];
}

- (NSString *)type
{
    return [dinner getDinnerType];
}

- (void)dealloc
{
    [super dealloc];
    [dinner release];
    
}

@end
