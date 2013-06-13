//
//  AppState.m
//  DoveSiButta
//
//  Created by Giovanni on 6/13/13.
//  Copyright (c) 2013 Giovanni Maggini. All rights reserved.
//

#import "AppState.h"
#import "SSKeychain.h"

@implementation AppState

+(AppState *)sharedInstance {
    static dispatch_once_t pred;
    static AppState *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[AppState alloc] init];
    });
    return shared;
}


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
}

- (NSString *)createNewUUID {
    
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}

@end
