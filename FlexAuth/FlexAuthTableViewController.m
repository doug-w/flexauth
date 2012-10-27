//
//  FlexAuthTableViewController.m
//  FlexAuth
//
//  Created by Doug Warren on 10/6/12.
//  Copyright (c) 2012 Doug Warren. All rights reserved.
//

#import "FlexAuthTableViewController.h"
#import "FlexAuthTimeSync.h"
#import "FlexAuthModel.h"

@interface FlexAuthTableViewController ()
@property IBOutlet UIProgressView* timerView;

@property NSTimer* stopWatchTimer;
@property float previousPercentValue;

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

    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.jpg"]];
    [tempImageView setFrame:self.tableView.frame];
    
    self.tableView.backgroundView = tempImageView;
    
    if ([FlexAuthTimeSync sharedService].receivedTime == NO) {
        // Add a KVO for the time changing due to drift between the device and blizzard
        [[FlexAuthTimeSync sharedService] addObserver:self.tableView
                                           forKeyPath:@"timeOffset"
                                              options:NSKeyValueObservingOptionNew
                                              context:nil];
    }
    
    [self updateTimerView];
    
    self.stopWatchTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/30.0
                                                           target:self
                                                         selector:@selector(updateTimerView)
                                                         userInfo:nil
                                                          repeats:YES];
    
    [[NSNotificationCenter defaultCenter]   addObserver:self.tableView
                                               selector:@selector(reloadData)
                                                   name:kFAMModelDidChangeNotification
                                                 object:nil];   
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.tableView];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{   
    return [[FlexAuthModel sharedService] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FlexCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.backgroundColor = [UIColor blackColor];
    
    cell.textLabel.text = [[FlexAuthModel sharedService] labelAtIndex:indexPath.row];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    
    cell.imageView.image = [UIImage imageNamed:@"gpg.png"];
    
    NSString* password = [[FlexAuthModel sharedService] passwordForLabel:cell.textLabel.text];
    
    cell.detailTextLabel.text = password;
    [cell.detailTextLabel setTextColor:[UIColor whiteColor]];
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
    NSTimeInterval currentTime = [[FlexAuthTimeSync sharedService] currentTimeMilliSec];
    double percentProgress = fmod(currentTime, 30000.0);
    percentProgress = percentProgress / 30000.0;
    
    // NSLog(@"Setting timer to %f", (float)percentProgress);
    
    [self.timerView setProgress:percentProgress];
    
    if (self.previousPercentValue > percentProgress) {
        [self.tableView reloadData];
    }

    
    self.previousPercentValue = percentProgress;
}

#pragma mark - KVO

- (void) observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    if ([keyPath isEqual:@"timeOffset"]) {
        [self updateTimerView];

        // Don't listen for any more changes
        [[FlexAuthTimeSync sharedService] removeObserver:self forKeyPath:@"timeOffset"];
    }
}

@end
