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
//#import "NerdDinnerEntities.h"
#import "DoveSiButtaEntities.h"

/*
//
// Adapter category on NSDictionary to make it obey the MKAnnotation protocol
//
@implementation NSDictionary (Annotations)


- (NSString *)title
{
	return [self objectForKey:@"title"];
}

- (NSNumber *)annotationid
{
    return [self objectForKey:@"id"];
}

- (NSString *)subtitle
{
	return [self objectForKey:@"description"];
}

- (CLLocationCoordinate2D)coordinate
{
	return CLLocationCoordinate2DMake(
                                      [[self objectForKey:@"latitude"] floatValue],
                                      [[self objectForKey:@"longitude"] floatValue]);
}

@end
 */


@implementation MapViewController
@synthesize mapView;
@synthesize buttonLat, buttonLon;
@synthesize iconsDictionary;
@synthesize selectedType;
@synthesize usingManualLocation, gpsLocation;
@synthesize address, postCode, country;
@synthesize comuniP2P;


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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


-(void) retrieveBoxes
{
    @try{
        
#if DEBUG
        NSLog(@"retriving dinners....");
#endif
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *serviceURI= [defaults objectForKey:@"serviceURI"];
        DoveSiButtaEntities *proxy=[[DoveSiButtaEntities alloc]initWithUri:serviceURI credential:nil];
        
        DataServiceQuery *query = [proxy boxes];
        //	//[query top:1];
        QueryOperationResponse *response = [query execute];
        NSArray *resultArr =[[response getResult] retain];
        //    NSArray *resultArr = [[proxy FindUpcomingDinners] retain]; //??? Returns no results as of 2012-01-12
        //        NSArray *resultArr =[[proxy GetMostRecentDinners] retain]; //Method with custom OData Query
//        [[resultArr reverseObjectEnumerator] allObjects]; //Reversed order if I use my own query
//#if DEBUG
//        NSLog(@"resultarray...%d",[resultArr count]);
//#endif
//        for (int i =0;i<[resultArr count]; i++) {
//            
//            DoveSiButtaModel_Box *p = [resultArr objectAtIndex:i];
//#if DEBUG
//            NSLog(@"=== Item %d  ===",i);
//            NSLog(@"dinner id...%@",[[p getBoxID] stringValue]);
//            NSLog(@"dinner name...%@",[p getTitle]);
//            NSLog(@"dinner desc......%@",[p getDescription]);
//            NSLog(@"Date..%@",[p getEventDate]);
//            //		NSLog(@"Type..%@",[p getDinnerType]);
//            NSLog(@"Latitude..%@",[p getLatitude]);
//            NSLog(@"Longitude..%@",[p getLongitude]);
//            NSLog(@"==Fine Dinner==");
//#endif   
//        }
        
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
    
    // Do any additional setup after loading the view from its nib.
    for (DoveSiButtaModel_Box *aResult in results)
	{
        
		//NSDictionary *resultLocation = [NSDictionary dictionaryWithObjectsAndKeys:[aResult getLatitude],@"latitude",[aResult getLongitude],@"longitude",[aResult getTitle],@"title", [aResult getDescription], @"description",[aResult getDinnerID], @"annotationid", nil];//  [aResult objectForKey:@"stationLocation"];
        //Per usare il Dictionary è necessario implementare 
        
        MapAnnotationDefault *resultAnnotation = [[MapAnnotationDefault alloc] init] ;
        resultAnnotation.item = aResult;
        [resultAnnotation retain];
        
        [mapView addAnnotation:resultAnnotation];
        
	}
    
}

-(void) retrieveBoxesForType:(NSString*)searchType
{
    @try{
        
#if DEBUG
        NSLog(@"retriving dinners....");
#endif
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *serviceURI= [defaults objectForKey:@"serviceURI"];
        DoveSiButtaEntities *proxy=[[DoveSiButtaEntities alloc]initWithUri:serviceURI credential:nil];

        DataServiceQuery *query = [proxy boxes];
        QueryOperationResponse *response = [query execute];
        results = [[NSMutableArray alloc] init ];
        NSArray *resultArr =[[response getResult] retain];
//        [[resultArr reverseObjectEnumerator] allObjects]; //Reversed order if I use my own query
//#if DEBUG
//        NSLog(@"resultarray...%d",[resultArr count]);
//#endif
        for (int i =0;i<[resultArr count]; i++) {
            
            DoveSiButtaModel_Box *p = [resultArr objectAtIndex:i];
//#if DEBUG
//            NSLog(@"=== Dinner %d  ===",i);
//            NSLog(@"dinner id...%@",[[p getBoxID] stringValue]);
//            NSLog(@"dinner name...%@",[p getTitle]);
//            NSLog(@"dinner desc......%@",[p getDescription]);
//            NSLog(@"Date..%@",[p getEventDate]);
//NSLog(@"Type..%@",[p getBoxType]);
//            NSLog(@"Latitude..%@",[p getLatitude]);
//            NSLog(@"Longitude..%@",[p getLongitude]);
//            NSLog(@"==Fine Dinner==");
//#endif   
            if ([[p getBoxType] rangeOfString:self.selectedType].location != NSNotFound) //TODO: andrebbe filtrato nella query
            {
                [results addObject:p];
            }
                
        }
        

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
    
    // Do any additional setup after loading the view from its nib.
    for (DoveSiButtaModel_Box *aResult in results)
	{
        
		//NSDictionary *resultLocation = [NSDictionary dictionaryWithObjectsAndKeys:[aResult getLatitude],@"latitude",[aResult getLongitude],@"longitude",[aResult getTitle],@"title", [aResult getDescription], @"description",[aResult getDinnerID], @"annotationid", nil];//  [aResult objectForKey:@"stationLocation"];
        //Per usare il Dictionary è necessario implementare 
        
        MapAnnotationDefault *resultAnnotation = [[MapAnnotationDefault alloc] init] ;
        resultAnnotation.item = aResult;
        [resultAnnotation retain];
        
        [mapView addAnnotation:resultAnnotation];
    
	}
    
}




-(void) retrieveDinnersWithAddress:(NSString*)searchAddress
{
    @try{
        
#if DEBUG
        NSLog(@"retriving dinners....");
#endif
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *serviceURI= [defaults objectForKey:@"serviceURI"];
        DoveSiButtaEntities *proxy=[[DoveSiButtaEntities alloc]initWithUri:serviceURI credential:nil];
        
//        DataServiceQuery *query = [proxy DinnersNearMeWithplaceorzip:searchAddress];
        //	//[query top:1];
        
//        QueryOperationResponse *response = [query execute];
//        NSArray *resultArr =[[response getResult] retain];
        NSArray *resultArr = [[proxy ItemsNearMeWithplaceorzip:[searchAddress stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]] retain];
        //        NSArray *resultArr =[[proxy GetMostRecentDinners] retain]; //Method with custom OData Query
//        [[resultArr reverseObjectEnumerator] allObjects]; //Reversed order if I use my own query
//#if DEBUG
//        NSLog(@"resultarray...%d",[resultArr count]);
//#endif
//        for (int i =0;i<[resultArr count]; i++) {
//            
//            DoveSiButtaModel_Box *p = [resultArr objectAtIndex:i];
//#if DEBUG
//            NSLog(@"=== Dinner %d  ===",i);
//            NSLog(@"dinner id...%@",[[p getBoxID] stringValue]);
//            NSLog(@"dinner name...%@",[p getTitle]);
//            NSLog(@"dinner desc......%@",[p getDescription]);
//            NSLog(@"Date..%@",[p getEventDate]);
//            NSLog(@"Type..%@",[p getBoxType]);
//            NSLog(@"Latitude..%@",[p getLatitude]);
//            NSLog(@"Longitude..%@",[p getLongitude]);
//            NSLog(@"==Fine Dinner==");
//#endif   
            
//        }
        
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
    
    // Do any additional setup after loading the view from its nib.
    for (DoveSiButtaModel_Box *aResult in results)
	{
        
		//NSDictionary *resultLocation = [NSDictionary dictionaryWithObjectsAndKeys:[aResult getLatitude],@"latitude",[aResult getLongitude],@"longitude",[aResult getTitle],@"title", [aResult getDescription], @"description",[aResult getDinnerID], @"annotationid", nil];//  [aResult objectForKey:@"stationLocation"];
        //Per usare il Dictionary è necessario implementare 
        
        MapAnnotationDefault *resultAnnotation = [[MapAnnotationDefault alloc] init] ;
        resultAnnotation.item = aResult;
        [resultAnnotation retain];
        
        [mapView addAnnotation:resultAnnotation];
        
	}
    
}


#pragma mark - IBAction

-(void) addItem:(id)sender
{
    //TODO: inserire qui Reverse Geocode (?)
    
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

   
    CLLocationCoordinate2D location = mapView.userLocation.location.coordinate;
    NSLocale *locale = [NSLocale currentLocale];
    
    [newItem setLatitude:[NSDecimalNumber decimalNumberWithString:[[NSNumber numberWithFloat:location.latitude]  descriptionWithLocale:locale] locale:locale]];
    [newItem setLongitude:[NSDecimalNumber decimalNumberWithString:[[NSNumber numberWithFloat:location.longitude] descriptionWithLocale:locale] locale:locale] ];

    addVC.newItem = newItem;

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:addVC];
    
    [self presentModalViewController:navController animated:YES];
    [addVC release];
    [navController release];
}


#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

#if TARGET_IPHONE_SIMULATOR
        //Add button sempre, per testing
        UIBarButtonItem *addButton =
        [[[UIBarButtonItem alloc]
          initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
          target:self
          action:@selector(addItem:)]
         autorelease];
        self.navigationItem.rightBarButtonItem = addButton;

#else
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera ]) {
        //Add button solo se in presenza di camera (no vecchi iPod e iPad)
        UIBarButtonItem *addButton =
        [[[UIBarButtonItem alloc]
          initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
          target:self
          action:@selector(addItem:)]
         autorelease];
        self.navigationItem.rightBarButtonItem = addButton;
    }
    
#endif
    
    
    
    
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
    


    
    
    //Location
    //    self.locationManager = [[[CLLocationManager alloc] init] autorelease];
    //    self.locationManager.delegate = self;
    //    [self.locationManager startUpdatingLocation];
    //    [self.locationManager startUpdatingHeading]; // <label id="code.viewDidLoad02.heading"/>
    
    // Start the gpsLocation manager
	// We start it *after* startup so that the UI is ready to display errors, if needed.
	locationManager = [[CLLocationManager alloc] init];


    usingManualLocation = NO;    
    locationManager.delegate = self; 
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    [locationManager startUpdatingLocation];
    
#ifdef __IPHONE_5_0
    geocoder = [[CLGeocoder alloc] init];
       
#endif   
    
    /*
    mapView.delegate = self;
    mapView.showsUserLocation = YES;
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
     */

    
    self.title = NSLocalizedString(@"Cassonetti vicini a te", @"");
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    mapView = nil;
}

- (void)dealloc
{
    mapView.delegate = nil;
    [selectedResult release];
	[results release];
	
	[super dealloc];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
- (MKAnnotationView *)mapView:(MKMapView *)mv viewForAnnotation:(id <MKAnnotation>)annotation
{
    if([annotation isKindOfClass:[MKUserLocation class]])
        return nil; 
    
    NSString *annotationIdentifier = @"PinViewAnnotation"; 
    
    MKPinAnnotationView *pinView = (MKPinAnnotationView *) [mapView 
                                                            dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    
    
    if (!pinView) 
    {
        pinView = [[[MKPinAnnotationView alloc] 
                    initWithAnnotation:annotation 
                    reuseIdentifier:annotationIdentifier] autorelease];
        
        [pinView setPinColor:MKPinAnnotationColorGreen];
        pinView.animatesDrop = YES; 
        pinView.canShowCallout = YES; 
        
//        UIImageView *houseIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"house.png"]];
//        pinView.leftCalloutAccessoryView = houseIconView; 
//        [houseIconView release];        
        UIImageView *houseIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"house.png"]];
        [houseIconView setFrame:CGRectMake(0, 0, 30, 30)];
        pinView.leftCalloutAccessoryView = houseIconView; 
        [houseIconView release];        
 
    }
    else 
    {
        pinView.annotation = annotation;
    }
    
    return pinView; 
    
}
 */


/*
//http://www.highoncoding.com/Articles/804_Introduction_to_MapKit_Framework_for_iPhone_Development.aspx
- (void)mapView:(MKMapView *)mv didUpdateUserLocation:(MKUserLocation *)userLocation
{
        CLLocationCoordinate2D userCoordinate = userLocation.location.coordinate; 
    
    for(int i = 1; i<=5;i++) 
    {
        CGFloat latDelta = rand()*.035/RAND_MAX -.02;
        CGFloat longDelta = rand()*.03/RAND_MAX -.015;
        
        CLLocationCoordinate2D newCoord = { userCoordinate.latitude + latDelta, userCoordinate.longitude + longDelta };
        MapPoint *mp = [[MapPoint alloc] initWithCoordinate:newCoord title:[NSString stringWithFormat:@"Azam Home %d",i] subTitle:@"Home Sweet Home"];    
        [mv addAnnotation:mp]; 
        [mp release];
        
    }
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
    
    MKPinAnnotationView *newAnnotationPin = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"simpleAnnotation"] autorelease];
    if([selectedResult getBoxID] == [annotation annotationid])
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
    [dinnerIconView release];    
    
    newAnnotationPin.rightCalloutAccessoryView = rightButton;

    
    return newAnnotationPin;
}


- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    // we have received our current location, so enable the "Get Current Address" button
    NSLog(@"updated user location");
    
    //TODO: spostare qui il codice di didUpdateToLocation
}

#pragma mark -
#pragma mark Reverse Geocoder Delegate
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
    self.country = placemark.country;
    self.postCode = placemark.postalCode;
    self.address = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
    
    for(NSString *entry in self.comuniP2P)
    {
        NSArray *comune = [self.comuniP2P objectForKey:entry];
        if ([self.address rangeOfString:[comune objectAtIndex:0]].location != NSNotFound && [self.address rangeOfString:[comune objectAtIndex:1]].location != NSNotFound) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Attenzione", @"") message:NSLocalizedString(@"Il comune in cui ti trovi effettua la raccolta differenziata porta a porta!", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Ok, grazie", @"") otherButtonTitles: nil];
            [alert show];
        }
    }
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    HUD.labelText = @"Caricamento";
    [HUD show:YES];
    //        [self retrieveDinnersWithAddress:self.address];
    //        [self retrieveDinners];
    [self retrieveBoxesForType:self.selectedType];
    
    
    

//    if (reverseGeocoder != nil)
//    {
//        // release the existing reverse geocoder to stop it running
//        [reverseGeocoder release];
//    }
//    

}
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot obtain address."
														message:errorMessage
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}





# pragma mark - Location

/*
 //
 // qualifiedAddressStringForResultDictionary:
 //
 // Generate the fully qualified address string from a result dictionary
 //
 // Parameters:
 //    result - the result dictionary
 //
 // returns the address, location, WA, Australia.
 //
 + (NSString *)qualifiedAddressStringForResultDictionary:(NSDictionary *)result
 {
 return [NSString stringWithFormat:@"%@, %@, WA, Australia",
 [result objectForKey:@"address"],
 [result objectForKey:@"location"]];
 }
 */

/*
//
// locationFailedWithCode:
//
// Handle an error from the GPS
//
// Parameters:
//    errorCode - either an error from the gpsLocation manager or FVLocationFailedOutsideWA if gpsLocation
//		is not in Western Australia
//
- (void)locationFailedWithCode:(NSInteger)errorCode
{
	if (!gpsLocationFailed)
	{
		gpsLocationFailed = YES;
		
		//
		// Don't show an error or override the gpsLocation if we're using a manually
		// entered gpsLocation
		//
		if (usingManualLocation)
		{
			return;
		}
		
		//
		// Deliberately set our own GPS Location to Brescia
		//
		self.gpsLocation = CLLocationCoordinate2DMake(45.53576534999999, 10.21160257);
		
		NSMutableString *errorString = [NSMutableString string];
		switch (errorCode) 
		{
                //
                // We shouldn't ever get an unknown error code, but just in case...
                //
                //			case FVLocationFailedOutsideWA:
                //				[errorString appendString:NSLocalizedStringFromTable(@"The gpsLocation reported by the GPS is not in Western Australia.", @"ResultsView", @"Error detail")];
                //				break;
                //                
                //
                // This error code is usually returned whenever user taps "Don't Allow" in response to
                // being told your app wants to access the current gpsLocation. Once this happens, you cannot
                // attempt to get the gpsLocation again until the app has quit and relaunched.
                //
                // "Don't Allow" on two successive app launches is the same as saying "never allow". The user
                // can reset this for all apps by going to Settings > General > Reset > Reset Location Warnings.
                //
			case kCLErrorDenied:
				[errorString appendString:NSLocalizedStringFromTable(@"Location from GPS denied.", @"ResultsView", nil)];
				break;
                
                //
                // This error code is usually returned whenever the device has no data or WiFi connectivity,
                // or when the gpsLocation cannot be determined for some other reason.
                //
                // CoreLocation will keep trying, so you can keep waiting, or prompt the user.
                //
			case kCLErrorLocationUnknown:
				[errorString appendString:NSLocalizedStringFromTable(@"Location from GPS reported error.", @"ResultsView", nil)];
				break;
                //
                // We shouldn't ever get an unknown error code, but just in case...
                //
			default:
				[errorString appendString:NSLocalizedStringFromTable(@"Location from GPS failed.", @"ResultsView", nil)];
				break;
		}
		
		[errorString appendString:NSLocalizedStringFromTable(@"È stata impostata una posizione di default.", @"ResultsView", nil)];
		
		//
		// Present the error dialog
		//
		UIAlertView *alert =
        [[UIAlertView alloc]
         initWithTitle:NSLocalizedStringFromTable(@"Errore GPS", @"ResultsView", nil)
         message:errorString
         delegate:self
         cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"ResultsView", @"Chiudi.")
         otherButtonTitles: nil];
		[alert show];    
		[alert release];
        
        //Imposto che stiamo usando location manualmente
        self.usingManualLocation = YES;
        
	}
}
*/


//
// locationManager:didFailWithError:
//
// Handle an error from the gpsLocation manager by calling the locationFailed
// method
//
// Parameters:
//    manager - the gpsLocation manager
//    error - the error assocated with this notification
//
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
//    [self locationFailedWithCode:[error code]];
    if ([error domain] == kCLErrorDomain) {
        
        // We handle CoreLocation-related errors here
        switch ([error code]) {
                // "Don't Allow" on two successive app launches is the same as saying "never allow". The user
                // can reset this for all apps by going to Settings > General > Reset > Reset Location Warnings.
            case kCLErrorDenied:
                self.usingManualLocation = YES; 
                
            case kCLErrorLocationUnknown:
                self.usingManualLocation = YES; 
                
            default:
                break;
        }
        
    } else {
        // We handle all non-CoreLocation errors here
        NSLog(@"Errore Sconosciuto");
    }
    
}

/*
 //
 // setGpsLocation:
 //
 // When the gpsLocation changes, refresh the page at the new gpsLocation
 //
 // Parameters:
 //    newLocation - gpsLocation to apply
 //
 - (void)setGpsLocation:(CLLocationCoordinate2D)newGpsLocation
 {
 //TODO: questa funzione va rivista
 //	gpsLocation = newGpsLocation;
 //	
 //	if (usingManualLocation)
 //	{
 //		return;
 //	}
 //	
 //	if (!CLLocationCoordinate2DIsValid(gpsLocation))
 //	{
 //		self.location = nil;
 //		return;
 //	}
 //	
 //	self.location =
 //    [[PostcodesController sharedPostcodesController]
 //     postcodeClosestToLocation:gpsLocation];
 }
 */



//
// locationManager:didUpdateToLocation:fromLocation:
//
// Receives gpsLocation updates
//
// Parameters:
//    manager - our gpsLocation manager
//    newLocation - the new gpsLocation
//    oldLocation - gpsLocation previously reported
//
 - (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([newLocation coordinate] ,1000,1000);        
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:region];  
    [mapView setRegion:adjustedRegion animated:YES];
    self.buttonLat.title = [NSString stringWithFormat:@"Lat %.3f", newLocation.coordinate.latitude];
    self.buttonLon.title = [NSString stringWithFormat:@"Lon %.3f", newLocation.coordinate.longitude];
    
    
    
//    gpsLocationFailed = NO;
    self.usingManualLocation = NO;
    self.gpsLocation = newLocation.coordinate;
    [locationManager stopUpdatingLocation]; //TODO: ok ma quando la faccio ripartire ? 
#ifdef __IPHONE_5_0

    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
    CLPlacemark *placemark = [placemarks objectAtIndex:0];
    self.country = placemark.country;
    self.postCode = placemark.postalCode;
    self.address = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
//    NSLog(@"Address: %@, postcode %@, country %@", self.address, self.postCode, self.country);
//    NSLog(@"Address of placemark: %@", ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO));
//    NSLog(@"street::::%@",[placemark thoroughfare]); //Via 
//    NSLog(@"street number::::%@",[placemark subThoroughfare]); //num civico
//    NSLog(@"postalcode %@", [placemark postalCode]);
//    NSLog(@"sublocality %@", [placemark subLocality]);  //Brescia
//    NSLog(@"locality %@", [placemark locality]); //Brescia
//    NSLog(@"administrative area::::%@",[placemark administrativeArea]); //Lombardy
//    
//    NSLog(@"streeteersub ::::%@",[placemark subAdministrativeArea]); //Province of Brescia
        
        for(NSString *entry in self.comuniP2P)
        {
            NSArray *comune = [self.comuniP2P objectForKey:entry];
            if ([self.address rangeOfString:[comune objectAtIndex:0]].location != NSNotFound && [[placemark subAdministrativeArea] rangeOfString:[comune objectAtIndex:1]].location != NSNotFound) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Attenzione", @"") message:NSLocalizedString(@"Il comune in cui ti trovi effettua la raccolta differenziata porta a porta!", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Ok, grazie", @"") otherButtonTitles: nil];
                [alert show];
            }
        }
        
        HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        HUD.delegate = self;
        HUD.labelText = @"Caricamento";
        [HUD show:YES];
        [self retrieveBoxesForType:self.selectedType];

    }];


#else

    CLLocationCoordinate2D locationToLookup = newLocation.coordinate;
    MKReverseGeocoder *reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:locationToLookup];
    reverseGeocoder.delegate = self;
    [reverseGeocoder start];

#endif
    
        
 }
 



@end
