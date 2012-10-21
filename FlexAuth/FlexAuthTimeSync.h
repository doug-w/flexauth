//
//  FlexAuthTimeSync.h
//  FlexAuth
//
//  Created by Doug Warren on 10/21/12.
//  Copyright (c) 2012 Doug Warren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlexAuthTimeSync : NSObject
@property (atomic, retain) NSNumber* timeOffset;
@property (nonatomic, readonly)BOOL receivedTime;

+ (FlexAuthTimeSync*) sharedService;

-(void) startTimeSync;
@end
