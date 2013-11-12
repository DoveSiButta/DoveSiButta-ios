//
//  TextViewViewController.h
//  DoveSiButta
//
//  Created by Giovanni on 11/7/13.
//  Copyright (c) 2013 Giovanni Maggini. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TextViewViewController;

@protocol TextViewViewControllerDelegate <NSObject>
- (void)textViewVCDidFinishWithText:(NSString *)text;
@end

@interface TextViewViewController : UIViewController

@property (nonatomic, strong) NSString *textViewText;
@property (nonatomic, strong) id <TextViewViewControllerDelegate> delegate;

@end


