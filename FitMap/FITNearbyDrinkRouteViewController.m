//
//  FITNearbyDrinkRouteViewController.m
//  FitMap
//
//  Created by Kangping Yao on 7/28/14.
//  Copyright (c) 2014 CMU. All rights reserved.
//

#import "FITNearbyDrinkRouteViewController.h"

@interface FITNearbyDrinkRouteViewController ()

@end

@implementation FITNearbyDrinkRouteViewController

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
    [super viewDidLoad];
    _routeMap.showsUserLocation = YES;
    MKUserLocation *userLocation = _routeMap.userLocation;
    MKCoordinateRegion region =
    MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate,
                                       2000, 2000);
    [_routeMap setRegion:region animated:NO];
    _routeMap.delegate = self;
    [self getDirections];
    // Do any additional setup after loading the view.
}
// get direction to the nearest drink store
- (void)getDirections
{
    MKDirectionsRequest *request =
    [[MKDirectionsRequest alloc] init];
    
    request.source = [MKMapItem mapItemForCurrentLocation];
    
    request.destination = _destination;
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
    MKPointAnnotation *annotation =
    [[MKPointAnnotation alloc]init];
    annotation.coordinate = _destination.placemark.coordinate;
    annotation.title = _destination.name;
    [_routeMap addAnnotation:annotation];
    [_routeMap selectAnnotation:annotation animated:YES];
}
// 
-(void)showRoute:(MKDirectionsResponse *)response
{
    for (MKRoute *route in response.routes)
    {
        [_routeMap
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
