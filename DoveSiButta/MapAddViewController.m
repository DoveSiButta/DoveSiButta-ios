//
//  MapAddViewController.m
//  DoveSiButta
//
//  Created by Giovanni Maggini on 20/02/12.
//  Copyright (c) 2012 Giovanni Maggini. All rights reserved.
//

#import "MapAddViewController.h"
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

@interface MapAddViewController ()

@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) MKReverseGeocoder* reverseGeocoder;
@property (nonatomic, strong) NSMutableArray* results;
@property (nonatomic, strong) DoveSiButtaModel_Box *selectedResult;

@end

@implementation MapAddViewController
@synthesize mapView;
@synthesize buttonLat, buttonLon;
@synthesize iconsDictionary;
@synthesize selectedType;
@synthesize address, postCode, country;
@synthesize comuniP2P;
@synthesize buttonAdd, buttonRefresh;
@synthesize locationManager;

@synthesize HUD;
@synthesize reverseGeocoder;
@synthesize results;
@synthesize selectedResult;


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
        self.title = NSLocalizedString(@"Segnala", @"");
        self.tabBarItem.image = [UIImage imageNamed:@"07-map-marker"];
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //TODO: mettere qui un refresh (ho messo getLocation: andrà bene?)
    
    [self getLocation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
#if TARGET_IPHONE_SIMULATOR
    //Add button sempre, per testing
    buttonAdd = [[UIBarButtonItem alloc]
                  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                  target:self
                  action:@selector(addItem:)];
    self.navigationItem.rightBarButtonItem = buttonAdd;
    
#else
    //TODO: avvisare l'utente! Con un messaggio e un'icona di assenza della camera.
    //E nel caso di un iPad con camera ma senza GPS ?!?!?!
    UIDeviceHardware *h=[[UIDeviceHardware alloc] init];
//    [self setDeviceModel:[h platformString]];   
    NSLog(@"DeviceModel: %@", [h platformString]);

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
        //Add button solo se in presenza di camera (no vecchi iPod e iPad)
        self.buttonRefresh =
        [[UIBarButtonItem alloc]
          initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
          target:self
          action:@selector(refresh:)];
        self.navigationItem.leftBarButtonItem = self.buttonRefresh;
 
    
    

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

    
   }

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(void)getLocation
{
    //TODO: check if we can use GPS!!!!!!!!

    [self.buttonRefresh setEnabled:NO];
    
    // Start the gpsLocation manager
	// We start it *after* startup so that the UI is ready to display errors, if needed.
    self.locationManager = nil;
    //TODO: e se l'utente ci ha impedito di usare la location?!?!?!
//    http://developer.apple.com/library/ios/#documentation/CoreLocation/Reference/CLLocationManager_Class/CLLocationManager/CLLocationManager.html#//apple_ref/occ/clm/CLLocationManager/authorizationStatus
	self.locationManager = [[CLLocationManager alloc] init];

    //    usingManualLocation = NO;    
    self.locationManager.delegate = self; 
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.purpose = NSLocalizedString(@"Trovare il cassonetto più vicino", @"");
    [self.locationManager startUpdatingLocation];
    


}


#pragma Mark Data

-(void) retrieveBoxesForType:(NSString*)searchType
{
    @try{
        
#if DEBUG
        NSLog(@"retriving boxes....");
#endif
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *serviceURI= [defaults objectForKey:@"serviceURI"];
        DoveSiButtaEntities *proxy=[[DoveSiButtaEntities alloc]initWithUri:serviceURI credential:nil];
        
        //        DataServiceQuery *query = [proxy boxes];
        //        QueryOperationResponse *response = [query execute];
        results = [[NSMutableArray alloc] init ];
        //        
        CLLocationCoordinate2D location = self.locationManager.location.coordinate;
        NSLocale *locale = [NSLocale currentLocale];
        
        //        results = [proxy ItemsNearMeByCoordinatesWithlatitude:[NSDecimalNumber decimalNumberWithString:[[NSNumber numberWithFloat:location.latitude ]  descriptionWithLocale:locale] locale:locale] longitude:self.[NSDecimalNumber decimalNumberWithString:[[NSNumber numberWithFloat:location.longitude ]  descriptionWithLocale:locale] locale:locale]];
        NSArray *resultArr = [proxy ItemsNearMeByCoordinatesWithlatitude:[NSDecimalNumber decimalNumberWithString:[[NSNumber numberWithFloat:location.latitude ]  descriptionWithLocale:locale] locale:locale] longitude:[NSDecimalNumber decimalNumberWithString:[[NSNumber numberWithFloat:location.longitude ]  descriptionWithLocale:locale] locale:locale]];
        //[[response getResult] retain];
        
        for (int i =0;i<[resultArr count]; i++) {
            
            DoveSiButtaModel_Box *p = [resultArr objectAtIndex:i];
//            if ([[p getBoxType] rangeOfString:self.selectedType].location != NSNotFound) //TODO: andrebbe filtrato nella query
//            {
                [self.results addObject:p];
//            }
            
            //TODO: se non c'è nessun cestino, visualizzare il messaggio "come mai non c'è nessun cestino?" e quindi spiegare come funziona la app
            
            
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
    
    
    self.HUD.labelText = [NSString stringWithFormat: @"Completato"];
    [self.HUD hide:YES afterDelay:1];
    
    [self.mapView removeAnnotations:self.mapView.annotations];  // remove any annotations that exist
    for (DoveSiButtaModel_Box *aResult in results)
	{
        
        MapAnnotationDefault *resultAnnotation = [[MapAnnotationDefault alloc] init] ;
        resultAnnotation.item = aResult;
        
        [mapView addAnnotation:resultAnnotation];
        
	}
    
        //At last we enable buttons
    [buttonAdd setEnabled:YES];
    [self.buttonRefresh setEnabled:YES];
    
    //Show user location
    [self.mapView setShowsUserLocation:YES];
    
}



#pragma mark - IBAction

-(void) addItem:(id)sender
{
    [self startReverseGeocode];
}

-(void) startReverseGeocode
{
    CLLocationCoordinate2D locationToLookup = self.locationManager.location.coordinate;
    self.reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:locationToLookup];
    self.reverseGeocoder.delegate = self;
    [self.reverseGeocoder start];
}

- (void)addLocationDidFinishWithCode:(int)finishCode
{
    if(finishCode == 0)
    {
//        [self retrieveBoxesForType:self.selectedType];
    }
    else {
        
    }
}


-(void) refresh:(id)sender
{
    [self getLocation];
}


#pragma mark AlertView Delegate Methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == ALERTVIEW_GEOCODEFAIL) {
        switch (buttonIndex) {
            case 1:
                [self startReverseGeocode];
                break;
                
            default:
                break;
        }
    }
    else if(alertView.tag == ALERTVIEW_LOCATIONFORBIDDEN)
    {
        switch (buttonIndex) {
            case 1:
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"]];
                //            // A system version of 3.1 or greater is required to use CADisplayLink. The NSTimer
                //            // class is used as fallback when it isn't available.
                //            NSString *reqSysVer = @"5.0";
                //            NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
                //            if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
                //            {
                //               [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"]];
                //            }
                //            else {
                //                NSURL*url=[NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"];
                //                [[UIApplication sharedApplication] openURL:url];
                //            }
            }
                break;
                
            default:
                break;
        }

    }
}

#pragma mark Map View Delegate Methods

- (void)showDetails:(id)sender forAnnotation:(MKAnnotationView <GMAnnotation> *)annotation
{
    // the detail view does not want a toolbar so hide it
    LocationDetailViewController *detailvc = [[LocationDetailViewController alloc] initWithItem:[annotation dinner]];
    [self.navigationController pushViewController:detailvc animated:YES];
}

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


- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    NSLog(@"MapView updated userLocation");
    //    NSLog(@"updated user location: %f %f", userLocation.coordinate.latitude, userLocation.coordinate.longitude);
    //    if((roundf(userLocation.coordinate.latitude) != 0.0f && roundf(userLocation.coordinate.longitude) != 0.0f ) && self.boxesLoaded == NO )
    //    {
    //        // we have received our current location, so enable the "Get Current Address" button
    //        
    //        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([userLocation coordinate] ,1000,1000);        
    //        MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:region];  
    //        [self.mapView setRegion:adjustedRegion animated:YES];
    //        self.buttonLat.title = [NSString stringWithFormat:@"Lat %.3f", userLocation.coordinate.latitude];
    //        self.buttonLon.title = [NSString stringWithFormat:@"Lon %.3f", userLocation.coordinate.longitude];
    //  
    //        HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    //        [self.navigationController.view addSubview:HUD];
    //        HUD.delegate = self;
    //        HUD.labelText = @"Caricamento";
    //        [HUD show:YES];
    //
    //        [self retrieveBoxesForType:self.selectedType];
    //        
    //        
    //        [buttonAdd setEnabled:YES];
    //        
    //    }
}

#pragma mark -
#pragma mark Reverse Geocoder Delegate
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
    self.country = placemark.country;
    self.postCode = placemark.postalCode;
    self.address = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
    
    //TODO: se la country != Italy --- > non abilitare il tasto "aggiungi" !!!
    
    
    //TODO: dove metto la segnalazione del comune raccolta P2P ? E rifare questo codice
//    for(NSString *entry in self.comuniP2P)
//    {
//        NSArray *comune = [self.comuniP2P objectForKey:entry];
//        if ([self.address rangeOfString:[comune objectAtIndex:0]].location != NSNotFound && [self.address rangeOfString:[comune objectAtIndex:1]].location != NSNotFound) {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Attenzione", @"") message:NSLocalizedString(@"Il comune in cui ti trovi effettua la raccolta differenziata porta a porta!", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Ok, grazie", @"") otherButtonTitles: nil];
//            [alert setTag:ALERTVIEW_COMUNEP2P];
//            [alert show];
//        }
//    }
    
    
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
    
    
    CLLocationCoordinate2D location = self.locationManager.location.coordinate;
    NSLocale *locale = [NSLocale currentLocale];
    
    [newItem setLatitude:[NSDecimalNumber decimalNumberWithString:[[NSNumber numberWithFloat:location.latitude]  descriptionWithLocale:locale] locale:locale]];
    [newItem setLongitude:[NSDecimalNumber decimalNumberWithString:[[NSNumber numberWithFloat:location.longitude] descriptionWithLocale:locale] locale:locale] ];
    
    addVC.myNewItem = newItem;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:addVC];
    
    [self presentModalViewController:navController animated:YES];
    [addVC setDelegate:self];
    
    
}
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Avviso", nil) message:errorMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:NSLocalizedString(@"Riprova", nil),nil];
    [alertView setTag:ALERTVIEW_GEOCODEFAIL];
    [alertView show];
}


# pragma mark - Location



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
            {
                UIAlertView *a = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Attenzione", @"") message:NSLocalizedString(@"REQUIRES_POSITION", @"") delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                a.tag = ALERTVIEW_LOCATIONFORBIDDEN; 
                [a show];
                [self.navigationController popViewControllerAnimated:YES];
                
            }
                break;
            case kCLErrorLocationUnknown:
                //                self.usingManualLocation = YES; 
                break;
            default:
                break;
        }
        
    } else {
        // We handle all non-CoreLocation errors here
        NSLog(@"Errore Sconosciuto");
    }
    
}


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
    if(newLocation.horizontalAccuracy < 0 ) return;
    
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) return;
    
    NSLog(@"updated user location: %f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    if( newLocation.horizontalAccuracy >= self.locationManager.desiredAccuracy ) //TODO: MORE WORK HERE
    {
#if DEBUG
        NSLog(@"Stop updating location");  
#endif
        // we have received our current location, so enable the "Get Current Address" button
        [self.locationManager stopUpdatingLocation];
//        [locationManager stopUpdatingLocation];
        self.locationManager.delegate = nil;
//        locationManager.delegate = nil;
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([newLocation coordinate] ,1000,1000);        
        MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:region];  
        [self.mapView setRegion:adjustedRegion animated:YES];
        self.buttonLat.title = [NSString stringWithFormat:@"Lat %.3f", newLocation.coordinate.latitude];
        self.buttonLon.title = [NSString stringWithFormat:@"Lon %.3f", newLocation.coordinate.longitude];
        
        
        
        //    gpsLocationFailed = NO;
        //    self.usingManualLocation = NO;
        //    self.gpsLocation = userLocation.coordinate;
        //        [self.locationManager stopUpdatingLocation]; //TODO: ok ma quando la faccio ripartire ? 
        
        
        //#ifdef __IPHONE_5_0
        //    
        //    [geocoder reverseGeocodeLocation:userLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        //        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        //        self.country = placemark.country;
        //        self.postCode = placemark.postalCode;
        //        self.address = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
        //        //    NSLog(@"Address: %@, postcode %@, country %@", self.address, self.postCode, self.country);
        //        //    NSLog(@"Address of placemark: %@", ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO));
        //        //    NSLog(@"street::::%@",[placemark thoroughfare]); //Via 
        //        //    NSLog(@"street number::::%@",[placemark subThoroughfare]); //num civico
        //        //    NSLog(@"postalcode %@", [placemark postalCode]);
        //        //    NSLog(@"sublocality %@", [placemark subLocality]);  //Brescia
        //        //    NSLog(@"locality %@", [placemark locality]); //Brescia
        //        //    NSLog(@"administrative area::::%@",[placemark administrativeArea]); //Lombardy
        //        //    
        //        //    NSLog(@"streeteersub ::::%@",[placemark subAdministrativeArea]); //Province of Brescia
        //        
        //        for(NSString *entry in self.comuniP2P)
        //        {
        //            NSArray *comune = [self.comuniP2P objectForKey:entry];
        //            if ([self.address rangeOfString:[comune objectAtIndex:0]].location != NSNotFound && [[placemark subAdministrativeArea] rangeOfString:[comune objectAtIndex:1]].location != NSNotFound) {
        //                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Attenzione", @"") message:NSLocalizedString(@"Il comune in cui ti trovi effettua la raccolta differenziata porta a porta!", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Ok, grazie", @"") otherButtonTitles: nil];
        //                [alert show];
        //            }
        //        }
        //        
        //        HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        //        [self.navigationController.view addSubview:HUD];
        //        HUD.delegate = self;
        //        HUD.labelText = @"Caricamento";
        //        [HUD show:YES];
        //        [self retrieveBoxesForType:self.selectedType];
        //        
        //    }];
        //    
        //    
        //#else
        
        HUD = [[MBProgressHUD alloc] initWithView:self.mapView];
        [self.mapView addSubview:HUD];
        HUD.delegate = self;
        HUD.labelText = NSLocalizedString(@"Caricamento", @"");
        [HUD show:YES];
        [self retrieveBoxesForType:self.selectedType];

    }
    
}






@end
