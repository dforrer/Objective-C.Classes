/**
 * VERSION:	1.03
 * AUTHOR:	Daniel Forrer
 * FEATURES:	Thread-safe
 */


#import "SQLiteDatabase.h"


@implementation SQLiteDatabase {
	sqlite3 * sqliteConnection;
}


/**
 * Initializes a new SQLiteDatabase-Object
 */
- (id) initCreateAtPath: (NSString *)path {
	// Check if superclass could create its object
	if ((self = [super init])) {
		if (sqlite3_open([path UTF8String], &sqliteConnection) != SQLITE_OK) {
		   DebugLog(@"[SQLITE] Unable to open database!");
		   return nil; // if it fails, return nil obj
		}
	}
	return self;
}



/**
 * Performs a 'query' and returns the number of rows found
 * The rows themselves are accessible in the 'rows'-Array
 *
 * IMPORTENT: NSString variables need
 * to be bound using the
 * NSStringSqliteExtension
 * [string sqlString]!
 * Supports: INSERT, UPDATE, DELETE, SELECT, etc.
 **/
- (long long) performQuery: (NSString*) query
				  rows: (NSArray**) rows
				 error: (NSError**) error {
	@synchronized(self)	{
		NSString * command = [[query componentsSeparatedByString:@" "] objectAtIndex:0];
		if ([command isEqualToString:@"SELECT"]) {
			// SELECT
			sqlite3_stmt *statement = nil;
			const char *sql = [query UTF8String];
			int errorCode;
			if ((errorCode = sqlite3_prepare_v2(sqliteConnection, sql, -1, &statement, NULL)) != SQLITE_OK) {
				NSString * errorString = [NSString stringWithFormat:@"[SQLITE] Error when preparing query!: %@", query];
				*error = [NSError errorWithDomain: errorString code:errorCode userInfo:nil];
				return -1;
			} else {
				NSMutableArray *result = [[NSMutableArray alloc] init];
				while (sqlite3_step(statement) == SQLITE_ROW) {
					@autoreleasepool {
						NSMutableArray *row = [[NSMutableArray alloc] init];
						for (int i=0; i < sqlite3_column_count(statement); i++) {
							int colType = sqlite3_column_type(statement, i);
							id value;
							if (colType == SQLITE_TEXT){
								const char *col = (const char*) sqlite3_column_text(statement, i);
								value = [[NSString alloc] initWithCString:col encoding:NSUTF8StringEncoding];
							} else if (colType == SQLITE_INTEGER) {
								int64_t col = sqlite3_column_int64(statement, i);
								value = [[NSNumber alloc] initWithLongLong:col];
							} else if (colType == SQLITE_FLOAT) {
								double col = sqlite3_column_double(statement, i);
								value = [[NSNumber alloc] initWithDouble:col];
							} else if (colType == SQLITE_NULL) {
								value = [NSNull null];
							} else {
								DebugLog(@"[SQLITE] UNKNOWN DATATYPE");
							}
							[row addObject:value];
						}
						[result addObject:row];
					}
				}
				sqlite3_finalize(statement);
				*rows = result;
				return [result count];
			}
		} else {
			// INSERT, UPDATE, DELETE, CREATE
			int retval = sqlite3_exec(sqliteConnection,[query cStringUsingEncoding:NSUTF8StringEncoding],NULL,NULL,NULL);
			if ([self handleError:retval forQuery:[query cStringUsingEncoding: NSUTF8StringEncoding]]) {
				return sqlite3_changes(sqliteConnection);
			} else {
				NSString * errorString = [NSString stringWithFormat:@"[SQLITE] Error when executing query!: %@", query];
				*error = [NSError errorWithDomain: errorString code:retval userInfo:nil];
				return -1;
			}
		}
	}
}



/**
 * Handle Errors
 */
- (int) handleError: (int)retval forQuery: (const char*)query {
	if (retval != SQLITE_OK) {
		switch (retval) {
			case SQLITE_BUSY:
				printf("ERROR: SQLITE_BUSY - The database file is locked! Query: %s\n",query);
				return 0;
				break;
			case SQLITE_DONE:
				printf("SQLITE_DONE");
				break;
			case SQLITE_ROW:
				printf("SQLITE_DONE");
				break;
			case SQLITE_LOCKED:
				printf("ERROR: SQLITE_LOCKED - A table in the database is locked! Query: %s\n", query);
				return 0;
				break;
			case SQLITE_CANTOPEN:
				// Dies sollte jetzt nicht mehr passieren, Problem lag wahrscheinlich bei
				// sha384file() welches nur fopen(), nicht aber wieder fclose() ausführte,
				// wodurch die maximal zu öffnenden Filedescriptormenge überschritten wurde.
				printf("ERROR: SQLITE_CANTOPEN - Unable to open the database file! Query: %s\n",query);
				return 0;
				break;
			case SQLITE_IOERR:
				// Dies sollte jetzt nicht mehr passieren, Problem lag wahrscheinlich bei
				// sha384file() welches nur fopen(), nicht aber wieder fclose() ausführte,
				// wodurch die maximal zu öffnenden Filedescriptormenge überschritten wurde.
				printf("ERROR: SQLITE_IOERR - Some kind of disk I/O error occurred! Query: %s\n",query);
				return 0;
				break;
			case SQLITE_MISUSE:
				printf("ERROR: SQLITE_MISUSE - Library used incorrectly! Query: %s\n",query);
				return 0;
				break;
			case SQLITE_ERROR:
				printf("ERROR: SQLITE_ERROR - SQL error or missing database! Query: %s\n",query);
				return 0;
				break;
			case SQLITE_CONSTRAINT:
				printf("SQLITE_CONSTRAINT: Abort due to constraint violation!\n");
				return 0;
				break;
			default:
				printf("Sqlite-ERROR %i: Can't execute: %s\n",retval, query);
				return 0;
				break;
		}
	}
	return 1;
}


- (int) getTotalChanges {
	return sqlite3_total_changes(sqliteConnection);
}


- (int) getChanges {
	return sqlite3_changes(sqliteConnection);
}


@end


/*
 #define SQLITE_OK           0   // Successful result //
 #define SQLITE_ERROR        1   // SQL error or missing database
 #define SQLITE_INTERNAL     2   // Internal logic error in SQLite
 #define SQLITE_PERM         3   // Access permission denied
 #define SQLITE_ABORT        4   // Callback routine requested an abort
 #define SQLITE_BUSY         5   // The database file is locked
 #define SQLITE_LOCKED       6   // A table in the database is locked
 #define SQLITE_NOMEM        7   // A malloc() failed
 #define SQLITE_READONLY     8   // Attempt to write a readonly database
 #define SQLITE_INTERRUPT    9   // Operation terminated by sqlite3_interrupt()
 #define SQLITE_IOERR       10   // Some kind of disk I/O error occurred
 #define SQLITE_CORRUPT     11   // The database disk image is malformed
 #define SQLITE_NOTFOUND    12   // Unknown opcode in sqlite3_file_control()
 #define SQLITE_FULL        13   // Insertion failed because database is full
 #define SQLITE_CANTOPEN    14   // Unable to open the database file
 #define SQLITE_PROTOCOL    15   // Database lock protocol error
 #define SQLITE_EMPTY       16   // Database is empty
 #define SQLITE_SCHEMA      17   // The database schema changed
 #define SQLITE_TOOBIG      18   // String or BLOB exceeds size limit
 #define SQLITE_CONSTRAINT  19   // Abort due to constraint violation
 #define SQLITE_MISMATCH    20   // Data type mismatch
 #define SQLITE_MISUSE      21   // Library used incorrectly
 #define SQLITE_NOLFS       22   // Uses OS features not supported on host
 #define SQLITE_AUTH        23   // Authorization denied
 #define SQLITE_FORMAT      24   // Auxiliary database format error
 #define SQLITE_RANGE       25   // 2nd parameter to sqlite3_bind out of range
 #define SQLITE_NOTADB      26   // File opened that is not a database file
 #define SQLITE_NOTICE      27   // Notifications from sqlite3_log()
 #define SQLITE_WARNING     28   // Warnings from sqlite3_log()
 #define SQLITE_ROW         100  // sqlite3_step() has another row ready
 #define SQLITE_DONE        101  // sqlite3_step() has finished executing
 
 */
