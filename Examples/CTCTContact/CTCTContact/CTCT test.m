//
//  CTCT test.m
//  CTCTContact
//
//  Created by A_Dumitras on 2/4/14.
//  Copyright (c) 2014 OSF Global. All rights reserved.
//

#import "CTCT test.h"
#import "EventSpotService.h"
#import "EventExtended.h"
#import "Event.h"

#import "CTCTGlobal.h"

@implementation CTCT_test

+(void)allEventSpotEvents
{
    HttpResponse *response =  [EventSpotService getEventCollectionWithAccessToken:[CTCTGlobal shared].token withALimitOf:10];
    ResultSet *set = response.data;
    NSArray *respArray = set.results;
}

+(void)postEvent
{
    EventAddress *address1 = [[EventAddress alloc]init];
    address1.city = @"Algeria";
    address1.state = @"Massachusetts";
    address1.country = @"United States";
    address1.countryCode = @"US";
    address1.latitude = 60;
    address1.longitude = 60;
    address1.line1 = @"line 1";
    address1.line2 = @"line 2";
    address1.line3 = @"line 3";
    address1.postalCode = @"11111";
    address1.stateCode = @"MA";
    
    EventContact *cont = [[EventContact alloc]init];
    cont.emailAddress = @"this@that.com";
    cont.name = @"john";
    cont.organizationName = @"home";
    cont.phoneNumber = @"2345678";
   
    EventNotificationOptions *notif1 = [[EventNotificationOptions alloc]init];
    notif1.isOptedIn = TRUE;
    notif1.notificationType = @"SO_REGISTRATION_NOTIFICATION";
    
    EventNotificationOptions *notif2 = [[EventNotificationOptions alloc]init];
    notif2.isOptedIn = TRUE;
    notif2.notificationType = @"SO_REGISTRATION_NOTIFICATION";
    
    EventOnlineMeeting *meeting1 = [[EventOnlineMeeting alloc]init];
    meeting1.instructions = @"this is a test";
    meeting1.providerMeetingId = @"meeting 1";
    meeting1.providerType = @"WebEx";
    meeting1.url = @"http://google.com";
    
    EventOnlineMeeting *meeting2 = [[EventOnlineMeeting alloc]init];
    meeting2.instructions = @"this is also a test";
    meeting2.providerMeetingId = @"meeting 2";
    meeting2.providerType = @"WebEx2";
    meeting2.url = @"google.com";
    
    EventTrackInformation *trackInfo = [[EventTrackInformation alloc]init];
    trackInfo.earlyFeeDate = @"2014-03-01T00:00:00.00Z";
    trackInfo.guestDisplayLabel = @"Guest";
    trackInfo.guestLimit = 10;
    trackInfo.informationSections = [NSArray arrayWithObjects:@"now", nil];
    trackInfo.isGuestAnonymusEnabled = false;
    trackInfo.isGuestNameRequired = false;
    trackInfo.isRegistrationClosedManually = false;
    trackInfo.isTicketingLinkDisabled = true;
    trackInfo.lateFeeDate = @"2014-03-02T00:00:00.00Z";
    trackInfo.registrationLimitCount = 10;
    trackInfo.registrationLimitDate = @"2014-03-11T00:00:00.00Z";
    
    EventExtended *event = [[EventExtended alloc]init];
    event.address = address1;
    event.areRegistrantsPublic = TRUE;
    event.contact = cont;
    event.currencyType = event.eventCurrencyTypeEnum.usd;
    event.description = @"this is my description";
    event.endDate = @"2014-05-01T00:00:00.00Z";
    event.googleAnalyticsKey = @"";
    event.googleMerchantId = @"";
    event.isCalendarDisplayed = TRUE;
    event.isCheckinAvailable = TRUE;
    event.isHomePageDisplayed = TRUE;
    event.isListedInExternalDirectory = false;
    event.isMapDisplayed = TRUE;
    event.isVirtualEvent = TRUE;
    event.location = @"at the palace";
    event.name = @"in god we trust, the rest bring data";
    event.notificationOptions = [NSArray arrayWithObjects:notif1,notif2,nil];
    event.onlineMeeting = meeting1;
    event.payableTo = @"king geroge";
    event.paymentAddress = address1;
    event.paymentOptions = [NSArray arrayWithObjects:event.eventPaymentTypeEnum.payPal,event.eventPaymentTypeEnum.check, nil];
    event.paypalAccountEmail = @"that@this.com";
    event.startDate = @"2014-02-06T00:00:00.00Z";
    event.themeName = @"Bamboo";
    event.timeZoneDescription = @"";
    event.timeZoneId = @"US/Central";
    event.title = @"the king's party";
    event.trackInformation = trackInfo;
    event.twitterHashTag = @"#tag";
    event.type = event.eventTypeEnum.partiesSocialEventsMixers;
    
    HttpResponse *response =  [EventSpotService addEventWithToken:[CTCTGlobal shared].token andEvent:event];
    EventExtended *eventExt = response.data;
}

#pragma mark - individual event
+(EventExtended *)getEvent
{
    HttpResponse *response =  [EventSpotService getEventCollectionWithAccessToken:[CTCTGlobal shared].token withALimitOf:10];
    ResultSet *set = response.data;
    NSArray *respArray = set.results;
    
    EventExtended *extEvent;
    if(respArray.count > 0)
    {
        Event *ev = [respArray objectAtIndex:1];
        HttpResponse *response =  [EventSpotService getEventWithAccessToken:[CTCTGlobal shared].token withEventId:ev.eventId];
        extEvent = response.data;
    }
    
    return extEvent;
}

+(void)updateEvent
{
    EventExtended *extEvent = [CTCT_test getEvent];
    extEvent.title = @"UPDATED EVENT YES YES YES";
    HttpResponse *response = [EventSpotService updateEventWithAccesToken:[CTCTGlobal shared].token withEventId:extEvent.eventId andEvent:extEvent];
    
    EventExtended *updatedEv = response.data;
}

+(void)patchEvent
{
    EventPatch *patch = [[EventPatch alloc]init];
    patch.op = @"REPLACE";
    patch.path = @"#/status";
    patch.value = @"ACTIVE";
    
    EventExtended *extEvent = [CTCT_test getEvent];
    HttpResponse *response = [EventSpotService patchEventWithAccesToken:[CTCTGlobal shared].token withEventId:extEvent.eventId action:patch];
    
    EventExtended *extItem = response.data;
}


#pragma mark - event fees collection
+(void)allEventFees
{
   EventExtended *extEvent = [CTCT_test getEvent];
   HttpResponse *response = [EventSpotService getEventFeesCollectionWithAccessToken:[CTCTGlobal shared].token withEventId:extEvent.eventId];
    
    NSArray *fee = response.data;
}

+ (void)postFee
{
    EventFee *feeToPost = [[EventFee alloc]init];
    feeToPost.earlyFee = 29.99;
    feeToPost.fee = 49.99;
    feeToPost.feeScope = feeToPost.feeScopeEnum.guests;
    feeToPost.label = @"programatic fee";
    feeToPost.lateFee = 69.99;
    
    EventExtended *extEvent = [CTCT_test getEvent];
    HttpResponse *response = [EventSpotService addEventFeeWithToken:[CTCTGlobal shared].token withEventId:extEvent.eventId andEventFee:feeToPost];
    
    EventFee *responseFee = response.data;
}
#pragma mark - individual event fee
+(EventFee *)getFee
{
    EventFee *selectedFee = nil;
    
    EventExtended *extEvent = [CTCT_test getEvent];
    HttpResponse *response = [EventSpotService getEventFeesCollectionWithAccessToken:[CTCTGlobal shared].token withEventId:extEvent.eventId];
    
    NSArray *fee = response.data;
    if(fee.count > 0)
    {
        EventFee *firstFee = fee[0];
    
    HttpResponse *responseForFee = [EventSpotService getEventFeeWithAccessToken:[CTCTGlobal shared].token withEventId:extEvent.eventId andFeeId:firstFee.feeId];
    selectedFee = responseForFee.data;
    }
    return selectedFee;
}

+(void)updateFee
{
    EventExtended *extEvent = [CTCT_test getEvent];
    EventFee *selectedFee = [self getFee];
    selectedFee.fee = 199.99;
    
    HttpResponse *rez = [EventSpotService updateEventFeeWithAccesToken:[CTCTGlobal shared].token withEventId:extEvent.eventId feeId:selectedFee.feeId andEventFee:selectedFee];
    EventFee *updatedFee = rez.data;
}

+ (void)deleteFee
{
    EventExtended *extEvent = [CTCT_test getEvent];
    EventFee *selectedFee = [self getFee];
    
    NSArray *err;
    BOOL isItDeleted = [EventSpotService deleteEventFeeWithAccesToken:[CTCTGlobal shared].token withEventId:extEvent.eventId andFeeId:selectedFee.feeId errors:&err];
}
#pragma mark - promo code collection
+(void)allPromocodes
{
    EventExtended *extEvent = [CTCT_test getEvent];
    HttpResponse *response = [EventSpotService getPromocodeCollectionWithAccessToken:[CTCTGlobal shared].token withEventId:extEvent.eventId]; 
    
    NSArray *promo = response.data;
}

+(void)postPromocode
{
    EventExtended *extEvent = [CTCT_test getEvent];
    
    EventPromocode *promoToAdd = [[EventPromocode alloc]init];
    promoToAdd.codeName = @"PCode";
    promoToAdd.codeType = promoToAdd.promocodeCodeTypeEnum.discount;
    promoToAdd.discountAmount = 50.05;
    promoToAdd.discountScope = promoToAdd.promocodeDiscountScopeEnum.orderTotal;
    
    promoToAdd.isPaused = true;
    promoToAdd.quantityTotal = 50;
    
    HttpResponse *response = [EventSpotService addPromocodeWithAccesToken:[CTCTGlobal shared].token  withEventId:extEvent.eventId andPromocode:promoToAdd];
    EventPromocode *promo = response.data;
}
#pragma mark - individual promocode
+(EventPromocode *)getPromocode
{
    EventPromocode *resultPromo = nil;
    
    EventExtended *extEvent = [CTCT_test getEvent];
    HttpResponse *response = [EventSpotService getPromocodeCollectionWithAccessToken:[CTCTGlobal shared].token withEventId:extEvent.eventId];
    
    NSArray *promo = response.data;
    if(promo.count > 0)
    {
    EventPromocode *selectedPromo = [promo objectAtIndex:0];
    HttpResponse *promocodeGet = [EventSpotService getPromocodeWithAccessToken:[CTCTGlobal shared].token withEventId:extEvent.eventId andPromocodeId:selectedPromo.promocodeId];
    
    resultPromo = promocodeGet.data;
    }
    return resultPromo;
}

+(void)updatePromocode
{
    EventExtended *extEvent = [CTCT_test getEvent];
    EventPromocode *resultPromo = [self getPromocode];
    resultPromo.discountAmount = 15.15;
    
    HttpResponse *response = [EventSpotService updatePromocodeWithAccessToken:[CTCTGlobal shared].token withEventId:extEvent.eventId andPromocodeId:resultPromo.promocodeId andPromocode:resultPromo];
    
    EventPromocode *updatedPromocode = response.data;
}

+(void)deletePromocode
{
    EventExtended *extEvent = [CTCT_test getEvent];
    EventPromocode *resultPromo = [self getPromocode];
    
    NSArray *err;
    BOOL isItDeleted = [EventSpotService deletePromocodeWithAccessToken:[CTCTGlobal shared].token withEventId:extEvent.eventId andPromocodeId:resultPromo.promocodeId errors:&err];
}

#pragma mark - registrant collections
+(void)allRegistrants
{
    EventExtended *extEvent = [CTCT_test getEvent];

    HttpResponse *response =  [EventSpotService getEventRegistrantCollectionWithAccessToken:[CTCTGlobal shared].token withEventId:extEvent.eventId withALimitOf:10];
    
    ResultSet *set = response.data;
    NSArray *respArray = set.results;
}

#pragma mark - individual registrant
+(void)registrant
{
    EventExtended *extEvent = [CTCT_test getEvent];
    
    HttpResponse *response =  [EventSpotService getEventRegistrantCollectionWithAccessToken:[CTCTGlobal shared].token withEventId:extEvent.eventId withALimitOf:10];
    
    ResultSet *set = response.data;
    NSArray *respArray = set.results;
    if(respArray.count > 0)
    {
        EventRegistrant *reg = respArray[2];
        
        HttpResponse *responseIndividual =  [EventSpotService getEventRegistrantWithAccessToken:[CTCTGlobal shared].token withEventId:extEvent.eventId andRegistrantId:reg.registrantId];
        EventRegistrantExtended *registrantResult = responseIndividual.data;
    }
}

#pragma mark - event item collection
+(void)allEventItems
{
    EventExtended *extEvent = [CTCT_test getEvent];
    HttpResponse *resp = [EventSpotService getEventItemCollectionWithAccessToken:[CTCTGlobal shared].token withEventId:extEvent.eventId];
    
    NSArray *arr = resp.data;
}

+(void)postEventItem
{
    EventExtended *extEvent = [CTCT_test getEvent];
    
    EventItem *evItem = [[EventItem alloc]init];
    evItem.defaultQuantityTotal = 100;
    evItem.description = @"this is what i added";
    evItem.name = @"the one and only item";
    evItem.perRegistrantLimit = 2;
    evItem.price = 680;
    evItem.showQuantityAvailable = TRUE;
    
    HttpResponse *resp = [EventSpotService addEventItemWithAccesToken:[CTCTGlobal shared].token withEventId:extEvent.eventId andItem:evItem];
    EventItem *addedItem = resp.data;
}

#pragma mark - individual event item
+(EventItem *)getEventItem
{
    EventItem *resultItem = nil;
    
    EventExtended *extEvent = [CTCT_test getEvent];
    HttpResponse *resp = [EventSpotService getEventItemCollectionWithAccessToken:[CTCTGlobal shared].token withEventId:extEvent.eventId];
    
    NSArray *arr = resp.data;
    if(arr.count > 0)
    {
    EventItem *item = [arr objectAtIndex:0];
    HttpResponse *getItem = [EventSpotService getEventItemWithAccessToken:[CTCTGlobal shared].token withEventId:extEvent.eventId andItemId:item.eventItemId];
    resultItem = getItem.data;
    }
    return resultItem;
}

+(void)updateEventItem
{
    EventExtended *extEvent = [CTCT_test getEvent];
    
    EventItem *evItem = [self getEventItem];
    evItem.name = @"This got updatedddddddd";
    HttpResponse *getItem = [EventSpotService updateEventItemWithAccessToken:[CTCTGlobal shared].token withEventId:extEvent.eventId itemId:evItem.eventItemId andItem:evItem];
    
    EventItem *itmUpdated = getItem.data;
}

+(void)deleteEventItem
{
    EventExtended *extEvent = [CTCT_test getEvent];
    EventItem *evItem = [self getEventItem];
    
    NSArray *err;
    BOOL isItDeleted = [EventSpotService deleteEventItemWithAccessToken:[CTCTGlobal shared].token withEventId:extEvent.eventId andItemId:evItem.eventItemId errors:&err];
}

#pragma mark - item attribute collection
+(void)allEventItemAttributes
{
    EventExtended *extEvent = [CTCT_test getEvent];
    EventItem *evItem = [self getEventItem];
    
    HttpResponse *resp = [EventSpotService getEventItemAttributeCollectionWithAccessToken:[CTCTGlobal shared].token withEventId:extEvent.eventId andItemId:evItem.eventItemId];
    NSArray *arr = resp.data;
}

+(void)postEventItemAttribute
{
    EventItemAttribute *itemAtrib = [[EventItemAttribute alloc]init];
    itemAtrib.name = @"test attribute name";
    itemAtrib.quantityTotal = 10;
    
    
    EventExtended *extEvent = [CTCT_test getEvent];
    EventItem *evItem = [self getEventItem];
    
    HttpResponse *response = [EventSpotService addEventItemAttributeWithAccesToken:[CTCTGlobal shared].token withEventId:extEvent.eventId itemId:evItem.eventItemId andItemAttribute:itemAtrib];
    EventItemAttribute *responseAttrib = response.data;
}

#pragma mark - individual item attribute
+(EventItemAttribute *)getEventItemAttribute
{
    EventItemAttribute *responseAttrib = nil;
    
    EventExtended *extEvent = [CTCT_test getEvent];
    EventItem *evItem = [self getEventItem];
    
    HttpResponse *resp = [EventSpotService getEventItemAttributeCollectionWithAccessToken:[CTCTGlobal shared].token withEventId:extEvent.eventId andItemId:evItem.eventItemId];
    NSArray *arr = resp.data;
    if(arr.count > 0)
    {
    EventItemAttribute *selectedItemAttrib = arr[0];
    
    HttpResponse *response = [EventSpotService getEventItemAttributeWithAccessToken:[CTCTGlobal shared].token withEventId:extEvent.eventId itemId:evItem.eventItemId andAttributeId:selectedItemAttrib.itemAttributeId];
 
    responseAttrib = response.data;
    }
    return responseAttrib;
}

+(void)updateEventItemAttribute
{
    EventExtended *extEvent = [CTCT_test getEvent];
    EventItem *evItem = [self getEventItem];
    EventItemAttribute *itemAtr = [self getEventItemAttribute];
    itemAtr.name = @"THE NAME OF THE UPDATE ATTRIBUTE";
    
    HttpResponse *getItemAtr = [EventSpotService updateEventItemAttributeWithAccessToken:[CTCTGlobal shared].token withEventId:extEvent.eventId itemId:evItem.eventItemId attributeId:itemAtr.itemAttributeId andAttribute:itemAtr];

    EventItemAttribute *itmUpdated = getItemAtr.data;
}

+(void)deleteEventItemAttribute
{
    EventExtended *extEvent = [CTCT_test getEvent];
    EventItem *evItem = [self getEventItem];
    EventItemAttribute *itemAtr = [self getEventItemAttribute];
    
    NSArray *err;
    BOOL isItDeleted = [EventSpotService deleteEventItemAttributeWithAccessToken:[CTCTGlobal shared].token withEventId:extEvent.eventId itemId:evItem.eventItemId andAttributeId:itemAtr.itemAttributeId errors:&err];
}
@end
