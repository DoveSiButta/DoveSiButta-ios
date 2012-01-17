//
//  MapAnnotationDefault.h
//  NerdDinner
//
//  Created by Giovanni Maggini on 23/12/11.
//  Copyright (c) 2011 Giovanni Maggini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "NerdDinnerEntities.h"

@protocol GMAnnotation <MKAnnotation>

@optional
- (NSNumber *)annotationid;
- (NerdDinnerModel_Dinner *)dinner;
- (NSString *)type;

@end

@interface MapAnnotationDefault : NSObject <GMAnnotation>
{
    NSNumber *annotationid;
    NSString *type;

}

@property (nonatomic, retain) NerdDinnerModel_Dinner *dinner;



@end
