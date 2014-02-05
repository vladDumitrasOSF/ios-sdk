//
//  CTCT test.h
//  CTCTContact
//
//  Created by A_Dumitras on 2/4/14.
//  Copyright (c) 2014 OSF Global. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EventItemAttribute;
@class EventExtended;
@class EventPromocode;
@class EventItem;
@class EventFee;

@interface CTCT_test : NSObject

#pragma mark - event collection
+(void)allEventSpotEvents;
+(void)postEvent;

#pragma mark - individual event 
+(EventExtended *)getEvent;
+(void)updateEvent;
+(void)patchEvent;

#pragma mark - event fees collection
+(void)allEventFees;
+(void)postFee;

#pragma mark - individual event fee
+(EventFee *)getFee;
+(void)updateFee;
+(void)deleteFee;

#pragma mark - promo code collection
+(void)allPromocodes;
+(void)postPromocode;

#pragma mark - individual promocode
+(EventPromocode *)getPromocode;
+(void)updatePromocode;
+(void)deletePromocode;

#pragma makr - registrant collection
+(void)allRegistrants;

#pragma makr - individual registrant
+(void)registrant;

#pragma mark - event item collection
+(void)allEventItems;
+(void)postEventItem;

#pragma mark - individual event item
+(EventItem *)getEventItem;
+(void)updateEventItem;
+(void)deleteEventItem;

#pragma mark - item attribute collection
+(void)allEventItemAttributes;
+(void)postEventItemAttribute;

#pragma mark - individual item attribute
+(EventItemAttribute *)getEventItemAttribute;
+(void)updateEventItemAttribute;
+(void)deleteEventItemAttribute;

@end