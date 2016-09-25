//
//  DetailTableViewController.m
//  JSONToCoreData
//
//  Created by NSSimpleApps on 20.09.15.
//  Copyright © 2015 NSSimpleApps. All rights reserved.
//

#import "DetailTableViewController.h"
#import "State.h"

@interface DetailTableViewController ()

@property (strong, nonatomic) NSArray<NSString *> *titleForSections;

@property (strong, nonatomic) NSArray<NSString *> *rowTitle;

@end

@implementation DetailTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = self.state.nameOfState;
    
    self.titleForSections = @[@"Area", @"Capital", @"Population"];
    
    self.rowTitle = @[(self.state.area).stringValue, self.state.capital, (self.state.population).stringValue];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return self.titleForSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.rowTitle[indexPath.section];
    
    return cell;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return self.titleForSections[section];
}

@end
