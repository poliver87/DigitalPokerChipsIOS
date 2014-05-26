
//
//  DPCTableStatusMenu.m
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 23/04/14.
//
//

#import "DPCTableStatusMenu.h"
#import "DPCSprite.h"
#import "DPCTextFactory.h"
#import "DPCPlayerEntry.h"

@implementation DPCTableStatusMenu {
    int STATE_NONE,STATE_SHOW,STATE_OPENING,STATE_OPEN,
    STATE_CLOSING,STATE_CLOSED,STATE_HIDE;
    int animationState;
    
    float xHidden;
    float xOpen;
    float xClosed;
    float xBellButtonCentreOffset;
    float yFirstPlayerEntryOffset;
    float yPlayerEntryPitch;
}

-(id)init {
    if (self=[super init]) {
        STATE_NONE = 0;
        STATE_SHOW = 1;
        STATE_OPENING = 2;
        STATE_OPEN = 3;
        STATE_CLOSING = 4;
        STATE_CLOSED = 5;
        STATE_HIDE = 6;
        
        self.visible=NO;
        _background=[DPCSprite DPCSpriteWithFile:@"dialog.png"];
        [self addChild:_background];
        _handle=[DPCSprite DPCSpriteWithFile:@"table_button.png"];
        [self addChild:_handle];
        _tableName=[DPCTextLabel node];
        _tableName.color=[CCColor colorWithRed:1 green:1 blue:1];
        [self addChild:_tableName];
        _leaveButton=[DPCSprite DPCSpriteWithFile:@"button_red.png"];
        [self addChild:_leaveButton];
        _leaveButtonLabel=[DPCTextLabel node];
        _leaveButtonLabel.color=[CCColor colorWithRed:1 green:1 blue:1];
        _leaveButtonLabel.string=@"Leave";
        [self addChild:_leaveButtonLabel];
        _bellButton=[DPCSprite DPCSpriteWithFile:@"button_bell_red.png"];
        [self addChild:_bellButton];
        _playerList=[CCNode node];
        [self addChild:_playerList];
    }
    return self;
}

-(void)setDimensions:(CGSize)screenSize {
    [_background setRadiusX:screenSize.width*0.16f radiusY:screenSize.height*0.45f];
    _tableName.string=@"LONGNAME!";
    _tableName.fontSize=[DPCTextFactory getMaxTextSize:_tableName width:_background.radiusX*1.8f height:_background.radiusY*0.3f];
    _tableName.string=@"";
    [_handle setRadiusX:_background.radiusY*0.12f radiusY:_background.radiusY*0.3f];
    [_leaveButton setRadiusX:_background.radiusX*0.9f radiusY:_background.radiusY*0.14f];
    _leaveButtonLabel.fontSize=[DPCTextFactory getMaxTextSize:_leaveButtonLabel width:_leaveButton.radiusX*1.8f height:_leaveButton.radiusY*1.5f];
    [_bellButton setRadiusX:_background.radiusY*0.11f radiusY:_background.radiusY*0.11f];
    yPlayerEntryPitch=_background.radiusY*0.2f;
    _tableName.string=@"LONGNAME!";    
    int entryTextSize=[DPCTextFactory getMaxTextSize:_tableName width:_background.radiusX*0.9f height:_background.radiusY*0.1f];
    _tableName.string=@"";
    [DPCPlayerEntry setTextSize:entryTextSize];
}

-(void)setPositions:(CGSize)screenSize {
    xOpen=screenSize.width-_background.radiusX*0.98f;
    xHidden=screenSize.width+_background.radiusX*2;
    xClosed=screenSize.width+_background.radiusX;
    _playerList.position=ccp(0,0);
    self.position=ccp(xHidden,screenSize.height*0.445f);
    [self.background setPosition:ccp(0,0)];
    [self.handle setPosition:ccp(-_background.radiusX-_handle.radiusX*0.94f,_background.radiusY*0.3f)];
    [self.leaveButton setPosition:ccp(0,-_background.radiusY*0.8f)];
    [self.leaveButtonLabel setPosition:self.leaveButton.position];
    [self.tableName setPosition:ccp(0,_background.radiusY*0.85f)];
    xBellButtonCentreOffset=_background.radiusX*0.8f;
    yFirstPlayerEntryOffset=_background.radiusY*0.65f;
    [DPCPlayerEntry setNameXOffset:-0.5f*_background.radiusX];
    [DPCPlayerEntry setAmountXOffset:0.5f*_background.radiusX];
}

-(void)animate:(float)delta {
    if (animationState==STATE_OPENING) {
        if (fabsf(xOpen-self.position.x)<2) {
            animationState=STATE_OPEN;
        } else {
            self.position=ccp(self.position.x+delta*8*(xOpen-self.position.x),self.position.y);
        }
    } else if (animationState==STATE_CLOSING) {
        if (fabsf(xClosed-self.position.x)<2) {
            animationState=STATE_CLOSED;
        } else {
            self.position=ccp(self.position.x+delta*8*(xClosed-self.position.x),self.position.y);
        }
    } else if (animationState==STATE_SHOW) {
        if (fabsf(xClosed-self.position.x)<2) {
            animationState=STATE_CLOSED;
            self.handle.touchable=YES;
        } else {
            self.position=ccp(self.position.x+delta*8*(xClosed-self.position.x),self.position.y);
        }
    } else if (animationState==STATE_HIDE) {
        if (fabsf(xHidden-self.position.x)<4) {
            [self disappear];
        } else {
            self.position=ccp(self.position.x+delta*8*(xHidden-self.position.x),self.position.y);
        }
    }
}

-(void)touchDragged:(CGPoint)touchPoint {
    float xInParent=[self.parent convertToNodeSpace:touchPoint].x+self.handle.radiusX+self.background.radiusX;
    if (xInParent<xOpen) {
        xInParent=xOpen;
    }
    
    self.position=ccp(xInParent,self.position.y);
}

-(void)show {
    if (!self.visible) {
        self.visible=YES;
        self.position=ccp(xHidden,self.position.y);
    }
    _bellButton.visible=NO;
    animationState=STATE_SHOW;
    self.handle.touchable=YES;
}

-(void)remove {
    self.handle.touchable=NO;
    animationState=STATE_HIDE;
}

-(void)disappear {
    animationState=STATE_NONE;
    self.handle.touchable=NO;
    self.leaveButton.touchable=NO;
    [self disableNudge];
    [_playerList removeAllChildrenWithCleanup:NO];
    self.visible=NO;
}

-(void)open {
    animationState=STATE_OPENING;
    self.leaveButton.touchable=YES;
    
    
}

-(void)close {
    animationState=STATE_CLOSING;
    self.leaveButton.touchable=NO;
    
}

-(BOOL)menuShouldOpen {
    if (fabsf(self.position.x-xOpen)<fabsf(self.position.x-xClosed)) {
        return YES;
    } else {
        return NO;
    }
}

-(void)syncStatusMenu:(NSArray *)newList {
    NSArray* sortedList=[newList sortedArrayUsingSelector:@selector(compare:)];
    [self.playerList removeAllChildrenWithCleanup:NO];
    for (int i=0;i<newList.count;i++) {
        DPCPlayerEntry* thisEntry=[sortedList objectAtIndex:i];
        thisEntry.position=ccp(0,yFirstPlayerEntryOffset-i*yPlayerEntryPitch);
        [self.playerList addChild:thisEntry];
    }
    //sort the list
}

-(void)enableNudge:(NSString *)name {
    _bellButton.opacity=1;
    _bellButton.touchable=YES;
    _nudgeName=name;
    for (int i=0;i<self.playerList.children.count;i++) {
        DPCPlayerEntry* thisEntry=[self.playerList.children objectAtIndex:i];
        if ([thisEntry.playerName.string isEqualToString:name]) {
            float yBell=thisEntry.position.y;
            _bellButton.position=ccp(xBellButtonCentreOffset,yBell);
        }
    }
}

-(void)disableNudge {
    _bellButton.opacity=0;
    _bellButton.touchable=NO;
}


@end
