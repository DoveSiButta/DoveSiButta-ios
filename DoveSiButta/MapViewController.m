//
//  MapViewController.m
//  DoveSiButta
//
//  Created by Giovanni Maggini on 22/12/11.
//  Copyright (c) 2011 Giovanni Maggini. All rights reserved.
//

#import "MapViewController.h"
#import "MapAnnotationDefault.h"
#import "LocationDetailViewController.h"


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


#define ALERTVIEW_GEOCODEFAIL 1
#define ALERTVIEW_COMUNEP2P 2
#define ALERTVIEW_LOCATIONFORBIDDEN 3


@interface MapViewController ()


@property(nonatomic, strong) NSMutableArray *results;
@property(nonatomic, strong) DoveSiButtaModel_Box *selectedResult;

@property(nonatomic, strong)MBProgressHUD *HUD;

//For location
//@property (nonatomic) CLLocationCoordinate2D gpsLocation;

@property (nonatomic, strong) MKReverseGeocoder *reverseGeocoder;

@end

@implementation MapViewController
@synthesize mapView;
@synthesize buttonLat, buttonLon;
@synthesize iconsDictionary;
@synthesize selectedType;
//@synthesize usingManualLocation, 
//@synthesize gpsLocation;
@synthesize address, postCode, country;
@synthesize comuniP2P;
@synthesize buttonAdd;

@synthesize results;
@synthesize HUD;
@synthesize reverseGeocoder;
@synthesize selectedResult;
@synthesize overlay; //OSM


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Butta", @"");
        self.tabBarItem.image = [UIImage imageNamed:@"103-map"];
        
    }
    return self;
}


#pragma mark - Data

//query con parametri
//http://nerddinner.com/Services/OData.svc/Dinners?$top=200&$skip=150&$orderby=EventDate%20desc
//http://www.odata.org/developers/protocols/uri-conventions

- (void) onAfterReceive:(HttpResponse*)response
{
	NSLog(@"on after receive");
	NSLog(@"http response = %@",[response getMessage]);
}

-(void) retrieveBoxesForType:(NSString*)searchType
{
    @try{
        
#if DEBUG
        NSLog(@"retriving boxes....");
#endif
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *serviceURI= [defaults objectForKey:@"serviceURI"];
        DoveSiButtaEntities *proxy=[[DoveSiButtaEntities alloc] initWithUri:serviceURI credential:nil];

//        DataServiceQuery *query = [proxy boxes];
//        QueryOperationResponse *response = [query execute];
        results = [[NSMutableArray alloc] init ];
//        
        CLLocationCoordinate2D location = [[AppState sharedInstance] currentLocation].coordinate;
        NSLocale *locale = [NSLocale currentLocale];
        
//        results = [proxy ItemsNearMeByCoordinatesWithlatitude:[NSDecimalNumber decimalNumberWithString:[[NSNumber numberWithFloat:location.latitude ]  descriptionWithLocale:locale] locale:locale] longitude:self.[NSDecimalNumber decimalNumberWithString:[[NSNumber numberWithFloat:location.longitude ]  descriptionWithLocale:locale] locale:locale]];
        NSArray *resultArr = [proxy ItemsNearMeByCoordinatesWithlatitude:[NSDecimalNumber decimalNumberWithString:[[NSNumber numberWithFloat:location.latitude ]  descriptionWithLocale:locale] locale:locale] longitude:[NSDecimalNumber decimalNumberWithString:[[NSNumber numberWithFloat:location.longitude ]  descriptionWithLocale:locale] locale:locale]];
        //[[response getResult] retain];

        
        for (int i =0;i<[resultArr count]; i++) {
            
            DoveSiButtaModel_Box *p = [resultArr objectAtIndex:i];
            if ([[p getBoxType] rangeOfString:self.selectedType].location != NSNotFound) //TODO: andrebbe filtrato nella query
            {
                [results addObject:p];
            }
                
        }
        
//        [proxy release];
//        [resultArr release];
//        [locale release];
//        [serviceURI release];
//        [defaults release];

    }
    @catch (DataServiceRequestException * e) 
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Avviso", @"") message:NSLocalizedString(@"Si è verificato un problema durante il caricamento.", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", @"") otherButtonTitles: nil];
        [alert show];
        NSLog(@"exception = %@,  innerExceptiom= %@",[e name],[[e getResponse] getError]);
    }	
    @catch (ODataServiceException * e) 
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Avviso", @"") message:NSLocalizedString(@"Si è verificato un problema durante il caricamento.", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", @"") otherButtonTitles: nil];
        [alert show];
        NSLog(@"exception = %@,  \nDetailedError = %@",[e name],[e getDetailedError]);
        
    }	
    @catch (NSException * e) 
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Avviso", @"") message:NSLocalizedString(@"Si è verificato un problema durante il caricamento.", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", @"") otherButtonTitles: nil];
        [alert show];
        NSLog(@"exception = %@, %@",[e name],[e reason]);
    }
    
    
    HUD.labelText = [NSString stringWithFormat: @"Completato"];
    [HUD hide:YES afterDelay:1];

    [self.mapView removeAnnotations:self.mapView.annotations];  // remove any annotations that exist
    for (DoveSiButtaModel_Box *aResult in results)
	{

        MapAnnotationDefault *resultAnnotation = [[MapAnnotationDefault alloc] init] ;
        resultAnnotation.item = aResult;
        
        [mapView addAnnotation:resultAnnotation];
    
	}

    //At last we enable button
    [buttonAdd setEnabled:YES];
    
    //Show user location    
    [self.mapView setShowsUserLocation:YES];
    
    if([results count] < 1)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Nessun punto raccolta!", @"") message:NSLocalizedString(@"Se non c'è nessun punto raccolta nella mappa, è perchè nessuno li ha ancora aggiunti.\n Tu puoi essere il primo, fai tap su \"Segnala\"!", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Ok, vado!", @"") otherButtonTitles: nil];
        [alert show];        
    }
    
}




-(void) retrieveBoxesWithAddress:(NSString*)searchAddress
{
    @try{
        
#if DEBUG
        NSLog(@"retriving boxes...");
#endif
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *serviceURI= [defaults objectForKey:@"serviceURI"];
        DoveSiButtaEntities *proxy=[[DoveSiButtaEntities alloc]initWithUri:serviceURI credential:nil];

        NSArray *resultArr = [proxy ItemsNearMeWithplaceorzip:[searchAddress stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];

        results = [resultArr mutableCopy];
    }
    @catch (DataServiceRequestException * e) 
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Avviso", @"") message:NSLocalizedString(@"Si è verificato un problema durante il caricamento.", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", @"") otherButtonTitles: nil];
        [alert show];
        NSLog(@"exception = %@,  innerExceptiom= %@",[e name],[[e getResponse] getError]);
    }	
    @catch (ODataServiceException * e) 
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Avviso", @"") message:NSLocalizedString(@"Si è verificato un problema durante il caricamento.", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", @"") otherButtonTitles: nil];
        [alert show];
        NSLog(@"exception = %@,  \nDetailedError = %@",[e name],[e getDetailedError]);
        
    }	
    @catch (NSException * e) 
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Avviso", @"") message:NSLocalizedString(@"Si è verificato un problema durante il caricamento.", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", @"") otherButtonTitles: nil];
        [alert show];
        NSLog(@"exception = %@, %@",[e name],[e reason]);
    }
    
    HUD.labelText = [NSString stringWithFormat: @"Completato"];
    [HUD hide:YES afterDelay:1];
    
    [self.mapView removeAnnotations:self.mapView.annotations];  // remove any annotations that exist
    for (DoveSiButtaModel_Box *aResult in results)
	{

        MapAnnotationDefault *resultAnnotation = [[MapAnnotationDefault alloc] init] ;
        resultAnnotation.item = aResult;
        
        [mapView addAnnotation:resultAnnotation];
        
	}
    
}


#pragma mark - IBAction

-(void) addItem:(id)sender
{
    CLLocationCoordinate2D locationToLookup = [[AppState sharedInstance] currentLocation].coordinate;
    self.reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:locationToLookup] ;
    reverseGeocoder.delegate = self;
    [reverseGeocoder start];
    
}


- (void)addLocationDidFinishWithCode:(int)finishCode
{
    if(finishCode == 0)
    {
//        [self retrieveBoxesForType:self.selectedType];
    }
}

#pragma mark - View lifecycle


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    CLLocationCoordinate2D coord = {latitude: 45.53189, longitude: 10.21727};
//    MKCoordinateSpan span = {latitudeDelta: 1, longitudeDelta: 1};
//    MKCoordinateRegion region = {coord, span};
//    [mapView setRegion:region];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

#if TARGET_IPHONE_SIMULATOR
        //Add button sempre, per testing
        buttonAdd = [[UIBarButtonItem alloc]
          initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
          target:self
          action:@selector(addItem:)];
        self.navigationItem.rightBarButtonItem = buttonAdd;

#else
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera ]) {
        //Add button solo se in presenza di camera (no vecchi iPod e iPad)
        buttonAdd =
        [[UIBarButtonItem alloc]
          initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
          target:self
          action:@selector(addItem:)];
        self.navigationItem.rightBarButtonItem = buttonAdd;
        [buttonAdd setEnabled:NO];
    }

#endif

    //Openstreetmap
    overlay = [[TileOverlay alloc] initOverlay];
    [mapView addOverlay:overlay];
    MKMapRect visibleRect = [mapView mapRectThatFits:overlay.boundingMapRect];
    visibleRect.size.width /= 2;
    visibleRect.size.height /= 2;
    visibleRect.origin.x += visibleRect.size.width / 2;
    visibleRect.origin.y += visibleRect.size.height / 2;
    mapView.visibleMapRect = visibleRect;
    
    
    //Eccezioni e comuni raccolta p2p
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ComuniRaccoltaP2P" ofType:@"plist"];
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:path];
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    
    // convert static property list into dictionary object
    NSDictionary *plistDictionary = (NSDictionary *)[NSPropertyListSerialization propertyListFromData:plistXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorDesc];
    if (!plistDictionary) 
    {
        NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
    }
    self.comuniP2P = plistDictionary;
    
    //Icons
    if([self.iconsDictionary count] < 1)
    {
        path = [[NSBundle mainBundle] pathForResource:@"IconForType" ofType:@"plist"];
        plistXML = [[NSFileManager defaultManager] contentsAtPath:path];
        errorDesc = nil;
        
        
        // convert static property list into dictionary object
        plistDictionary = (NSDictionary *)[NSPropertyListSerialization propertyListFromData:plistXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorDesc];
        if (!plistDictionary) 
        {
            NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
        }
        self.iconsDictionary = plistDictionary;

    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLocationServiceFailure:) name:kLocationServicesFailure object:nil];
    
    [self loadBoxes];
    
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

#pragma mark - AlertView Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case ALERTVIEW_LOCATIONFORBIDDEN:
            [self.navigationController popViewControllerAnimated:YES];
            break;
            
        default:
            break;
    }
}


#pragma mark Map View Delegate methods

- (void)showDetails:(id)sender forAnnotation:(MKAnnotationView <GMAnnotation> *)annotation
{
    // the detail view does not want a toolbar so hide it
    LocationDetailViewController *detailvc = [[LocationDetailViewController alloc] initWithItem:[annotation dinner]];
    [self.navigationController pushViewController:detailvc animated:YES];
}
    /*
- (void)mapView:(MKMapView *)map regionDidChangeAnimated:(BOOL)animated
{

    NSArray *oldAnnotations = mapView.annotations;
    [mapView removeAnnotations:oldAnnotations];
    
    NSArray *weatherItems = [weatherServer weatherItemsForMapRegion:mapView.region maximumCount:4];
    [mapView addAnnotations:weatherItems];

}
     */


/*
 //Se si usa questo metodo, usare UNA SOLA ANNOTATION per l'intera mappa
- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views
{    
    MKAnnotationView *annotationView = [views objectAtIndex:0];
    id<MKAnnotation> mp = [annotationView annotation];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([mp coordinate] ,250,250);
    
    [mv setRegion:region animated:YES];
}
*/

/*
//
// mapView:didSelectAnnotationView:
//
// Changes the selectedResult to the annotation of the selected view and updates
// the table
//
// Parameters:
//    aMapView - the map view
//    aView - the selected annotation view
//
- (void)mapView:(MKMapView *)aMapView didSelectAnnotationView:(MKAnnotationView *)aView
{
	[selectedResult autorelease];
	selectedResult = [(NSDictionary *)[aView annotation] retain];
    
	[self updateTableForSelectedResult];
}
*/

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    MapAnnotationDefault *myAnnotation = (MapAnnotationDefault*)view.annotation;
    LocationDetailViewController *ldvc = [[LocationDetailViewController alloc] initWithItem:myAnnotation.item];
    //[myAnnotation loadDetailView];
    [self.navigationController pushViewController:ldvc animated:YES];
    
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <GMAnnotation>)annotation
{
    
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;

    
    MKPinAnnotationView *newAnnotationPin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"simpleAnnotation"];
    if([self.selectedResult getBoxID] == [annotation annotationid])
    {
        newAnnotationPin.pinColor = MKPinAnnotationColorRed;
    }
    else
    {
        newAnnotationPin.pinColor = MKPinAnnotationColorGreen; // Or Red/Green
    }
    newAnnotationPin.animatesDrop = YES;
    newAnnotationPin.canShowCallout = YES;
    UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//    [rightButton addTarget:self
//                    action:@selector(showDetails: forAnnotation:)
//          forControlEvents:UIControlEventTouchUpInside];
//    UIImageView *dinnerIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Dinner"]];
    UIImageView *dinnerIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[self.iconsDictionary objectForKey:annotation.type]]];
    [dinnerIconView setFrame:CGRectMake(0, 0, 30, 30)];
    newAnnotationPin.leftCalloutAccessoryView = dinnerIconView; 
    
    newAnnotationPin.rightCalloutAccessoryView = rightButton;

    
    return newAnnotationPin;
}

#pragma mark -
#pragma mark Reverse Geocoder Delegate
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
    @try {
        self.country = placemark.country;
        self.postCode = placemark.postalCode;
        self.address = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
        
        //TODO: dove metto la segnalazione del comune raccolta P2P ? 
        //E riscrivere questo codice
//        for(NSString *entry in self.comuniP2P)
//        {
//            NSArray *comune = [self.comuniP2P objectForKey:entry];
//            if ([self.address rangeOfString:[comune objectAtIndex:0]].location != NSNotFound && [self.address rangeOfString:[comune objectAtIndex:1]].location != NSNotFound) {
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Attenzione", @"") message:NSLocalizedString(@"Il comune in cui ti trovi effettua la raccolta differenziata porta a porta!", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Ok, grazie", @"") otherButtonTitles: nil];
//                [alert show];
//            }
//        }
        
        LocationAddViewController *addVC = [[LocationAddViewController alloc] init];
        
        DoveSiButtaModel_Box *newItem = [[DoveSiButtaModel_Box alloc] init];
        if( [self.address length] > 50)
        {
            NSString *shortTitle = [self.address substringToIndex:49];
            [newItem setTitle:shortTitle ];
        }
        else
        {
            [newItem setTitle:self.address ];
        }
        
        
        [newItem setAddress:self.address];
        [newItem setCountry:self.country];
        [newItem setHostedBy:@""];
        [newItem setEventDate:[NSDate date]];
        
        
        CLLocationCoordinate2D location = [[AppState sharedInstance] currentLocation].coordinate;
        NSLocale *locale = [NSLocale currentLocale];
        
        [newItem setLatitude:[NSDecimalNumber decimalNumberWithString:[[NSNumber numberWithFloat:location.latitude]  descriptionWithLocale:locale] locale:locale]];
        [newItem setLongitude:[NSDecimalNumber decimalNumberWithString:[[NSNumber numberWithFloat:location.longitude] descriptionWithLocale:locale] locale:locale] ];
        
        addVC.myNewItem = newItem;
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:addVC];
        
        [self presentModalViewController:navController animated:YES];
        [addVC setDelegate:self];
        
//        if (geocoder != nil)
//        {
//            // release the existing reverse geocoder to stop it running
//            [geocoder autorelease];
//        }
        

    }
    @catch (NSException *exception) {
        NSString *errorMessage = [exception description];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Non sono riuscito a ottenere l'indirizzo", @"")
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }

 

}
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
    NSLog(@"Reverse Geocoder Error: %@", errorMessage);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Avviso", @"")  message:NSLocalizedString(@"Non sono riuscito a ottenere l'indirizzo", nil)
                           delegate:nil
                  cancelButtonTitle:NSLocalizedString(@"Lascia perdere", nil)
                  otherButtonTitles:NSLocalizedString(@"Riprova",nil),nil]; 
    [alertView show];
}


# pragma mark - Location

- (void)handleLocationServiceFailure:(NSNotification*)notification
{
    UIAlertView *a = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Attenzione", @"") message:NSLocalizedString(@"DoveSiButta necessita della tua posizione per cercare i cassonetti più vicini. Puoi abilitare o disabilitare questa scelta nelle impostazioni.", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Ok",nil) otherButtonTitles: nil];
    a.tag = ALERTVIEW_LOCATIONFORBIDDEN;
    [a show];
}


- (void)loadBoxes
{
    //TODO: ensure we have the best location possible!
    
    CLLocation *location = [[AppState sharedInstance] currentLocation];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([location coordinate] ,1000,1000);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:region];
    [self.mapView setRegion:adjustedRegion animated:YES];
    self.buttonLat.title = [NSString stringWithFormat:@"Lat %.3f", location.coordinate.latitude];
    self.buttonLon.title = [NSString stringWithFormat:@"Lon %.3f", location.coordinate.longitude];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    HUD.labelText = @"Caricamento";
    [HUD show:YES];

    [self retrieveBoxesForType:self.selectedType];

    
}
 
//OSM
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)ovl
{
    TileOverlayView *view = [[TileOverlayView alloc] initWithOverlay:ovl];
    view.tileAlpha = 1.0; // e.g. 0.6 alpha for semi-transparent overlay
    return view;
}


@end
