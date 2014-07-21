//
//  SaveLocationViewController.h
//  GTL
//
//  Created by Akhil Nambiar on 7/17/14.
//
//

#import <UIKit/UIKit.h>
#import "GTMOAuth2Authentication.h"
#import "GTLDrive.h"

@interface SaveLocationViewController : UIViewController

@property (strong, nonatomic) GTLServiceDrive *driveService;
@property (strong, nonatomic) GTLDriveFile *driveFile;
@property BOOL withHandout;

@end
