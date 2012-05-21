//
//  MasterViewController.m
//  DoveSiButta
//
//  Created by Giovanni Maggini on 22/12/11.
//  Copyright (c) 2011 Giovanni Maggini. All rights reserved.
//

#import "MasterViewController.h"

#import "MapViewController.h"
#import "LocationAddViewController.h"
#import "HelpViewController.h"

//OData
#import "WindowsCredential.h"
#import "ACSCredential.h"
#import "ACSUtil.h"
#import "AzureTableCredential.h"
#import "Tables.h"
#import "ODataServiceException.h"
#import "ODataXMlParser.h"
//Service
#import "DoveSiButtaEntities.h"

//Cells
#import "ApplicationCell.h"
#import "CompositeSubviewBasedApplicationCell.h"
#import "HybridSubviewBasedApplicationCell.h"

// Define one of the following macros to 1 to control which type of cell will be used.
#define USE_INDIVIDUAL_SUBVIEWS_CELL    1	// use a xib file defining the cell
#define USE_COMPOSITE_SUBVIEW_CELL      0	// use a single view to draw all the content
#define USE_HYBRID_CELL                 0	// use a single view to draw most of the content + separate label to render the rest of the content


/*
 Predefined colors to alternate the background color of each cell row by row
 (see tableView:cellForRowAtIndexPath: and tableView:willDisplayCell:forRowAtIndexPath:).
 */
#define DARK_BACKGROUND  [UIColor colorWithRed:151.0/255.0 green:152.0/255.0 blue:155.0/255.0 alpha:1.0]
#define LIGHT_BACKGROUND [UIColor colorWithRed:172.0/255.0 green:173.0/255.0 blue:175.0/255.0 alpha:1.0]


@implementation MasterViewController

@synthesize mapViewController = _mapViewController;
@synthesize listContent, filteredListContent;
@synthesize savedSearchTerm, savedScopeButtonIndex, searchWasActive;
@synthesize tmpCell, cellNib;
//@synthesize navigationController;





- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Trova", @"");
        self.tabBarItem.image = [UIImage imageNamed:@"103-map"];
    }
    return self;
}
							
- (void)dealloc
{
    [_mapViewController release];
    [listContent release];
	[filteredListContent release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //Buttons
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"?" style:UIBarButtonItemStyleBordered target:self action:@selector(showHelp:)] autorelease];
     //Per creare un nuovo elemento da questo schermo dovrei per forza avere iOS5. Dato che solo con iOS5 posso fare il reverse geocode della posizione dell'utente senza dover avere una MKMapView da cui prendere la posizione attuale

    /*
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle: @"Configura"                                                                               style: UIBarButtonItemStyleBordered                                                                              target: self        action: @selector(configuration:)] autorelease];
     */
    
    /*
    //Only if we use items as data source
    // Configure the table view.
    self.tableView.rowHeight = 73.0;
    self.tableView.backgroundColor = DARK_BACKGROUND;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.searchDisplayController.searchResultsTableView.rowHeight = 73.0;
    self.searchDisplayController.searchResultsTableView.backgroundColor = DARK_BACKGROUND;
    self.searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    */
     
    
    // create our UINib instance which will later help us load and instanciate the
	// UITableViewCells's UI via a xib file.
	//
	// Note:
	// The UINib classe provides better performance in situations where you want to create multiple
	// copies of a nib file’s contents. The normal nib-loading process involves reading the nib file
	// from disk and then instantiating the objects it contains. However, with the UINib class, the
	// nib file is read from disk once and the contents are stored in memory.
	// Because they are in memory, creating successive sets of objects takes less time because it
	// does not require accessing the disk.
	//
	self.cellNib = [UINib nibWithNibName:@"IndividualSubviewsBasedApplicationCell" bundle:nil];
    
    // restore search settings if they were saved in didReceiveMemoryWarning.
    if (self.savedSearchTerm)
    {
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
        [self.searchDisplayController.searchBar setText:savedSearchTerm];
        
        self.savedSearchTerm = nil;
    }

    
    //Icons
  
    // read property list into memory as an NSData object
    NSString *path = [[NSBundle mainBundle] pathForResource:@"IconForType" ofType:@"plist"];
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:path];
    NSError *error = [[NSError alloc] init];
    NSPropertyListFormat format;
    
    // convert static property list into dictionary object
    NSDictionary *plistDictionary = (NSDictionary*)[NSPropertyListSerialization propertyListWithData:plistXML options:NSPropertyListMutableContainersAndLeaves format:&format error:&error];

    if (!plistDictionary) 
    {
        NSLog(@"Error reading plist: %@, format: %d", error, format);
    }
    iconsDictionary = plistDictionary;
    [iconsDictionary retain];
    
    //Types
    path = [[NSBundle mainBundle] pathForResource:@"RifiutiTypes" ofType:@"plist"];
    plistXML = [[NSFileManager defaultManager] contentsAtPath:path];
    
    // convert static property list into dictionary object
    plistDictionary =(NSDictionary*)[NSPropertyListSerialization propertyListWithData:plistXML options:NSPropertyListMutableContainersAndLeaves format:&format error:&error]; 
    if (!plistDictionary) 
    {
        NSLog(@"Error reading plist: %@, format: %d", error, format);
    }
    NSMutableArray* rifiutiTypes = [[NSMutableArray alloc] init];
    for(NSString *dic in plistDictionary)
    {
        NSDictionary *i = [plistDictionary objectForKey:dic];
        [rifiutiTypes addObject:i];
    }
    [rifiutiTypes retain];
    NSLog(@"rifiutitypes: %@", rifiutiTypes);
    self.listContent = rifiutiTypes;
    self.filteredListContent = [self.listContent mutableCopy];


    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [listContent release];
	listContent = nil;
    [filteredListContent release];
    filteredListContent = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
   }

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    
    self.searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
    self.savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1; 
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return [resultArray count];
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return [self.filteredListContent count];
    }
	else
	{
        return [self.listContent count];
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    

    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    // Configure the cell.
    NSDictionary *cellDict = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        cellDict = [self.filteredListContent objectAtIndex:indexPath.row];
    }
	else
	{
        cellDict = [self.listContent objectAtIndex:indexPath.row];
    }
        
    cell.textLabel.text = NSLocalizedString([cellDict objectForKey:@"type"], @"Detail");

    cell.imageView.image = [UIImage imageNamed:[iconsDictionary objectForKey:[cellDict objectForKey:@"id"]] ];
    cell.imageView.highlightedImage =  [UIImage imageNamed:[iconsDictionary objectForKey:[cellDict objectForKey:@"id"]] ];
    //TODO: aggiungere immagine quando selezionato

    return cell;


}

/*
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = ((ApplicationCell *)cell).useDarkBackground ? DARK_BACKGROUND : LIGHT_BACKGROUND;
}
*/
 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.mapViewController = [[[MapViewController alloc] initWithNibName:@"MapViewController" bundle:[NSBundle mainBundle]] autorelease];
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        self.mapViewController.selectedType = [[filteredListContent objectAtIndex:indexPath.row] objectForKey:@"id"];
    }
    else
    {
        self.mapViewController.selectedType = [[listContent objectAtIndex:indexPath.row] objectForKey:@"id"];
    }
    self.mapViewController.iconsDictionary = iconsDictionary;
    [self.navigationController pushViewController:self.mapViewController animated:YES];
}



#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	/*
	 Update the filtered array based on the search text and scope.
	 */
	
	[self.filteredListContent removeAllObjects]; // First clear the filtered array.
	
	/*
	 Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
	 */
	for (DoveSiButtaModel_Box *dinner in listContent)
	{
        //TODO: check il filtro
        if([[dinner getTitle] rangeOfString:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)].location != NSNotFound)
        {
            [self.filteredListContent addObject:dinner];
        }

        /*
		if ([scope isEqualToString:@"All"])
		{
			NSComparisonResult result0 = [[dinner getTitle] compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
            NSComparisonResult result1 = [[dinner getDescription] compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
            if (result0 == NSOrderedSame || result1 == NSOrderedSame)
			{
				[self.filteredListContent addObject:dinner];
            }
		}
        else
        {
            NSComparisonResult result = [[dinner getTitle] compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
            if (result == NSOrderedSame)
			{
				[self.filteredListContent addObject:dinner];
            }
        }
         */
	}
}



#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


#pragma mark - Manage IBActions

-(IBAction)addItem:(id)sender
{
    LocationAddViewController *addVC = [[LocationAddViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:addVC];
    
    [self presentModalViewController:navController animated:YES];
    [addVC release];
    [navController release];
}

-(IBAction)configuration:(id)sender
{
    //TODO: display config
}

-(IBAction)showHelp:(id)sender
{
    HelpViewController *hvc = [[HelpViewController alloc] init];
    UINavigationController *helpNVC = [[UINavigationController alloc] initWithRootViewController:hvc];
    
    [self presentModalViewController:helpNVC animated:YES];
    [helpNVC release];
    [hvc release];
    
}


@end
