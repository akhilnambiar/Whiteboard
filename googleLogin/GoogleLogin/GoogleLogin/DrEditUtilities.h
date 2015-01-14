//
//  DrEditUtilities.h
//  GoogleLogin
//
//  Created by Akhil Nambiar on 6/23/14.
//  Copyright (c) 2014 Akhil Nambiar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DrEditUtilities : NSObject
+ (UIAlertView *)showLoadingMessageWithTitle:(NSString *)title
                                    delegate:(id)delegate;
+ (void)showErrorMessageWithTitle:(NSString *)title
                          message:(NSString *)message
                         delegate:(id)delegate;
@end