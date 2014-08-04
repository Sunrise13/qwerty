//
//  BNRDetailViewController.h
//  qwerty
//
//  Created by Oleksiy on 7/29/14.
//  Copyright (c) 2014 Oleksiy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "BNRMasterViewController.h"

@interface BNRDetailViewController : UIViewController <UISplitViewControllerDelegate, MKMapViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (strong, nonatomic) NSMutableArray *pinArr;
@property (weak, nonatomic) BNRMasterViewController * master;
@property (strong, nonatomic)  __block NSMutableArray * placemarks;
@property (strong, nonatomic) NSMutableArray *pinNameArr;
@property (strong, nonatomic) MKRoute *routeDetails;
@property (nonatomic,strong) CLGeocoder *someGeocoder;
@property (nonatomic, strong) UILongPressGestureRecognizer * longPressGestureRecognizer;


- (void) multiNavigation:(NSNotification *)n;
@end
