//
//  FlexAuthTableViewController.m
//  FlexAuth
//
//  Created by Doug Warren on 10/6/12.
//  Copyright (c) 2012 Doug Warren. All rights reserved.
//

#import "FlexAuthTableViewController.h"
#import "FlexAuthTimeSync.h"

// Move to crypto
#import "NSData+HexString.h"
#import "CommonCrypto/CommonHMAC.h"

@interface FlexAuthTableViewController ()
@property NSDictionary* model;

@property IBOutlet UIProgressView* timerView;

@property (nonatomic, copy)NSNumber* timeOffset;

@property NSTimer* stopWatchTimer;
@property float previousPercentValue;

@property (nonatomic, assign) NSUserDefaults* userDefaults;
@end

@implementation FlexAuthTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.userDefaults = [NSUserDefaults standardUserDefaults];

    // Load time from the user defaults
    self.timeOffset = [self.userDefaults objectForKey:@"offset"];
    
    // If the time service has come back load time from there
    if ([FlexAuthTimeSync sharedService].receivedTime == YES) {
        self.timeOffset = [FlexAuthTimeSync sharedService].timeOffset;
        [self.userDefaults setObject:self.timeOffset
                              forKey:@"offset"];
        [self.userDefaults synchronize];
    } else {
        // Otherwise use the time we had last time but wait for the new time to come in
        [[FlexAuthTimeSync sharedService] addObserver:self
                                           forKeyPath:@"timeOffset"
                                              options:NSKeyValueObservingOptionNew
                                              context:nil];
    }
    
    NSArray* tokenRows = [self.userDefaults objectForKey:@"rows"];
    
    if([tokenRows count] == 0)
    {
        NSDictionary *defaultData = [NSDictionary dictionaryWithObject:@"Hi"
                                                                forKey:@"label"];
        [self.userDefaults setObject:[NSArray arrayWithObject:defaultData]
                              forKey:@"rows"];
        [self.userDefaults synchronize];
    }

    [self updateTimerView];
    
    self.stopWatchTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/10.0
                                                           target:self
                                                         selector:@selector(updateTimerView)
                                                         userInfo:nil
                                                          repeats:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray* tokenRows = [self.userDefaults objectForKey:@"rows"];
    
    return [tokenRows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FlexCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
 
    NSArray* tokenRows = [self.userDefaults objectForKey:@"rows"];
    NSDictionary* rowData = [tokenRows objectAtIndex:indexPath.row];
    
    // Configure the cell...
    cell.textLabel.text = [rowData objectForKey:@"label"];
    
    NSString* password = [self getPassword];
    
    cell.detailTextLabel.text = password;
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - FlexAuthTableViewController methods

- (void) updateTimerView
{

    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    double percentProgress = fmod(currentTime, 30.0);
    percentProgress = percentProgress / 30.0;
    
    // NSLog(@"Setting timer to %f", (float)percentProgress);
    
    [self.timerView setProgress:percentProgress];
    
    if(self.previousPercentValue > percentProgress)
    {
        [self.tableView reloadData];
    }
    
    self.previousPercentValue = percentProgress;
}

- (uint64_t)currentTimeMilliSec
{
    NSTimeInterval currentTimeMilliSec = [[NSDate date] timeIntervalSince1970]*1000;
    currentTimeMilliSec += [self.timeOffset doubleValue];
    uint64_t time = currentTimeMilliSec / 30000L ;
    
    // time = 44987614;
    
    return time;
}

- (NSString*) getPassword
{
    // TODO: DJW Move this to a model class
    // Model listens to the timestamp
    // Model throws an event when it's time to change
    // View Controller listens to the event and notifies the view
    
    
    // TODO: DJW oblit this in git history
    NSString* secret = @"f46a0ab66c12e7030de53a0497b954dc8b9f25d9";

    uint64_t time = [self currentTimeMilliSec];
    
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

#pragma mark - KVO

- (void) observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    if ([keyPath isEqual:@"timeOffset"]) {
        self.timeOffset = [change objectForKey:NSKeyValueChangeNewKey];
        [self.tableView reloadData];
        [self updateTimerView];

        [[FlexAuthTimeSync sharedService] removeObserver:self forKeyPath:@"timeOffset"];
        
        [self.userDefaults setObject:self.timeOffset
                              forKey:@"offset"];
        [self.userDefaults synchronize];
    }
}

@end
