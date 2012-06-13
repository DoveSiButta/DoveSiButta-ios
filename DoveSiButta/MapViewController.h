//
//  MapViewController.h
//  DoveSiButta
//
//  Created by Giovanni Maggini on 22/12/11.
//  Copyright (c) 2011 Giovanni Maggini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "DoveSiButtaEntities.h"

//HUD
#import "MBProgressHUD.h"

//For reverse geocoder to get address string correctly
#import <AddressBookUI/AddressBookUI.h>

//For adding
#import "LocationAddViewController.h"


//#ifdef __IPHONE_5_0
//@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, MBProgressHUDDelegate, UIAlertViewDelegate> 
//#else
@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, MBProgressHUDDelegate,MKReverseGeocoderDelegate, UIAlertViewDelegate, LocationAddViewControllerDelegate>
//#endif

{
//    MKMapView * mapView;
//    NSMutableArray *results;
//    DoveSiButtaModel_Box *selectedResult;
//
//    //for debug.
//    NSDictionary * comuniP2P;
//    
//    
////    NSString*  selectedType;
//    
//    //HUD
////    MBProgressHUD *HUD;
//
//    //For location
//    CLLocationManager * locationManager;
//	CLLocationCoordinate2D gpsLocation;
//	BOOL gpsLocationFailed;
//	BOOL usingManualLocation;
//#ifdef __IPHONE_5_0
//    CLGeocoder *geocoder; //!!!! iOS5.0
//#endif
    
}

//MapView
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

//data source - > use results
//@property (nonatomic, retain) NSArray *listContent;

//UI
@property (strong, nonatomic) IBOutlet UIBarButtonItem *buttonLat;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *buttonLon;
@property (strong, nonatomic) NSDictionary *iconsDictionary;
@property (nonatomic) UIBarButtonItem *buttonAdd;

//For comuni raccolta p2p
@property (strong, nonatomic) NSDictionary *comuniP2P;

//For managing rifiuti types
@property (strong, nonatomic) NSString* selectedType;

//For location
//@property (nonatomic, assign) BOOL usingManualLocation;
//@property (nonatomic, assign) CLLocationCoordinate2D gpsLocation;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *postCode;
@property (strong, nonatomic) NSString *country;

@property (strong, nonatomic) CLLocationManager *locationManager;





@end
