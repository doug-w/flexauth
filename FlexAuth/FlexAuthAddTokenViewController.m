//
//  FlexAuthAddTokenViewController.m
//  FlexAuth
//
//  Created by Doug Warren on 10/27/12.
//  Copyright (c) 2012 Doug Warren. All rights reserved.
//

#import "FlexAuthAddTokenViewController.h"
#import "FlexAuthModel.h"

@interface FlexAuthAddTokenViewController ()

@property (weak, nonatomic) IBOutlet UITextField *accountNameField;
@property (weak, nonatomic) IBOutlet UILabel *tokenLabel;
@property (weak, nonatomic) IBOutlet UIButton *requestTokenButton;
@property (weak, nonatomic) IBOutlet UIButton *enterTokenButton;

@property (weak, nonatomic) IBOutlet UILabel *serialLabel;
@property (weak, nonatomic) IBOutlet UITextField *serialField;
@property (weak, nonatomic) IBOutlet UILabel *secretLabel;
@property (weak, nonatomic) IBOutlet UITextField *secretField;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property (weak, nonatomic) UIActivityIndicatorView* networkActivity;

- (IBAction)requestNewToken:(id)sender;
- (IBAction)enterTokenManually:(id)sender;
- (IBAction)saveToken:(id)sender;
- (IBAction)backGroundTap:(id) sender;

- (void)displayTokenEntryUI:(BOOL)toDisplay;
- (void)setupTextField:(UITextField*)textField withTag:(NSInteger)tag;
- (void)saveFailedPopup:(NSString*)reason;

@end

@implementation FlexAuthAddTokenViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.networkActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.networkActivity.hidesWhenStopped = TRUE;
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
    
    [self setupTextField:self.accountNameField withTag:1];
    [self setupTextField:self.serialField withTag:2];
    [self setupTextField:self.secretField withTag:3];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [self displayTokenEntryUI:NO];
}

#define kFAMUSEnrollURL @"http://m.us.mobileservice.blizzard.com/enrollment/enroll.htm"

- (void)retrieveNewToken:(NSString*)region
{
    if([region isEqualToString:@"US"]) {
        NSData* tokenData = [NSData dataWithContentsOfURL:[NSURL URLWithString:kFAMUSEnrollURL]];

    }
    [self.networkActivity stopAnimating];
}

#pragma mark - IBActions

- (IBAction)requestNewToken:(id)sender
{
    [self.networkActivity startAnimating];
    [self performSelectorInBackground:@selector(retrieveNewToken) withObject:@"US"];
    
    //[self displayTokenEntryUI:YES];
}

- (IBAction)enterTokenManually:(id)sender
{
   [self displayTokenEntryUI:YES];
}

- (IBAction)saveToken:(id)sender
{
    NSString* failureMessage;

    if ([self.accountNameField.text length] == 0) {
        failureMessage = @"Please enter an Account Name";
    } else if ([[FlexAuthModel sharedService] isValidLabel:self.accountNameField.text] == NO) {
        failureMessage = @"Name already used enter another";
    } else if ([self.serialField.text length] == 0) {
        failureMessage = @"Please enter a Serial number";
    } else if ([self.secretField.text length] != 40) {
        failureMessage = @"Please recheck secret code it is not valid";
    }
    
    if (failureMessage != nil) {
        [self saveFailedPopup:failureMessage];
        return;
    }

    [[FlexAuthModel sharedService] addToken:self.accountNameField.text
                                 withSerial:self.serialField.text
                                 withSecret:self.secretField.text];

    self.tabBarController.selectedIndex = 0;
}

- (IBAction)backGroundTap:(id)sender
{
    [[[self view] subviews] makeObjectsPerformSelector: @selector(resignFirstResponder)];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    UIView* nextResponder = [textField.superview viewWithTag:textField.tag+1];
    if (nextResponder && nextResponder.hidden == NO) {
        [nextResponder becomeFirstResponder];
    }
}

#pragma mark - Utility functions

- (void)saveFailedPopup:(NSString *)reason
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Save Failed"
                                                      message:reason
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
}

- (void)setupTextField:(UITextField*)textField withTag:(NSInteger)tag
{
    textField.delegate = self;
    textField.tag = tag;
    textField.returnKeyType = UIReturnKeyNext;
}

-(void)displayTokenEntryUI:(BOOL)toDisplay
{
    self.tokenLabel.hidden = toDisplay;
    self.requestTokenButton.hidden = toDisplay;
    self.enterTokenButton.hidden = toDisplay;
    
    self.serialLabel.hidden = !toDisplay;
    self.serialField.hidden = !toDisplay;
    self.secretLabel.hidden = !toDisplay;
    self.secretField.hidden = !toDisplay;
    self.saveButton.hidden = !toDisplay;
}
@end
