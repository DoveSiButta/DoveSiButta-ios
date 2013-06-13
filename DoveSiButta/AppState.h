//
//  AppState.h
//  DoveSiButta
//
//  Created by Giovanni on 6/13/13.
//  Copyright (c) 2013 Giovanni Maggini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppState : NSObject

+(AppState *)sharedInstance;

-(NSString*)uniqueIdentifier;

@end
