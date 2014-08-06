//
//  BNRMasterViewController.m
//  qwerty
//
//  Created by Oleksiy on 7/29/14.
//  Copyright (c) 2014 Oleksiy. All rights reserved.
//

#import "BNRMasterViewController.h"
#import "BNRDetailViewController.h"
#import "pinItem.h"
@interface BNRMasterViewController () {
    NSMutableArray *_objects;
}

@end

@implementation BNRMasterViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.detailViewController = (BNRDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"PropertyList" withExtension:@"plist"];
    self.arr = [NSMutableArray arrayWithContentsOfURL:url];
    [self.table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
   // _table.allowsMultipleSelection=YES;
    
    if(self.db)
    {
        [self.db setupCoreData];
        self.managedObjs=[self.db getManagedObjArray];

    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.managedObjs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;

    
    NSString *cityName = ((pinItem *)self.managedObjs[indexPath.row]).city ;
    
    cell.textLabel.text = cityName;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [_objects removeObjectAtIndex:indexPath.row];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
//    }
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSDate *object = _objects[indexPath.row];
        self.detailViewController.detailItem = object;
    }
    
    
    pinItem * item=self.managedObjs[indexPath.row];
    NSDictionary *dic =[[NSDictionary alloc] initWithObjectsAndKeys:item, @"managedObj", nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"multiNavigation"
                                                        object:self
                                                      userInfo:dic];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *dic = self.arr[indexPath.row];
       // NSString *cityName =dic[@"city"];
        
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
        [[NSNotificationCenter defaultCenter] postNotificationName:@"prepareForMulti" object:self userInfo:nil];
    }
    if([sender selectedSegmentIndex]==0)
    {
        self.table.allowsMultipleSelection=NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"prepareForMulti" object:self userInfo:nil];
    }
        
}

- (void)AddViewController:(BNRAddViewController *)controller didAddCity:(NSDictionary *)city
{
//    BOOL ok = true;
//    for(NSDictionary*ar in _arr)
//    {
//        if([ar[@"city"]isEqualToString:city[@"city"]])
//            ok = false;
//    }
    
//    if(![[controller.search text] isEqual: @""] && ok)
//    {
//        [_arr addObject:city];
        [self.tableView reloadData];
//    }
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
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self.db.context deleteObject:self.managedObjs[indexPath.row]];
        [_managedObjs removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
    
}
@end
