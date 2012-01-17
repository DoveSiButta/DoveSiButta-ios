//
//  MasterViewController.h
//  NerdDinner
//
//  Created by Giovanni Maggini on 22/12/11.
//  Copyright (c) 2011 Giovanni Maggini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewController.h"
#import <CoreLocation/CoreLocation.h>

//ProgressHUD
#import "MBProgressHUD.h"

//Cells
#import "ApplicationCell.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate, MBProgressHUDDelegate, CLLocationManagerDelegate>
{
//    NSArray *resultArray;
    
    UISegmentedControl *segmentedControlTopBar;
    
    
    NSArray			*listContent;			// The master content.
	NSMutableArray	*filteredListContent;	// The content filtered as a result of a search.
    
    // The saved state of the search UI if a memory warning removed the view.
    NSString		*savedSearchTerm;
    NSInteger		savedScopeButtonIndex;
    BOOL			searchWasActive;
    
    //ProgressHUD
    MBProgressHUD *HUD;
    
    //Cells
  	ApplicationCell *tmpCell;
    // referring to our xib-based UITableViewCell ('IndividualSubviewsBasedApplicationCell')
	UINib *cellNib;
    
    //Icons
    NSDictionary *iconsDictionary;
    
    //For location
    CLLocationManager *locationManager;
	CLLocationCoordinate2D gpsLocation;
	BOOL gpsLocationFailed;
	BOOL usingManualLocation;
}

/* For LLVM 3.0
@property (strong, nonatomic) DetailViewController *detailViewController;
*/

//@property (nonatomic, retain) DetailViewController *detailViewController;
@property (nonatomic, retain) MapViewController *mapViewController;
//@property (nonatomic, retain) NSArray *resultArray;

@property (nonatomic, retain) NSArray *listContent;
@property (nonatomic, retain) NSMutableArray *filteredListContent;

//saved state
@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;


@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControlTopBar;

//Cells
@property (nonatomic, retain) IBOutlet ApplicationCell *tmpCell;
@property (nonatomic, retain) UINib *cellNib;

//For location
@property (nonatomic, assign) BOOL usingManualLocation;
@property (nonatomic, assign) CLLocationCoordinate2D gpsLocation;

+ (NSString *)qualifiedAddressStringForResultDictionary:(NSDictionary *)result;

@end
