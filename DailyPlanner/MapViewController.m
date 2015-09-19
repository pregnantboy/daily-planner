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


# pragma mark - SearchResultsView
- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.searchResultsView.hidden = YES; // hide search results
    NSUInteger idx = indexPath.row;
    GMSAutocompletePrediction *pred = (GMSAutocompletePrediction *)self.searchAutocompleteResults[idx];
    GMSPlacesClient * places = [[GMSPlacesClient alloc] init];
    [places lookUpPlaceID:pred.placeID callback:^(GMSPlace * _Nullable result, NSError * _Nullable error) {
        [self.map clear];
        [self placeMarkerAtPosition:result.coordinate];
        [self goToPosition:result.coordinate];
    }];
}

- (void) placeMarkerAtPosition:(CLLocationCoordinate2D)position {
    
}

- (void) goToPosition:(CLLocationCoordinate2D)coord {
    
}

- (NSInteger)tableView:(UITableView * _Nonnull)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.searchAutocompleteResults.count;
}

- (UITableViewCell * _Nonnull)tableView:(UITableView * _Nonnull)tableView
                  cellForRowAtIndexPath:(NSIndexPath * _Nonnull)indexPath {
    self.searchResultsView.hidden = YES;
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchResultCell"];
    NSUInteger idx = indexPath.row;
    GMSAutocompletePrediction *pred = self.searchAutocompleteResults[idx];
    cell.textLabel.text = pred.attributedFullText.string;
    return cell;
}

# pragma mark - Search

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    // show table view cell
    self.searchResultsView.hidden = NO;
}

- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText {
    if ([searchBar.text isEqualToString:@""]){
        self.searchResultsView.hidden = YES; //hide if empty
    } else {
        // do the search
        GMSPlacesClient * places = [[GMSPlacesClient alloc] init];
        [places autocompleteQuery:searchBar.text
                           bounds:nil
                           filter:nil
                         callback:^(NSArray * _Nullable results, NSError * _Nullable error) {
                             self.searchAutocompleteResults = [results mutableCopy]; // save search results in array
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
