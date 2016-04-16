//
//  MMDeck2.h
//  HyperControllerDesktop
//
//  Created by Luke Irvine on 8/04/2016.
//  Copyright © 2016 MirrorMedia. All rights reserved.
//

#import "GCDAsyncSocket.h"
#import <Cocoa/Cocoa.h>


@interface MMDeck2 : NSTableCellView <NSCoding, NSTextFieldDelegate, NSTableViewDelegate, NSTableViewDataSource>

{
    int deckNumber;
    int connectionIndicator;
    NSString *slot1RemainTextField;
    NSImage *playButton;
    NSImage *stopButton;
    NSImage *recordButton;
    NSImage *fastForwardButton;
    NSImage *rewindButton;
}

+ (NSString *)reuseIdentifier;

@property BOOL socket1Connected;
@property BOOL gang;

@property (strong) NSString *ipAddress;
@property (strong) NSString *deckName;
@property (strong) NSString *timecode;
@property (nonatomic, retain) NSTimer *connectTimer;

- (void)stop;
- (void)play;
- (void)gotostart;
- (void)gotoend;
- (void)rewind;
- (void)fastForward;
- (void)recordButton;
- (void)connect;
- (void) recordWithGroupName:(NSString*)groupName includeDate:(BOOL)dateON includeDeckname:(BOOL)DecknameON includeGroupName:(BOOL)GroupON;
- (void)changeSlotToSlotNumber:(int)SlotNumber;
- (void) getInfoFromDeck;
- (void) getClipsFromDeck;
- (instancetype)initWithName: (NSString*)name ipAddress:(NSString*)address;
- (void) disconnect;


@end
