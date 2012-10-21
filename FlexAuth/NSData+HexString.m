//
//  NSData+HexString.m
//  FlexAuth
//
//  Created by Doug Warren on 10/7/12.
//  Copyright (c) 2012 Doug Warren. All rights reserved.
//

#import "NSData+HexString.h"

@implementation NSData (HexString)
+(id)dataWithHexString:(NSString *)string
{
    char charBuffer[3];
    charBuffer[2] = '\0';
    
    int lenString = [string length];
    unsigned char* byteBuffer = malloc(lenString / 2);
    unsigned char* pByteBuffer = byteBuffer;
    
    for(int i = 0 ; i < lenString ; i += 2)
    {
        charBuffer[0] = [string characterAtIndex:i];
        charBuffer[1] = [string characterAtIndex:i+1];
        
        char* pEnd = NULL;
        *pByteBuffer = strtol(charBuffer, &pEnd, 16);
        pByteBuffer++;
    }
    
    return [NSData dataWithBytesNoCopy:byteBuffer length:lenString/2 freeWhenDone:YES];
}
@end
