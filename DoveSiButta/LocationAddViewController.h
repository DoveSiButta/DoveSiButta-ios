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
#import "DoveSiButtaEntities.h"


@interface LocationAddViewController : PageViewController <MBProgressHUDDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>
{
    MBProgressHUD *HUD;
}

@property (nonatomic, retain) DoveSiButtaModel_Box *newItem;
@property (nonatomic, retain) NSString* pictureFile; //se non c'è la foto, non posso procedere!
@property (nonatomic, retain) NSMutableArray* selectedTypes;
@property (nonatomic, retain) NSMutableSet* setTypes;

//- (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSizeWithSameAspectRatio:(CGSize)targetSize;


@end
