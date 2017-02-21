//
//  FoursquareManager.h
//  foursquare-lite
//
//  Created by Kacper Piątkowski on 21.02.2017.
//  Copyright © 2017 KacperPiatkowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Venue.h"

@interface FoursquareManager : NSObject

+ (FoursquareManager *)sharedManager;
- (void)getVenues:(void (^)(NSArray <Venue *> *venues, NSError *error))completionHandler;
- (void)withArray:(NSArray*)array getPhotos:(void (^)(NSArray *photos, NSError *error))completionHandler;

@end