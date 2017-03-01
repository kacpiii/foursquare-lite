//
//  ViewController.m
//  foursquare-lite
//
//  Created by Kacper Piątkowski on 21.02.2017.
//  Copyright © 2017 KacperPiatkowski. All rights reserved.
//

#import "ViewController.h"
#import "venueDetailsViewController.h"
#import "mapViewController.h"
#import "FoursquareManager.h"
#import "Venue.h"
#import "UIImageView+AFNetworking.h"
#import <CoreLocation/CoreLocation.h>
#import "CustomTableViewCell.h"

@interface ViewController () <CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
}

@property (nonatomic) NSArray <Venue *> *venues;
@property (nonatomic) NSArray *photos;
@property (assign) BOOL sorted;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mapButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //user's location - start updating
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = 5; //minimum update distance in meters
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        [self->locationManager requestWhenInUseAuthorization];
    [locationManager startUpdatingLocation];
    
    //refreshControl
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl = refreshControl;
    self.refreshControl.backgroundColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    //left bar button item
    UIBarButtonItem *mapIcon = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStylePlain target:self action:@selector(goToMapVC)];
    self.mapButton = mapIcon;
    
    //right bar button item
    UIBarButtonItem *sortIcon = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sort"] style:UIBarButtonItemStyleDone target:self action:@selector(buttonPressed:)];
    self.navigationItem.rightBarButtonItem = sortIcon;
    
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.venues count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CustomTableViewCell *cell = (CustomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"CustomTableViewCell"];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
     
    Venue *venue =[self.venues objectAtIndex:indexPath.row];
    
    if (venue.imageURL) {
        [cell.imageView setImageWithURL:[NSURL URLWithString:venue.imageURL]
                       placeholderImage:[UIImage imageNamed:@"placeholder"]];
        cell.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        cell.imageView.layer.borderWidth = 2;
    } else {
        cell.imageView.image = [UIImage imageNamed:@"placeholder"];
    }
    
    cell.venueName.text = [NSString stringWithFormat:@"%@", venue.name];
    
    NSString *kilometers = [NSString stringWithFormat:@"%.02f", venue.distance / 1000];
    if (venue.distance > 1000) {
        cell.distanceValue.text = kilometers;
        cell.distanceUnit.text = @"km";
    } else {
        cell.distanceValue.text = [NSString stringWithFormat:@"%.0f", venue.distance];
        cell.distanceUnit.text = @"m";
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showDetails" sender:self];
}

//pass data from one vc to another vc using segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showDetails"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Venue *venue = self.venues[indexPath.row];
        NSString *name = venue.name;
        NSString *imageURL = venue.imageURL;
        [(venueDetailsViewController *)segue.destinationViewController setImageURL:imageURL];
        [(venueDetailsViewController *)segue.destinationViewController setName:name];
    } else if ([segue.identifier isEqualToString:@"showMap"]) {
        NSArray *venues = self.venues;
        [(mapViewController *)segue.destinationViewController setVenues:venues];
    }
}

//sort
- (NSArray *)sortArrayForCells:(NSArray *)arrayToSorted {
    NSArray *descriptor = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"distance"
                                                                                 ascending:YES
                                                                                  selector:nil]];
    NSArray *sortedVenues = [arrayToSorted sortedArrayUsingDescriptors:descriptor];
    return sortedVenues;
}

//sort after tapping on button
- (NSArray *)sortArray:(NSArray *)arrayToSorted ascending:(BOOL)asc {
    NSArray *descriptor = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"distance"
                                                                                 ascending:asc
                                                                                  selector:nil]];
    NSArray *sortedVenues = [arrayToSorted sortedArrayUsingDescriptors:descriptor];
    [self setSorted:asc];
    return sortedVenues;
}

//sort button action
- (void)buttonPressed:(id)sender {
    self.venues = [self sortArray:self.venues ascending:!self.sorted];
    [self.tableView reloadData];
}

//pull to refresh
- (void)refresh {
    [locationManager startUpdatingLocation];
    [self.refreshControl endRefreshing];
}

//map button action
- (IBAction)goToMapVC {
    mapViewController *mapVC = [self.storyboard instantiateViewControllerWithIdentifier:@"mapVC"];
    [self.navigationController pushViewController:mapVC animated:YES];
}

#pragma mark CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    currentLocation = [locations lastObject];
    NSLog(@"currentLocation is %@",currentLocation);
    
    [[FoursquareManager sharedManager] withLocation:currentLocation getVenuesFromExplore:^(NSArray<Venue *> *venues, NSError *error) {
        self.venues = [self sortArrayForCells:venues];
        [self.tableView reloadData];
    }];
}

@end
