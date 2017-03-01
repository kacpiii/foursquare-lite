//
//  CustomTableViewCell.h
//  foursquare-lite
//
//  Created by Kacper Piątkowski on 01.03.2017.
//  Copyright © 2017 KacperPiatkowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *venueName;
@property (nonatomic, weak) IBOutlet UILabel *venueAddress;
@property (nonatomic, weak) IBOutlet UILabel *venueCategory;
@property (nonatomic, weak) IBOutlet UILabel *venueRating;
@property (nonatomic, weak) IBOutlet UILabel *distanceValue;
@property (nonatomic, weak) IBOutlet UILabel *distanceUnit;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIView *ratingView;

@end
