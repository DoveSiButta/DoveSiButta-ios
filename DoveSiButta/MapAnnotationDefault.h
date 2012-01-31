//
//  MapAnnotationDefault.h
//  DoveSiButta
//
//  Created by Giovanni Maggini on 23/12/11.
//  Copyright (c) 2011 Giovanni Maggini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "DoveSiButtaEntities.h"

@protocol GMAnnotation <MKAnnotation>

@optional
- (NSNumber *)annotationid;
- (DoveSiButtaModel_Box *)dinner;
- (NSString *)type;

@end

@interface MapAnnotationDefault : NSObject <GMAnnotation>
{
    NSNumber *annotationid;
    NSString *type;

}

@property (nonatomic, retain) DoveSiButtaModel_Box *item;



@end
