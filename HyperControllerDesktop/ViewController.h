//
//  ViewController.h
//  Hyper Controller
//
//  Created by luke on 21/10/2014.
//  Copyright (c) 2014 MirrorMedia. All rights reserved.
//

#import "MMDeck2.h"


@interface ViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource,NSTextFieldDelegate>

{
    NSMutableArray *decksArray;
    NSMutableArray *deckAddresses;
    NSMutableArray *deckNames;
}
@property (weak, nonatomic) IBOutlet NSTableView *mainTable;
@property (weak, nonatomic) IBOutlet NSTextField *groupFilenameField;
@property (weak, nonatomic) IBOutlet NSButton *useTimeDateToggle;
@property (weak, nonatomic) IBOutlet NSButton *useDecknameToggle;

- (IBAction)addDeck:(id)sender;
- (IBAction)deleteDeck:(id)sender;
- (IBAction)save:(id)sender;

- (IBAction)stopAll:(id)sender;
- (IBAction)playAll:(id)sender;
- (IBAction)gotostartAll:(id)sender;
- (IBAction)recordAll:(id)sender;
- (IBAction)fastForwardAll:(id)sender;
- (IBAction)rewindAll:(id)sender;


- (void) checkAllConnected;
@end

