//
//  InvitesViewController.h
//  ClassBoard
//
//  Created by Akhil Nambiar on 7/20/14.
//  Copyright (c) 2014 Akhil Nambiar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLDrive.h"
@interface InvitesViewController : UIViewController
@property (nonatomic, retain) GTLServiceDrive *driveService;
@property (weak, nonatomic) NSDictionary *userData;
@property NSString* userId;
@end
