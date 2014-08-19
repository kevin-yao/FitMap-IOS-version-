//
//  FITNearbyDrinkRouteViewController.h
//  FitMap
//
//  Created by Kangping Yao on 7/28/14.
//  Copyright (c) 2014 CMU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@interface FITNearbyDrinkRouteViewController : UIViewController  <MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *routeMap;
@property (strong, nonatomic) MKMapItem *destination;
@end
