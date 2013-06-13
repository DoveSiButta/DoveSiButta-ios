//
//  LocationDetailViewController.m
//  DoveSiButta
//
//  Created by Giovanni Maggini on 10/01/12.
//  Copyright (c) 2012 Giovanni Maggini. All rights reserved.
//

#import "LocationDetailViewController.h"
//Pageviewcontroller
#import "TextFieldCell.h"
#import "DetailDisclosureCell.h"
#import "NibLoadedCell.h"
#import "PictureFileViewController.h"

#import "SHK.h"

@implementation LocationDetailViewController
@synthesize selectedBox;
@synthesize coordinate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithItem:(DoveSiButtaModel_Box*)item
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.selectedBox = item;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


/*
-(void)addRSVP:(id)sender;
{
    NSLog(@"Work in progress to add RSVP");
    //Può essere usato in 2 modi: per dare un "voto" al cassonetto o per riportare un errore
}
*/


- (void)shareItem:(id)sender
{
    // Create the item to share (in this example, a url)
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.dovesibutta.com/%@",[self.selectedBox getBoxID]]];

	SHKItem *item = [SHKItem URL:url title:@"Ho appena trovato il cestino della raccolta differenziata che stavo cercando grazie a DoveSiButta!"];
    
	// Get the ShareKit action sheet
	SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
    
	// Display the action sheet
	[actionSheet showFromToolbar:self.navigationController.toolbar];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Dettagli", @"");
    

    //Share Button
    UIBarButtonItem *shareButton =
    [[UIBarButtonItem alloc]
      initWithBarButtonSystemItem:UIBarButtonSystemItemAction
      target:self
      action:@selector(shareItem:)];
    self.navigationItem.rightBarButtonItem = shareButton;

    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
   	[self addSectionAtIndex:0 withAnimation:UITableViewRowAnimationNone];

    [self addSectionAtIndex:1 withAnimation:UITableViewRowAnimationNone];
    [self appendRowToSection:1 cellClass:[TextFieldCell class] 
                    cellData:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"Where", @""),
                              @"label",
                              [NSString stringWithFormat:@"%@",[selectedBox getTitle] ], @"value",
                              NSLocalizedString(@"Value goes here", @""),
                              @"placeholder", 
                              [NSNumber numberWithBool:NO], 
                              @"editable",
                              nil]
               withAnimation:UITableViewRowAnimationNone];
    [self appendRowToSection:1 cellClass:[TextFieldCell class] 
                    cellData:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"When", @""),
                              @"label",
                              [NSString stringWithFormat:@"%@",[selectedBox getEventDate] ], @"value",
                              NSLocalizedString(@"Value goes here", @""),
                              @"placeholder", 
                              [NSNumber numberWithBool:NO], 
                              @"editable",
                              nil]
               withAnimation:UITableViewRowAnimationNone];
    [self appendRowToSection:1 cellClass:[TextFieldCell class] 
                    cellData:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"Latitude", @""),
                              @"label",
                              [NSString stringWithFormat:@"%@",[selectedBox getLatitude] ], @"value",
                              NSLocalizedString(@"Value goes here", @""),
                              @"placeholder", 
                              [NSNumber numberWithBool:NO], 
                              @"editable",
                              nil]
               withAnimation:UITableViewRowAnimationNone];
    [self appendRowToSection:1 cellClass:[TextFieldCell class] 
                    cellData:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"Longitude", @""),
                              @"label",
                              [NSString stringWithFormat:@"%@",[selectedBox getLongitude] ], @"value",
                              NSLocalizedString(@"Value goes here", @""),
                              @"placeholder", 
                              [NSNumber numberWithBool:NO], 
                              @"editable",
                              nil]
               withAnimation:UITableViewRowAnimationNone];
    [self appendRowToSection:1 cellClass:[TextFieldCell class] 
                    cellData:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"ID", @""),
                              @"label",
                              [NSString stringWithFormat:@"%@",[selectedBox getBoxID] ], @"value",
                              NSLocalizedString(@"Value goes here", @""),
                              @"placeholder", 
                              [NSNumber numberWithBool:NO], 
                              @"editable",
                              nil]
               withAnimation:UITableViewRowAnimationNone];
    /*
    [self appendRowToSection:1 cellClass:[TextFieldCell class] 
                    cellData:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"Hosted By", @""),
                              @"label",
                              [NSString stringWithFormat:@"%@",[selectedDinner getHostedBy] ], @"value",
                              NSLocalizedString(@"Value goes here", @""),
                              @"placeholder", 
                              NO, 
                              @"editable",
                              nil]
               withAnimation:UITableViewRowAnimationNone];
    [self appendRowToSection:1 cellClass:[TextFieldCell class] 
                    cellData:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"Description", @""),
                              @"label",
                              [NSString stringWithFormat:@"%@",[selectedDinner getDescription] ], @"value",
                              NSLocalizedString(@"Value goes here", @""),
                              @"placeholder", 
                              NO, 
                              @"editable",
                              nil]
               withAnimation:UITableViewRowAnimationNone];
    [self appendRowToSection:1 cellClass:[TextFieldCell class] 
                    cellData:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"Phone", @""),
                              @"label",
                              [NSString stringWithFormat:@"%@",[selectedDinner getContactPhone] ], @"value",
                              NSLocalizedString(@"Value goes here", @""),
                              @"placeholder", 
                              NO, 
                              @"editable",
                              nil]
               withAnimation:UITableViewRowAnimationNone];
*/
    [self appendRowToSection:1 cellClass:[TextFieldCell class] 
                    cellData:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"Address", @""),
                              @"label",
                              [NSString stringWithFormat:@"%@",[selectedBox getAddress] ], @"value",
                              NSLocalizedString(@"Value goes here", @""),
                              @"placeholder", 
                              [NSNumber numberWithBool:NO], 
                              @"editable",
                              nil]
               withAnimation:UITableViewRowAnimationNone];
    [self appendRowToSection:1 cellClass:[TextFieldCell class] 
                    cellData:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"Country", @""),
                              @"label",
                              [NSString stringWithFormat:@"%@",[selectedBox getCountry] ], @"value",
                              NSLocalizedString(@"Value goes here", @""),
                              @"placeholder", 
                              [NSNumber numberWithBool:NO], 
                              @"editable",
                              nil]
               withAnimation:UITableViewRowAnimationNone];
    /*
    [self appendRowToSection:1 cellClass:[DetailDisclosureCell class] 
                    cellData: [NSMutableDictionary dictionaryWithObjectsAndKeys: 
                               NSLocalizedString(@"View RSVPs",@""),
                               @"label",
                               @"showRSVP", 
                               @"action", //TODO: Mostra chi l'ha trovata interessante
                               nil] 
               withAnimation:UITableViewRowAnimationNone]; 
     */
    [self addSectionAtIndex:2 withAnimation:UITableViewRowAnimationNone];
    [self appendRowToSection:2 cellClass:[DetailDisclosureCell class] 
                    cellData: [NSMutableDictionary dictionaryWithObjectsAndKeys: 
                               NSLocalizedString(@"Guarda la foto",@""),
                               @"label",
                               @"showPicture", 
                               @"action", 
                               nil] 
               withAnimation:UITableViewRowAnimationNone]; 
    
    [self addSectionAtIndex:3 withAnimation:UITableViewRowAnimationNone];
    [self appendRowToSection:3 cellClass:[DetailDisclosureCell class] 
                    cellData: [NSMutableDictionary dictionaryWithObjectsAndKeys: 
                               NSLocalizedString(@"Trova direzione",@""),
                               @"label",
                               @"findDirection", 
                               @"action", 
                               nil] 
               withAnimation:UITableViewRowAnimationNone]; 


}

- (NSString *)tableView:(UITableView *)aTableView
titleForHeaderInSection:(NSInteger)section
{
	if (section == 0)
	{
		return NSLocalizedString(@"", nil);
	}
	else if (section == 1)
	{
		return NSLocalizedString(@"Informazioni Dettagliate", nil);
	}
	else if (section == 2)
	{
		return NSLocalizedString(@"", nil);
	}
    else if (section == 3)
	{
		return NSLocalizedString(@"", nil);
	}
    
	return nil;
}



#pragma mark - Table view delegates

//
// tableView:didSelectRowAtIndexPath:
//
// Handle row selection
//
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)anIndexPath
{
    //	PageCell *cell = (PageCell *)[aTableView cellForRowAtIndexPath:anIndexPath];
	if (![[aTableView cellForRowAtIndexPath:anIndexPath] isKindOfClass:[PageCell class]])
	{
		return;
	}
	
    if ([[aTableView cellForRowAtIndexPath:anIndexPath] isKindOfClass:[DetailDisclosureCell class]]) {
        DetailDisclosureCell *cell = (DetailDisclosureCell *)[aTableView cellForRowAtIndexPath:anIndexPath];
        [cell handleSelectionInTableView:aTableView];
        if([cell.action isEqualToString:@"showPicture"])
        {
            
            PictureFileViewController *pvc = [[PictureFileViewController alloc] initWithNibName:@"PictureFileViewController" bundle:[NSBundle mainBundle]];
            pvc.selectedItem = [self.selectedBox getBoxID];
            [self.navigationController pushViewController:pvc animated:YES];
        }
        else if([cell.action isEqualToString:@"findDirection"])
        {
            NSString *sourceLocation;
            NSString *queryType;
            
            queryType = @"daddr";
            sourceLocation =
            [NSString stringWithFormat:@"&saddr=%f,+%f",
            self.coordinate.latitude,
            self.coordinate.longitude];
            
            //TODO: per iOS6 http://developer.apple.com/library/ios/#featuredarticles/iPhoneURLScheme_Reference/Articles/MapLinks.html
//            NSString *urlString =
//            [NSString stringWithFormat:
//            @"http://maps.google.com/maps?%@=%@%@",
//            queryType,
//            (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(
//                                              nil,
//                                              (__bridge CFStringRef)[selectedBox getAddress],
//                                              nil,
//                                              (__bridge CFStringRef)@"&=",
//                                              kCFStringEncodingUTF8)
//            ,
//            sourceLocation];
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
            
            
            CLLocation* fromLocation = [[CLLocation alloc] initWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
            
            // Create a region centered on the starting point with a 10km span
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(fromLocation.coordinate, 10000, 10000);
            
            [MKMapItem openMapsWithItems:[NSArray arrayWithObject:fromLocation]
                           launchOptions:[NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSValue valueWithMKCoordinate:region.center], MKLaunchOptionsMapCenterKey,
                                          [NSValue valueWithMKCoordinateSpan:region.span], MKLaunchOptionsMapSpanKey, nil]];
            
        }
        else if ([cell.action isEqualToString:@"showRSVP"])
        {
            
        }
        
        return;
    }
    
    PageCell *cell = (PageCell *)[aTableView cellForRowAtIndexPath:anIndexPath];
    [cell handleSelectionInTableView:aTableView];
    
	
}


#pragma mark - View

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if(DeviceIsPad())
    {
        return YES;
    }
    else {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    }
}

@end
