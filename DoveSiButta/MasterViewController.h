//
//  MasterViewController.h
//  DoveSiButta
//
//  Created by Giovanni Maggini on 22/12/11.
//  Copyright (c) 2011 Giovanni Maggini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewController.h"


//ProgressHUD

//Cells
#import "ApplicationCell.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate>
{   
    
    UIBarButtonItem *configButton;
    UIBarButtonItem *addButton;
        
    //data sources
    NSArray			* listContent;			// The master content.
	NSMutableArray	* filteredListContent;	// The content filtered as a result of a search.
    
    // The saved state of the search UI if a memory warning removed the view.
    NSString		*savedSearchTerm;
    NSInteger		savedScopeButtonIndex;
    BOOL			searchWasActive;
    
    //Cells
  	ApplicationCell * tmpCell;
    // referring to our xib-based UITableViewCell ('IndividualSubviewsBasedApplicationCell')
	UINib * cellNib;
    
    //Icons
    NSDictionary *iconsDictionary;
        
}

//detail
@property (strong, nonatomic) MapViewController *mapViewController;

//tableview data sources
@property (strong, nonatomic) NSArray *listContent;
@property (strong, nonatomic) NSMutableArray *filteredListContent;

//saved state
@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;


//Cells
@property (strong, nonatomic) IBOutlet ApplicationCell *tmpCell;
@property (strong, nonatomic) UINib *cellNib;

//@property (nonatomic, retain) UINavigationController *navigationController;

@end
