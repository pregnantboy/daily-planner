//
//  MapViewController.m
//  DailyPlanner
//
//  Created by Soham Ghosh on 19/9/15.
//  Copyright © 2015 Ian Chen. All rights reserved.
//

#import "MapViewController.h"
@interface MapViewController ()

@end

@implementation MapViewController
BOOL markersPlaced_;
BOOL locationUpdated_;

- (void)viewDidLoad {
    [super viewDidLoad];
    locationUpdated_ = NO;
    markersPlaced_ = NO;
    self.map.delegate = self;
    self.searchResultsView.delegate = self;
    self.searchResultsView.dataSource = self;
    self.searchResultsView.hidden = YES;
    self.locationManager = [[LocationManager alloc] init];
    
    // Listen to the myLocation property of GMSMapView.
    [self.map addObserver:self
               forKeyPath:@"myLocation"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
    // Ask for My Location data after the map has already been added to the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        self.map.myLocationEnabled = YES;
        self.map.settings.myLocationButton = YES;
    });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [self.map removeObserver:self
                  forKeyPath:@"myLocation"
                     context:NULL];
}

#pragma mark - Location KVO updates

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (!locationUpdated_) {
        // If the first location update has not yet been recieved, then jump to that
        // location.
        locationUpdated_ = YES;
        CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
        [self goToPosition:location.coordinate];
    }
}

# pragma mark - Map Methods

- (void) mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate{
    NSLog(@"%f, %f", coordinate.latitude, coordinate.longitude);
}

- (void) mapView:(GMSMapView *) mapView
didChangeCameraPosition:(GMSCameraPosition *) position  {
    NSLog(@"zoom: %f", position.zoom);
    if (position.zoom < 12.2){  // remove markers if zoom is too low
        [self.map clear];
        markersPlaced_ = NO;
        NSLog(@"removed markers");
    } else if (!markersPlaced_){
        NSLog(@"placed markers");
        markersPlaced_ = YES;
        for (LocationObject * loc in [self.locationManager getLocations]){
//            NSLog(@"Placed marker at %f,%f:: %@", loc.position.latitude, loc.position.longitude, loc.title);
            [self placeMarkerAtPosition:loc.position title:loc.title icon:[UIImage imageNamed:[self.locationManager getLocationIcon]]];;
        }
    }
}


- (void) mapView:(GMSMapView *) mapView
didTapInfoWindowOfMarker:(GMSMarker *) marker {
    NSLog(@"Did click on marker window");
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Confirm Location"
                                                                   message:marker.title
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              [self.locationManager chooseLocation:marker.title position:marker.position];
                                                              [self performSegueWithIdentifier:@"unwindToEventViewSegue" sender:self];
                                                          }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * action) {
                                                          // handle cancellation here
                                                          }];
    
    [alert addAction:defaultAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

# pragma mark - SearchResultsView
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger idx = indexPath.row;
    GMSAutocompletePrediction *pred = (GMSAutocompletePrediction *)self.searchAutocompleteResults[idx];
    GMSPlacesClient * places = [[GMSPlacesClient alloc] init];
    [places lookUpPlaceID:pred.placeID callback:^(GMSPlace *GMS_NULLABLE_PTR result, NSError *GMS_NULLABLE_PTR error){
        [self.map clear];
        markersPlaced_ = NO;
        [self placeMarkerAtPosition:result.coordinate title:pred.attributedFullText.string];
        [self goToPosition:result.coordinate];
        self.searchResultsView.hidden = YES; // hide search results
    }];
}

- (void) placeMarkerAtPosition:(CLLocationCoordinate2D)position title:(NSString *)title{
    GMSMarker * marker = [GMSMarker markerWithPosition:position];
    marker.title = title;
    marker.map = self.map;
}

- (void) placeMarkerAtPosition:(CLLocationCoordinate2D)position title:(NSString *)title  icon:(UIImage *)icon{
    GMSMarker * marker = [GMSMarker markerWithPosition:position];
    marker.title = title;
    marker.icon = icon;
    marker.snippet = @"Click to choose";
    marker.map = self.map;
}

- (IBAction)clickCancel:(id)sender {
    [self performSegueWithIdentifier:@"unwindToEventViewSegue" sender:self];
    
}


- (IBAction)selectCategory:(UISegmentedControl *)sender {
    NSInteger idx = [sender selectedSegmentIndex];
    switch (idx) {
        case 0:
            [self.locationManager setCategory:FOOD];
            break;
        case 1:
            [self.locationManager setCategory:SPORTS];
            break;
    }
    [self.map clear];
    for (LocationObject * loc in [self.locationManager getLocations]){  // place new markers
        NSLog(@"Placed marker at %f,%f:: %@", loc.position.latitude, loc.position.longitude, loc.title);
        [self placeMarkerAtPosition:loc.position title:loc.title icon:[UIImage imageNamed:[self.locationManager getLocationIcon]]];;
    }
    
}

- (void) goToPosition:(CLLocationCoordinate2D)coord {
    [self.map moveCamera:[GMSCameraUpdate setTarget:coord]];
    [self.map moveCamera:[GMSCameraUpdate zoomTo:13.2]];
}

- (IBAction)categorySelector:(UISegmentedControl *)sender {
    // put in logic to handle when category changes
}

- (NSInteger)tableView:(UITableView * GMS_NULLABLE_PTR)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.searchAutocompleteResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
                  cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchResultCell"];
    NSUInteger idx = indexPath.row;
    GMSAutocompletePrediction *pred = self.searchAutocompleteResults[idx];
    cell.textLabel.text = pred.attributedFullText.string;
    return cell;
}

# pragma mark - Search


- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText {
    if ([searchBar.text isEqualToString:@""]){
        self.searchResultsView.hidden = YES; //hide if empty
    } else {
        self.searchResultsView.hidden = NO;
        // do the search
        GMSPlacesClient * places = [[GMSPlacesClient alloc] init];
        [places autocompleteQuery:searchBar.text
                           bounds:nil
                           filter:nil
                         callback:^(NSArray * results, NSError * error) {
                             self.searchAutocompleteResults = [results mutableCopy]; // save search results in array
                             [self.searchResultsView reloadData];
                         }];
    }
    
}



#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
