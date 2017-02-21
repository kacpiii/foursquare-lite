//
//  Venue.m
//  foursquare-lite
//
//  Created by Kacper Piątkowski on 21.02.2017.
//  Copyright © 2017 KacperPiatkowski. All rights reserved.
//

#import "Venue.h"

@implementation Venue

- (NSString *)description {
    return [NSString stringWithFormat:@"%@", self.imageURL];
}

@end
