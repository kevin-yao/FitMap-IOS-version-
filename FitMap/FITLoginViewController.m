//
//  FITLoginViewController.m
//  FitMap
//
//  Created by Kangping Yao on 7/21/14.
//  Fitbit connection by Xiaoxiao Kong
//  Copyright (c) 2014 CMU. All rights reserved.
//

#import "FITLoginViewController.h"
#import "UserInfo.h"
#import "FITAppDelegate.h"
#import "FITDailyRunViewController.h"
#import "FITAccountViewController.h"
#import "UserInformation.h"
@interface FITLoginViewController ()
{
    NSString* loginUsername;
    UserInfo* userInfo;
    UserInformation* userSingletonInstance;
}
- (BOOL)checkPassword: (NSString*) username;
@end

@implementation FITLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.password.secureTextEntry = YES;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//enable return key
- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
//check password first, if it is right, set user information as a singleton instance
- (IBAction)loginClicked:(id)sender {
    loginUsername = self.username.text;
    if([self checkPassword: loginUsername]){
        userSingletonInstance=[UserInformation getInstance];
        [userSingletonInstance setUsername:userInfo.username];
        [userSingletonInstance setPassword:userInfo.password];
        [userSingletonInstance setWeight:userInfo.weight];
        [self performSegueWithIdentifier:@"login_success" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"login_success"]){
        UITabBarController *tabBarController = [segue destinationViewController];
        UINavigationController *navigationController = tabBarController.viewControllers[3];
        FITAccountViewController *accountViewController = (FITAccountViewController*)navigationController.topViewController;
        accountViewController.userInfo = userInfo;
    }
}
//match the password with the record in database
- (BOOL)checkPassword: (NSString*) username {
    NSManagedObjectContext *context = [AppDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"UserInfo" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"username == %@", loginUsername];
    NSError *error2;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error2];
    if([fetchedObjects count]>0){
        userInfo = [fetchedObjects objectAtIndex:0];
        NSLog(@"password: %@", userInfo.password);
        if([userInfo.password isEqualToString:self.password.text]){
            return YES;
        }else{
            [self alertStatus:@"Password isn't right, try again!": @"Login Fail": 0];
            return NO;
        }
    }else{
        [self alertStatus: @"username doesn't exist, please sign up!": @"Login Fail": 0];
        return NO;
    }
}
//tap background to finsih text editing
- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
}
//connect to fitbit
- (IBAction)connectFitbit:(id)sender {
    OAuthIOModal *oauthioModal = [[OAuthIOModal alloc] initWithKey:@"dI4U1elCs-mHOUl0zfFFS7Pmltc" delegate:self];
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    [options setObject:@"true" forKey:@"cache"];
    [oauthioModal showWithProvider:@"fitbit"];
}

// Handles the results of a successful authentication
- (void)didReceiveOAuthIOResponse:(OAuthIORequest *)request{
    //test for get credentials
    NSDictionary *credentials = [request getCredentials];
    NSLog(@"oauth_token: %@", [credentials objectForKey:@"oauth_token"]);
    NSLog(@"oauth_token_secret: %@", [credentials objectForKey:@"oauth_token_secret"]);
    //get weight data
    [request get:@"/1/user/-/profile.xml" success:^(NSDictionary *output, NSString *body, NSHTTPURLResponse *httpResponse)
     {
         NSString *rawResult = body;
         NSArray *myWords = [rawResult componentsSeparatedByString:@"<weight>"];
         NSString* firstCut = [myWords objectAtIndex: 1];
         NSArray *WeightArray = [firstCut componentsSeparatedByString:@"</weight>"];
         NSString* weight = [WeightArray objectAtIndex: 0];
         double finalWeight = [weight doubleValue] * 2.2;
         [self saveWeightData:&finalWeight];
         
     }];
    
    
}

// Handle errors in the case of an unsuccessful authentication
- (void)didFailWithOAuthIOError:(NSError *)error{
    
}

//save weight data to core data
- (void) saveWeightData: (double *) weight {
    FITAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate managedObjectContext];
    NSManagedObject *dataRecord = [NSEntityDescription
                                   insertNewObjectForEntityForName:@"UserInfo"
                                   inManagedObjectContext:context];
    
    [dataRecord setValue:@"Christina" forKey:@"username"];
    [dataRecord setValue:@"password" forKey:@"password"];
    [dataRecord setValue:[NSNumber numberWithDouble:*weight] forKey:@"weight"];
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Error:%@", error);
    }
    NSLog(@"Weight saved");
    
    
}

- (void) alertStatus:(NSString *)msg :(NSString *)title :(int) tag
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
    alertView.tag = tag;
    [alertView show];
}
@end
