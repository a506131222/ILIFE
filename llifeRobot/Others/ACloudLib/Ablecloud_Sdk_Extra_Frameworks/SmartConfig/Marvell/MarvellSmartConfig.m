//
//  MarvellSmartConfig.m
//  ac-service-ios-Demo
//
//  Created by __zimu on 16/7/6.
//  Copyright © 2016年 OK. All rights reserved.
//

#import "MarvellSmartConfig.h"
#import "zlib.h"
#import "arpa/inet.h"


BOOL isChecked;
NSTimer *marvellTimer;
int TimerCount;
char ssid[33];
unsigned char bssid[6];
char passphrase[64];
int passLen;
int passLength;
unsigned int ssidLength;
int invalidKey;
int invalidPassphrase;
unsigned long passCRC;
unsigned long ssidCRC;


@interface MarvellSmartConfig () <NSNetServiceBrowserDelegate>
@property (assign, nonatomic) NSInteger state;
@property (assign, nonatomic) NSInteger substate;
@end

@implementation MarvellSmartConfig


- (void)marvell:(NSString *)ssid password:(NSString *)password {
    
    preamble[0] = 0x45;
    preamble[1] = 0x5a;
    preamble[2] = 0x50;
    preamble[3] = 0x52;
    preamble[4] = 0x32;
    preamble[5] = 0x32;
    
    [self xmitterTask:ssid password:password];
}

- (void)stopSmartConfig {
    if ([marvellTimer isValid] && [marvellTimer isKindOfClass:[NSTimer class]]) {
        [marvellTimer invalidate];
        marvellTimer = nil;
    }
}

- (void)xmitterTask:(NSString *)ssidStr password:(NSString *)password {
    ssidLength = (unsigned int)ssidStr.length;
    
    for(int i = 0 ;i < [ssidStr length]; i++) {
        ssid[i] = [ssidStr characterAtIndex:i];
    }
    
    const char *pwd = [password UTF8String];
    
    strcpy(passphrase, pwd);
    passLength = (int)password.length;
    passLen = passLength;
    unsigned char *str = (unsigned char *)pwd;
    unsigned char *str1 = (unsigned char *)ssid;
    
    passCRC = crc32(0, str, passLen);
    ssidCRC = crc32(0, str1, ssidLength);
    
//    NSLog(@"CRC is %lu", passCRC);
    
    passCRC = passCRC & 0xffffffff;
    ssidCRC = ssidCRC & 0xffffffff;
    
//    NSLog(@"Passphrase %d %d %s", passLen, passLength, passphrase);
//    NSLog(@"CRC32 %lu", passCRC);
    
    marvellTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(statemachine) userInfo:nil repeats:YES];
    _state = 0;
    _substate = 0;
}


-(void)statemachine
{
    //    NSLog(@"statemachine");
    NSString *temp;
    if (_state == 0 && _substate == 0) {
        TimerCount++;
        if (TimerCount % 10 == 0) {
            temp = [NSString stringWithFormat:@"Information sent %d times.", TimerCount];
        }
    }
//    if (TimerCount >= 50) {
//        [self queryMdnsService];
////        NSLog(@"Browsing services");
//        
//        if ([timer isValid] && [timer isKindOfClass:[NSTimer class]]) {
//            [timer invalidate];
//            timer = nil;
//        }
//        _state = 0;
//        _substate = 0;
//        TimerCount = 0;
//    }
    
    switch(_state) {
        case 0:
            if (_substate == 3) {
                _state = 1;
                _substate = 0;
            } else {
                [self xmitState0:_substate];
                _substate++;
            }
            break;
        case 1:
            
            [self xmitState1:_substate LengthSSID:2];
            _substate++;
            if (ssidLength % 2 == 1) {
                if (_substate * 2 == ssidLength + 5) {
                    [self xmitState1:_substate LengthSSID: 1];
                    _state = 2;
                    _substate = 0;
                }
            } else {
                if ((_substate - 1) * 2 == (ssidLength + 4)) {
                    _state = 2;
                    _substate = 0;
                }
            }
            break;
        case 2:
            [self xmitState2:_substate LengthPassphrase:2];
            
            _substate++;
            if (passLen % 2 == 1) {
                if (_substate * 2 == passLen + 5) {
                    [self xmitState2:_substate LengthPassphrase: 1];
                    _state = 0;
                    _substate = 0;
                }
            } else {
                if ((_substate - 1) * 2 == (passLen + 4)) {
                    _state = 0;
                    _substate = 0;
                }
            }
            break;
            
        default:
            NSLog(@"MRVL: I should not be here!");
    }
}



int count = 0;
char preamble[6];

-(void)xmitState0:(int)substate
{
    int i, j, k;
    
    k = preamble[2  * substate];
    j = preamble[2 * substate + 1];
    i = substate | 0x78;
    [self xmitRaw:i data: j substate: k];
}

-(void)xmitState1:(int)substate LengthSSID:(int)len
{
    if (substate == 0) {
        int u = 0x40;
        [self xmitRaw:u data:ssidLength substate: ssidLength];
    } else if (substate == 1 || substate == 2) {
        int k = (int) (ssidCRC >> ((2 * (substate - 1) + 0) * 8)) & 0xff;
        int j = (int) (ssidCRC >> ((2 * (substate - 1) + 1) * 8)) & 0xff;
        int i = substate | 0x40;
        [self xmitRaw:i data: j substate: k];
    } else {
        int u = 0x40 | substate;
        int l = (0xff & ssid[(2 * (substate - 3))]);
        int m;
        if (len == 2)
            m = (0xff & ssid[(2 * (substate - 3) + 1)]);
        else
            m = 0;
        [self xmitRaw:u data:m substate:l];
    }
}

-(void)xmitState2: (int)substate LengthPassphrase:(int)len
{
    if (substate == 0) {
        int u = 0x00;
        [self xmitRaw:u data:passLen substate: passLen];
    } else if (substate == 1 || substate == 2) {
        int k = (int) (passCRC >> ((2 * (substate - 1) + 0) * 8)) & 0xff;
        int j = (int) (passCRC >> ((2 * (substate - 1) + 1) * 8)) & 0xff;
        int i = substate;
        [self xmitRaw:i data: j substate: k];
    } else {
        int u = substate;
        int l = (0xff & passphrase[(2 * (substate - 3))]);
        int m;
        if (len == 2)
            m = (0xff & passphrase[(2 * (substate - 3)) + 1]);
        else
            m = 0;
        [self xmitRaw:u data:m substate:l];
    }
}

-(void)xmitState3: (int)substate
{
    int i, j, k;
    
    k = (int) (passCRC >> ((2 * _substate + 0) * 8)) & 0xff;
    j = (int) (passCRC >> ((2 * _substate + 1) * 8)) & 0xff;
    i = substate | 0x7c;
    
    [self xmitRaw:i data: j substate: k];
}
struct icmphdr
{
    u_int16_t qr;       /* type sub-code */
    u_int16_t opcode;
    u_int16_t aa;
    u_int16_t tc;
    u_int16_t rd;
    u_int16_t ra;
    u_int16_t z;
    u_int16_t ad;
    u_int16_t cd;
    u_int16_t rcode;
    u_int16_t q_count;
};



-(void)queryMdnsService
{
    NSNetServiceBrowser *serviceBrowser;
    
    serviceBrowser = [[NSNetServiceBrowser alloc] init];
    [serviceBrowser setDelegate:self];
    [serviceBrowser searchForServicesOfType:@"_ezconnect._tcp" inDomain:@"local"];
    
//    NSLog(@"Sending mdns query");
    
}

-(void) xmitRaw:(int) u data:(int) m substate:(int) l
{
    int sock;
    struct sockaddr_in addr;
    char buf = 'a';
    if (count == 110)
        count = 0;
    NSMutableString* getnamebyaddr = [NSMutableString stringWithFormat:@"226.%d.%d.%d", u, m, l];
    const char * d_addr = [getnamebyaddr UTF8String];
//    NSLog(@"String %@", getnamebyaddr);
    
    if ((sock = socket(PF_INET, SOCK_DGRAM, 0)) < 0) {
//        NSLog(@"ERROR: broadcastMessage - socket() failed");
        return;
    }
    
    bzero((char *)&addr, sizeof(struct sockaddr_in));
    
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = inet_addr(d_addr);
    addr.sin_port        = htons(10000);
    
    if ((sendto(sock, &buf, sizeof(buf), 0, (struct sockaddr *) &addr, sizeof(addr))) != 1) {
//        NSLog(@"Errno %d", errno);
//        NSLog(@"ERROR: broadcastMessage - sendto() sent incorrect number of bytes");
        return;
    }
    
    close(sock);
}



@end
