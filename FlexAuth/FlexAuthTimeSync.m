//
//  FlexAuthTimeSync.m
//  FlexAuth
//
//  Created by Doug Warren on 10/21/12.
//  Copyright (c) 2012 Doug Warren. All rights reserved.
//

#import "FlexAuthTimeSync.h"

#define kFATSTimeURL @"http://m.us.mobileservice.blizzard.com/enrollment/time.htm"

@interface FlexAuthTimeSync ()
- (void) timeSync;
@end

@implementation FlexAuthTimeSync

+ (FlexAuthTimeSync*) sharedService
{
    static FlexAuthTimeSync* service = nil;
    if (service == nil) {
        @synchronized(service) {
            if(service == nil) {
                service = [[FlexAuthTimeSync alloc] init];
            }
        }
    }
    
    return service;
}

- (id) init
{
    self = [super init];
    if (self) {
        _receivedTime = NO;
        
        // Load time from the user defaults
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        
        _timeOffset = [userDefaults objectForKey:@"offset"];
    }
    
    return self;
}

- (void) startTimeSync
{
    [self performSelectorInBackground:@selector(timeSync) withObject:nil];
}

- (void) timeSync
{
    NSData* timeData = [NSData dataWithContentsOfURL:[NSURL URLWithString:kFATSTimeURL]];
    
    if ([timeData length] > 0) {
        int64_t blizzardTime;
        [timeData getBytes:&blizzardTime length:sizeof(blizzardTime)];
        blizzardTime = CFSwapInt64BigToHost(blizzardTime);
        NSLog(@"Raw time is %lld", blizzardTime);
        
        NSTimeInterval delta = blizzardTime - [[NSDate date] timeIntervalSince1970]*1000;
        NSLog(@"Delta is %lf", delta);
        _timeOffset = [NSNumber numberWithDouble:delta];
        _receivedTime = YES;
        
        // Persist it to our user settings
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:self.timeOffset
                         forKey:@"offset"];
        [userDefaults synchronize];
    }
}

- (NSTimeInterval)currentTimeMilliSec
{
    NSTimeInterval currentTimeMilliSec = [[NSDate date] timeIntervalSince1970]*1000;
    currentTimeMilliSec += [self.timeOffset doubleValue];
    
    // time = 44987614;
    
    return currentTimeMilliSec;
}
@end