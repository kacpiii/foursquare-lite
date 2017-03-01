//
//  mapViewController.m
//  foursquare-lite
//
//  Created by Kacper Piątkowski on 24.02.2017.
//  Copyright © 2017 KacperPiatkowski. All rights reserved.
//

#import "mapViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "Venue.h"
#import "UIImageView+AFNetworking.h"

@interface mapViewController () <GMSMapViewDelegate>

@end

@implementation mapViewController {
    GMSMapView *_mapView;
    BOOL _firstLocationUpdate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.868
                                                            longitude:151.2086
                                                                 zoom:12];
    
    _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    _mapView.settings.compassButton = YES;
    _mapView.settings.myLocationButton = YES;
    
    // Listen to the myLocation property of GMSMapView.
    [_mapView addObserver:self
               forKeyPath:@"myLocation"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
    self.view = _mapView;
    
    // Ask for My Location data after the map has already been added to the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        _mapView.myLocationEnabled = YES;
    });
    
    for (Venue *venue in _venues) {
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(venue.lat, venue.lng);
        marker.title = venue.name; 
        marker.map = _mapView;
        
//        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:venue.thumbImageURL]]];
//        marker.icon = image;
    }
}

- (void)dealloc {
    [_mapView removeObserver:self
                  forKeyPath:@"myLocation"
                     context:NULL];
}

#pragma mark - KVO updates

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (!_firstLocationUpdate) {
        // If the first location update has not yet been recieved, then jump to that
        // location.
        _firstLocationUpdate = YES;
        CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
        _mapView.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                         zoom:14];
    }
}
                       

- (UIImage *)image:(UIImage*)originalImage scaledToSize:(CGSize)size
{
   //avoid redundant drawing
   if (CGSizeEqualToSize(originalImage.size, size))
   {
       return originalImage;
   }
   
   //create drawing context
   UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
   
   //draw
   [originalImage drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
   
   //capture resultant image
   UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
   UIGraphicsEndImageContext();
   
   //return image
   return image;
}
                       
@end
