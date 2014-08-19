//
//  FITRouteViewController.h
//  FitMap
//
//  Created by Kangping Yao on 7/25/14.
//  Copyright (c) 2014 CMU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Social/Social.h>
#import <CoreLocation/CoreLocation.h>

@interface FITRouteViewController : UIViewController< MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic,retain) NSMutableArray *locations;
@property (strong, nonatomic) IBOutlet UILabel *distance;
@property (strong, nonatomic) IBOutlet UILabel *calorie;
@property (strong, nonatomic) id detailItem;
- (IBAction)shareOnFacebook:(id)sender;
@end
