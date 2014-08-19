//
//  FITRouteViewController.m
//  FitMap
//
//  Created by Kangping Yao on 7/25/14.
//  Copyright (c) 2014 CMU. All rights reserved.
//

#import "FITRouteViewController.h"
#import "UserInformation.h"

@interface FITRouteViewController ()
{
    double distanceValue;
    double calorieValue;
    NSString *startingAddress;
    NSString *destinationAddress;
    UserInformation *userInformation;
}
@property (nonatomic, strong) MKPolylineView *lineView;
@property (nonatomic, strong) MKPolyline *polyline;
@property (nonatomic, assign) BOOL didUpdateUserLocation;
@end

@implementation FITRouteViewController

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
    distanceValue=0.0;
    calorieValue = 0.0;
    self.didUpdateUserLocation = NO;
    self.mapView.delegate = self;
    [_mapView removeOverlays:_mapView.overlays];
    startingAddress = (NSString*)[self.detailItem valueForKey:@"startingAddress"];
    destinationAddress = (NSString*)[self.detailItem valueForKey:@"destination"];
    userInformation = [UserInformation getInstance];
    [self drawLineSubroutine];
}

#pragma mark - Managing the detail item
- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//Use GPS data to draw a route user has run
- (void)drawLineSubroutine {
    // remove polyline if one exists
    //[self.mapView removeOverlay:self.polyline];
    MKCoordinateRegion region;
    if(self.locations!=nil && self.locations.count>2){
    // create an array of coordinates from allPins
        CLLocationCoordinate2D coordinates[self.locations.count];
        int i = 0;
        for (CLLocation *currentPoint in self.locations) {
            coordinates[i] = currentPoint.coordinate;
            i++;
        }
        double distance = ([(CLLocation*)self.locations[0] distanceFromLocation:(CLLocation*)[self.locations lastObject]]) * 0.000621371192;
        region = MKCoordinateRegionMakeWithDistance(coordinates[0], 6000*distance, 6000*distance);
        [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
        // create a polyline with all cooridnates
        MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coordinates count:self.locations.count];
        [self.mapView addOverlay:polyline level:MKOverlayLevelAboveRoads];
        MKPointAnnotation *startPoint = [[MKPointAnnotation alloc] init];
        startPoint.coordinate = coordinates[0];
        startPoint.title = @"Start point";
    
        MKPointAnnotation *endPoint = [[MKPointAnnotation alloc] init];
        endPoint.coordinate = coordinates[self.locations.count-1] ;
        endPoint.title = @"End point";
        [_mapView addAnnotation:startPoint];
        [_mapView addAnnotation:endPoint];
        [_mapView selectAnnotation:startPoint animated:YES];
        
        distanceValue =  [(NSNumber*)[self.detailItem valueForKey:@"distance"] doubleValue];
        calorieValue =  [(NSNumber*)[self.detailItem valueForKey:@"calorie"] doubleValue];
        self.distance.text = [NSString stringWithFormat:@"%.5lf miles",distanceValue];
        self.calorie.text = [NSString stringWithFormat:@"%.5lf Calories",calorieValue];
    }else{
        _mapView.showsUserLocation = YES;
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(_mapView.userLocation.coordinate, 2000, 2000);
        [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
        self.didUpdateUserLocation = YES;
        self.distance.text=@"0.0";
        self.calorie.text=@"0.0";
    }
}
//add the overlay
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    MKPolylineRenderer *renderer =
    [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor blueColor];
    renderer.lineWidth = 5.0;
    return renderer;
}
//set map region
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if(self.didUpdateUserLocation){
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 2000, 2000);
        [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
        self.didUpdateUserLocation = NO;
    }
}
//post map and message to facebook
- (IBAction)shareOnFacebook:(id)sender {
    UIGraphicsBeginImageContext(_mapView.frame.size);
    [_mapView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * mapImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *facebookSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        NSString *message = [NSString stringWithFormat:@"I have run %.2f miles from %@ to %@ consumed %.2f Calories with FitMap", distanceValue, startingAddress, destinationAddress, calorieValue];
        [facebookSheet setInitialText:message];
        [facebookSheet addImage:mapImage];
        [self presentViewController:facebookSheet animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message:@"You can't use facebook right now, make sure "
                                  "your device has an internet connection and you have"
                                  "one Facebook account setup"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}
@end
