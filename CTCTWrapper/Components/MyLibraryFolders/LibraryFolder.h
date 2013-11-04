//
//  LibraryFolder.h
//  CTCTContact
//
//  Copyright (c) 2013 Constant Contact. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Component.h"
/**
 * Represents a folder in Constant Contact
 *
 */
@interface LibraryFolder: NSObject

@property (nonatomic, strong, readonly) NSString *folderId;
@property (nonatomic, strong) NSString           *name;
@property (nonatomic, readwrite) int             level;
@property (nonatomic, strong) NSMutableArray     *children;
@property (nonatomic, readwrite) int             itemCount;
@property (nonatomic, strong) NSString           *parrentId;
@property (nonatomic, strong) NSString           *modifiedDate;
@property (nonatomic, strong) NSString           *createdDate;

/**
 * Factory method to create an folder object from an dictionary
 *
 * @param NSDictionary *dictionary - dictionary with propertyes to set
 *
 * @return Activity
 */
- (id)initWithDictionary:(NSDictionary *)dictionary;

+ (LibraryFolder *)folderWithDictionary:(NSDictionary *)dictionary;

/**
 * Create jsonDict used for a POST/PUT request, also handles removing attributes that will cause errors if sent
 *
 * @return NSMutableDictionary - dictionary that can be used to create json, or can be added in another json string
 */
- (NSDictionary*)proxyForJSON;
- (NSString*)JSON;

@end
