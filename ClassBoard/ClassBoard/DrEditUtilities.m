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
+ (NSData *) getDataFrom:(NSString *)url withKeys:(NSArray *)keys withValues:(NSArray *)values{
    /*
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *inter = @"";
    NSMutableArray *jsonItems = [[NSMutableArray alloc]init];
    int i = 0;
    if (keys!=nil){
        for (NSString *x in keys){
            inter = [NSString stringWithFormat:@"%@=[%@]",x,[values objectAtIndex:i]];
            [jsonItems insertObject:inter atIndex:i];
        }
        NSString *get = [[jsonItems valueForKey:@"description"] componentsJoinedByString:@"&"];
        NSData *getData = [get dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSLog(@"The Get Data is %@",get);
        NSString *getLength = [NSString stringWithFormat:@"%d", [getData length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setValue:getLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:get forHTTPHeaderField:@"json"];
        [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:getData];
    }
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:url]];
    */
    // Trying something drastic
    NSError *error = [[NSError alloc] init];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@"1" forKey:@"username"];
    
    
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    if (!data) {
        return NO;
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:data];
    /*
    NSURLResponse *urlResponse = nil;
    
    NSData *urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    
    NSData *response = [NSJSONSerialization JSONObjectWithData:urlData options:NSJSONWritingPrettyPrinted error:&error];
    */
    
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] != 200){
        NSLog(@"Error getting %@, HTTP status code %i", url, [responseCode statusCode]);
        return nil;
    }
    return oResponseData;
    //return [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
}


+ (NSDictionary *)groupsFromJSON:(NSData *)objectNotation forKeys:(NSArray *)keys error:(NSError **)error
{
    NSLog(@"enter function");
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
    NSLog(@"magic, %@",result);
     
    return parsedObject;
}

/*
 @Returns a drive file if you pass in a Query and the service Drive Object. Returns nil othrewise
 */


@end
