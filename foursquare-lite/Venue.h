//
//  Venue.h
//  foursquare-lite
//
//  Created by Kacper Piątkowski on 21.02.2017.
//  Copyright © 2017 KacperPiatkowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Venue : NSObject

@property (nonatomic, copy) NSString *iid;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *imageURL;
@property (nonatomic, copy) NSArray *imagesURL;
@property (nonatomic) float distance;
@property (nonatomic) double lat;
@property (nonatomic) double lng;
@property (nonatomic) int imagesCount;

@end
