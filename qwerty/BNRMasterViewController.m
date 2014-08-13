//
//  BNRMasterViewController.m
//  qwerty
//
//  Created by Oleksiy on 7/29/14.
//  Copyright (c) 2014 Oleksiy. All rights reserved.
//

#import "BNRMasterViewController.h"
#import "BNRDetailViewController.h"
#import "BNRAddViewController.h"
#import "pinItem.h"


#import "DataManager.h"

@interface BNRMasterViewController ()
{
}

@end

@implementation BNRMasterViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.detailViewController = (BNRDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    if([DataManager sharedManager])
    {
        [[DataManager sharedManager] setupCoreData];
        self.managedObjs=[[DataManager sharedManager] getManagedObjArray];
        
        [super viewDidLoad];
        self.detailViewController = (BNRDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
        
        //if([DataManager sharedManager])
        //{
        [[DataManager sharedManager] setupCoreData];
        self.managedObjs=[[DataManager sharedManager] getManagedObjArray];
        //}
        
        self.countriesList = [[NSMutableDictionary alloc] init];
        
        for (pinItem *d in self.managedObjs)
        {
            
            if ([self.countriesList objectForKey:d.country] == nil)
            {
                [self.countriesList setObject:[NSMutableArray new] forKey:d.country];
                NSLog(@"%@\n", d.country);
            }
            
            NSMutableArray *ar = [self.countriesList objectForKey:d.country];
            [ar addObject:d.city];
        }
        self.countrySectionTitle = [[NSMutableArray alloc] init];
        self.countrySectionTitle = [[self.countriesList allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
        return [self.countrySectionTitle count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *sectionTitle = [self.countrySectionTitle objectAtIndex:section];
    NSArray *sectionCity = [self.countriesList objectForKey:sectionTitle];
    return [sectionCity count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    //return [animalSectionTitle objectAtIndex:section];
    
    return [self.countrySectionTitle objectAtIndex:section];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0f;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 220, 0)];
    header.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 220, 30)];
    label.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    label.font = [UIFont boldSystemFontOfSize:25];
    label.backgroundColor = [UIColor groupTableViewBackgroundColor];
    label.text = [self tableView:tableView titleForHeaderInSection:section];
    
    [header addSubview:label];
    
    return header;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSString *sectionTitle = [self.countrySectionTitle objectAtIndex:indexPath.section];
    NSArray *sectionCity = [self.countriesList objectForKey:sectionTitle];
    NSString *cities = [sectionCity objectAtIndex:indexPath.row];
    cell.textLabel.text = cities;
    //cell.imageView.image = [UIImage imageNamed:[self getImageFilename:sectionTitle]];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    pinItem * item=self.managedObjs[indexPath.row];
    NSDictionary *dic =[[NSDictionary alloc] initWithObjectsAndKeys:item, @"managedObj", nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"navigation"
                                                        object:self
                                                      userInfo:dic];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *dic = self.managedObjs[indexPath.row];
        
        [[segue destinationViewController] setDetailItem:dic];
    }
    
    if ([segue.identifier isEqualToString:@"AddCity"]) {
        BNRAddViewController *PController = segue.destinationViewController;
        PController.delegate = self;
        PController.detailViewController = self.detailViewController;
    }
}

- (IBAction)selectItems:(UISegmentedControl *)sender
{
    if([sender selectedSegmentIndex]==1)
    {
        self.table.allowsMultipleSelection=YES;
    }
    if([sender selectedSegmentIndex]==0)
    {
        self.table.allowsMultipleSelection=NO;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"navigationModeChanged" object:self userInfo:nil]; //navigationModeChanged6
        
}

- (void)reloadData
{
    self.countriesList = [[NSMutableDictionary alloc] init];
    
    for (pinItem *d in self.managedObjs)
    {
        
        if ([self.countriesList objectForKey:d.country] == nil)
        {
            [self.countriesList setObject:[NSMutableArray new] forKey:d.country];
            NSLog(@"%@\n", d.country);
        }
        
        NSMutableArray *ar = [self.countriesList objectForKey:d.country];
        [ar addObject:d.city];
    }
    self.countrySectionTitle = [[NSMutableArray alloc] init];
    self.countrySectionTitle = [[self.countriesList allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
        [self.tableView reloadData];
}


- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellEditingStyle result = UITableViewCellEditingStyleNone;
    
    if ([tableView isEqual:self.table])
    {
        result = UITableViewCellEditingStyleDelete;
    }
    return result;
}

-(void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.table setEditing:editing animated:animated];
}

-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (editingStyle == UITableViewCellEditingStyleDelete)
//    {
//        [[[DataManager sharedManager] context] deleteObject:self.managedObjs[indexPath.row]];
//        [_managedObjs removeObjectAtIndex:indexPath.row];
//        
//        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
//    }
    
}
@end
