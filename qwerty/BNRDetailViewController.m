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
#import "pinItem.h"

static NSInteger y=10;
typedef enum
{
    RouteAuto,
    RouteBike,
    RouteFly,
    RoutePoligon
} Route;
static Route route;

@interface BNRDetailViewController ()

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@property(strong, nonatomic) NSMutableDictionary *buttonsForMultinavigation;
- (void)configureView;
@end

@implementation BNRDetailViewController
//Begin V.S Code
@synthesize mapTypeControl;
//End V.S. Code
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

- (void)createPinAndSetRegion:(NSNotification *)n
{
    
    NSNumber *lat = ((pinItem *)n.userInfo[@"managedObj"]).lat;
    NSNumber *longitude = ((pinItem *)n.userInfo[@"managedObj"]).lon;
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake( [lat doubleValue], [longitude doubleValue]);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.2, 0.2);
    MKCoordinateRegion reg = MKCoordinateRegionMake(center, span);
    
    
    MKPointAnnotation *pin=[MKPointAnnotation new];
    pin.title=((pinItem *)n.userInfo[@"managedObj"]).city;
    pin.coordinate=CLLocationCoordinate2DMake([lat doubleValue], [longitude doubleValue]);
    [self.pinArr addObject:pin];
    [self.map addAnnotation:pin];
    

    
    [self.map setRegion:reg animated:YES];

}

- (void) navigation:(NSNotification *)n
{

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
        
    }

    [self createPinAndSetRegion:n];
    
    self.master=n.object;
    NSArray * pathes=[((BNRMasterViewController *)n.object).table indexPathsForSelectedRows];
    if(pathes!=nil)
    {
       

            NSIndexPath * path=(NSIndexPath *)[pathes lastObject];
            pinItem * item=self.master.managedObjs[path.row];
        
            UITextField * txt=[UITextField new];
            txt.text=item.city;
            txt.frame=CGRectMake(10, y, 200, 28);
            txt.borderStyle=UITextBorderStyleRoundedRect;
            txt.textAlignment=NSTextAlignmentCenter;
            txt.alpha=0.7;
            txt.enabled=NO;
            [self.pinNameArr addObject:txt];
            [self.map addSubview:txt];
           if(multipleSelection)
               y+=35;
        
        if([self.pinNameArr count]==2)
        {
            
            UIButton * createRouteButton=[UIButton new];
            createRouteButton.frame=CGRectMake(250, 10, 200, 25);
            [createRouteButton setTitle:@"Auto Route" forState:UIControlStateNormal];
            [createRouteButton setBackgroundColor:[UIColor whiteColor]];
            [createRouteButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            [createRouteButton addTarget:self action:@selector(getGeolocations:) forControlEvents:UIControlEventTouchUpInside];
            [self.buttonsForMultinavigation setValue:createRouteButton forKey:@"Auto Route"];
            
            [self.map addSubview:createRouteButton];
            
        }
        if([self.pinNameArr count]==3)
        {
            route=RoutePoligon;
            
            UIButton * createRouteButton=[UIButton new];
            createRouteButton.frame=CGRectMake(250, 45, 200, 25);
            [createRouteButton setTitle:@"Polygon" forState:UIControlStateNormal];
            [createRouteButton setBackgroundColor:[UIColor whiteColor]];
            [createRouteButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            [createRouteButton addTarget:self action:@selector(getGeolocations:) forControlEvents:UIControlEventTouchUpInside];
            [self.buttonsForMultinavigation setValue:createRouteButton forKey:@"Polygon"];
            [self.map addSubview:createRouteButton];
        }

    }

}


-(void)getGeolocations:(id)sender
{
    NSString * typeOfRoute=((UIButton *) sender).titleLabel.text;
    if([typeOfRoute isEqualToString:@"Auto Route"])
    {
        NSLog(@"Auto");
        route=RouteAuto;
    }
    if([typeOfRoute isEqualToString:@"Polygon"])
    {
        route=RoutePoligon;
    }
        
    NSArray * pathes=[self.master.table indexPathsForSelectedRows];
    for(int i=0; i<[pathes count]; i++)
    {
        
        CLGeocoder *geocoder=[CLGeocoder new];
        pinItem* currentItem = self.master.managedObjs[[(NSIndexPath*)pathes[i] row]];
        CLLocation *loc=[[CLLocation alloc] initWithLatitude: [currentItem.lat doubleValue]
                                                longitude:[currentItem.lon doubleValue]];
        [geocoder reverseGeocodeLocation:loc
                  completionHandler:^(NSArray *placemark, NSError *error)
                {
                    if (error)
                    {
                        NSLog(@"Geocode failed with error: %@", error);
                        return;
                    }
                    NSLog(@"Create placemark %d", i);
                    [self.placemarks setObject:placemark forKey:[NSNumber numberWithInt:i]];
                    if([self.placemarks count]==[pathes count])
                    {
                        NSLog(@"In switch");
                        switch(route)
                        {
                            case RouteAuto: [self calculateAndShowRoutes]; break;
                            case RoutePoligon: [self calculateAndShowPolygon]; break;
                        }
                    }
                }];
                
        
    }
}

- (void)calculateAndShowRoutes
{
    NSArray* arr=[self.map overlays];
    for(id<MKOverlay> overlay in arr)
    {
        if(![overlay isKindOfClass:[MKTileOverlay class]])
        {
            [self.map removeOverlay:overlay];
        }
        
    }
    

    self.dist.frame=CGRectMake(500, 650, 200, 28);
    self.dist.borderStyle=UITextBorderStyleNone;
    self.dist.textAlignment=NSTextAlignmentCenter;
    self.dist.alpha=1;
    
    __block NSMutableString * renderDistance = [[NSMutableString alloc] initWithString:@"Distance: "];
    
    NSLog(@"In calculateAndShowRoutes");
    NSArray * pathes=[self.master.table indexPathsForSelectedRows];
    
    __block CGFloat routeDistance = 0.0;
    __block CGFloat centerX = ((CLPlacemark *)(self.placemarks[[NSNumber numberWithInt:0]][0])).location.coordinate.latitude;
    __block CGFloat centerY = ((CLPlacemark *)(self.placemarks[[NSNumber numberWithInt:0]][0])).location.coordinate.longitude;
    __block int countFlags = 0;
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
                countFlags++;
                _routeDetails = response.routes.lastObject;
                routeDistance += _routeDetails.distance;
                _map.delegate=self;
                
                [_map addOverlay:_routeDetails.polyline];
                
                
                centerX += ((CLPlacemark *)(self.placemarks[[NSNumber numberWithInt:i+1]][0])).location.coordinate.latitude;
                
                centerY += ((CLPlacemark *)(self.placemarks[[NSNumber numberWithInt:i+1]][0])).location.coordinate.longitude;
                double maxX = ABS(((CLPlacemark *)(self.placemarks[[NSNumber numberWithInt:0]][0])).location.coordinate.latitude - centerX);
                double maxY= ABS(((CLPlacemark *)(self.placemarks[[NSNumber numberWithInt:0]][0])).location.coordinate.longitude - centerY);
                
                
                    if (countFlags ==[pathes count]-1)
                    {
                        [renderDistance appendString:[NSString stringWithFormat:@"%.2f", routeDistance*0.001]];
                        [renderDistance appendString:@"km"];
                        self.dist.text = renderDistance;
                
                    [self.map addSubview:self.dist];
                    centerX /= [pathes count];
                   centerY /= [pathes count];
                
                    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(centerX,  centerY);
                    for(int j=1; j<[pathes count]; j++)
                    {
                        CGFloat curX = ABS(((CLPlacemark *)(self.placemarks[[NSNumber numberWithInt:j]][0])).location.coordinate.latitude - centerX);
                        CGFloat curY = ABS(((CLPlacemark *)(self.placemarks[[NSNumber numberWithInt:j]][0])).location.coordinate.longitude - centerY);
                        if (curX>maxX)
                           maxX = curX;
                        if (curY>maxY)
                            maxY = curY;
                        
                    }
                    CGFloat scalingFactor = ABS((cos(2 * M_PI * centerX / 360.0) ));
                    MKCoordinateSpan span;
                    span.latitudeDelta = maxX;
                    span.longitudeDelta = maxY;
                    MKCoordinateRegion reg = MKCoordinateRegionMake(center, span);
                    [self.map setRegion:reg animated:YES];
                }
                
                
            }
        }];

    }
}

- (void) calculateAndShowPolygon
{
    NSArray* arr=[self.map overlays];
    for(id<MKOverlay> overlay in arr)
    {
        if(![overlay isKindOfClass:[MKTileOverlay class]])
        {
            [self.map removeOverlay:overlay];
        }
        
    }
    NSLog(@"In calculateAndShowPolygon");
    CLLocationCoordinate2D points[[self.placemarks count]];
    int i=0;
    for(NSNumber *key in self.placemarks)
    {
        points[i]=((CLPlacemark *)(self.placemarks[key][0])).location.coordinate;
        i++;
    }
    MKPolygon * poly=[MKPolygon polygonWithCoordinates:points count:[self.placemarks count]];
    [self.map addOverlay:poly];
}

- (void)viewDidLoad
{

    [super viewDidLoad];
    [self configureView];
    self.pinArr=[NSMutableArray new];
    self.dist = [UITextField new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(navigation:)
                                                 name:@"navigation"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(navigationModeChanged:)
                                                 name:@"navigationModeChanged"
                                               object:nil];
    
    self.placemarks=[NSMutableDictionary new];
    self.pinNameArr=[NSMutableArray new];

    self.buttonsForMultinavigation=[NSMutableDictionary new];
    self.map.showsUserLocation = YES;
    self.map.delegate=self;
    [self reloadTileOverlay];
    
}

- (void)navigationModeChanged:(NSNotificationCenter *)n
{
    
    y=10;
    [self.map removeAnnotations:self.pinArr];
    [self.dist removeFromSuperview];

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
    NSArray* arr=[self.map overlays];
    for(id<MKOverlay> overlay in arr)
    {
        if(![overlay isKindOfClass:[MKTileOverlay class]])
        {
            [self.map removeOverlay:overlay];
        }
        
    }
    
    for(NSString *key in self.buttonsForMultinavigation)
    {
        [self.buttonsForMultinavigation[key] removeFromSuperview];
    }
    [self.buttonsForMultinavigation removeAllObjects];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    if ([overlay isKindOfClass:[MKPolygon class]])
    {
        MKPolygonRenderer*    aRenderer = [[MKPolygonRenderer alloc] initWithPolygon:(MKPolygon*)overlay];
        
        aRenderer.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
        aRenderer.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        aRenderer.lineWidth = 3;
        
        return aRenderer;
    }
    if([overlay isKindOfClass:[MKTileOverlay class]]) {
        MKTileOverlay *tileOverlay = (MKTileOverlay *)overlay;
        MKTileOverlayRenderer *renderer = nil;
        
        renderer = [[MKTileOverlayRenderer alloc] initWithTileOverlay:tileOverlay];
        
        
        return renderer;}
    else
    {

    MKPolylineRenderer  * routeLineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    routeLineRenderer.strokeColor = [UIColor redColor];
    routeLineRenderer.lineWidth = 5;
    return routeLineRenderer;
    }
}

-(void)reloadTileOverlay {
    
    // remove existing map tile overlay
    if(self.tileOverlay) {
        [self.map removeOverlay:self.tileOverlay];
    }
    
    
    NSString *urlTemplate = nil;
    //urlTemplate = @"http://mt0.google.com/vt/x={x}&y={y}&z={z}";                          //Google Maps
    urlTemplate=@"http://otile1.mqcdn.com/tiles/1.0.0/map/{z}/{x}/{y}.png";                 //MapQuest
    //urlTemplate=@"http://static-maps.yandex.ru/1.x/?ll={x},{y}&size=256,256&z={z}&l=map"; //Yandex.Map
    self.tileOverlay = [[MapTileOverlay alloc] initWithURLTemplate:urlTemplate];
    
    
    self.tileOverlay.canReplaceMapContent=YES;
    [self.map addOverlay:self.tileOverlay];
    
    
}
//begin V.S. Code
//Get screenshot of mapView
- (IBAction)getMapScreenShot {
    @try{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
            UIGraphicsBeginImageContextWithOptions(window.bounds.size, NO, [UIScreen mainScreen].scale);
        else
            UIGraphicsBeginImageContext(window.bounds.size);
        
        [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        //Show Alert
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Saving image"
                              message:@"Image was succesfully saved!"
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:@"Cancel",nil];
        [alert show];
    }
    @catch(NSException* e){
        NSLog(@"Exception: %@", e);
    }

}
- (IBAction)changeMapType:(id)sender {
    @try{
    if ([mapTypeControl selectedSegmentIndex]==0){
        _map.mapType = MKMapTypeStandard;
        
    }
    else if ([mapTypeControl selectedSegmentIndex]==1){
        _map.mapType = MKMapTypeSatellite;
    }
    else if ([mapTypeControl selectedSegmentIndex]==2){
        _map.mapType=MKMapTypeHybrid;
    }
    }
    @catch(NSException* e){
        NSLog(@"Exception: %@", e);
    }
}
//Initialize annotations
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKPinAnnotationView *aView= [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin1"];
    if (aView == nil) {
        aView.annotation = annotation;
    }
    aView.animatesDrop=YES;
    aView.canShowCallout = YES;
    aView.rightCalloutAccessoryView =  [UIButton buttonWithType:UIButtonTypeInfoDark];
    aView.calloutOffset = CGPointMake(-10, 5);
    UIImageView *imView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
    imView.image =[UIImage imageNamed:@"city_small.png"];
    aView.leftCalloutAccessoryView = imView;
    return aView;
}
//Select annotation event
-(void)mapView:(MKMapView *)mapView1 didSelectAnnotationView:(MKAnnotationView *)view
{
    @try{
        NSLog(@"select");
        MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
        CGPoint cgp = CGPointMake(view.center.x*0.3, view.center.y*0.3);
        CLLocationCoordinate2D cllc_cd = [((MKMapView *)mapView1) convertPoint:cgp toCoordinateFromView:(MKAnnotationView *)view];
        
        MKCoordinateSpan mkc_spn = MKCoordinateSpanMake(0.2, 0.2);
        options.region = MKCoordinateRegionMake((CLLocationCoordinate2D)cllc_cd, (MKCoordinateSpan)mkc_spn);
        options.scale =[UIScreen mainScreen].scale;
        //options.size = mapView1.frame.size; //original size of mapView
        options.size = CGSizeMake(300, 300);
        UIImage *uimage = nil;
        
        MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
        [snapshotter startWithCompletionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
            UIImage *image = snapshot.image;
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        }];
        UIImageWriteToSavedPhotosAlbum(uimage, nil, nil, nil);
        
        UIImageView *imView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        imView.image =uimage;
        
        //[(MKAnnotationView *)view setLeftCalloutAccessoryView:imView]; //to set view for Pin
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
}
//Deselect annotation event
-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    NSLog(@"Deselect");
}
//Click on pin event  popover view controller
-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    id <MKAnnotation> annotation = [view annotation];
    if ([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        NSLog(@"Map ");
    }

    //_pin_info = [[UIPopoverController alloc] initWithContentViewController:mapView];
    //_pin_info.popoverContentSize = CGSizeMake(320.0, 400.0);
    //[_pin_info presentPopoverFromRect:[(UIButton *)sender frame]  inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    /*UIViewController *PopoverView =[[UIViewController alloc] initWithNibName:@"UIViewController" bundle:nil];
     _pin_info =[[UIPopoverController alloc] initWithContentViewController:PopoverView];
     [_pin_info presentPopoverFromRect:CGRectMake(10, 10, 200, 300) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];*/
    
     UIAlertView *alertView1 = [[UIAlertView alloc]  initWithTitle:view.annotation.title
     message:[@"Do you want to find information about '" stringByAppendingFormat:@"%@%@", view.annotation.title, @"'?"]
     delegate:self
     cancelButtonTitle:@"OK"
     otherButtonTitles:@"Cancel", nil];
     [alertView1 show];
}
-(void)mapView:(MKMapView *)mapViewm annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{}

//Events on alert buttons
-(void) alertView:(UIAlertView *)alertView_1 clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        //NSURL *url1 = [NSURL URLWithString:[@"https://www.google.com.ua/?gws_rd=ssl#q=" stringByAppendingString: alertView_1.title]];
        if ([[UIApplication sharedApplication]
             canOpenURL:[NSURL URLWithString:[@"https://www.google.com.ua/?gws_rd=ssl#q=" stringByAppendingString: alertView_1.title]]])
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"https://www.google.com.ua/?gws_rd=ssl#q=" stringByAppendingString: alertView_1.title]]];
        }
       // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"https://www.google.com.ua/?gws_rd=ssl#q=" stringByAppendingString: alertView.title]]];
    }
    else if (buttonIndex == 1) {
    }
}

#define CAL_MERCATOR_OFFSET 268435456
#define CAL_MERCATOR_RADIUS 85445659.44705395
#pragma mark -
#pragma mark Map conversion methods
- (double) calLongitudeToPixelSpaceX:(double) longitude {
    return round(CAL_MERCATOR_OFFSET + CAL_MERCATOR_RADIUS * longitude * M_PI / 180.0);
}
- (double) calLatitudeToPixelSpaceY:(double) latitude {
    return round(CAL_MERCATOR_OFFSET - CAL_MERCATOR_RADIUS * logf((1 + sinf(latitude * M_PI / 180.0)) / (1 - sinf(latitude * M_PI / 180.0))) / 2.0);
}
- (double) calPixelSpaceXToLongitude:(double) pixelX {
    return ((round(pixelX) - CAL_MERCATOR_OFFSET) / CAL_MERCATOR_RADIUS) * 180.0 / M_PI;
}
- (double) calPixelSpaceYToLatitude:(double) pixelY {
    return (M_PI / 2.0 - 2.0 * atan(exp((round(pixelY) - CAL_MERCATOR_OFFSET) / CAL_MERCATOR_RADIUS))) * 180.0 / M_PI;
}
- (MKCoordinateSpan) calCoordinateSpanWithMapView:(MKMapView *) mapView centerCoordinate:(CLLocationCoordinate2D) centerCoordinate andZoomLevel:(NSUInteger) zoomLevel {
    // convert center coordiate to pixel space
    double centerPixelX = [self calLongitudeToPixelSpaceX:centerCoordinate.longitude];
    double centerPixelY = [self calLatitudeToPixelSpaceY:centerCoordinate.latitude];
    // determine the scale value from the zoom level
    NSInteger zoomExponent = 20 - zoomLevel;
    double zoomScale = pow(2, zoomExponent);
    // scale the map’s size in pixel space
    CGSize mapSizeInPixels = mapView.bounds.size;
    double scaledMapWidth = mapSizeInPixels.width * zoomScale;
    double scaledMapHeight = mapSizeInPixels.height * zoomScale;
    // figure out the position of the top-left pixel
    double topLeftPixelX = centerPixelX - (scaledMapWidth / 2);
    double topLeftPixelY = centerPixelY - (scaledMapHeight / 2);
    // find delta between left and right longitudes
    CLLocationDegrees minLng = [self calPixelSpaceXToLongitude:topLeftPixelX];
    CLLocationDegrees maxLng = [self calPixelSpaceXToLongitude:topLeftPixelX + scaledMapWidth];
    CLLocationDegrees longitudeDelta = maxLng - minLng;
    // find delta between top and bottom latitudes
    CLLocationDegrees minLat = [self calPixelSpaceYToLatitude:topLeftPixelY];
    CLLocationDegrees maxLat = [self calPixelSpaceYToLatitude:topLeftPixelY + scaledMapHeight];
    CLLocationDegrees latitudeDelta = -1 * (maxLat - minLat);
    // create and return the lat/lng span
    MKCoordinateSpan span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta);
    return span;
}


//end S.V. Code

@end
