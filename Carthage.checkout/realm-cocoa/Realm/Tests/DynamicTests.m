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

#import "RLMTestCase.h"
#import "RLMSchema.h"
#import "RLMRealm_Dynamic.h"
#import "RLMSchema_Private.h"

@interface DynamicTests : RLMTestCase
@end

@implementation DynamicTests

#pragma mark - Tests

- (void)testDynamicRealmExists {
    @autoreleasepool {
        // open realm in autoreleasepool to create tables and then dispose
        RLMRealm *realm = [RLMRealm realmWithPath:RLMTestRealmPath() readOnly:NO error:nil];
        [realm beginWriteTransaction];
        [DynamicObject createInRealm:realm withObject:@[@"column1", @1]];
        [DynamicObject createInRealm:realm withObject:@[@"column2", @2]];
        [realm commitWriteTransaction];
    }
    
    RLMRealm *dyrealm = [self dynamicRealmWithTestPathAndSchema:nil];
    XCTAssertNotNil(dyrealm, @"realm should not be nil");
    
    // verify schema
    RLMObjectSchema *dynSchema = dyrealm.schema[@"DynamicObject"];
    XCTAssertNotNil(dynSchema, @"Should be able to get object schema dynamically");
    XCTAssertEqual(dynSchema.properties.count, (NSUInteger)2, @"DynamicObject should have 2 properties");
    XCTAssertEqualObjects([dynSchema.properties[0] name], @"stringCol", @"Invalid property name");
    XCTAssertEqual([(RLMProperty *)dynSchema.properties[1] type], RLMPropertyTypeInt, @"Invalid type");
    
    // verify object type
    RLMResults *results = [dyrealm allObjects:@"DynamicObject"];
    XCTAssertEqual(results.count, (NSUInteger)2, @"Array should have 2 elements");
    XCTAssertNotEqual(results.objectClassName, DynamicObject.className,
                      @"Array class should by a dynamic object class");
}

- (void)testDynamicSchema {
    RLMSchema *schema = [[RLMSchema alloc] init];
    RLMProperty *prop = [[RLMProperty alloc] initWithName:@"a"
                                                     type:RLMPropertyTypeInt
                                          objectClassName:nil
                                               attributes:0];
    RLMObjectSchema *objectSchema = [[RLMObjectSchema alloc] initWithClassName:@"TrulyDynamicObject"
                                                                   objectClass:RLMObject.class properties:@[prop]];
    schema.objectSchema = @[objectSchema];
    RLMRealm *dyrealm = [self dynamicRealmWithTestPathAndSchema:schema];
    XCTAssertNotNil(dyrealm, @"dynamic realm shouldn't be nil");
}

- (void)testDynamicProperties {
    @autoreleasepool {
        // open realm in autoreleasepool to create tables and then dispose
        RLMRealm *realm = [RLMRealm realmWithPath:RLMTestRealmPath() readOnly:NO error:nil];
        [realm beginWriteTransaction];
        [DynamicObject createInRealm:realm withObject:@[@"column1", @1]];
        [DynamicObject createInRealm:realm withObject:@[@"column2", @2]];
        [realm commitWriteTransaction];
    }
    
    // verify properties
    RLMRealm *dyrealm = [self dynamicRealmWithTestPathAndSchema:nil];
    RLMResults *results = [dyrealm allObjects:@"DynamicObject"];
    
    RLMObject *o1 = results[0], *o2 = results[1];
    XCTAssertEqualObjects(o1[@"intCol"], @1, @"First object should have column value 1");
    XCTAssertEqualObjects(o2[@"stringCol"], @"column2", @"Second object should have string value column2");
    XCTAssertThrows(o1[@"invalid"], @"Invalid column name should throw");
}

- (void)testDynamicTypes {
    NSDate *now = [NSDate dateWithTimeIntervalSince1970:100000];
    id obj1 = @[@YES, @1, @1.1f, @1.11, @"string", [NSData dataWithBytes:"a" length:1], now, @YES, @11, @0, NSNull.null];
    
    StringObject *obj = [[StringObject alloc] init];
    obj.stringCol = @"string";
    id obj2 = @[@NO, @2, @2.2f, @2.22, @"string2", [NSData dataWithBytes:"b" length:1], now, @NO, @22, now, obj];
    @autoreleasepool {
        // open realm in autoreleasepool to create tables and then dispose
        RLMRealm *realm = [RLMRealm realmWithPath:RLMTestRealmPath() readOnly:NO error:nil];
        [realm beginWriteTransaction];
        [AllTypesObject createInRealm:realm withObject:obj1];
        [AllTypesObject createInRealm:realm withObject:obj2];
        [realm commitWriteTransaction];
    }
    
    // verify properties
    RLMRealm *dyrealm = [self dynamicRealmWithTestPathAndSchema:nil];
    RLMResults *results = [dyrealm allObjects:AllTypesObject.className];
    XCTAssertEqual(results.count, (NSUInteger)2, @"Should have 2 objects");
    
    RLMObjectSchema *schema = dyrealm.schema[AllTypesObject.className];
    for (int i = 0; i < 10; i++) {
        NSString *propName = [schema.properties[i] name];
        XCTAssertEqualObjects(obj1[i], results[0][propName], @"Invalid property value");
        XCTAssertEqualObjects(obj2[i], results[1][propName], @"Invalid property value");
    }
    
    // check sub object type
    XCTAssertEqualObjects([schema.properties[10] objectClassName], @"StringObject",
                          @"Sub-object type in schema should be 'StringObject'");
    
    // check object equality
    XCTAssertNil(results[0][@"objectCol"], @"object should be nil");
    XCTAssertEqualObjects(results[1][@"objectCol"][@"stringCol"], @"string",
                          @"Child object should have string value 'string'");
}

- (void)testDynamicAdd {
    @autoreleasepool {
        // open realm in autoreleasepool to create tables and then dispose
        [RLMRealm realmWithPath:RLMTestRealmPath() readOnly:NO error:nil];
    }

    RLMRealm *dyrealm = [self dynamicRealmWithTestPathAndSchema:nil];
    [dyrealm beginWriteTransaction];
    RLMObject *stringObject = [dyrealm createObject:StringObject.className withObject:@[@"string"]];
    [dyrealm createObject:AllTypesObject.className withObject:@[@NO, @2, @2.2f, @2.22, @"string2",
        [NSData dataWithBytes:"b" length:1], NSDate.date, @NO, @22, @0, stringObject]];
    [dyrealm commitWriteTransaction];

    XCTAssertEqual(1U, [dyrealm allObjects:StringObject.className].count);
    XCTAssertEqual(1U, [dyrealm allObjects:AllTypesObject.className].count);
}

- (void)testDynamicArray {
    @autoreleasepool {
        // open realm in autoreleasepool to create tables and then dispose
        [RLMRealm realmWithPath:RLMTestRealmPath() readOnly:NO error:nil];
    }

    RLMRealm *dyrealm = [self dynamicRealmWithTestPathAndSchema:nil];
    [dyrealm beginWriteTransaction];
    RLMObject *stringObject = [dyrealm createObject:StringObject.className withObject:@[@"string"]];
    RLMObject *stringObject1 = [dyrealm createObject:StringObject.className withObject:@[@"string1"]];
    [dyrealm createObject:ArrayPropertyObject.className withObject:@[@"name", @[stringObject, stringObject1], @[]]];
    [dyrealm commitWriteTransaction];

    RLMResults *results = [dyrealm allObjects:ArrayPropertyObject.className];
    XCTAssertEqual(1U, results.count);
    RLMObject *arrayObj = results.firstObject;
    RLMArray *array = arrayObj[@"array"];
    XCTAssertEqual(2U, array.count);
    XCTAssertEqualObjects(array[0][@"stringCol"], stringObject[@"stringCol"]);

    [dyrealm beginWriteTransaction];
    [array removeObjectAtIndex:0];
    [array addObject:stringObject];
    [dyrealm commitWriteTransaction];

    XCTAssertEqual(2U, array.count);
    XCTAssertEqualObjects(array[0][@"stringCol"], stringObject1[@"stringCol"]);
    XCTAssertEqualObjects(array[1][@"stringCol"], stringObject[@"stringCol"]);
}

@end
