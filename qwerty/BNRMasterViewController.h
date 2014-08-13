//
//  BNRMasterViewController.h
//  qwerty
//
//  Created by Oleksiy on 7/29/14.
//  Copyright (c) 2014 Oleksiy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BNRAddViewController.h"
#import "DataManager.h"

@class DataManager;
@class BNRAddViewController;
@class BNRDetailViewController;

@interface BNRMasterViewController : UITableViewController

@property (weak, nonatomic) BNRDetailViewController *detailViewController;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (nonatomic, strong) NSMutableArray *managedObjs;

@property (nonatomic, strong) NSMutableDictionary *countriesList;
@property (nonatomic, strong)  NSArray *countrySectionTitle;
//@property (nonatomic, strong) DataManager *db;

@end

