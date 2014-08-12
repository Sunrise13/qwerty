
//  BNRAddViewController.m
//  qwerty
//
//  Created by Oleksiy on 8/7/14.
//  Copyright (c) 2014 Oleksiy. All rights reserved.
//
#import "BNRAddViewController.h"
#import "BNRDetailViewController.h"
#import "pinItem.h"


@interface BNRAddViewController () < NSFetchedResultsControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate>

@end

@implementation BNRAddViewController
{
    //Variables which we need to do a search
    MKLocalSearch *localSearch;
    MKLocalSearchResponse *results;
}

CLPlacemark * general;
CLPlacemark *thePlacemark;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.detailViewController.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
    self.detailViewController.longPressGestureRecognizer.numberOfTouchesRequired = 1;
    self.detailViewController.longPressGestureRecognizer.allowableMovement = 50.0;
    self.detailViewController.longPressGestureRecognizer.minimumPressDuration = 0.8;
    [self.detailViewController.view addGestureRecognizer:self.detailViewController.longPressGestureRecognizer];
    [self.searchDisplayController setDelegate:self];
    [self.searchB setDelegate:self];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.detailViewController.view removeGestureRecognizer:self.detailViewController.longPressGestureRecognizer];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// Adding the city
- (IBAction)addCity:(id)sender {
    
    NSArray *ann = [self.detailViewController.map annotations];
    [self.detailViewController.map removeAnnotations:ann];
   
if(general)
{
    NSManagedObjectContext * context=((BNRMasterViewController *)self.delegate).db.context;
    pinItem * item=[NSEntityDescription insertNewObjectForEntityForName:@"Pin"inManagedObjectContext:context];
    
    NSNumber * lat = [[NSNumber alloc] initWithDouble:general.location.coordinate.latitude];
    NSNumber * lon = [[NSNumber alloc] initWithDouble:general.location.coordinate.longitude];
    item.lat = lat;
    item.lon = lon;
    item.city = general.locality;
    
    
    [context save:nil];
    [context reset];
    
    ((BNRMasterViewController *)self.delegate).managedObjs=[((BNRMasterViewController *)self.delegate).db getManagedObjArray];
    
    [self.delegate reloadData];
  }
  [self.navigationController popViewControllerAnimated:YES];
   ann = [self.detailViewController.map annotations];
   [self.detailViewController.map removeAnnotations:ann];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Yes"])
    {
        [self addCity: nil];
    }
}


//selector for long pressing on the map
- (void) handleLongPressGestures:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if(self)
        if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
            return;
    
    __block MKPointAnnotation *touchPin = [[ MKPointAnnotation alloc] init];
    
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.detailViewController.map];
    CLLocationCoordinate2D location =
    [self.detailViewController.map convertPoint:touchPoint toCoordinateFromView:self.detailViewController.map];
    
    CLGeocoder * geocoder = [[CLGeocoder alloc] init];
    CLLocation * locClass = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];

    [geocoder reverseGeocodeLocation: locClass completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (error == nil && [placemarks count]>0)
         {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             
             if(general)
                 general = placemark;
             else
                general = [[CLPlacemark alloc] initWithPlacemark: placemark];
            
             //getting the city by pressing if there is a city
             if (placemark.locality) {
                 
                 
                 NSArray *ann = [self.detailViewController.map annotations];
                 [self.detailViewController.map removeAnnotations:ann];
                 
                 touchPin = [[ MKPointAnnotation alloc] init];
                 touchPin.coordinate = location;
                 touchPin.title = placemark.locality;
                 [self.detailViewController.map addAnnotation:touchPin];
                 
                 UIAlertView *addNewPinView = [[UIAlertView alloc] initWithTitle:@"Do you want to add this city to your collection?" message: placemark.locality delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                 
                 [addNewPinView show];
                 
                }
             
         }
         else if ((error == nil) && [placemarks count]==0)
         {
             NSLog(@"No results");
             
         }
         else if(error!=nil)
         {
             NSLog(@"Error! %@", [error description]);
         }
         
         
     }];
   
}

#pragma mark - searching some cities

//////////////////////////////////////City______Searching/////////////////////////////////////////////////

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *IDENTIFIER = @"SearchResultsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
   
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IDENTIFIER];
    }
    
    MKMapItem *item = results.mapItems[indexPath.row];
    
    cell.textLabel.text = item.name;
   // cell.detailTextLabel.text = item.placemark.addressDictionary[@"Street"];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [results.mapItems count];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    // [self.searchDisplayController setActive:NO animated:YES];
    
    NSArray *ann = [self.detailViewController.map annotations];
    [self.detailViewController.map removeAnnotation:ann.lastObject];
   
    MKMapItem *item = results.mapItems[indexPath.row];
    
    if(general)
        general = item.placemark;
    else
        general = [[CLPlacemark alloc] initWithPlacemark: item.placemark];
    
    [self.detailViewController.map addAnnotation:item.placemark];
    [self.detailViewController.map selectAnnotation:item.placemark animated:YES];
    [self.detailViewController.map setCenterCoordinate:item.placemark.location.coordinate animated:YES];
    [self.detailViewController.map setUserTrackingMode:MKUserTrackingModeNone];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if([searchText length] >= 3)
    {
        // Cancel any previous searches.
        [localSearch cancel];
        
        // Perform a new search.
        MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
        request.naturalLanguageQuery = searchBar.text;
        request.region = self.detailViewController.map.region;
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        localSearch = [[MKLocalSearch alloc] initWithRequest:request];
        
        [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error){
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            if (error != nil) {
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Map Error",nil)
                                            message:[error localizedDescription]
                                           delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] show];
                return;
            }
            
            if ([response.mapItems count] == 0) {
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Results",nil)
                                            message:nil
                                           delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] show];
                return;
            }
            
            results = response;
            
            [self.searchDisplayController.searchResultsTableView reloadData];
        }];
        
    }
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@end
