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
//#import "NerdDinnerEntities.h"
#import "DoveSiButtaEntities.h"


@interface LocationAddViewController : PageViewController <MBProgressHUDDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, retain) DoveSiButtaModel_Box *newItem;
@property (nonatomic, retain) NSString* pictureFile; //se non c'è la foto, non posso procedere!


//- (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSizeWithSameAspectRatio:(CGSize)targetSize;


@end
