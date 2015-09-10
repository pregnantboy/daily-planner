/* Copyright (c) 2015 Google Inc.
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
//  GTLGmailListMessagesResponse.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   Gmail API (gmail/v1)
// Description:
//   The Gmail REST API.
// Documentation:
//   https://developers.google.com/gmail/api/
// Classes:
//   GTLGmailListMessagesResponse (0 custom class methods, 3 custom properties)

#import "GTLGmailListMessagesResponse.h"

#import "GTLGmailMessage.h"

// ----------------------------------------------------------------------------
//
//   GTLGmailListMessagesResponse
//

@implementation GTLGmailListMessagesResponse
@dynamic messages, nextPageToken, resultSizeEstimate;

+ (NSDictionary *)arrayPropertyToClassMap {
  NSDictionary *map = @{
    @"messages" : [GTLGmailMessage class]
  };
  return map;
}

@end
