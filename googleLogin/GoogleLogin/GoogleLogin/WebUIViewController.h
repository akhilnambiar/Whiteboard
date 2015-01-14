//
//  WebUIViewController.h
//  GoogleLogin
//
//  Created by Akhil Nambiar on 6/1/14.
//  Copyright (c) 2014 Akhil Nambiar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleOAuth.h"

@interface WebUIViewController : UIViewController<GoogleOAuthDelegate>

- (IBAction)showProfile:(id)sender;
- (IBAction)revokeAccess:(id)sender;

@end
