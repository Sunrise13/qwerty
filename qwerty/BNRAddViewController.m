//
//  BNRAddViewController.m
//  qwerty
//
//  Created by Oleksiy on 8/1/14.
//  Copyright (c) 2014 Oleksiy. All rights reserved.
//

#import "BNRAddViewController.h"
#import "BNRDetailViewController.h"

@interface BNRAddViewController ()

@end

@implementation BNRAddViewController



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
    self.detailViewController.longPressGestureRecognizer.minimumPressDuration = 1.5;
    [self.detailViewController.view addGestureRecognizer:self.detailViewController.longPressGestureRecognizer];
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.detailViewController.view removeGestureRecognizer:self.detailViewController.longPressGestureRecognizer];
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
    
    NSNumber * lat = [NSNumber numberWithDouble:[self.latitudeLabel.text doubleValue]];
    NSNumber * lon = [NSNumber numberWithDouble:[self.longitudeLabel.text doubleValue]];
    NSString * str = self.search.text;
    
    NSDictionary * city = [[NSDictionary alloc] initWithObjectsAndKeys:str,@"city",lat,@"lat",lon,@"long", nil];
    
   [self.delegate AddViewController:self didAddCity:city];
}


//Searching the city
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    void(^result)(NSArray *placemarks, NSError *error) = ^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            thePlacemark = [placemarks lastObject];
            float spanX = 1.00725;
            float spanY = 1.00725;
            
            MKCoordinateRegion region;
            region.center.latitude = thePlacemark.location.coordinate.latitude;
            region.center.longitude = thePlacemark.location.coordinate.longitude;
            NSString *lat = [NSString stringWithFormat:@"%f", region.center.latitude];
            NSString *lon = [NSString stringWithFormat:@"%f", region.center.longitude];
            
            //Setting coordinate label
            self.latitudeLabel.text = lat;
            self.longitudeLabel.text = lon;
            self.search.text = thePlacemark.locality;
            
            region.span = MKCoordinateSpanMake(spanX, spanY);
            [self.detailViewController.map setRegion:region animated:YES];
            [self addAnnotation:thePlacemark];
        }
    };
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:searchBar.text completionHandler:result];
    [searchBar resignFirstResponder];
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
             
             NSString * lat = [[NSString alloc] initWithFormat:@"%f",location.latitude];
             NSString * lon = [[NSString alloc] initWithFormat:@"%f",location.longitude];
             self.longitudeLabel.text = lat;
             self.latitudeLabel.text = lon;
                 self.search.text = placemark.locality;}
        
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

@end

