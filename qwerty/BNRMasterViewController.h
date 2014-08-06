//
//  BNRMasterViewController.h
//  qwerty
//
//  Created by Oleksiy on 7/29/14.
//  Copyright (c) 2014 Oleksiy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BNRAddViewController.h"
#import "CoreDataHelper.h"
@class BNRAddViewController;
@protocol hello <NSObject>

- (void)AddViewController:(BNRAddViewController *)controller didAddCity:(NSDictionary *)city;

@end


@class BNRDetailViewController;

@interface BNRMasterViewController : UITableViewController <hello>

@property (weak, nonatomic) BNRDetailViewController *detailViewController;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (nonatomic, strong) NSMutableArray *arr;
@property (nonatomic, strong) NSMutableArray *managedObjs;
@property (nonatomic, strong) CoreDataHelper *db;

-(void)saveToFile;

@end

