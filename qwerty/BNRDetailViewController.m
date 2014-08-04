//
//  BNRDetailViewController.m
//  qwerty
//
//  Created by Oleksiy on 7/29/14.
//  Copyright (c) 2014 Oleksiy. All rights reserved.
//

#import "BNRDetailViewController.h"
#import "BNRMasterViewController.h"
#import <MapKit/MapKit.h>

@interface BNRDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation BNRDetailViewController
@synthesize someGeocoder;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
//        self.detailDescriptionLabel.text = [self.detailItem description];
        
        NSDictionary *n = (NSDictionary *)self.detailItem;
        NSString *lat = n[@"lat"];
        NSString *longitude = n[@"long"];
        
        CLLocationCoordinate2D center = CLLocationCoordinate2DMake( [lat doubleValue], [longitude doubleValue]);
        MKCoordinateSpan span = MKCoordinateSpanMake(0.2, 0.2);
        MKCoordinateRegion reg = MKCoordinateRegionMake(center, span);
        
        [self.map setRegion:reg animated:YES];
    }
}

- (void)navigateTo:(NSNotification *)n
{
    
    BOOL multipleSelection=((BNRMasterViewController *)n.object).table.allowsMultipleSelection;
    
   
  
    
    NSString *lat = n.userInfo[@"lat"];
    NSString *longitude = n.userInfo[@"long"];
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake( [lat doubleValue], [longitude doubleValue]);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.2, 0.2);
    MKCoordinateRegion reg = MKCoordinateRegionMake(center, span);
    
    
    MKPointAnnotation *pin=[MKPointAnnotation new];
    pin.title=n.userInfo[@"city"];
    pin.coordinate=CLLocationCoordinate2DMake([lat doubleValue], [longitude doubleValue]);
    [self.pinArr addObject:pin];
    [self.map addAnnotation:pin];
    

    
    [self.map setRegion:reg animated:YES];

}

- (void) multiNavigation:(NSNotification *)n
{
    static BOOL first=true;

    BOOL multipleSelection=((BNRMasterViewController *)n.object).table.allowsMultipleSelection;
    if(!multipleSelection)
    {
        [self.map removeAnnotations:self.pinArr];
        [self.pinArr removeAllObjects];
        for( UITextField * txt in _pinNameArr)
        {
            [txt removeFromSuperview];
        }
        [self.pinNameArr removeAllObjects];
        [self navigateTo:n];
        
    }
    else
    {
        [self navigateTo:n];
    }
   
    
    self.master=n.object;
    NSArray * pathes=[((BNRMasterViewController *)n.object).table indexPathsForSelectedRows];
    if(pathes!=nil)
    {
        static NSInteger y=10;

            NSIndexPath * path=(NSIndexPath *)[pathes lastObject];
            NSDictionary * city=self.master.arr[path.row];
            
            UITextField * txt=[UITextField new];
            txt.text=city[@"city"];
            txt.frame=CGRectMake(10, y, 200, 28);
            txt.borderStyle=UITextBorderStyleRoundedRect;
            txt.textAlignment=NSTextAlignmentCenter;
            txt.alpha=0.7;
            [self.pinNameArr addObject:txt];
            [self.map addSubview:txt];
           if(multipleSelection)
               y+=35;
        
        if([self.pinNameArr count]>=2&&first==true)
        {
            first=false;
            UIButton * createRouteButton=[UIButton new];
            createRouteButton.frame=CGRectMake(250, 25, 200, 25);
            [createRouteButton setTitle:@"Create route" forState:UIControlStateNormal];
            [createRouteButton setBackgroundColor:[UIColor whiteColor]];
            [createRouteButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            [createRouteButton addTarget:self action:@selector(getGeolocations) forControlEvents:UIControlEventTouchUpInside];
            [self.map addSubview:createRouteButton];
            
        }
        
    }

}


-(void)getGeolocations
{
    NSLog(@"In getGeolocation");
     NSArray * pathes=[self.master.table indexPathsForSelectedRows];
    for(int i=0; i<[pathes count]; i++)
    {
       
        CLGeocoder *geo=[CLGeocoder new];
        CLLocation *loc=[[CLLocation alloc] initWithLatitude:([self.master.arr[[(NSIndexPath*)pathes[i] row]][@"lat"] doubleValue])
                                                   longitude:([self.master.arr[[(NSIndexPath*)pathes[i] row]][@"long"] doubleValue])];
        [geo reverseGeocodeLocation:loc
                  completionHandler:^(NSArray *placemark, NSError *error)
                {
                    if (error)
                    {
                        NSLog(@"Geocode failed with error: %@", error);
                        //[self displayError:error];
                        return;
                    }
                    NSLog(@"Create placemark %d", i);
                    [self.placemarks setObject:placemark forKey:[NSNumber numberWithInt:i]];
                    if([self.placemarks count]==[pathes count])
                        [self calculateAndShowRoutes];
                }];
                
        
    }
    
    
}

- (void)calculateAndShowRoutes
{
    NSLog(@"In calculateAndShowRoutes");
       NSArray * pathes=[self.master.table indexPathsForSelectedRows];
    for(int i=0; i<=[pathes count]-2; i++)
    {
        MKDirectionsRequest *directionRequest=[MKDirectionsRequest new];
        
        directionRequest.source=[[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithPlacemark:self.placemarks[[NSNumber numberWithInt:i]][0]]];
        directionRequest.destination=[[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithPlacemark:self.placemarks[[NSNumber numberWithInt:i+1]][0]]];
        MKDirections *directions = [[MKDirections alloc] initWithRequest:directionRequest];
        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
            if (error) {
                NSLog(@"Error %@", error.description);
            } else {
                NSLog(@"create route with %d, and %d", i, i+1);
                _routeDetails = response.routes.lastObject;
                _map.delegate=self;
                [_map addOverlay:_routeDetails.polyline];
                }
        }];
    }
    
    
    
}
- (void)viewDidLoad
{
    self.pinArr=[NSMutableArray new];
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(navigateTo:)
                                                 name:@"navigateTo"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closeApp:)
                                                 name:@"UIApplicationDidEnterBackgroundNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(multiNavigation:)
                                                 name:@"multiNavigation"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(prepareForMulti:)
                                                 name:@"prepareForMulti"
                                               object:nil];
    
    self.placemarks=[NSMutableDictionary new];
    self.pinNameArr=[NSMutableArray new];
    self.map.showsUserLocation = YES;
}


-(void)closeApp:(NSNotificationCenter *)n
{
   // NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
   // NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"PropertyList.plist"];
   NSString * filePath  = @"PropertyList.plist";
   [_master.arr writeToFile:filePath atomically:YES];
}

- (void)prepareForMulti:(NSNotificationCenter *)n
{
    [self.map removeAnnotations:self.pinArr];
    [self.pinArr removeAllObjects];
    for( UITextField * txt in _pinNameArr)
    {
        [txt removeFromSuperview];
    }
    [self.pinNameArr removeAllObjects];
    NSArray *indexes=[self.master.table indexPathsForSelectedRows];
    for( NSIndexPath *path in indexes)
    {
        [self.master.table deselectRowAtIndexPath:path animated:NO];
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (MKOverlayRenderer *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolygon class]])
    {
        MKPolygonRenderer*    aRenderer = [[MKPolygonRenderer alloc] initWithPolygon:(MKPolygon*)overlay];
        
        aRenderer.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
        aRenderer.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        aRenderer.lineWidth = 3;
        
        return aRenderer;
    }
    
    return nil;
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}
-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer  * routeLineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    routeLineRenderer.strokeColor = [UIColor redColor];
    routeLineRenderer.lineWidth = 5;
    return routeLineRenderer;
}


@end
