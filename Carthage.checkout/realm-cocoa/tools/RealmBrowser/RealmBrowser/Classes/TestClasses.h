////////////////////////////////////////////////////////////////////////////
//
// Copyright 2014 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@interface RealmTestClass0 : RLMObject

@property NSInteger integerValue;
@property NSString *stringValue;
@property NSData *dataValue;

@end

RLM_ARRAY_TYPE(RealmTestClass0)

@interface RealmTestClass1 : RLMObject

@property NSInteger integerValue;
@property BOOL boolValue;
@property float floatValue;
@property double doubleValue;
@property NSString *stringValue;
@property NSDate *dateValue;
@property RLMArray<RealmTestClass0> *arrayReference;

@end

@interface RealmTestClass2 : RLMObject

@property NSInteger integerValue;
@property BOOL boolValue;
@property RealmTestClass1 *objectReference;

@end