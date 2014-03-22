//
//  SQLiteDatabase_Unit_TestsTests.m
//  SQLiteDatabase Unit TestsTests
//
//  Created by Daniel Forrer on 22.03.14.
//  Copyright (c) 2014 Daniel Forrer. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SQLiteDatabase.h"

@interface SQLiteDatabase_Unit_TestsTests : XCTestCase

@end

@implementation SQLiteDatabase_Unit_TestsTests
{
	SQLiteDatabase * db;
}

- (void)setUp
{
	[super setUp];
	// Put setup code here. This method is called before the invocation of each test method in the class.
	db = [[SQLiteDatabase alloc] initCreateAtPath:@":memory:"];

}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCreateTable
{
	NSError * error;
	NSArray * rows;

	long long rv = [db performQuery:@"CREATE TABLE IF NOT EXISTS test (uid TEXT PRIMARY KEY, row1 TEXT, row2 SQLITE3_INT64 UNIQUE, row3 INTEGER)" rows:&rows error:&error];
	XCTAssertEqual(rv, (long long) 0, @"No rows should be returned");
	XCTAssertNil(error, @"Table could not be created");
	XCTAssertNil(rows, @"No rows should be returned");
}

- (void) testInsertRow
{
	NSError * error;
	NSArray * rows;

	// Setup
	//------
	[db performQuery:@"CREATE TABLE IF NOT EXISTS test (uid TEXT PRIMARY KEY, row1 TEXT, row2 SQLITE3_INT64 UNIQUE, row3 INTEGER)" rows:&rows error:&error];
	
	// Actual Test
	//------------
	long long rv = [db performQuery:@"insert into test (row1, row2, row3) values ('Test',248477148428,3474747)" rows:&rows error:&error];
	XCTAssertEqual(rv, (long long) 1, @"Insert should return 1 row changed");
	XCTAssertNil(error, @"Insert failed");
	XCTAssertNil(rows, @"No rows should be returned");
}

- (void) testSelectRow
{
	NSError * error;
	NSArray * rows;
	
	// Setup
	//------
	[db performQuery:@"CREATE TABLE IF NOT EXISTS test (uid INTEGER PRIMARY KEY, row1 TEXT, row2 SQLITE3_INT64 UNIQUE, row3 INTEGER)" rows:&rows error:&error];
	[db performQuery:@"insert into test (row1, row2, row3) values ('Test',248477148428,3474747)" rows:&rows error:&error];
	
	// Actual Test
	//------------
	long long rv = [db performQuery:@"select row1, row2, row3 from test" rows:&rows error:&error];
	XCTAssertEqual(rv, (long long) 1, @"Insert should return 1 row changed");
	XCTAssertNil(error, @"Insert failed");
	XCTAssertNotNil(rows, @"");
	XCTAssertTrue([rows[0][0] isEqualToString:@"Test"]);
	XCTAssertTrue([rows[0][1] isEqualToNumber:[NSNumber numberWithLongLong:248477148428]]);
	XCTAssertTrue([rows[0][2] isEqualToNumber:[NSNumber numberWithInt:3474747]]);

	// Test Select without result
	//---------------------------
	rv = [db performQuery:@"select row1, row2, row3 from test where uid=4;" rows:&rows error:&error];
	XCTAssertEqual(rv, (long long) 0, @"");
	XCTAssertNil(error, @"Insert failed");
	XCTAssertNotNil(rows, @"");
	XCTAssertTrue([rows count] == 0);
}


@end
