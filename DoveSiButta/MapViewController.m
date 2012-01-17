//
//  MapViewController.m
//  NerdDinner
//
//  Created by Giovanni Maggini on 22/12/11.
//  Copyright (c) 2011 Giovanni Maggini. All rights reserved.
//

#import "MapViewController.h"
#import "MapAnnotationDefault.h"
#import "LocationDetailViewController.h"


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

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

- (id)initWithSelectedResult:(NerdDinnerModel_Dinner *)aResult
                  allResults:(NSArray *)allResults{
    self = [super initWithNibName:@"MapViewController" bundle:[NSBundle mainBundle]];
    if (self) {
        selectedResult = [aResult retain];
		results = [allResults retain];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    if([self.iconsDictionary count] < 1)
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"IconForType" ofType:@"plist"];
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:path];
        NSString *errorDesc = nil;
        NSPropertyListFormat format;
        
        // convert static property list into dictionary object
        NSDictionary *plistDictionary = (NSDictionary *)[NSPropertyListSerialization propertyListFromData:plistXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorDesc];
        if (!plistDictionary) 
        {
            NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
        }
        self.iconsDictionary = plistDictionary;

    }
    /*
    mapView.delegate = self;
    mapView.showsUserLocation = YES;
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
     */

//    
//    for (id<MKAnnotation> annotation in mapView.annotations) {
//        [mapView removeAnnotation:annotation];
//    }
    
    self.title = [selectedResult getTitle];
    self.buttonLat.title = [NSString stringWithFormat:@"Lat %.3f", [[selectedResult getLatitude] floatValue]];
    self.buttonLon.title = [NSString stringWithFormat:@"Lon %.3f", [[selectedResult getLongitude] floatValue]];
    
    // Do any additional setup after loading the view from its nib.
    for (NerdDinnerModel_Dinner *aResult in results)
	{
       
		//NSDictionary *resultLocation = [NSDictionary dictionaryWithObjectsAndKeys:[aResult getLatitude],@"latitude",[aResult getLongitude],@"longitude",[aResult getTitle],@"title", [aResult getDescription], @"description",[aResult getDinnerID], @"annotationid", nil];//  [aResult objectForKey:@"stationLocation"];
        //Per usare il Dictionary è necessario implementare 
        
        MapAnnotationDefault *resultAnnotation = [[MapAnnotationDefault alloc] init] ;
        resultAnnotation.dinner = aResult;
        [resultAnnotation retain];

        [mapView addAnnotation:resultAnnotation];
         
        if([aResult getDinnerID] == [selectedResult getDinnerID])
        {
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([resultAnnotation coordinate] ,1000,1000);        
            MKCoordinateRegion adjustedRegion = [mapView regionThatFits:region];  
            [mapView setRegion:adjustedRegion animated:YES];
        }
//		if (resultLocation)
//		{
//			[mapView addAnnotation:(id<MKAnnotation>)resultLocation];
//            NSLog(@"Aggiunto annotazione %@", resultLocation);
//		}
	}
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
    LocationDetailViewController *detailvc = [[LocationDetailViewController alloc] initWithDinner:[annotation dinner]];
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

///
///
//TODO: update map when moved or zoomed. Do not reload mapview everytime!
///
///


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
    LocationDetailViewController *ldvc = [[LocationDetailViewController alloc] initWithDinner:myAnnotation.dinner];
    //[myAnnotation loadDetailView];
    [self.navigationController pushViewController:ldvc animated:YES];
    
}


- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <GMAnnotation>)annotation
{
    
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    MKPinAnnotationView *newAnnotationPin = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"simpleAnnotation"] autorelease];
    if([selectedResult getDinnerID] == [annotation annotationid])
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


@end
