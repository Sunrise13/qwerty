
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
    //    self.detailViewController.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
    //    self.detailViewController.longPressGestureRecognizer.numberOfTouchesRequired = 1;
    //    self.detailViewController.longPressGestureRecognizer.allowableMovement = 50.0;
    //    self.detailViewController.longPressGestureRecognizer.minimumPressDuration = 1.5;
    //    [self.detailViewController.view addGestureRecognizer:self.detailViewController.longPressGestureRecognizer];
    //
    
    [self.searchDisplayController setDelegate:self];
    [self.searchB setDelegate:self];
}

-(void)viewDidDisappear:(BOOL)animated
{
    // [self.detailViewController.view removeGestureRecognizer:self.detailViewController.longPressGestureRecognizer];
}

-(void)viewDidAppear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Adding the city
- (IBAction)addCity:(id)sender {
    
    NSManagedObjectContext * context=((BNRMasterViewController *)self.delegate).db.context;
  //  pinItem * item=[NSEntityDescription insertNewObjectForEntityForName:@"Pin"inManagedObjectContext:context];
    
    // item.lat= [NSNumber numberWithDouble:[self.latitudeLabel.text doubleValue]];
    // item.lon= [NSNumber numberWithDouble:[self.longitudeLabel.text doubleValue]];
    // item.city= self.search.text;
    [context save:nil];
    [context reset];
    ((BNRMasterViewController *)self.delegate).managedObjs=[((BNRMasterViewController *)self.delegate).db getManagedObjArray];
    [self.delegate AddViewController:self didAddCity:nil];
}


//Adding the annotaion to the map
- (void)addAnnotation:(CLPlacemark *)placemark {
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = CLLocationCoordinate2DMake(placemark.location.coordinate.latitude, placemark.location.coordinate.longitude);
    point.title = [placemark.addressDictionary objectForKey:@"Street"];
    point.subtitle = [placemark.addressDictionary objectForKey:@"City"];
    [self.detailViewController.map addAnnotation:point];
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
    NSMutableString * newTitle = [NSMutableString new];
    
    __block MKPointAnnotation *touchPin = [[ MKPointAnnotation alloc] init];
    
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.detailViewController.map];
    CLLocationCoordinate2D location =
    [self.detailViewController.map convertPoint:touchPoint toCoordinateFromView:self.detailViewController.map];
    
    CLLocation * locClass = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
    
    self.detailViewController.someGeocoder = [[CLGeocoder alloc] init] ;
    [self.detailViewController.someGeocoder reverseGeocodeLocation: locClass completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (error == nil && [placemarks count]>0)
         {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             //отримуєм місто
             
             if (placemark.locality) {
                 [newTitle appendString: placemark.locality];
                 
                 
                 NSArray *ann = [self.detailViewController.map annotations];
                 
                 //приколи з видаленням останнього піна і створенням його знову
                 [self.detailViewController.map removeAnnotations:ann];
                 // [self.map addAnnotation:touchPin];
                 
                 touchPin = [[ MKPointAnnotation alloc] init];
                 touchPin.coordinate = location;
                 touchPin.title = newTitle;
                 [self.detailViewController.map addAnnotation:touchPin]; //на карті в місці натиснення відображається стандартний червоний пін
                 
                 UIAlertView *addNewPinView = [[UIAlertView alloc] initWithTitle:@"Do you want to add this city to your collection?" message: newTitle delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                 
                 [addNewPinView show];
                 
                 // NSString * lat = [[NSString alloc] initWithFormat:@"%f",location.latitude];
                 // NSString * lon = [[NSString alloc] initWithFormat:@"%f",location.longitude];
                 //   self.longitudeLabel.text = lat;
                 //   self.latitudeLabel.text = lon;
                 //       self.search.text = placemark.locality;}
             }
         }
         else if ((error == nil) && [placemarks count]==0)
         {
             NSLog(@"No results");
             
         }
         else if(error!=nil)
         {
             NSLog(@"Error!");
         }
         
         
     }];
   
}

#pragma mark - searching some cities

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////City______Searching/////////////////////////////////////////////////

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *IDENTIFIER = @"SearchResultsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
   
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IDENTIFIER];
    }
    
    MKMapItem *item = results.mapItems[indexPath.row];
    
    cell.textLabel.text = item.name;
    cell.detailTextLabel.text = item.placemark.addressDictionary[@"Street"];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [results.mapItems count];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchDisplayController setActive:NO animated:YES];
    
    NSArray *ann = [self.detailViewController.map annotations];
   
    if(ann)
    [self.detailViewController.map removeAnnotation:ann.lastObject];
    
    MKMapItem *item = results.mapItems[indexPath.row];
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
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@end
