//
//  DataManager.h
//  qwerty
//
//  Created by Sasha Gypsy on 12.08.14.
//  Copyright (c) 2014 Oleksiy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DataManager : NSObject

@property (nonatomic, readonly) NSManagedObjectContext *context;
@property (nonatomic, readonly) NSManagedObjectModel *model;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *coordinator;
@property (nonatomic, readonly) NSPersistentStore *store;

+ (id) sharedManager;
- (void) setupCoreData;
- (void) saveContext;
- (NSMutableArray *) getManagedObjArray;
@end
