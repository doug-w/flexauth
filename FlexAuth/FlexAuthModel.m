//
//  FlexAuthModel.m
//  FlexAuth
//
//  Created by Doug Warren on 10/27/12.
//  Copyright (c) 2012 Doug Warren. All rights reserved.
//

#import "FlexAuthModel.h"
#import "FlexAuthTimeSync.h"
#import "NSData+HexString.h"
#import "CommonCrypto/CommonHMAC.h"

@interface FlexAuthModel ()
@property (nonatomic, assign) NSUserDefaults* userDefaults;
@property (nonatomic, retain) NSArray* tokenRows;

-(NSDictionary*) _rowForLabel:(NSString*)label;
@end

@implementation FlexAuthModel
+ (FlexAuthModel*) sharedService
{
    static FlexAuthModel* service = nil;
    if (service == nil) {
        @synchronized(service) {
            if(service == nil) {
                service = [[FlexAuthModel alloc] init];
            }
        }
    }
    
    return service;
}

- (id) init
{
    self.userDefaults = [NSUserDefaults standardUserDefaults];

    _tokenRows = [self.userDefaults objectForKey:@"rows"];
    
    if([_tokenRows count] == 0)
    {
        // TODO: DJW oblit this in git history
        NSDictionary *defaultRow = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"Hi", @"label",
                                    @"f46a0ab66c12e7030de53a0497b954dc8b9f25d9", @"secret",
                                    nil
                                    ];
        [self.userDefaults setObject:[NSArray arrayWithObject:defaultRow]
                              forKey:@"rows"];
        [self.userDefaults synchronize];
        _tokenRows = [self.userDefaults objectForKey:@"rows"];
    }
    
    return self;
}

- (NSInteger) count
{
    return [self.tokenRows count];
}

- (NSString*) labelAtIndex:(NSInteger)index
{
    NSDictionary* rowData = [self.tokenRows objectAtIndex:index];
    return [rowData objectForKey:@"label"];
}

- (NSString*) passwordForLabel:(NSString*)label
{
    NSDictionary* rowData = [self _rowForLabel:label];
    NSString* secret = [rowData objectForKey:@"secret"];
    
    uint64_t time = [[FlexAuthTimeSync sharedService] currentTimeMilliSec] / 30000L;
    
    // For simulator testing
    time = CFSwapInt64HostToBig(time);
    
    NSData* data = [NSData dataWithBytes:&time length:sizeof(time)];
    
    NSData* key = [NSData dataWithHexString:secret];
    char macOut[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac( kCCHmacAlgSHA1, [key bytes], [key length], [data bytes], [data length], &macOut );
    
	NSData* mac = [NSData dataWithBytes:macOut length:CC_SHA1_DIGEST_LENGTH];
    
    unsigned char source;
    NSRange sourceRange = {19, 1};
    [mac getBytes:&source range:sourceRange];
    source = source & 0x0F;
    
    NSRange authRange = {(int)source, 4};
    
    int auth;
    [mac getBytes:&auth range:authRange];
    auth = CFSwapInt32BigToHost(auth);
    
    int code = auth & 0x7FFFFFFF;
    
    double modulo = pow(10.0, 8.0);
    code = (int)fmod((double)code, modulo);
    
    return [NSString stringWithFormat:@"%08d", code];
}

-(NSDictionary*) _rowForLabel:(NSString*)label
{
    for(NSDictionary* dict in self.tokenRows) {
        if ([[dict objectForKey:@"label"] isEqualToString:label]) {
            return dict;
        }
    }
    return nil;
}
@end
