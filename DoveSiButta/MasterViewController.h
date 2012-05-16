//
//  MasterViewController.h
//  DoveSiButta
//
//  Created by Giovanni Maggini on 22/12/11.
//  Copyright (c) 2011 Giovanni Maggini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewController.h"

//Manager
#import "Manager.h"

//ProgressHUD
#import "MBProgressHUD.h"

//Cells
#import "ApplicationCell.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate, MBProgressHUDDelegate>
{   
    
    UIBarButtonItem *configButton;
    UIBarButtonItem *addButton;
        
    //data sources
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
        
}

//detail
@property (nonatomic, retain) MapViewController *mapViewController;

//tableview data sources
@property (nonatomic, retain) NSArray *listContent;
@property (nonatomic, retain) NSMutableArray *filteredListContent;

//saved state
@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;


//Cells
@property (nonatomic, retain) IBOutlet ApplicationCell *tmpCell;
@property (nonatomic, retain) UINib *cellNib;

//@property (nonatomic, retain) UINavigationController *navigationController;

@end
