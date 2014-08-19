//
//  FITLoginViewController.h
//  FitMap
//
//  Created by Kangping Yao on 7/21/14.
//  Fitbit connection by Xiaoxiao Kong
//  Copyright (c) 2014 CMU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OAuthiOS/OAuthiOS.h>

@interface FITLoginViewController : UIViewController <UITextFieldDelegate,OAuthIODelegate>

@property (strong, nonatomic) IBOutlet UITextField *username;
@property (strong, nonatomic) IBOutlet UITextField *password;

- (IBAction)loginClicked:(id)sender;
- (IBAction)backgroundTap:(id)sender;

- (IBAction)connectFitbit:(id)sender;

// Handles the results of a successful authentication
- (void)didReceiveOAuthIOResponse:(OAuthIORequest *)request;

// Handle errors in the case of an unsuccessful authentication
- (void)didFailWithOAuthIOError:(NSError *)error;

@end
