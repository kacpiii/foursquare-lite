//
//  ViewController.h
//  foursquare-lite
//
//  Created by Kacper Piątkowski on 21.02.2017.
//  Copyright © 2017 KacperPiatkowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) UIRefreshControl *refreshControl;

@end

