//
//  FITExerciseDetailViewController.m
//  FitMap
//
//  Created by Kangping Yao on 7/22/14.
//  Copyright (c) 2014 CMU. All rights reserved.
//

#import "FITExerciseDetailViewController.h"
#import "FITRouteViewController.h"
#import "FITAppDelegate.h"
#import "UserInformation.h"
@interface FITExerciseDetailViewController ()
{
    MKPointAnnotation *point;
    FITRouteViewController *routeViewController;
    UserInformation *userInformation;
    float distanceNum;
    float calorieNum;
    BOOL firstIndex;
}
@property (nonatomic, assign) BOOL didUpdateUserLocation;
@property (nonatomic) BOOL startStopButtonIsActive;
- (void)configureView;
- (void)getDirections;
- (void)saveData: (NSString *) fileName;
@end

@implementation FITExerciseDetailViewController


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
    self.managedObjectContext = [AppDelegate managedObjectContext];
    self.locations = [[NSMutableArray alloc]init];
    self.didUpdateUserLocation = YES;
    self.startStopButtonIsActive = YES;
    self.mapView.delegate=self;
    self.mapView.showsUserLocation = YES;
    distanceNum = 0.0;
    calorieNum = 0.0;
    firstIndex = YES;
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    userInformation=[UserInformation getInstance];
    [self configureView];
    [self getDirections];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_mapView setShowsUserLocation: NO];
}
#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
    }
}
//get direction to user's destination
- (void)getDirections
{
    NSString *location = [self.detailItem valueForKey:@"destination"];
    if(location!=nil){
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:location
                     completionHandler:^(NSArray* placemarks, NSError* error){
                         if (placemarks && placemarks.count > 0) {
                             CLPlacemark *topResult = [placemarks objectAtIndex:0];
                             MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:topResult];
                             MKMapItem *destination = [[MKMapItem alloc]initWithPlacemark:placemark];
                             MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
                             
                             request.source = [MKMapItem mapItemForCurrentLocation];
                             
                             request.destination = destination;
                             request.requestsAlternateRoutes = NO;
                             MKDirections *directions =
                             [[MKDirections alloc] initWithRequest:request];
                             
                             [directions calculateDirectionsWithCompletionHandler:
                              ^(MKDirectionsResponse *response, NSError *error) {
                                  if (error) {
                                      // Handle error
                                  } else {
                                      [self showRoute:response];
                                  }
                              }];
                             
                             if(point==nil){
                                 point = [[MKPointAnnotation alloc] init];
                             }
                             point.coordinate = placemark.coordinate;
                             point.title = location;
                             [_mapView addAnnotation:point];
                         }
                     }
         ];
    }
}

-(void)showRoute:(MKDirectionsResponse *)response
{
    for (MKRoute *route in response.routes)
    {
        [_mapView
         addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    MKPolylineRenderer *renderer =
    [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor blueColor];
    renderer.lineWidth = 5.0;
    return renderer;
}

- (void)configureView
{
    // Update the user interface for the detail item.
    self.distance.text = @"0.0 miles";
    self.calorie.text = @"0.0 Calories";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if(self.didUpdateUserLocation){
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 2000, 2000);
        [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
        self.didUpdateUserLocation = NO;
    }
}
//record user's path by saving gps data
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    if(!newLocation) return;
    //save the starting point
    if(firstIndex)
    {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error == nil && [placemarks count] > 0) {
                CLPlacemark *placemark = [placemarks lastObject];
                NSString *startingAddress = [NSString stringWithFormat:@"%@ %@ %@ %@ %@",
                                             placemark.subThoroughfare==nil?@"":placemark.subThoroughfare,
                                             placemark.thoroughfare==nil?@"":placemark.thoroughfare,
                                             placemark.locality==nil?@"":placemark.locality,
                                             placemark.administrativeArea==nil?@"":placemark.administrativeArea,
                                             placemark.postalCode==nil?@"":placemark.postalCode];
                [self.detailItem setValue:startingAddress forKey:@"startingAddress"];
                // Save the context.
                NSError *error = nil;
                if (![self.managedObjectContext save:&error]) {
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                }
            } else {
                NSLog(@"%@", error.debugDescription);
            }
        } ];
        firstIndex = NO;
    }
    if ((oldLocation.coordinate.latitude != newLocation.coordinate.latitude) &&
        (oldLocation.coordinate.longitude != newLocation.coordinate.longitude))
    {
        CLLocation *loc1 = [[CLLocation alloc] initWithLatitude:oldLocation.coordinate.latitude longitude:oldLocation.coordinate.longitude];
        
        CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
        double interval = ([loc1 distanceFromLocation:loc2]) * 0.000621371192;
        if(interval<1.0){
            distanceNum += interval;
            calorieNum += 0.75*interval*[userInformation.getWeight doubleValue];
            CLLocation *curLocation = [[CLLocation alloc] init];
            curLocation = [newLocation copy];
            [self.locations addObject:curLocation];
        }
        [self.distance setText:[NSString stringWithFormat:@"%.5lf miles",distanceNum]];
        [self.calorie setText:[NSString stringWithFormat:@"%.5lf Calories",calorieNum]];
    }
}
//save GPS data to file
-(void)saveData: (NSString *)fileName
{
    NSArray *directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [directories firstObject];
    NSString *file = [documents stringByAppendingPathComponent:fileName];
    if(![[NSFileManager defaultManager] fileExistsAtPath:file]){
        [[NSFileManager defaultManager]
         createFileAtPath:file contents:nil attributes:nil];
    }
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:file];
    for(int i=0; i<self.locations.count; i++){
        CLLocation *curLocation = self.locations[i];
        NSString *resultLine = [NSString stringWithFormat:@"%f,%f\n", curLocation.coordinate.latitude, curLocation.coordinate.longitude];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[resultLine dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [fileHandle closeFile];
    NSLog(@"SAVE DATA");
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    routeViewController=[segue destinationViewController];
    routeViewController.locations = self.locations;
    [routeViewController setDetailItem:self.detailItem];
}
//button control
- (IBAction)startStopAction:(id)sender {
    // First press will start running, change button title and begin updating location
    if(self.startStopButtonIsActive){
        self.startStopButtonIsActive=!self.startStopButtonIsActive;
        [self.startStopButton setTitle:@"Completed?" forState:UIControlStateNormal];
        [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
        [self.locationManager startUpdatingLocation];
    }else
    // Second press will finish the running, and end updating location.
    {
        [self.detailItem setValue:[NSNumber numberWithBool: YES] forKey:@"completed"];
        [self.detailItem setValue:[NSNumber numberWithDouble: distanceNum] forKey:@"distance"];
        [self.detailItem setValue:[NSNumber numberWithDouble: calorieNum] forKey:@"calorie"];
        // Save the context.
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        self.startStopButtonIsActive=!self.startStopButtonIsActive;
        [self.startStopButton setTitle:@"Start" forState:UIControlStateNormal];
        [self.locationManager stopUpdatingLocation];
        NSDate *alarmTime = [self.detailItem valueForKey:@"alarmTime"];
        [self saveData: [[alarmTime description] stringByAppendingString:@".csv"]];
        [self performSegueWithIdentifier:@"showRoute" sender:sender];
    }
}
@end
