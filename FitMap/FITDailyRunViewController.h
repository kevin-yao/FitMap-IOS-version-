//
//  FITFirstViewController.h
//  FitMap
//
//  Created by Kangping Yao on 7/20/14.
//  Copyright (c) 2014 CMU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "FITAppDelegate.h"
@interface FITDailyRunViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>
- (IBAction)unwindToDailyRun:(UIStoryboardSegue *)segue;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,retain) NSMutableArray *locations;
@end
