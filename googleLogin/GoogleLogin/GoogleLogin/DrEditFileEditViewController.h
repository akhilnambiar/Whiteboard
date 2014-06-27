//
//  DrEditFileEditViewController.h
//  GoogleLogin
//
//  Created by Akhil Nambiar on 6/22/14.
//  Copyright (c) 2014 Akhil Nambiar. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GTLDrive.h"

#import "DrEditFileEditDelegate.h"

@interface DrEditFileEditViewController : UIViewController <UITextViewDelegate, UIAlertViewDelegate>
@property GTLServiceDrive *driveService;
@property GTLDriveFile *driveFile;
@property id<DrEditFileEditDelegate> delegate;
@property NSInteger fileIndex;
@end