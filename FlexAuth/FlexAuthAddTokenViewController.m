//
//  FlexAuthAddTokenViewController.m
//  FlexAuth
//
//  Created by Doug Warren on 10/27/12.
//  Copyright (c) 2012 Doug Warren. All rights reserved.
//

#import "FlexAuthAddTokenViewController.h"

@interface FlexAuthAddTokenViewController ()

@end

@implementation FlexAuthAddTokenViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.jpg"]];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.requestTokenButton.hidden = NO;
    self.enterTokenButton.hidden = NO;
}

- (IBAction)requestNewToken:(id)sender
{
    self.requestTokenButton.hidden = YES;
    self.enterTokenButton.hidden = YES;
}

- (IBAction)enterTokenManually:(id)sender
{
    self.requestTokenButton.hidden = YES;
    self.enterTokenButton.hidden = YES;
}
@end
