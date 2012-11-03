//
//  FlexAuthModel.h
//  FlexAuth
//
//  Created by Doug Warren on 10/27/12.
//  Copyright (c) 2012 Doug Warren. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kFAMModelDidChangeNotification @"FAMModelDidChangeNotification"

@interface FlexAuthModel : NSObject
+ (FlexAuthModel*) sharedService;

- (BOOL) isValidLabel:(NSString*)label;
- (NSInteger) count;
- (NSString*) labelAtIndex:(NSInteger)index;
- (NSString*) passwordForLabel:(NSString*)label;

@end
