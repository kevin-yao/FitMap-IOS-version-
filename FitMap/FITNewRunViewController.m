//
//  FITNewRunViewController.m
//  FitMap
//
//  Created by Kangping Yao on 7/21/14.
//  Copyright (c) 2014 CMU. All rights reserved.
//

#import "FITNewRunViewController.h"
#import "RunInfo.h"
#import "UserInformation.h"
@interface FITNewRunViewController ()
{
    NSString *address;
    MKPointAnnotation *point;
    UserInformation *userInformation;
}
@property (nonatomic, assign) BOOL didUpdateUserLocation;
@property (weak, nonatomic) IBOutlet UITextField *destination;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@end

@implementation FITNewRunViewController

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
    // Do any additional setup after loading the view.
    self.managedObjectContext = [AppDelegate managedObjectContext];
    self.didUpdateUserLocation = YES;
    userInformation = [UserInformation getInstance];
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_mapView setShowsUserLocation: NO];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if(sender != self.doneButton) return;
    // Request to reload table view data
    if(address!=nil){
        // Get the current date
        NSDate *pickerDate = [self.datePicker date];
        // Schedule the alarm
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = pickerDate;
        localNotification.alertBody = @"It's time to workout";
        localNotification.alertAction = @"Show me the item";
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
        RunInfo *runInfo = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
        // If appropriate, configure the new managed object.
        // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
        runInfo.username = [userInformation getUsername];
        runInfo.alarmTime = pickerDate;
        runInfo.destination = address;
        runInfo.completed = [NSNumber numberWithBool: NO];
        
        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//touch background to start location
- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
    NSString *location = self.destination.text;
    if(location!=nil){
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            [geocoder geocodeAddressString:location
                 completionHandler:^(NSArray* placemarks, NSError* error){
                     if (placemarks && placemarks.count > 0) {
                         CLPlacemark *topResult = [placemarks objectAtIndex:0];
                         MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:topResult];
                         address = [NSString stringWithFormat:@"%@ %@ %@ %@ %@",
                                    placemark.subThoroughfare==nil?@"":placemark.subThoroughfare,
                                    placemark.thoroughfare==nil?@"":placemark.thoroughfare,
                                    placemark.locality==nil?@"":placemark.locality,
                                    placemark.administrativeArea==nil?@"":placemark.administrativeArea,
                                    placemark.postalCode==nil?@"":placemark.postalCode];
                         MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(placemark.coordinate, 2000, 2000);
                         [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
                         if(point==nil){
                             point = [[MKPointAnnotation alloc] init];
                         }
                         point.coordinate = placemark.coordinate;
                         point.title = address;
                         [_mapView addAnnotation:point];
                     }else{
                         UIAlertView *alertView = [[UIAlertView alloc]
                                                   initWithTitle:@"Locate Fail"
                                                   message:@"Sorry, we can't find this address. Please " "enter another address"
                                                   delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
                         [alertView show];
                     }
                 }
         ];
        }
}

#pragma mark - Fetched results controller
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RunInfo" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"alarmTime" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"username == %@", [userInformation getUsername]];
    [NSFetchedResultsController deleteCacheWithName:@"Master"];
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if(self.didUpdateUserLocation){
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 2000, 2000);
        [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
        self.didUpdateUserLocation = NO;
    }
}

@end
