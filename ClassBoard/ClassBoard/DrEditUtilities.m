/* Copyright (c) 2012 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  DrEditUtilities.m
//

#import "DrEditUtilities.h"


@implementation DrEditUtilities
+ (UIAlertView *)showLoadingMessageWithTitle:(NSString *)title 
                                    delegate:(id)delegate {
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                  message:@""
                                                 delegate:self
                                        cancelButtonTitle:nil
                                        otherButtonTitles:nil];
  UIActivityIndicatorView *progress= 
  [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 50, 30, 30)];
  progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
  [alert addSubview:progress];
  [progress startAnimating];
  [alert show];
  return alert;
}

+ (void)showErrorMessageWithTitle:(NSString *)title
                          message:(NSString*)message
                         delegate:(id)delegate {
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                  message:message
                                                 delegate:self
                                        cancelButtonTitle:@"Dismiss"
                                        otherButtonTitles:nil];
  [alert show];
}


//This will take in a JSON response and return NSData
+ (NSData *) getDataFrom:(NSString *)url{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:url]];
    
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] != 200){
        NSLog(@"Error getting %@, HTTP status code %i", url, [responseCode statusCode]);
        return nil;
    }
    return oResponseData;
    //return [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
}


+ (NSMutableArray *)groupsFromJSON:(NSData *)objectNotation forKeys:(NSArray *)keys error:(NSError **)error
{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:&localError];
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (NSString *key in keys){
        NSArray *group = [parsedObject objectForKey:key];
        [result addObject:group];
    }
    return result;
}

/*
 @Returns a drive file if you pass in a Query and the service Drive Object. Returns nil othrewise
 */


@end
