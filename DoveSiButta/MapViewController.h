//
//  MapViewController.h
//  NerdDinner
//
//  Created by Giovanni Maggini on 22/12/11.
//  Copyright (c) 2011 Giovanni Maggini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "NerdDinnerEntities.h"


@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>
{
    MKMapView *mapView;
    NSArray *results;
    NerdDinnerModel_Dinner *selectedResult;
    CLLocationManager *locationManager;

    //Icons
    

}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;

- (id)initWithSelectedResult:(NerdDinnerModel_Dinner *)aResult
                  allResults:(NSArray *)allResults;

@property (nonatomic,retain) IBOutlet UIBarButtonItem *buttonLat;
@property (nonatomic,retain) IBOutlet UIBarButtonItem *buttonLon;
@property (nonatomic,retain) NSDictionary *iconsDictionary;
@end
