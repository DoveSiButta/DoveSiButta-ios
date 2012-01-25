//
//  LocationAddViewController.h
//  DoveSiButta
//
//  Created by Giovanni Maggini on 15/01/12.
//  Copyright (c) 2012 Giovanni Maggini. All rights reserved.
//

#import "PageViewController.h"
#import "MBProgressHUD.h"
//Service
#import "NerdDinnerEntities.h"


@interface LocationAddViewController : PageViewController <MBProgressHUDDelegate>

@property (nonatomic, retain) NerdDinnerModel_Dinner *newItem;
@property (nonatomic, retain) NSString* pictureFile; //se non c'è la foto, non posso procedere!



@end
