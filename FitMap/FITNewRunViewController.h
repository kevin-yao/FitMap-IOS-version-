//
//  FITNewRunViewController.h
//  FitMap
//
//  Created by Kangping Yao on 7/21/14.
//  Copyright (c) 2014 CMU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>
#import "FITAppDelegate.h"
@interface FITNewRunViewController : UIViewController <UITextFieldDelegate,NSFetchedResultsControllerDelegate, MKMapViewDelegate, CLLocationManagerDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
- (IBAction)backgroundTap:(id)sender;
@end
