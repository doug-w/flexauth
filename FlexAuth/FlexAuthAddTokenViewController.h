//
//  FlexAuthAddTokenViewController.h
//  FlexAuth
//
//  Created by Doug Warren on 10/27/12.
//  Copyright (c) 2012 Doug Warren. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlexAuthAddTokenViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *requestTokenButton;
@property (weak, nonatomic) IBOutlet UIButton *enterTokenButton;



- (IBAction)requestNewToken:(id)sender;
- (IBAction)enterTokenManually:(id)sender;
@end
