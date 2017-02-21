//
//  ViewController.m
//  foursquare-lite
//
//  Created by Kacper Piątkowski on 21.02.2017.
//  Copyright © 2017 KacperPiatkowski. All rights reserved.
//

#import "ViewController.h"
#import "FoursquareManager.h"
#import "Venue.h"
#import "UIImageView+AFNetworking.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController () <CLLocationManagerDelegate> {
    
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    
}

@property (nonatomic) NSArray <Venue *> *venues;
@property (nonatomic) NSArray *photos;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (assign) BOOL sorted;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        [self->locationManager requestWhenInUseAuthorization];
    
    [locationManager startUpdatingLocation];
    [locationManager performSelector:@selector(stopUpdatingLocation) withObject:nil afterDelay:60];
    
    //refreshControl
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl = refreshControl;
    self.refreshControl.backgroundColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    UIBarButtonItem *sortIcon = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sort"] style:UIBarButtonItemStyleDone target:self action:@selector(buttonPressed:)];
    self.navigationItem.rightBarButtonItem = sortIcon;
    
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    
    [[FoursquareManager sharedManager] getVenuesFromExplore:^(NSArray<Venue *> *venues, NSError *error) {
        self.venues = venues;
        [self.tableView reloadData];
        [[FoursquareManager sharedManager] withArray:self.venues getPhotos:^(NSArray *photos, NSError *error) {
            self.photos = photos;
            [self.tableView reloadData];
        }];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.venues count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"venueCell"];
    Venue *venue =[self.venues objectAtIndex:indexPath.row];
    
    CLLocation *venueLocation = [[CLLocation alloc] initWithLatitude:venue.lat longitude:venue.lng];
    float distance = [currentLocation distanceFromLocation:venueLocation];
    NSString *kilometers = [NSString stringWithFormat:@"%.02f km", distance/1000];
    
    if (distance>1000) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", venue.name, kilometers];
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ - %.0f m", venue.name, distance];
    }
    
    if (venue.imageURL) {
        [cell.imageView setImageWithURL:[NSURL URLWithString:venue.imageURL]
                       placeholderImage:[UIImage imageNamed:@"placeholder"]];
        cell.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        cell.imageView.layer.borderWidth = 2;
    } else {
        cell.imageView.image = [UIImage imageNamed:@"placeholder"];
    }
    
    return cell;
}

- (NSArray *)sortArray:(NSArray *)arrayToSorted ascending:(BOOL)asc {
    NSArray *descriptor = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                                 ascending:asc
                                                                                  selector:@selector(localizedCaseInsensitiveCompare:)]];
    NSArray *sortedVenues = [arrayToSorted sortedArrayUsingDescriptors:descriptor];
    [self setSorted:asc];
    return sortedVenues;
}

- (void)buttonPressed:(id)sender {
    self.venues = [self sortArray:self.venues ascending:!self.sorted];
    [self.tableView reloadData];
}

- (void)refresh {
    NSLog(@"Pull To Refresh Method Called");
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

#pragma mark CLLocationManager Delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    currentLocation = [locations lastObject];
    [locationManager stopUpdatingLocation];
    NSLog(@"currentLocation is %@",currentLocation);
}

@end
