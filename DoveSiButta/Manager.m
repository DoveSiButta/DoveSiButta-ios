    		//
//  Manager.m
//  ElencoServiziCoreData
//
//  Created by Giovanni Maggini on 07/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//



#import "Manager.h"
#import "SynthesizeSingleton.h"



@implementation Manager
@synthesize uri;
SYNTHESIZE_SINGLETON_FOR_CLASS(Manager)

#pragma mark - Initializations


- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


- (id)initWithUri:(NSString *)serviceUri
{
    self = [super init];
    if (self) {
        self.uri = serviceUri;
        // Initialization code here.
    }
    
    return self;
}



+(Manager*) sharedManagerWithUri:(NSString *)serviceUri
{
    return [[self alloc] initWithUri:serviceUri ];
}



@end
