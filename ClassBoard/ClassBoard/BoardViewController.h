//
//  BoardViewController.h
//  Board
//
//  Created by Akhil Nambiar on 4/3/14.
//  Copyright (c) 2014 Akhil Nambiar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRWebSocket.h"
#import "SmoothedBIView.h"
#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "GTLDrive.h"



@interface BoardViewController : UIViewController <SRWebSocketDelegate,boardViewDelegate,UIAlertViewDelegate>

@property (nonatomic, retain) GTLServiceDrive *driveService;
@property GTLDriveFile *driveFile;
@property NSString *fileTitle;
@property BOOL withHandout;
@property (weak, nonatomic) NSDictionary *userData;

@end
