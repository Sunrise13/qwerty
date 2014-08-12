//
//  MapTileOverlay.h
//  Map and Cache experiment
//
//  Created by Ostap R on 08.08.14.
//  Copyright (c) 2014 Ostap Romanko. All rights reserved.
//
#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>

@interface MapTileOverlay : MKTileOverlay <NSURLConnectionDelegate>

@property(nonatomic) NSMutableSet *setOfConnections;
@property(nonatomic) NSMutableDictionary *dicOfData;

-(MKTileOverlayPath)genLatAndLonFromXY:(MKTileOverlayPath)xy;

@end
