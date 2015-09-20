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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchResultsView.delegate = self;
    self.searchResultsView.dataSource = self;
    self.searchResultsView.hidden = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

# pragma mark - Map Methods

- (void) mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate{
    NSLog(@"%f, %f", coordinate.latitude, coordinate.longitude);
}

# pragma mark - SearchResultsView
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger idx = indexPath.row;
    GMSAutocompletePrediction *pred = (GMSAutocompletePrediction *)self.searchAutocompleteResults[idx];
    GMSPlacesClient * places = [[GMSPlacesClient alloc] init];
    [places lookUpPlaceID:pred.placeID callback:^(GMSPlace *GMS_NULLABLE_PTR result, NSError *GMS_NULLABLE_PTR error){
        [self.map clear];
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

- (void) goToPosition:(CLLocationCoordinate2D)coord {
    [self.map moveCamera:[GMSCameraUpdate setTarget:coord]];
    [self.map moveCamera:[GMSCameraUpdate zoomTo:13]];
}

- (NSInteger)tableView:(UITableView * GMS_NULLABLE_PTR)tableView
 numberOfRowsInSection:(NSInteger)section {
    printf("%lu\n", self.searchAutocompleteResults.count);
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
