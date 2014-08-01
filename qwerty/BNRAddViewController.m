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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)addCity:(id)sender {
    
    NSNumber * lat = [NSNumber numberWithDouble:[self.latitudeLabel.text doubleValue]];
    NSNumber * lon = [NSNumber numberWithDouble:[self.longitudeLabel.text doubleValue]];
    NSString * str = self.search.text;
    NSDictionary * city = [[NSDictionary alloc] initWithObjectsAndKeys:str,@"city",lat,@"lat",lon,@"long", nil];
    [self.delegate AddViewController:self didAddCity:city];
}

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
            //Setting coordinate labels
            
            self.latitudeLabel.text = lat;
            self.longitudeLabel.text = lon;
            
            region.span = MKCoordinateSpanMake(spanX, spanY);
            if(self.detailViewController==nil)
                NSLog(@"It's NIL!");
            [self.detailViewController.map setRegion:region animated:YES];
            [self addAnnotation:thePlacemark];
        }
    };
    
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:searchBar.text completionHandler:result];

    [searchBar resignFirstResponder];
}



- (void)addAnnotation:(CLPlacemark *)placemark {
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = CLLocationCoordinate2DMake(placemark.location.coordinate.latitude, placemark.location.coordinate.longitude);
    point.title = [placemark.addressDictionary objectForKey:@"Street"];
    point.subtitle = [placemark.addressDictionary objectForKey:@"City"];
    [self.detailViewController.map addAnnotation:point];
}

@end

