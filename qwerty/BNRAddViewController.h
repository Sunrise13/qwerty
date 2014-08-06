//
//  BNRAddViewController.h
//  qwerty
//
//  Created by Oleksiy on 8/1/14.
//  Copyright (c) 2014 Oleksiy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "BNRMasterViewController.h"

//@class BNRCity;
@class BNRAddViewController;
@class BNRDetailViewController;

//@protocol BNRAddViewControllerDelegate <NSObject>
@protocol hello <NSObject>

- (void)AddViewController:(BNRAddViewController *)controller didAddCity:(NSDictionary *)city;

@end

@interface BNRAddViewController : UIViewController <UISplitViewControllerDelegate, MKMapViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) BNRDetailViewController *detailViewController;

@property (nonatomic, weak) id <hello> delegate ;
@property (weak, nonatomic) IBOutlet UISearchBar *search;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *adButton;
@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (strong, nonatomic)  __block NSMutableArray * placemarks;


@end
