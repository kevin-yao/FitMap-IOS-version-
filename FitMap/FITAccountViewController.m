//
//  AccountViewController.m
//  FitMap
//
//  Created by Christina on 7/28/14.
//  Copyright (c) 2014 CMU. All rights reserved.
//

#import "FITAccountViewController.h"
#import "FITTermOfUseViewController.h"
#import "FITAppDelegate.h"
#import "UserInfo.h"

@interface FITAccountViewController ()
{
    NSArray *fetchedObjects;
    BOOL editOrSave;
}
@end

@implementation FITAccountViewController

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
    editOrSave = YES;
    [self.userNamelbl setUserInteractionEnabled:NO];
    [self.passwordlbl setUserInteractionEnabled:NO];
    [self.weightlbl setUserInteractionEnabled:NO];
    if(self.userInfo!=nil){
        [self displayManagedObject: self.userInfo];
    }
}
//configure text field view
-(void)displayManagedObject:(UserInfo *)obj {
    self.userNamelbl.text = [obj valueForKey:@"username"];
    self.passwordlbl.text = [obj valueForKey:@"password"];
    self.weightlbl.text = [(NSNumber *)[obj valueForKey:@"weight"] stringValue];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//switch to term of use
- (IBAction)termbtn:(id)sender {
    FITTermOfUseViewController *termViewController =
    [self.storyboard instantiateViewControllerWithIdentifier:@"TermView"];
    [self.navigationController pushViewController:termViewController animated:YES];
}
//log out
- (IBAction)logOutbtn:(id)sender {
    FITAccountViewController *accountViewController =
    [self.storyboard instantiateViewControllerWithIdentifier:@"SignUpView"];
    [self presentViewController:accountViewController animated:YES completion:nil];
}
//when user press "edit", enable textfield interface.
//when they are done, save data to database
- (IBAction)editUserInformation:(id)sender {
    if(editOrSave){
        editOrSave = NO;
        [self.editInformationBtn setTitle:@"Save" forState:UIControlStateNormal];
        [self.userNamelbl setUserInteractionEnabled:YES];
        [self.passwordlbl setUserInteractionEnabled:YES];
        [self.weightlbl setUserInteractionEnabled:YES];
    }else{
        editOrSave = YES;
        [self.editInformationBtn setTitle:@"Edit" forState:UIControlStateNormal];
        NSManagedObjectContext *context = [AppDelegate managedObjectContext];
        //delete previous record if they are existed
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:@"UserInfo" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"username == %@", self.userNamelbl.text];
        NSError *error2;
        fetchedObjects = [context executeFetchRequest:fetchRequest error:&error2];
        for (UserInfo *obj in fetchedObjects) {
            [context deleteObject:obj];
        }
        //save new record
        UserInfo *userInfo = [NSEntityDescription
                              insertNewObjectForEntityForName:@"UserInfo"
                              inManagedObjectContext:context];
        userInfo.username = self.userNamelbl.text;
        userInfo.password = self.passwordlbl.text;
        NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber * myNumber = [numberFormatter numberFromString:self.weightlbl.text];
        userInfo.weight = myNumber;
        
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Error:%@", error);
        }
        
        [fetchRequest setEntity:entity];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"username == %@", self.userNamelbl.text];
        fetchedObjects = [context executeFetchRequest:fetchRequest error:&error2];
        //display new record
        userInfo = [fetchedObjects objectAtIndex:0];
        [self displayManagedObject:userInfo];
        [self.userNamelbl setUserInteractionEnabled:NO];
        [self.passwordlbl setUserInteractionEnabled:NO];
        [self.weightlbl setUserInteractionEnabled:NO];
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
}
@end
