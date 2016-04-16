//
//  MMDeck2.m
//  HyperControllerDesktop
//
//  Created by Luke Irvine on 8/04/2016.
//  Copyright © 2016 MirrorMedia. All rights reserved.
//

#import "MMDeck2.h"

#define REMOTE_ENABLE 3

@implementation MMDeck2

#define COLLAPSED_DECK 174
#define EXPANDED_DECK 385


{
    GCDAsyncSocket *socket1;
    int test;
    int counter;
    BOOL detailPressed;
    NSMutableArray *clipsArray;
    int clips;
    int clipLoop;
    NSTimer *infoTimer;
    NSTimer *getInfoTimer;
    NSArray * clipsArrayAllInfo;
    int slotID;
    NSTimer *slotInfoTimer;
    int buttonRepeat;
    NSTextField *currentTextField;
    
}
@synthesize connectTimer;
@synthesize socket1Connected;



//- (id)initWithStyle:(NSTableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
//{
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    if (self) {
//        //        NSLog(@"test");
//    }
//    return self;
//}


//- (instancetype)initWithName: (NSString*)name ipAddress:(NSString*)address
//{
//    self = [super init];
//    if (self) {
//        NSArray *array = [[NSBundle mainBundle] loadNibFile:@"deck" externalNameTable:<#(null_unspecified NSDictionary *)#> withZone:<#(null_unspecified NSZone *)#>
//        self = [array objectAtIndex:0];
//        _ipAddress = address;xzx
//        _deckName = name;
//        clipsArray = [[NSMutableArray alloc]init];
//        _rowHeightCustom = COLLAPSED_DECK;
//        socket1 = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
//        
//        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//        
//        [nc addObserver:self selector:@selector(keyboardWillShow:) name:
//         UIKeyboardWillShowNotification object:nil];
//        
//        [nc addObserver:self selector:@selector(keyboardWillHide:) name:
//         UIKeyboardWillHideNotification object:nil];
//        
//        tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
//                                                                action:@selector(didTapAnywhere:)];
//        
//    }
//    return self;
//}

+ (NSString *)reuseIdentifier {
    return @"mmCellIdentifier";
}


- (void)awakeFromNib {
}


- (void)checkConnected:(id)sender{
//    _ipAddress = _ipField.text;
//    _deckName = _nameLabel.text;
    if (!socket1Connected) {
        [socket1 disconnect];
        counter = 0;
        [self connectionTimer];
    }
    
    
    
}

- (void) connectionTimer{
    [self.connectTimer invalidate];
    self.connectTimer =  [NSTimer scheduledTimerWithTimeInterval:2
                                                          target:self
                                                        selector:@selector(hostConnect:)
                                                        userInfo:nil
                                                         repeats:YES];
}


- (void)hostConnect:(id)sender {
    //    NSLog(@"Connecting to:%@",_ipAddress);
    
    NSError *err = nil;
    counter += 1;
    if (counter > 5) {
        [self.connectTimer invalidate];
        connectionIndicator = 0;
    }
    [socket1 disconnect];
    connectionIndicator = 0;
    if (![socket1 connectToHost:[[NSString alloc]initWithFormat: @"%@",_ipAddress] onPort:9993 error:&err]) {
        //        NSLog(@"%@", err);
    }
    
    [self startRead];
}

- (void) disconnect{
    [socket1 disconnect];
}


- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    //    NSLog(@"Connected! port:%D host:%@",port,host);
    [self.connectTimer invalidate];
    socket1Connected = YES;
    connectionIndicator = 1;
    //[_readout setText:[NSString stringWithFormat:@"%@\nConnected %@:%i",_readout.text, host, port]];
    if (sock == socket1) {
        
        [socket1 writeData:[@"remote: override: true\r\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:REMOTE_ENABLE];
        [slotInfoTimer invalidate];
        slotInfoTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                         target:self
                                                       selector:@selector(getSlotInfo)
                                                       userInfo:nil
                                                        repeats:YES];
        [infoTimer invalidate];
        infoTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                     target:self
                                                   selector:@selector(getInfoFromDeck)
                                                   userInfo:nil
                                                    repeats:YES];
        
    }
    
}

-(void) getSlotInfo{
    [socket1 writeData:[@"slot info\r\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:REMOTE_ENABLE];
}


- (void) getInfoFromDeck{
    
    [socket1 writeData:[@"transport info\r\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    [self startRead];
    
}



- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    if (socket1Connected) {
        socket1Connected = NO;
        [self checkConnected:nil];
    }
    connectionIndicator = 0;
    
}



- (void)startRead{
    [socket1 readDataToData:[GCDAsyncSocket CRData] withTimeout:-1 tag:0];
}


- (NSString *) formatTime: (unsigned long) interval{
    unsigned long seconds = interval;
    //    unsigned long seconds = milliseconds / 1000;
    //    milliseconds %= 1000;
    unsigned long minutes = seconds / 60;
    seconds %= 60;
    unsigned long hours = minutes / 60;
    minutes %= 60;
    
    NSMutableString * result = [NSMutableString new];
    
    if(hours)
        [result appendFormat: @"%02lu:", hours];
    
    [result appendFormat: @"%02lu:", minutes];
    [result appendFormat: @"%02lu", seconds];
    //    [result appendFormat: @"%2d",milliseconds];
    
    return result;
}


- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSString *readString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    //    NSLog(@"%@",readString);
    
    
    if ([readString rangeOfString:@"slot id:"].length > 0) {
        slotID = [readString substringWithRange:NSMakeRange(10, 1)].intValue;
    }
    if ([readString rangeOfString:@"recording time:"].length > 0) {
        
        NSString *timeRemianing = [self formatTime:[readString substringWithRange:NSMakeRange(17, 5)].intValue];
        
        slot1RemainTextField = [NSString stringWithFormat:@"%@",timeRemianing];
        
    }
 
    if ([readString rangeOfString:@"clip count:"].length > 0) {
        clipsArrayAllInfo = [[NSMutableArray alloc]init];
        clipsArray = [[NSMutableArray alloc]init];
        NSString *clipAmountString = [readString substringWithRange:NSMakeRange(13, 2)];
        clips = clipAmountString.integerValue;
        //        NSLog(@"%@-------",readString);
        if (clips == 0) {
        }
        
    }
    if (clips > 0) {
        ;
        NSRange range = [readString rangeOfString:@".mov"];
        if (range.location != NSNotFound) {
            //            NSLog(@"Found the range of the substring at (%d, %d)", range.location, range.location + range.length);
            
            NSString *clipName = [readString substringWithRange:NSMakeRange(4, range.length + range.location -4)];
            //            NSLog(@"%@",clipName);
            if (clipLoop <= clips) {
                //            clipsArrayAllInfo = [clipName componentsSeparatedByString:@" "];
                //            NSLog(@"Array values are : %@",clipsArrayAllInfo);
                [clipsArray addObject:clipName];
                //////////////////////////
                clipLoop += 1;
                
            }
            if (clipLoop == clips) {
                clips = 0;
                clipLoop = 0;
            }
        }
        
        
    }
    
    
    if ([readString rangeOfString:@"display timecode:"].length > 0) {
        _timecode = [readString substringWithRange:NSMakeRange(18, 12)];
    }
    if ([readString rangeOfString:@"status: play"].length > 0) {
        playButton = [NSImage imageNamed:@"play_on"];
        stopButton =[NSImage imageNamed:@"stop"];
        recordButton =[NSImage imageNamed:@"recordOff"];
        fastForwardButton = [NSImage imageNamed:@"FastForward"];
        rewindButton = [NSImage imageNamed:@"Rewind"];
    } if ([readString rangeOfString:@"status: stopped"].length > 0||[readString rangeOfString:@"status: preview"].length > 0) {
        playButton = [NSImage imageNamed:@"play"];
        stopButton = [NSImage imageNamed:@"stop_on"];
        recordButton = [NSImage imageNamed:@"recordOff"];
        fastForwardButton = [NSImage imageNamed:@"FastForward"];
        rewindButton = [NSImage imageNamed:@"Rewind"];
    } if ([readString rangeOfString:@"status: record"].length > 0) {
        playButton = [NSImage imageNamed:@"play"];
        stopButton = [NSImage imageNamed:@"stop"];
        recordButton = [NSImage imageNamed:@"recordOn"];
        fastForwardButton = [NSImage imageNamed:@"FastForward"];
        rewindButton = [NSImage imageNamed:@"Rewind"];
    } if ([readString rangeOfString:@"status: forward"].length > 0) {
        playButton = [NSImage imageNamed:@"play"];
        stopButton = [NSImage imageNamed:@"stop"];
        recordButton = [NSImage imageNamed:@"recordOff"];
        fastForwardButton = [NSImage imageNamed:@"FastForward_On"];
        rewindButton = [NSImage imageNamed:@"Rewind"];
    } if ([readString rangeOfString:@"status: rewind"].length > 0) {
        playButton = [NSImage imageNamed:@"play"];
        stopButton = [NSImage imageNamed:@"stop"];
        recordButton = [NSImage imageNamed:@"recordOff"];
        fastForwardButton = [NSImage imageNamed:@"FastForward"];
        rewindButton = [NSImage imageNamed:@"Rewind_On"];
    }
    
    
    [self startRead];
}

- (NSInteger)numberOfSectionsInTableView: (NSTableView *)tableView {
    return 1;
}

- (NSInteger)tableView: (NSTableView *)tableView numberOfRowsInSection: (NSInteger)section {
    
    
    return clipsArray.count;
}




//- (NSTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    static NSString *CellIdentifier =@"cell";
//    NSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil){
//        cell = [[[NSBundle mainBundle] loadNibNamed:@"clipCell" owner:nil options:nil] objectAtIndex:0];
//    }
//    if (clipsArray.count > 0){
//        cell.textLabel.text=[clipsArray objectAtIndex:indexPath.row];
//    }
//    return cell;
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    int clipNumber = indexPath.row + 1;
//    [socket1 writeData:[[NSString stringWithFormat:@"goto: clip id: %i\r\n",clipNumber] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
//    //    [socket1 writeData:[[NSString stringWithFormat:@"notify: slot: true %i\r\n",clipNumber] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
//}
//
//

- (void)stop:(id)sender {
    buttonRepeat = 0;
    [socket1 writeData:[@"stop\r\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    getInfoTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                    target:self
                                                  selector:@selector(getClipsFromDeck)
                                                  userInfo:nil
                                                   repeats:NO];
    [self startRead];
    
    
}

- (void)play:(id)sender {
    [socket1 writeData:[@"play\r\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    buttonRepeat = 1;
    
}

- (void)gotostart:(id)sender {
    
    [socket1 writeData:[@"goto: clip: start\r\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    buttonRepeat = 2;
}

- (void)gotoend:(id)sender {
    [socket1 writeData:[@"goto: clip: end\r\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    buttonRepeat = 3;
    
}

- (void)rewind:(id)sender {
    if (socket1Connected) {
        if (buttonRepeat != 4 && buttonRepeat != 44) {
            [socket1 writeData:[@"play: speed: -400\r\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
            buttonRepeat = 4;
        } else if (buttonRepeat == 4) {
            [socket1 writeData:[@"play: speed: -1000\r\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
            buttonRepeat = 44;
        } else if (buttonRepeat == 44) {
            [socket1 writeData:[@"play: speed: -1600\r\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
        }
    }
}

- (void)fastForward:(id)sender {
    if (socket1Connected) {
        if (buttonRepeat != 5 && buttonRepeat != 55) {
            [socket1 writeData:[@"play: speed: 400\r\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
            buttonRepeat = 5;
        } else if (buttonRepeat == 5) {
            [socket1 writeData:[@"play: speed: 1000\r\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
            buttonRepeat = 55;
        } else if (buttonRepeat == 55) {
            [socket1 writeData:[@"play: speed: 1600\r\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
        }
    }
}

- (void)recordButton:(id)sender {
    [self recordWithGroupName:@"" includeDate:NO includeDeckname:YES includeGroupName:NO];
    buttonRepeat = 6;
}

- (void) recordWithGroupName:(NSString*)groupName includeDate:(BOOL)dateON includeDeckname:(BOOL)DecknameON includeGroupName:(BOOL)GroupON{
    if (DecknameON) {
        groupName = [groupName stringByAppendingString:@"_"];
    }
    if (!GroupON) {
        groupName = @"";
    }
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"yyyyMMdd_hh-mm-ss_"];
    NSString *timeDate;
    if (dateON) {
        timeDate = [DateFormatter stringFromDate:[NSDate date]];
    } else {
        timeDate = @"";
    }
    
    NSString *Dname;
    if (DecknameON) {
        Dname = _deckName;
    } else {
        Dname = @"";
    }
    
    NSString *fullFileName = [NSString stringWithFormat:@"%@%@%@",timeDate,groupName,Dname];
    [socket1 writeData:[[NSString stringWithFormat:@"record: name:%@_\r\n",fullFileName] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    //    NSLog(@"%@",fullFileName);
}

- (void)connect:(id)sender {
    socket1Connected = NO;
    [self checkConnected:nil];
}


-(void)changeSlotToSlotNumber:(int)SlotNumber{
    if(SlotNumber == 0){
        [socket1 writeData:[@"slot select: slot id: 1\r\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
        getInfoTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                        target:self
                                                      selector:@selector(getClipsFromDeck)
                                                      userInfo:nil
                                                       repeats:NO];
        
    }
    if(SlotNumber == 1){
        [socket1 writeData:[@"slot select: slot id: 2\r\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
        getInfoTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                        target:self
                                                      selector:@selector(getClipsFromDeck)
                                                      userInfo:nil
                                                       repeats:NO];
    }
}



- (void) getClipsFromDeck{
    [socket1 writeData:[@"clips get\r\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
