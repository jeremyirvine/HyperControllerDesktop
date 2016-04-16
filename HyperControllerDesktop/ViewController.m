//
//  ViewController.m
//  Hyper Controller
//
//  Created by luke on 21/10/2014.
//  Copyright (c) 2014 MirrorMedia. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()



@end



@implementation ViewController


{
    NSUserDefaults *prefs;
    long int selectedRow;
    int previousSelectedRow;
    NSTextField *currentTextField;
    NSIndexPath *selectedRowIndex;
    int previousRow;
    BOOL defaultstest;
    NSMutableArray *expandArray;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    

    
    prefs = [NSUserDefaults standardUserDefaults];
    deckAddresses = [[NSMutableArray alloc]init];
    deckNames = [[NSMutableArray alloc]init];
    decksArray = [[NSMutableArray alloc]init];
    defaultstest = [prefs boolForKey:@"defaultstest"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deckExpand)
                                                 name:@"expandDeck"
                                               object:nil];

    
    if (defaultstest) {
//        NSLog(@"defaults yay");
        deckAddresses = [prefs objectForKey:@"deckAddresses"];
        deckNames = [prefs objectForKey:@"deckNames"];
        int i = 0;
        for (NSString *address in deckAddresses) {
            MMDeck2 *deck = [[MMDeck2 alloc]initWithName:[deckNames objectAtIndex:i] ipAddress:address];
//            [deck addObserver:self forKeyPath:@"myName" options:NSKeyValueObservingOptionNew context:nil];

            [decksArray addObject:deck];
            i += 1;
        
        }
    

//    }
    } else {
        [self defaultEveything];
    }



    
   }


- (void) deckExpand {
    
//    NSLog(@"expand");
    [_mainTable beginUpdates];
    [_mainTable reloadData];
    [_mainTable endUpdates];
}

- (void) defaultEveything{
    MMDeck2 *deck1 = [[MMDeck2 alloc]initWithName:@"Deck1" ipAddress:@"192.168.10.51"];
    MMDeck2 *deck2 = [[MMDeck2 alloc]initWithName:@"Deck2" ipAddress:@"192.168.10.52"];
    MMDeck2 *deck3 = [[MMDeck2 alloc]initWithName:@"Deck3" ipAddress:@"192.168.10.53"];
    decksArray = [[NSMutableArray alloc]initWithObjects:deck1,deck2,deck3,nil];
    
    [prefs setBool:YES forKey:@"defaultstest"];
    
    [self savePrefs];

}

- (void) checkAllConnected{
    for (MMDeck2 *deck in decksArray) {
        if (!deck.socket1Connected) {
            [deck connect];
        }
    }

}


-(void) savePrefs{
    deckAddresses = [[NSMutableArray alloc]init];
    deckNames = [[NSMutableArray alloc]init];
    for (MMDeck2 *deck in decksArray) {
        if ([deck ipAddress]) {
            [deckAddresses addObject:[deck ipAddress]];
        }else{
            [deckAddresses addObject:@"0.0.0.0"];
        }
        if ([deck deckName]) {
            [deckNames addObject:[deck deckName]];
        }else{
            [deckNames addObject:@"Deck"];
        }
    }
    
    [prefs setObject:deckAddresses forKey:@"deckAddresses"];
    [prefs setObject:deckNames forKey:@"deckNames"];
    [prefs synchronize];

}




- (NSInteger)numberOfSectionsInTableView: (NSTableView *)tableView {
    return 1;
}

- (NSInteger)tableView: (NSTableView *)tableView numberOfRowsInSection: (NSInteger)section {
//    NSLog(@"%lu",(unsigned long)decksArray.count);

    return decksArray.count;
}


- (CGFloat)tableView:(NSTableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
//    if(selectedRowIndex && indexPath.row == selectedRowIndex.row) {
//        if (previousRow == 0) {
//            previousRow = 1;
//            return 385;
//        }else{
//            previousRow = 0;
//        }
//
//    }
    return 174;
}




- (BOOL)tableView:(NSTableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


- (IBAction)addDeck:(id)sender {
    
    MMDeck2 *deck = [[MMDeck2 alloc]initWithName:[NSString stringWithFormat:@"Deck%u", decksArray.count+1] ipAddress:[NSString stringWithFormat:@"192.168.10.1%u", decksArray.count+1]];
    [decksArray addObject:deck];
    [_mainTable reloadData];

    [self savePrefs];
    
}


- (IBAction)deleteDeck:(id)sender {
//    [decksArray removeObjectAtIndex:[[_mainTable indexPathForSelectedRow]row]];
    [[decksArray objectAtIndex:decksArray.count-1] disconnect];
    [decksArray removeObjectAtIndex:decksArray.count-1];
    [_mainTable reloadData];
    [self savePrefs];
}

- (IBAction)save:(id)sender{
    [self savePrefs];

}

- (IBAction)stopAll:(id)sender{
    for (MMDeck2 *deck in decksArray) {
        if ((deck.gang = YES)) {
            [deck stop];
        }
    }
    
}
- (IBAction)playAll:(id)sender{
    for (MMDeck2 *deck in decksArray) {
        if ((deck.gang = YES)) {
        [deck play];
        }
    }
    
}
- (IBAction)gotostartAll:(id)sender{
    for (MMDeck2 *deck in decksArray) {
        if ((deck.gang = YES)) {
            [deck gotostart];
        }
    }
    
}
- (IBAction)recordAll:(id)sender{
    for (MMDeck2 *deck in decksArray) {
        if ((deck.gang = YES)) {
//        [deck recordWithGroupName:[_groupFilenameField stringValue] includeDate:[_useTimeDateToggle] includeDeckname:_useDecknameToggle.on includeGroupName:YES];
        }
    }
    
}

- (IBAction)fastForwardAll:(id)sender {
    for (MMDeck2 *deck in decksArray) {
        if ((deck.gang = YES)) {
            [deck fastForward];
        }
    }
    
}

- (void)rewindAll {
    for (MMDeck2 *deck in decksArray) {
        if ((deck.gang = YES)) {
            [deck rewind];
        }
    }
}




@end
