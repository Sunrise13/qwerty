//
//  MapTileOverlay.m
//  Map and Cache experiment
//
//  Created by Ostap R on 08.08.14.
//  Copyright (c) 2014 Ostap Romanko. All rights reserved.
//

#import "MapTileOverlay.h"
#import <MapKit/MapKit.h>
#import <math.h>

@implementation MapTileOverlay

-(void)loadTileAtPath:(MKTileOverlayPath)path result:(void (^)(NSData *, NSError *))result {
    NSLog(@"Loading tile x/y/z: %ld/%ld/%ld",(long)path.x,(long)path.y,(long)path.z);
    [super loadTileAtPath:path result:result];
    
    
}

-(MKTileOverlayPath)genLatAndLonFromXY:(MKTileOverlayPath)xy
{
    double lon=xy.x / pow(2.0, xy.z) * 360.0 - 180;
    double n = M_PI - 2.0 * M_PI * xy.y / pow(2.0, xy.z);
	double lat=180.0 / M_PI * atan(0.5 * (exp(n) - exp(-n)));
    MKTileOverlayPath result;
    result.x=lon; result.y=lat;
    result.z=xy.z;
    return result;
}



//def get_lat_lng_for_number(xtile, ytile, zoom)
//n = 2.0 ** zoom
//lon_deg = xtile / n * 360.0 - 180.0
//lat_rad = Math::atan(Math::sinh(Math::PI * (1 - 2 * ytile / n)))
//lat_deg = 180.0 * (lat_rad / Math::PI)
//{:lat_deg => lat_deg, :lng_deg => lon_deg}
//end

@end
