//
//  LocationAddViewController.m
//  DoveSiButta
//
//  Created by Giovanni Maggini on 15/01/12.
//  Copyright (c) 2012 Giovanni Maggini. All rights reserved.
//

#import "LocationAddViewController.h"
//Pageviewcontroller
#import "TextFieldCell.h"
#import "DetailDisclosureCell.h"
#import "NibLoadedCell.h"
#import "PictureFileViewController.h"

//OData
#import "WindowsCredential.h"
#import "ACSCredential.h"
#import "ACSUtil.h"
#import "AzureTableCredential.h"
#import "Tables.h"
#import "ODataServiceException.h"
#import "ODataXMlParser.h"



@implementation LocationAddViewController
@synthesize newItem;
@synthesize pictureFile;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

- (void)saveItem:(id)sender
{
    //TODO: Controlla che i dati ci siano tutti i dati
    //TODO:  Controlla che ci sia la foto
}


- (void)cancelNewItem:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Tasto Cancel
    UIBarButtonItem *cancelButton =
    [[[UIBarButtonItem alloc]
      initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
      target:self
      action:@selector(cancelNewItem:)]
     autorelease];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    //Tasto Salva
    UIBarButtonItem *saveButton =
    [[[UIBarButtonItem alloc]
      initWithBarButtonSystemItem:UIBarButtonSystemItemSave
      target:self
      action:@selector(saveItem:)]
     autorelease];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    //TODO: fare in modo che le celle assomiglino a quelle di CoreDataBooks
    //TODO: mettere un tasto per aggiornare la posizione corrente con CLGeocoder, fare il reverse geocoding e mostrare all'utente l'indirizzo chiedendo: è corretto?
    //TODO: fare aggiungere la foto all'utente
    
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
   	[self addSectionAtIndex:0 withAnimation:UITableViewRowAnimationNone];
    
    [self appendRowToSection:0 cellClass:[NibLoadedCell class] 
                    cellData:[NSDictionary dictionaryWithObjectsAndKeys:
                              [newItem getTitle],@"labelText",
                              [NSString stringWithString:@"indifferenziata_300px"],@"imageName",                               NSLocalizedString(@"Nuovo Cestino", @"Title Label"),@"titleLabelText", 
                              nil] 
               withAnimation:UITableViewRowAnimationNone];
    
    [self addSectionAtIndex:1 withAnimation:UITableViewRowAnimationNone];
    [self appendRowToSection:1 cellClass:[TextFieldCell class] 
                    cellData:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"Dove", @""),
                              @"label",
                              [NSString stringWithFormat:@"%@",[newItem getAddress] ], @"value",
                              NSLocalizedString(@"Value goes here", @""),
                              @"placeholder", 
                              NO, 
                              @"editable",
                              nil]
               withAnimation:UITableViewRowAnimationNone];
    [self appendRowToSection:1 cellClass:[TextFieldCell class] 
                    cellData:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"When", @""),
                              @"label",
                              [NSString stringWithFormat:@"%@",[newItem getEventDate] ], @"value",
                              NSLocalizedString(@"Value goes here", @""),
                              @"placeholder", 
                              NO, 
                              @"editable",
                              nil]
               withAnimation:UITableViewRowAnimationNone];
    [self appendRowToSection:1 cellClass:[TextFieldCell class] 
                    cellData:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"Latitude", @""),
                              @"label",
                              [NSString stringWithFormat:@"%@",[newItem getLatitude] ], @"value",
                              NSLocalizedString(@"Value goes here", @""),
                              @"placeholder", 
                              NO, 
                              @"editable",
                              nil]
               withAnimation:UITableViewRowAnimationNone];
    [self appendRowToSection:1 cellClass:[TextFieldCell class] 
                    cellData:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"Longitude", @""),
                              @"label",
                              [NSString stringWithFormat:@"%@",[newItem getLongitude] ], @"value",
                              NSLocalizedString(@"Value goes here", @""),
                              @"placeholder", 
                              NO, 
                              @"editable",
                              nil]
               withAnimation:UITableViewRowAnimationNone];
    /*
    [self appendRowToSection:1 cellClass:[TextFieldCell class] 
                    cellData:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"ID", @""),
                              @"label",
                              [NSString stringWithFormat:@"%@",[newItem getDinnerID] ], @"value",
                              NSLocalizedString(@"Value goes here", @""),
                              @"placeholder", 
                              NO, 
                              @"editable",
                              nil]
               withAnimation:UITableViewRowAnimationNone];
     */
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
     [self appendRowToSection:1 cellClass:[TextFieldCell class] 
     cellData:[NSMutableDictionary dictionaryWithObjectsAndKeys:
     NSLocalizedString(@"Hosted by ID", @""),
     @"label",
     [NSString stringWithFormat:@"%@",[selectedDinner getHostedById] ], @"value",
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
                              [NSString stringWithFormat:@"%@",[newItem getAddress] ], @"value",
                              NSLocalizedString(@"Value goes here", @""),
                              @"placeholder", 
                              NO, 
                              @"editable",
                              nil]
               withAnimation:UITableViewRowAnimationNone];
    [self appendRowToSection:1 cellClass:[TextFieldCell class] 
                    cellData:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                              NSLocalizedString(@"Country", @""),
                              @"label",
                              [NSString stringWithFormat:@"%@",[newItem getCountry] ], @"value",
                              NSLocalizedString(@"Value goes here", @""),
                              @"placeholder", 
                              NO, 
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
    [self appendRowToSection:1 cellClass:[DetailDisclosureCell class] 
                    cellData: [NSMutableDictionary dictionaryWithObjectsAndKeys: 
                               NSLocalizedString(@"Scatta una foto!",@""),
                               @"label",
                               @"addPicture", 
                               @"action", 
                               nil] 
               withAnimation:UITableViewRowAnimationNone]; 
    
    //TODO: qui ci vanno le celle (che sono poi delle normali LabelCell ma con accanto il checkbox
    
    [dateFormat release];

    
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
        if([cell.action isEqualToString:@"addPicture"])
        {
            //TODO: UIImagePickersticazzi ?!?!?!
        }
        
        return;
    }
    
    PageCell *cell = (PageCell *)[aTableView cellForRowAtIndexPath:anIndexPath];
    [cell handleSelectionInTableView:aTableView];
    
	
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
