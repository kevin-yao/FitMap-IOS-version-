//
//  AccountViewController.h
//  FitMap
//
//  Created by Christina on 7/28/14.
//  Copyright (c) 2014 CMU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"
@interface FITAccountViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userNamelbl;
@property (weak, nonatomic) IBOutlet UITextField *passwordlbl;
@property (weak, nonatomic) IBOutlet UITextField *weightlbl;
@property (strong, nonatomic) IBOutlet UIButton *editInformationBtn;
@property (strong, nonatomic) UserInfo *userInfo;
- (IBAction)termbtn:(id)sender;
- (IBAction)logOutbtn:(id)sender;
- (IBAction)editUserInformation:(id)sender;
- (IBAction)backgroundTap:(id)sender;
@end
