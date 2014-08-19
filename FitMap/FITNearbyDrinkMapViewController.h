//
//  FITNearbyDrinkMapViewController.h
//  FitMap
//
//  Created by Kangping Yao on 7/28/14.
//  Copyright (c) 2014 CMU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapKit/MapKit.h"

@interface FITNearbyDrinkMapViewController : UIViewController  <MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSMutableArray *matchingItems;
- (IBAction)showDetail:(id)sender;
- (IBAction)performSearch:(id)sender;

@end
