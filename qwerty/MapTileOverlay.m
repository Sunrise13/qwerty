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


-(instancetype)initWithURLTemplate:(NSString *)URLTemplate
{
    self=[super initWithURLTemplate:URLTemplate];
    self.setOfConnections=[[NSMutableSet alloc] init];
    self.dicOfData=[[NSMutableDictionary alloc] init];
    return self;
    
}

-(void)loadTileAtPath:(MKTileOverlayPath)path result:(void (^)(NSData *, NSError *))result
{
    
    //NSLog(@"Loading tile x/y/z: %ld/%ld/%ld",(long)path.x,(long)path.y,(long)path.z);
    
    NSMutableString *pathToTile=[[NSMutableString alloc]initWithString:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
    NSMutableString *pathdd=[[NSMutableString alloc]initWithString:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
    [pathdd appendString:@"/{z}{x}{y}.png"];
    NSString *tileName=[NSString stringWithFormat:@"%ld%ld%ld.png", (long)path.z, (long)path.x, (long)path.y];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    [pathToTile appendString:@"/"];
    [pathToTile appendString:tileName];
    
    if([fileManager fileExistsAtPath:pathToTile isDirectory:NO])
    {
        
       NSData *data=[[NSData alloc] initWithContentsOfFile:pathToTile];
        result(data, nil);
    }
    else
    {
        
        NSURL *url=[self URLForTilePath:path];
        NSMutableURLRequest *req=[[NSMutableURLRequest alloc]initWithURL:url];
        req.timeoutInterval=5.0;
        NSURLConnection *con=[NSURLConnection alloc];
        //[self.setOfConnections addObject:con];
        NSArray * arr=@[[[NSMutableData alloc] init], result, pathToTile];
        [self.dicOfData setObject:arr forKey: [[NSString alloc] initWithFormat:@"%p",con]];
        [con initWithRequest:req delegate:self];
       

    }



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



#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    //_responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    NSArray * arr=[self.dicOfData objectForKey:[[NSString alloc]initWithFormat:@"%p", connection ]];
    [((NSMutableData*)arr[0]) appendData:data];
    //[_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    NSString *key=[[NSString alloc]initWithFormat:@"%p", connection ];
    NSArray * arr=[self.dicOfData objectForKey:key];
    NSMutableData * data=((NSMutableData*)arr[0]);
    void(^result)(NSData *, NSError *)=((void (^)(NSData *, NSError *))arr[1]);
    NSString *path=((NSString *) arr[2]);
    [self.dicOfData removeObjectForKey:key];
    //[self.setOfConnections removeObject:connection];
    result(data, nil);
    [data writeToFile:path atomically:YES];

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"ERRRRRROOOOR %@", error);
    NSString *key=[[NSString alloc]initWithFormat:@"%p", connection ];
    NSArray * arr=[self.dicOfData objectForKey:key];
    void(^result)(NSData *, NSError *)=((void (^)(NSData *, NSError *))arr[1]);
    [self.dicOfData removeObjectForKey:key];
    //[self.setOfConnections removeObject:connection];
    result(nil, error);
    

}


//def get_lat_lng_for_number(xtile, ytile, zoom)
//n = 2.0 ** zoom
//lon_deg = xtile / n * 360.0 - 180.0
//lat_rad = Math::atan(Math::sinh(Math::PI * (1 - 2 * ytile / n)))
//lat_deg = 180.0 * (lat_rad / Math::PI)
//{:lat_deg => lat_deg, :lng_deg => lon_deg}
//end

@end
