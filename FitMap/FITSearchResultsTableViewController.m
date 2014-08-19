//
//  FITSearchResultsTableViewController.m
//  FitMap
//
//  Created by Kangping Yao on 7/28/14.
//  Copyright (c) 2014 CMU. All rights reserved.
//

#import "FITSearchResultsTableViewController.h"
#import <MapKit/MapKit.h>
#import "FITNearbyDrinkResultsTableViewCell.h"
#import "FITNearbyDrinkRouteViewController.h"
@interface FITSearchResultsTableViewController ()

@end

@implementation FITSearchResultsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _mapItems.count;
}
// fill table view cell with mapitem
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"resultCell";
    FITNearbyDrinkResultsTableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                    forIndexPath:indexPath];
    
    long row = [indexPath row];
    
    MKMapItem *item = _mapItems[row];

    cell.nameLabel.text = item.name;
    cell.phoneLabel.text = item.phoneNumber;
    
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    FITNearbyDrinkRouteViewController *routeController =
    [segue destinationViewController];
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    long row = [indexPath row];
    routeController.destination = _mapItems[row];
}

@end
