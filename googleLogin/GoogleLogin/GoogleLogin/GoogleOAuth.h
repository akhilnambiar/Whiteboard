//
//  GoogleOAuth.h
//  GoogleLogin
//
//  Created by Akhil Nambiar on 6/2/14.
//  Copyright (c) 2014 Akhil Nambiar. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    httpMethod_GET,
    httpMethod_POST,
    httpMethod_DELETE,
    httpMethod_PUT
} HTTP_Method;

@protocol GoogleOAuthDelegate
-(void)authorizationWasSuccessful;
-(void)accessTokenWasRevoked;
-(void)responseFromServiceWasReceived:(NSString *)responseJSONAsString andResponseJSONAsData:(NSData *)responseJSONAsData;
-(void)errorOccuredWithShortDescription:(NSString *)errorShortDescription andErrorDetails:(NSString *)errorDetails;
-(void)errorInResponseWithBody:(NSString *)errorMessage;
@end

@interface GoogleOAuth : UIWebView<UIWebViewDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) id<GoogleOAuthDelegate> gOAuthDelegate;
-(void)authorizeUserWithClienID:(NSString *)client_ID andClientSecret:(NSString *)client_Secret
                  andParentView:(UIView *)parent_View andScopes:(NSArray *)scopes;
-(void)revokeAccessToken;
-(void)callAPI:(NSString *)apiURL withHttpMethod:(HTTP_Method)httpMethod
postParameterNames:(NSArray *)params postParameterValues:(NSArray *)values;
-(NSString*)getToken;
extern NSString* GoogleToken;

@end
