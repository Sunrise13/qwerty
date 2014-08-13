//
//  pinItem.h
//  qwerty
//
//  Created by Ostap R on 06.08.14.
//  Copyright (c) 2014 Oleksiy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface pinItem : NSManagedObject

@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSNumber * lon;
@property (nonatomic, retain) NSNumber * lat;

@end
