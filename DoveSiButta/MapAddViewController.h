//
//  MapAddViewController.h
//  DoveSiButta
//
//  Created by Giovanni Maggini on 20/02/12.
//  Copyright (c) 2012 Giovanni Maggini. All rights reserved.
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

@interface MapAddViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, MBProgressHUDDelegate,MKReverseGeocoderDelegate, UIAlertViewDelegate, LocationAddViewControllerDelegate>
{
    NSMutableArray *results;
    DoveSiButtaModel_Box *selectedResult;
    
    //for debug.
    NSDictionary *comuniP2P;
    
    NSString* selectedType;
    
    //HUD
    MBProgressHUD *HUD;
    
    //For location
    CLLocationManager *locationManager;
	CLLocationCoordinate2D gpsLocation;
    //	BOOL gpsLocationFailed;
    //	BOOL usingManualLocation;
}


//MapView
@property (nonatomic, retain) IBOutlet MKMapView *mapView;

//data source - > use results
//@property (nonatomic, retain) NSArray *listContent;

//UI
@property (nonatomic,retain) IBOutlet UIBarButtonItem *buttonLat;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *buttonLon;
@property (nonatomic,retain) NSDictionary *iconsDictionary;
@property (nonatomic,retain) UIBarButtonItem *buttonAdd;
@property (nonatomic,retain) UIBarButtonItem *buttonRefresh;

//For comuni raccolta p2p
@property (nonatomic, retain) NSDictionary *comuniP2P;

//For managing rifiuti types
@property (nonatomic, retain) NSString* selectedType;

//For location
//@property (nonatomic, assign) BOOL usingManualLocation;
//@property (nonatomic, assign) CLLocationCoordinate2D gpsLocation;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSString *postCode;
@property (nonatomic, retain) NSString *country;

@property (nonatomic, retain) CLLocationManager *locationManager;

-(void) getLocation;




@end
