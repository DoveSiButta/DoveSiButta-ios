//
//  LocationAddViewController.h
//  DoveSiButta
//
//  Created by Giovanni Maggini on 15/01/12.
//  Copyright (c) 2012 Giovanni Maggini. All rights reserved.
//

#import "PageViewController.h"
#import "SVProgressHUD.h"
//Service
#import "DoveSiButtaEntities.h"
#import "TextViewViewController.h"


@protocol LocationAddViewControllerDelegate
- (void)addLocationDidFinishWithCode:(int)finishCode;
@end

@interface LocationAddViewController : PageViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, TextViewViewControllerDelegate>
{
    id <LocationAddViewControllerDelegate>  delegate;
}

@property (strong, nonatomic) DoveSiButtaModel_Box *myNewItem;
@property (strong, nonatomic) NSString* pictureFile; //se non c'è la foto, non posso procedere!
@property (strong, nonatomic) NSMutableArray* selectedTypes;
@property (strong, nonatomic) NSMutableSet* setTypes;

@property (nonatomic, strong) id <LocationAddViewControllerDelegate> delegate;

@end
