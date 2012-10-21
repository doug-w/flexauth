//
//  NSData+HexString.h
//  FlexAuth
//
//  Created by Doug Warren on 10/7/12.
//  Copyright (c) 2012 Doug Warren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (HexString)
+(id)dataWithHexString:(NSString*) string;
@end
