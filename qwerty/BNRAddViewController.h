//
//  BNRAddViewController.h
//  qwerty
//
//  Created by Oleksiy on 8/7/14.
//  Copyright (c) 2014 Oleksiy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
//#import "BNRMasterViewController.h"


@class BNRAddViewController;
@class BNRDetailViewController;

@protocol hello <NSObject>

- (void)AddViewController:(BNRAddViewController *)controller didAddCity:(NSDictionary *)city;

@end

@interface BNRAddViewController : UITableViewController <UISplitViewControllerDelegate, MKMapViewDelegate, UIAlertViewDelegate>
{
   // UISearchBar *searchBar;
}
@property (weak, nonatomic) IBOutlet UISearchBar *searchB;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) BNRDetailViewController *detailViewController;
//@property (strong, nonatomic) IBOutlet UITableView *searchB;
//@property (weak, nonatomic) IBOutlet UISearchBar *searchB;
@property (nonatomic, weak) id <hello> delegate ;
@property (strong, nonatomic)  __block NSMutableArray * placemarks;


@end
