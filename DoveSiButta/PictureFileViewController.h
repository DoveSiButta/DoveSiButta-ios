//
//  PictureFileViewController.h
//  DoveSiButta
//
//  Created by Giovanni Maggini on 22/01/12.
//  Copyright (c) 2012 Giovanni Maggini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"


@interface PictureFileViewController : UIViewController <MBProgressHUDDelegate>
{
    MBProgressHUD *HUD;
}
@property (strong, nonatomic) NSNumber* selectedItem;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end
