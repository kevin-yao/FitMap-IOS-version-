//
//  FITFirstViewController.m
//  FitMap
//
//  Created by Kangping Yao on 7/20/14.
//  Copyright (c) 2014 CMU. All rights reserved.
//

#import "FITDailyRunViewController.h"
#import "FITNewRunViewController.h"
#import "RunInfo.h"
#import "FITExerciseDetailViewController.h"
#import "FITRouteViewController.h"
#import "UserInformation.h"
#import <CoreLocation/CoreLocation.h>

@interface FITDailyRunViewController ()
{
    FITExerciseDetailViewController *exerciseDetailViewController;
    FITRouteViewController *routeViewController;
    FITNewRunViewController *newRunViewController;
    UserInformation *userInformation;
}
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)getData: (NSString*)fileName;
- (void)deleteFile: (NSString*)fileName;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation FITDailyRunViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.managedObjectContext = [AppDelegate managedObjectContext];
    userInformation = [UserInformation getInstance];
    self.locations = [[NSMutableArray alloc]init];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

- (IBAction)unwindToDailyRun:(UIStoryboardSegue *)segue
{
  
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[self.fetchedResultsController sections] count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *notDefaultTableIdentifier = @"NotDefaultCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:notDefaultTableIdentifier];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RunInfo *runInfo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if([runInfo.completed boolValue]){
        [self performSegueWithIdentifier:@"showRunHistory" sender:self];
    }else{
        [self performSegueWithIdentifier:@"startRun" sender:self];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
//delete corresponding record in sqlite and the GPS file
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        RunInfo *runInfo = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self deleteFile:[[runInfo.alarmTime description] stringByAppendingString:@".csv"]];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSManagedObject *object  = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    if ([[segue identifier] isEqualToString:@"startRun"]) {
        exerciseDetailViewController = [segue destinationViewController];
        [exerciseDetailViewController setDetailItem:object];
    }else if([[segue identifier] isEqualToString:@"showRunHistory"])
    {
        NSString *fileName = [[(NSDate*)[object valueForKey:@"alarmTime"]description] stringByAppendingString:@".csv"];
        [self getData:fileName];
        routeViewController=[segue destinationViewController];
        routeViewController.locations = self.locations;
        [routeViewController setDetailItem:object];
    }else if([[segue identifier] isEqualToString:@"addNewRun"]){
        UINavigationController *navigationController = [segue destinationViewController];
        newRunViewController = (FITNewRunViewController*)navigationController.topViewController;
    }
}
//save gps data as a ".csv" file and use start time as file name
-(void)getData:(NSString *)fileName{
    NSArray *directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [directories firstObject];
    NSString *file = [documents stringByAppendingPathComponent:fileName];
    NSString *result;
    if([[NSFileManager defaultManager] fileExistsAtPath:file]){
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:file];
        result = [[NSString alloc] initWithData:[fileHandle availableData] encoding:NSUTF8StringEncoding];
        [fileHandle closeFile];
    }
    NSArray* pointStrings = [result componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(pointStrings.count>=1){
        [self.locations removeAllObjects];
        for(int idx = 0; idx < pointStrings.count-1; idx++)
        {
            // break the string down even further to latitude and longitude fields.
            NSString* currentPointString = [pointStrings objectAtIndex:idx];
            NSArray* latLonArr = [currentPointString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
        
            CLLocationDegrees latitude  = [[latLonArr objectAtIndex:0] doubleValue];
            CLLocationDegrees longitude = [[latLonArr objectAtIndex:1] doubleValue];
        
            // create our location and add it to the correct spot in the array
            CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
            [self.locations addObject:location];
        }
    }
}
//delete file when user deletes one table view cell
- (void)deleteFile: (NSString*)fileName{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success) {
        NSLog(@"DELETE FILE SUCCESSFULLY");
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}
#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RunInfo" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"alarmTime" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    //fetchRequest.predicate = [NSPredicate predicateWithFormat:@"username == %@", self.userInfo.username];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"username == %@", userInformation.getUsername];
    [NSFetchedResultsController deleteCacheWithName:@"Master"];
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}
//configure table cell view
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    RunInfo *runInfo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd hh:mm:ss a"];
    NSString *stringDate = [formatter stringFromDate:runInfo.alarmTime];
    cell.textLabel.text = [NSString stringWithFormat:@"Des: %@", runInfo.destination];
    NSString *isDone = [runInfo.completed boolValue]? @"Yes" : @"No";
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Time: %@; Done?: %@", stringDate, isDone];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
