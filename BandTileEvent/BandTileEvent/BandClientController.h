//
//  BandClientController.h
//  BandTileEvent
//
//  Created by Mark Thistle on 2/10/16.
//  Copyright © 2016 Microsoft. All rights reserved.
//

#ifndef BandClientController_h
#define BandClientController_h

#import <MicrosoftBandKit_iOS/MicrosoftBandKit_iOS.h>

@interface BandClientController : NSObject <MSBClientTileDelegate, MSBClientManagerDelegate>

@property (nonatomic, weak) MSBClient *client;

- (BOOL)setupBandConnection;
- (BOOL)addTileToBand;

@end

#endif /* BandClientController_h */
