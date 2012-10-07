//
//  FlexAuthTableViewController.m
//  FlexAuth
//
//  Created by Doug Warren on 10/6/12.
//  Copyright (c) 2012 Doug Warren. All rights reserved.
//

#import "FlexAuthTableViewController.h"

@interface FlexAuthTableViewController ()
@property NSDictionary* model;

@property IBOutlet UIProgressView* timerView;

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
    NSArray* tokenRows = [self.userDefaults objectForKey:@"rows"];
    
    if([tokenRows count] == 0)
    {
        NSDictionary *defaultData = [NSDictionary dictionaryWithObject:@"Hi" forKey:@"label"];
        [self.userDefaults setObject:[NSArray arrayWithObject:defaultData] forKey:@"rows"];
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
    
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    int randomNumber = fmod(currentTime, 1000000000.0);
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",randomNumber];
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
@end
