//
//  FoursquareManager.m
//  foursquare-lite
//
//  Created by Kacper Piątkowski on 21.02.2017.
//  Copyright © 2017 KacperPiatkowski. All rights reserved.
//

#import "FoursquareManager.h"
#import <AFNetworking/AFNetworking.h>
#import "ViewController.h"

@implementation FoursquareManager

+ (FoursquareManager *)sharedManager
{
    static FoursquareManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[FoursquareManager alloc] init];
        
        _sharedInstance.dateFormat = [NSDateFormatter new];
        [_sharedInstance.dateFormat setDateFormat:@"yyyyMMdd"];
    });
    return _sharedInstance;
}

- (void)withLocation:(CLLocation *)location getVenuesFromSearch:(void (^)(NSArray <Venue *> *venues, NSError *error))completionHandler
{
    NSDictionary *params = @{
                             @"client_id" : @"AXLFRYZ0ESKQVNPTMK1Y1RT10XLCSWVAEBAP0ZTANZKHYLIN",
                             @"client_secret" : @"1GWJR0XKM504Z4EBFPLL0MFO3GHGHUXZGJSYXJNDEYHROZ3A",
                             @"v" : [self returnDate],
                             @"ll" : [NSString stringWithFormat:@"%f, %f", location.coordinate.latitude, location.coordinate.longitude]
                             };
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager GET:@"https://api.foursquare.com/v2/venues/search"
      parameters:params
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             if (completionHandler) {
                 NSMutableArray <Venue *> *venues = [NSMutableArray new];
                 if (responseObject) {
                     if ([responseObject[@"response"][@"venues"] isKindOfClass:[NSArray class]]) {
                         NSArray *venueTemp = responseObject[@"response"][@"venues"];
                         for (int i=0; i<venueTemp.count; i++) {
                             if (venueTemp[i][@"location"]) {
                                 NSDictionary *locationTemp = venueTemp[i][@"location"];
                                 Venue *venue = [Venue new];
                                 venue.name = venueTemp[i][@"name"];
                                 venue.iid = venueTemp[i][@"id"];
                                 if (locationTemp) {
                                     venue.lat = [locationTemp[@"lat"] doubleValue];
                                     venue.lng = [locationTemp[@"lng"] doubleValue];
                                 }
                                 [venues addObject:venue];
                             }
                         }
                         completionHandler([venues copy], nil);
                     }
                 }
             }
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             if (completionHandler) {
                 completionHandler(nil, error);
             }
         }
     ];
}

- (void)withLocation:(CLLocation *)location getVenuesFromExplore:(void (^)(NSArray <Venue *> *venues, NSError *error))completionHandler
{
    NSDictionary *params = @{
                             @"client_id" : @"AXLFRYZ0ESKQVNPTMK1Y1RT10XLCSWVAEBAP0ZTANZKHYLIN",
                             @"client_secret" : @"1GWJR0XKM504Z4EBFPLL0MFO3GHGHUXZGJSYXJNDEYHROZ3A",
                             @"v" : [self returnDate],
                             @"venuePhotos" : @(YES),
                             @"ll" : [NSString stringWithFormat:@"%f, %f", location.coordinate.latitude, location.coordinate.longitude]
                             };
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager GET:@"https://api.foursquare.com/v2/venues/explore"
      parameters:params
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             if (completionHandler) {
                 NSMutableArray <Venue *> *venues = [NSMutableArray new];
                 if (responseObject) {
                     if ([responseObject[@"response"][@"groups"] isKindOfClass:[NSArray class]]) {
                         NSArray *groupTemp = responseObject[@"response"][@"groups"];
                         NSDictionary *temp = groupTemp[0];
                         NSArray *itemsTemp = temp[@"items"];
                         for (int i=0; i<itemsTemp.count; i++) {
                             NSDictionary *venueTemp = itemsTemp[i][@"venue"];
                             Venue *venue = [Venue new];
                             venue.name = venueTemp[@"name"];
                             venue.iid = venueTemp[@"id"];
                             venue.rating = [venueTemp[@"rating"] floatValue];
                             venue.ratingColor = venueTemp[@"ratingColor"];
                             NSDictionary *locationTemp = venueTemp[@"location"];
                             if (locationTemp) {
                                 venue.address = locationTemp[@"address"];
                                 venue.lat = [locationTemp[@"lat"] doubleValue];
                                 venue.lng = [locationTemp[@"lng"] doubleValue];
                                 if (venue.lat && venue.lng) {
                                     CLLocation *venueLocation = [[CLLocation alloc] initWithLatitude:venue.lat longitude:venue.lng];
                                     float distance = [location distanceFromLocation:venueLocation];
                                     venue.distance = distance;
                                 }
                             }
                             NSArray *categoryTemp = venueTemp[@"categories"];
                             NSDictionary *categories = categoryTemp[0];
                             venue.category = [NSString stringWithFormat:@"%@", categories[@"name"]];
                             
                             int photosCount = [venueTemp[@"photos"][@"count"] intValue];
                             if (photosCount > 0) {
                                 NSArray *photosTemp = venueTemp[@"photos"][@"groups"];
                                 NSDictionary *temp2 = photosTemp[0];
                                 NSArray *itemsTemp2 = temp2[@"items"];
                                 NSString *photoSize = @"400x400";
                                 NSString *thumbSize = @"36x36";
                                 venue.imageURL = [NSString stringWithFormat:@"%@%@%@", itemsTemp2[0][@"prefix"], photoSize, itemsTemp2[0][@"suffix"]];
                                 venue.thumbImageURL = [NSString stringWithFormat:@"%@%@%@", itemsTemp2[0][@"prefix"], thumbSize, itemsTemp2[0][@"suffix"]];
                             }
                             
                             [venues addObject:venue];
                         }
                         completionHandler([venues copy], nil);
                     }
                 }
             }
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             if (completionHandler) {
                 completionHandler(nil, error);
             }
         }
     ];
}

- (void)withArray:(NSArray <Venue *> *)venues getPhotos:(void (^)(NSArray *photos, NSError *error))completionHandler
{
    for (Venue *venue in venues) {
        NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/%@/photos", [venue valueForKey:@"iid"]]];
        NSString *path = baseURL.absoluteString;
        
        NSDictionary *params = @{
                                 @"client_id" : @"AXLFRYZ0ESKQVNPTMK1Y1RT10XLCSWVAEBAP0ZTANZKHYLIN",
                                 @"client_secret" : @"1GWJR0XKM504Z4EBFPLL0MFO3GHGHUXZGJSYXJNDEYHROZ3A",
                                 @"v" : [self returnDate]
                                 };
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        
        [manager GET:path
          parameters:params
            progress:nil
             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                 if (completionHandler) {
                     NSMutableArray *ids = [NSMutableArray new];
                     if (responseObject) {
                         if ([responseObject[@"response"][@"photos"] isKindOfClass:NSDictionary.class]) {
                             NSDictionary *idsItems = responseObject[@"response"][@"photos"];
                             NSArray *items = idsItems[@"items"];
                             venue.imagesCount = (int)items.count;
                             if (items.count > 0) {
                                 NSString *prefix = @"https://igx.4sqi.net/img/general/400x400";
                                 venue.imageURL = [NSString stringWithFormat:@"%@%@", prefix, items[0][@"suffix"]];
                             }
                             completionHandler([ids copy], nil);
                         }
                     }
                 }
             }
             failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                 if (completionHandler) {
                     completionHandler(nil, error);
                 }
             }
         ];
    }
}

- (NSString *)returnDate {
    NSDate *now = [NSDate date];
    NSString *nowString = [self.dateFormat stringFromDate:now];
    return nowString;
}

@end
