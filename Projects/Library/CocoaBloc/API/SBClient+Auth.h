//
//  SBClient+Auth.h
//  CocoaBloc
//
//  Created by John Heaton on 9/8/14.
//  Copyright (c) 2014 StageBloc. All rights reserved.
//

#import "SBClient.h"

@interface SBClient (Auth)

/// @name Authentication/Sign Up

/*!
 Set the current app's client ID and client secret, which must be
 registered for use with StageBloc.
 
 @param clientID 		the client ID
 @param clientSecret 	the client secret
 */
+ (void)setClientID:(NSString *)clientID clientSecret:(NSString *)clientSecret;

/*!
 Log in a StageBloc user with the given credentials.
 
 @param username the user's username/email address
 @param password the user's password
 
 @return A "cold" signal that will perform the log in upon subscription.
 The subscribed signal will send a "next" value
 of an array of admin accounts (SBAccount) for that user (SBUser).
 */
- (RACSignal *)logInWithUsername:(NSString *)username
                        password:(NSString *)password;

/*!
 Sign up a new StageBloc user with the given user information and desired credentials.
 
 @param email 		the user's address
 @param password 	the user's password
 @param birthDate 	the user's birth date
 
 @return A "cold" signal that will perform the sign up upon subscription.
 The subscribed signal will send a "next" value
 of the newly authenticated user (SBUser).
 */
- (RACSignal *)signUpWithEmail:(NSString *)email
                      password:(NSString *)password
                     birthDate:(NSDate *)birthDate __attribute__((unavailable("Not implemented in v1 yet")));

/// The state of authentication for this client instance. Only after signing in a
/// user will this be true.
@property (nonatomic, getter = isAuthenticated, readonly) BOOL authenticated;

/// The oauth2 token for the currently authenticated user. This will be sent
/// in all requests after authentication.
@property (nonatomic, copy, readonly) NSString *token;

@end