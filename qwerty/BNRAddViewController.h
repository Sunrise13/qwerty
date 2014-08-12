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
#import "DataManager.h"
//#import "BNRMasterViewController.h"


@class BNRAddViewController;
@class BNRDetailViewController;

@protocol hello <NSObject>

- (void)reloadData;

@end

@interface BNRAddViewController : UITableViewController <UISplitViewControllerDelegate, MKMapViewDelegate, UIAlertViewDelegate>
{
  
}
@property (weak, nonatomic) IBOutlet UISearchBar *searchB;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) BNRDetailViewController *detailViewController;
@property (nonatomic, weak) id <hello> delegate ;

@property (strong, nonatomic)  __block NSMutableArray * placemarks;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@end
