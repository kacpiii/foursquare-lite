//
//  CustomTableViewCell.m
//  foursquare-lite
//
//  Created by Kacper Piątkowski on 01.03.2017.
//  Copyright © 2017 KacperPiatkowski. All rights reserved.
//

#import "CustomTableViewCell.h"

@implementation CustomTableViewCell

@synthesize venueName = _venueName;
@synthesize distanceValue = _distanceValue;
@synthesize distanceUnit = _distanceUnit;
@synthesize imageView = _imageView;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//}

@end
