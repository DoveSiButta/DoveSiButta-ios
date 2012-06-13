//
//  MapAnnotationDefault.m
//  DoveSiButta
//
//  Created by Giovanni Maggini on 23/12/11.
//  Copyright (c) 2011 Giovanni Maggini. All rights reserved.
//

#import "MapAnnotationDefault.h"

@implementation MapAnnotationDefault
@synthesize item;


- (CLLocationCoordinate2D)coordinate;
{
    CLLocationCoordinate2D theCoordinate;
    theCoordinate.latitude = [[self.item getLatitude] floatValue] ;
    theCoordinate.longitude = [[self.item getLongitude] floatValue] ;
//    NSLog(@"Latitude: %f, Longitude: %f", theCoordinate.latitude, theCoordinate.longitude);
    return theCoordinate; 
}

// required if you set the MKPinAnnotationView's "canShowCallout" property to YES
- (NSString *)title
{
    return [self.item getTitle];
}

// optional
- (NSString *)subtitle
{
    return [self.item getDescription];
}

- (NSNumber *)annotationid
{
    return [self.item getBoxID];
}

- (NSString *)type
{
    return [self.item getBoxType];
}



@end
