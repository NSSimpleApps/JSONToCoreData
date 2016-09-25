//
//  MasterViewController.m
//  JSONToCoreData
//
//  Created by NSSimpleApps on 05.02.15.
//  Copyright (c) 2015 NSSimpleApps. All rights reserved.
//

#import "MasterViewController.h"
#import "State.h"
#import "NSJSONSerialization+NSDictionaryWithFile.h"
#import "DetailTableViewController.h"
#import "CoreDataManager.h"

@interface MasterViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation MasterViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([State class])];
    fetchRequest.resultType = NSCountResultType;
    
    NSUInteger countForFetchRequest = [[CoreDataManager sharedManager].managedObjectContext countForFetchRequest:fetchRequest error:nil];
    
    if (countForFetchRequest > 0) {
        
        self.navigationItem.rightBarButtonItem = nil;
        
        [self.fetchedResultsController performFetch:nil];
    }
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController == nil) {
        
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([State class])];
        fetchRequest.propertiesToFetch = @[@"nameOfState", @"capital", @"area", @"population"];
        fetchRequest.fetchBatchSize = 20;
        
        NSSortDescriptor *sortByNameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"nameOfState" ascending:YES];
        
        fetchRequest.sortDescriptors = @[sortByNameDescriptor];
        
        NSManagedObjectContext *context = [CoreDataManager sharedManager].managedObjectContext;
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                            managedObjectContext:context
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
        _fetchedResultsController.delegate = self;
        //[_fetchedResultsController performFetch:nil];
    }
    return _fetchedResultsController;
}


- (IBAction)createDataBaseAction:(UIBarButtonItem *)sender {
    
    sender.enabled = NO;
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.center = self.view.center;
    activityIndicator.color = [UIColor blueColor];
    
    [self.tableView addSubview:activityIndicator];
    
    [activityIndicator startAnimating];
    
    NSManagedObjectContext *backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    backgroundContext.parentContext = [CoreDataManager sharedManager].managedObjectContext;
    
    [backgroundContext performBlock:^{
        
        NSDictionary *JSONDictionary = [NSJSONSerialization dictionaryWithFile:[[NSBundle mainBundle] pathForResource:@"states" ofType:@"json"]];
            
        for (NSString* nameOfState in JSONDictionary) {
                
            NSDictionary* parametersOfState = JSONDictionary[nameOfState];
                
            State *state = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([State class])
                                                             inManagedObjectContext:backgroundContext];
            state.nameOfState = nameOfState;
            state.capital = parametersOfState[@"capital"];
            state.area = @([parametersOfState[@"area"] integerValue]);
            state.population = @([parametersOfState[@"population"] integerValue]);
        }
            
        NSError *error = nil;
            
        if (![backgroundContext save:&error]) {
                
            NSLog(@"Couldn't save: %@", error.localizedDescription);
            
            abort();
            
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [activityIndicator stopAnimating];
                [activityIndicator removeFromSuperview];
                
                self.navigationItem.rightBarButtonItem = nil;
                
                [self.fetchedResultsController performFetch:nil];
                
                [self.tableView reloadData];
            });
        }
    }];
}
    
    
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    id<NSFetchedResultsSectionInfo> sectionInfo = (self.fetchedResultsController).sections[section];
    
    return sectionInfo.numberOfObjects;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    State *state = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = state.nameOfState;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSManagedObjectContext *context = (self.fetchedResultsController).managedObjectContext;
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            
            NSLog(@"Unresolved error %@, %@", error, error.userInfo);
            abort();
        }
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}



- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath {
    
    switch (type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
        break;
    
        case NSFetchedResultsChangeDelete:
        
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
        break;
        
        
        case NSFetchedResultsChangeUpdate:
            
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
        break;
        
        case NSFetchedResultsChangeMove:
            
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
             
        break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch (type) {
            
        case NSFetchedResultsChangeInsert:
            
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView endUpdates];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"ShowDetailSegue"]) {
        
        NSIndexPath* selectedIndexPath = [self.tableView indexPathForCell:sender];
        
        State *state = [self.fetchedResultsController objectAtIndexPath:selectedIndexPath];
        
        DetailTableViewController* detailViewController = (DetailTableViewController*)segue.destinationViewController;
        detailViewController.state = state;
    }
}

/*NSManagedObjectContext *mainContext = [CoreDataManager sharedManager].managedObjectContext;
 
 NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([State class])
 inManagedObjectContext:mainContext];
 
 NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
 fetchRequest.entity = entity;
 fetchRequest.resultType = NSManagedObjectIDResultType;
 
 NSArray *items = [mainContext executeFetchRequest:fetchRequest error:nil];
 
 for (NSManagedObject *managedObject in items) {
 
 [mainContext deleteObject:managedObject];
 }
 NSError *error = nil;
 
 if (![mainContext save:&error]) {
 
 NSLog(@"Couldn't save: %@", [error localizedDescription]);
 
 abort();
 }*/

@end
