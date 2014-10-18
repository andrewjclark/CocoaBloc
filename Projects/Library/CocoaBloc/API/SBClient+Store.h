//
//  SBClient+Store.h
//  CocoaBloc
//
//  Created by John Heaton on 9/8/14.
//  Copyright (c) 2014 StageBloc. All rights reserved.
//

#import "SBClient.h"

@interface SBClient (Store)

- (RACSignal *)getDashboardData;
- (RACSignal *)getStoreOrders;
- (RACSignal *)getStoreItemWithID:(NSNumber *)storeItemID forAccount:(SBAccount *)account;
- (RACSignal *)getStoreItemsForAccount:(SBAccount *)account parameters:(NSDictionary *)parameters;
- (RACSignal *)connectAccountWithStripeUsingToken:(NSString *)stripeToken;
- (RACSignal *)updateOrderWithID;

@end
