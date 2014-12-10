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

#import "RLMNavigationState.h"

#import "RLMArrayNode.h"

@interface RLMArrayNavigationState : RLMNavigationState

@property (nonatomic, readonly) RLMProperty *property;
@property (nonatomic, readonly) NSInteger arrayIndex;

- (instancetype)initWithSelectedType:(RLMTypeNode *)type typeIndex:(NSInteger)typeIndex property:(RLMProperty *)property arrayIndex:(NSInteger)arrayIndex;

@end
