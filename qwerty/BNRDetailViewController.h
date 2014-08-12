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
#import "MapTileOverlay.h"

@interface BNRDetailViewController : UIViewController <UISplitViewControllerDelegate, MKMapViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) BNRMasterViewController * master; //pointer to MasterViewController
@property (weak, nonatomic) IBOutlet MKMapView *map;


//Ostap
@property (strong, nonatomic)  __block NSMutableDictionary * placemarks;
@property (strong, nonatomic) NSMutableArray *pinArr;
@property (strong, nonatomic) NSMutableArray *pinNameArr;
@property (strong, nonatomic) MKRoute *routeDetails;
@property (strong, nonatomic) MapTileOverlay *tileOverlay;

//Sasha
@property (nonatomic, strong) UILongPressGestureRecognizer * longPressGestureRecognizer;
@property (strong, nonatomic) UITextField *dist;
//Begin V.S. Code
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapTypeControl;
//End V.S. Code

- (void) navigation:(NSNotification *)n;
@end
