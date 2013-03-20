//
//  Panoramic.h
//  ARIS
//
//  Created by Brian Thiel on 6/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DisplayObjectProtocol.h"
#import "LocationObjectProtocol.h"

@interface Panoramic : NSObject <DisplayableObjectProtocol, LocationObjectProtocol>
{
    int panoramicId;
    int iconMediaId;
    int alignMediaId;
    NSString *name;
    NSString *description;
    NSArray *textureArray;
    NSArray *mediaArray;
}

@property(nonatomic, assign) int panoramicId;
@property(nonatomic, assign) int iconMediaId;
@property(nonatomic, assign) int alignMediaId;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *description;
@property(nonatomic, strong) NSArray *textureArray;
@property(nonatomic, strong) NSArray *mediaArray;

@end
