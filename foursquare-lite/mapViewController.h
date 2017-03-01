//
//  mapViewController.h
//  foursquare-lite
//
//  Created by Kacper Piątkowski on 24.02.2017.
//  Copyright © 2017 KacperPiatkowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface mapViewController : UIViewController

@property (nonatomic, copy) NSString *name;
@property (nonatomic) double lat;
@property (nonatomic) double lng;
@property (nonatomic) NSArray *venues;

@end
