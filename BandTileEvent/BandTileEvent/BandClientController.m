//
//  BandClientController.m
//  BandTileEvent
//
//  Created by Mark Thistle on 2/10/16.
//  Copyright © 2016 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@implementation BandClientController

- (BOOL)setupBandConnection:(NSError *)error {
    [MSBClientManager sharedManager].delegate = self;
    NSArray	*clients = [[MSBClientManager sharedManager] attachedClients];
    self.client = [clients firstObject];
    if (self.client == nil)
    {
        NSError *error = [NSError errorWithDomain:@"MSBClient" code:-1 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Failed! No Bands attached.", nil) }]
        return NO;
    }
    
    self.client.tileDelegate = self;
    [[MSBClientManager sharedManager] connectClient:self.client];
    
    return YES;
}

- (BOOL)addTileToBand:(NSError *)error {
    MSBTile *tile = [self tileWithButtonLayout];
    __weak typeof(self) weakSelf = self;
    [self.client.tileManager addTile:tile completionHandler:^(NSError *error)
     {
         if (!error || error.code == MSBErrorTypeTileAlreadyExist)
         {
             NSLog(@"Creating a page with text button...");
             MSBPageData *pageData = [weakSelf buttonPage];
             [weakSelf.client.tileManager setPages:@[pageData] tileId:tile.tileId completionHandler:^(NSError *error)
              {
                  if (!error)
                  {
                      NSLog(@"Page sent.");
                      NSLog(@"You can press the button on D Tile to observe Tile Events.");
                  }
                  else
                  {
                      NSLog(error.description);
                  }
              }];
         }
         else
         {
             NSLog(error.description);
         }
     }];
}


#pragma mark - Band Tile Layout Methods
- (MSBTile *)tileWithButtonLayout
{
    NSString *tileName = @"Button tile";
    
    // Create Tile Icon
    MSBIcon *tileIcon = [MSBIcon iconWithUIImage:[UIImage imageNamed:@"D.png"] error:nil];
    
    // Create small Icon
    MSBIcon *smallIcon = [MSBIcon iconWithUIImage:[UIImage imageNamed:@"Dd.png"] error:nil];
    
    // Create a Tile
    // You should generate your own TileID for your own Tile to prevent collisions with other Tiles.
    NSUUID *tileID = [[NSUUID alloc] initWithUUIDString:@"CABDBA9F-12FD-47A5-8453-E7270A43BB99"];
    MSBTile *tile = [MSBTile tileWithId:tileID name:tileName tileIcon:tileIcon smallIcon:smallIcon error:nil];
    
    // Create a Text Block
    MSBPageTextBlock *textBlock = [[MSBPageTextBlock alloc] initWithRect:[MSBPageRect rectWithX:0 y:0 width:200 height:40] font:MSBPageTextBlockFontSmall];
    textBlock.elementId = 10;
    textBlock.baseline = 25;
    textBlock.baselineAlignment = MSBPageTextBlockBaselineAlignmentRelative;
    textBlock.horizontalAlignment = MSBPageHorizontalAlignmentCenter;
    textBlock.autoWidth = NO;
    textBlock.color = [MSBColor colorWithUIColor:[UIColor redColor] error:nil];
    textBlock.margins = [MSBPageMargins marginsWithLeft:5 top:2 right:5 bottom:2];
    
    // Create a Text Button
    MSBPageTextButton *button = [[MSBPageTextButton alloc] initWithRect:[MSBPageRect rectWithX:0 y:0 width:200 height:40]];
    button.elementId = 11;
    button.horizontalAlignment = MSBPageHorizontalAlignmentCenter;
    button.pressedColor = [MSBColor colorWithUIColor:[UIColor purpleColor] error:nil];
    button.margins = [MSBPageMargins marginsWithLeft:5 top:2 right:5 bottom:2];
    
    MSBPageFlowPanel *flowPanel = [[MSBPageFlowPanel alloc] initWithRect:[MSBPageRect rectWithX:15 y:0 width:230 height:105]];
    [flowPanel addElements:@[textBlock, button]];
    
    MSBPageLayout *pageLayout = [[MSBPageLayout alloc] initWithRoot:flowPanel];
    [tile.pageLayouts addObject:pageLayout];
    
    return tile;
}

- (MSBPageData *)buttonPage
{
    NSUUID *pageID = [[NSUUID alloc] initWithUUIDString:@"1234BA9F-12FD-47A5-83A9-E7270A43BB99"];
    NSArray *pageValues = @[[MSBPageTextButtonData pageTextButtonDataWithElementId:11 text:@"Press Me" error:nil],
                            [MSBPageTextBlockData pageTextBlockDataWithElementId:10 text:@"TextButton Sample" error:nil]];
    MSBPageData *pageData = [MSBPageData pageDataWithId:pageID layoutIndex:0 value:pageValues];
    return pageData;
}

#pragma mark - MSBClientManagerDelegate

- (void)clientManager:(MSBClientManager *)clientManager clientDidConnect:(MSBClient *)client
{
    //[self markSampleReady:YES];
    NSLog([NSString stringWithFormat:@"Band <%@> connected.", client.name]);
}

- (void)clientManager:(MSBClientManager *)clientManager clientDidDisconnect:(MSBClient *)client
{
    //[self markSampleReady:NO];
    NSLog([NSString stringWithFormat:@"Band <%@> disconnected.", client.name]);
}

- (void)clientManager:(MSBClientManager *)clientManager client:(MSBClient *)client didFailToConnectWithError:(NSError *)error
{
    NSLog([NSString stringWithFormat:@"Failed to connect to Band <%@>.", client.name]);
    NSLog(error.description];
}

#pragma mark - MSBClientTileDelegate

- (void)client:(MSBClient *)client tileDidOpen:(MSBTileEvent *)event
{
    NSLog([NSString stringWithFormat:@"%@", event]);
}

- (void)client:(MSBClient *)client buttonDidPress:(MSBTileButtonEvent *)event
{
    NSLog([NSString stringWithFormat:@"%@", event]);
}

- (void)client:(MSBClient *)client tileDidClose:(MSBTileEvent *)event
{
    NSLog([NSString stringWithFormat:@"%@", event]);
}

@end