//
//  venueDetailsViewController.m
//  foursquare-lite
//
//  Created by Kacper Piątkowski on 22.02.2017.
//  Copyright © 2017 KacperPiatkowski. All rights reserved.
//

#import "venueDetailsViewController.h"
#import "UIImageView+AFNetworking.h"

@interface venueDetailsViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *venueImage;
@property (weak, nonatomic) IBOutlet UILabel *venueName;

@end

@implementation venueDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.venueImage setImageWithURL:[NSURL URLWithString:self.imageURL]];
    self.venueName.text = self.name;
}

@end
