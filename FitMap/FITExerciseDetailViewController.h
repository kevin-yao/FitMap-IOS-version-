//
//  FITExerciseDetailViewController.h
//  FitMap
//
//  Created by Kangping Yao on 7/22/14.
//  Copyright (c) 2014 CMU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
@interface FITExerciseDetailViewController : UIViewController< MKMapViewDelegate, CLLocationManagerDelegate>
{
    CFTimeInterval startTime;
    CFTimeInterval endTime;
}
@property (strong, nonatomic) IBOutlet UILabel *distance;
@property (strong, nonatomic) IBOutlet UILabel *calorie;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic,retain) CLLocationManager *locationManager; 
@property (strong, nonatomic) IBOutlet UIButton *startStopButton;
@property (strong, nonatomic) id detailItem;
@property (nonatomic,retain) NSMutableArray *locations;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
- (IBAction)startStopAction:(id)sender;

@end
