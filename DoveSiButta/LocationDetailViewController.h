//
//  LocationDetailViewController.h
//  NerdDinner
//
//  Created by Giovanni Maggini on 10/01/12.
//  Copyright (c) 2012 Giovanni Maggini. All rights reserved.
//

#import "PageViewController.h"
#import "NerdDinnerEntities.h"

@interface LocationDetailViewController : PageViewController

@property (nonatomic, retain) NerdDinnerModel_Dinner *selectedDinner;

- (id)initWithDinner:(NerdDinnerModel_Dinner*)dinner;
- (void)addRSVP:(id)sender;;

@end
