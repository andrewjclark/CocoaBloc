//
//  SBClient+Status.m
//  CocoaBloc
//
//  Created by John Heaton on 9/8/14.
//  Copyright (c) 2014 StageBloc. All rights reserved.
//

#import "SBClient+Status.h"

@implementation SBClient (Status)

- (RACSignal *)getStatusWithID:(NSNumber *)statusID {
    return [RACSignal empty];
#warning imp
}

- (RACSignal *)getUsersLikingStatus:(SBStatus *)status {
    return [RACSignal empty];
#warning imp
}

- (RACSignal *)deleteStatus:(SBStatus *)status {
    return [RACSignal empty];
#warning imp
}

@end
