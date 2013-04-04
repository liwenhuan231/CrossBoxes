//
//  GameLayer.m
//  CrossBoxes
//
//  Created by Roger on 12-8-26.
//  Copyright __MyCompanyName__ 2012年. All rights reserved.
//


// Import the interfaces
#import "GameLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "SimpleAudioEngine.h"

#pragma mark - GameLayer

@implementation GameHud

- (id) init
{
    if ((self = [super init])) {
        CGSize size = [[CCDirector sharedDirector] winSize];
        label = [CCLabelTTF labelWithString:@"0" dimensions:CGSizeMake(50,20) hAlignment:UITextAlignmentRight fontName:@"Marion-Bold" fontSize:18.0];
        label.color = ccc3(255, 255, 255);
        int margin = 5;
        label.position = ccp(size.width - (label.contentSize.width / 2) - margin, label.contentSize.height / 2 - margin);
        [self addChild:label];
    }
    
    return self;
}

- (void) scoreChanged:(int)score
{
    [label setString:[NSString stringWithFormat:@"%d", score]];
}

@end

// GameLayer implementation
@implementation GameLayer

@synthesize boxTagArray     = _boxTagArray;
@synthesize boxNameArray    = _boxNameArray;
@synthesize hud             = _hud;
@synthesize score           = _score;

+ (CCScene *) scene
{
    CCScene *scene = [CCScene node];
    
    GameLayer *layer = [GameLayer node];
    
    [layer setContentSize:CGSizeMake(480, 288)];
    [layer setPosition:CGPointMake(0, 16)];
    
    [scene addChild:layer];
    
    GameHud *hud = [GameHud node];
    [scene addChild:hud];
    layer.hud = hud;
    
    return scene;
}


- (id) init
{
    [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"music.caf"];
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"music.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"touch.wav"];
    
    if (self = [super initWithColor:ccc4(255, 255, 255, 255)]) {
        int x, y;
        int tag = 1;
        for (y = 24; y <= 264; y = y + 48) {
            for (x = 24; x <= 488; x = x + 48) {
                [self addBoxesSetX:x SetY:y TagId:tag];
                tag ++;
            }
        }
        
        self.isTouchEnabled = YES;
        
    }
    
    _boxTagArray    = [[NSMutableArray alloc] init];
    _boxNameArray   = [[NSMutableArray alloc] init];
    
    return self;
}

- (void) addBoxesSetX: (int) x SetY: (int) y TagId: (int) tag
{
    CCSprite *_PIC01 = [CCSprite spriteWithFile:@"pic01.png"];
    CCSprite *_PIC02 = [CCSprite spriteWithFile:@"pic02.png"];
    CCSprite *_PIC03 = [CCSprite spriteWithFile:@"pic03.png"];
    CCSprite *_PIC04 = [CCSprite spriteWithFile:@"pic04.png"];
    CCSprite *_PIC05 = [CCSprite spriteWithFile:@"pic05.png"];
    
    CCSprite *PICS[5] = {_PIC01, _PIC02, _PIC03, _PIC04, _PIC05};
    int randomBoxIndex = arc4random() % 5;
    PICS[randomBoxIndex].position = ccp(x, y);
    PICS[randomBoxIndex].opacity = 255;
    PICS[randomBoxIndex].tag = tag;
    [self addChild:PICS[randomBoxIndex]];
}

- (BOOL) isNotRepeat //判断路径是否重复
{
    NSString *firstTagName;
    NSString *secondTagName;
    
    NSMutableArray *removedBoxArray = [self removeRepeatNumber:_boxTagArray];
    
    for (int j=0; j<removedBoxArray.count-2; j++) {
        firstTagName = [removedBoxArray objectAtIndex:j];
        secondTagName = [removedBoxArray objectAtIndex:j+2];
        if ([firstTagName isEqualToString:secondTagName]) {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL) isNeighbor //判断路径是否为竖线或横线
{
    int firstTagNum;
    int secondTagNum;
    for (int i=0; i<_boxTagArray.count-1; i++) {
        firstTagNum = [[_boxTagArray objectAtIndex:i] intValue];
        secondTagNum = [[_boxTagArray objectAtIndex:i+1] intValue];
        if ((firstTagNum + 1 == secondTagNum) || (firstTagNum - 1 == secondTagNum) ||
            (firstTagNum + 10 == secondTagNum) || (firstTagNum - 10 == secondTagNum) ||
            (firstTagNum == secondTagNum)) {
            return YES;
        }
    }
    return NO;
}

- (BOOL) countTag //判断路径内所选方块个数是否大于等于3
{
    int count = 1;
    NSString *firstTag;
    NSString *secondTag;
    for (int i=0; i<_boxTagArray.count-1; i++) {
        firstTag = [_boxTagArray objectAtIndex:i];
        secondTag = [_boxTagArray objectAtIndex:i+1];
        if (!([firstTag isEqualToString:secondTag])) {
            count = count + 1;
        }
    }
    if (count < 3) {
        return NO;
    }
    return YES;
}

- (BOOL) compareArray //判断是否为同一类型的方块
{
    NSString *firstName;
    NSString *secondName;
    for (int i=0; i<_boxNameArray.count-1; i++) {
        firstName   = [_boxNameArray objectAtIndex:i];
        secondName  = [_boxNameArray objectAtIndex:i+1];
        if (!([firstName isEqualToString:secondName])) {
            return NO;
        }
    }
    return YES;
}

- (BOOL) removeAble //判断是否还有方块可以被消除
{
    int moveAble = 0;
    
    CCSprite *sprite;
    
    NSMutableDictionary *sprites = [[NSMutableDictionary alloc] init];
    
    for (int i=1; i<61; i++) {
        sprite = (CCSprite *)[self getChildByTag:i];
        
        NSString *tag = [NSString stringWithFormat:@"%d", sprite.tag];
        NSString *name = [NSString stringWithFormat:@"%d", sprite.texture.name];
        
        [sprites setObject:name forKey:tag];
    }
    
    for (int i=1; i<5; i++) {
        for (int j=i*10+2; j<i*10+9; j++) {
            
            //中间三个方块的TAG
            int mMidTag = [[sprites objectForKey:[NSString stringWithFormat:@"%d", j]] intValue];
            int rMidTag = [[sprites objectForKey:[NSString stringWithFormat:@"%d", (j+1)]] intValue];
            int lMidTag = [[sprites objectForKey:[NSString stringWithFormat:@"%d", (j-1)]] intValue];
            
            NSLog(@"%d, %d, %d \n", lMidTag, mMidTag, rMidTag);
            
            //下方三个方块的TAG
            int mBtmTag = [[sprites objectForKey:[NSString stringWithFormat:@"%d", (j-10)]] intValue];
            int rBtmTag = [[sprites objectForKey:[NSString stringWithFormat:@"%d", (j-9)]] intValue];
            int lBtmTag = [[sprites objectForKey:[NSString stringWithFormat:@"%d", (j-11)]] intValue];
            
            //上方三个方块的TAG
            int mTopTag = [[sprites objectForKey:[NSString stringWithFormat:@"%d", (j+10)]] intValue];
            int rTopTag = [[sprites objectForKey:[NSString stringWithFormat:@"%d", (j+11)]] intValue];
            int lTopTag = [[sprites objectForKey:[NSString stringWithFormat:@"%d", (j+9)]] intValue];
            
            if (mMidTag == rMidTag && mMidTag == lMidTag) {
                moveAble = 1;
            }
            
            if (mMidTag == mTopTag && mMidTag == mBtmTag) {
                moveAble = 1;
            }
            
            if (mMidTag == lBtmTag && mMidTag == mBtmTag) {
                moveAble = 1;
            }
            
            if (mMidTag == rBtmTag && mMidTag == mBtmTag) {
                moveAble = 1;
            }
            
            if (mMidTag == lTopTag && mMidTag == mTopTag) {
                moveAble = 1;
            }
            
            if (mMidTag == rTopTag && mMidTag == mTopTag) {
                moveAble = 1;
            }
            
            if (mMidTag == lBtmTag && mMidTag == lMidTag) {
                moveAble = 1;
            }
            
            if (mMidTag == rBtmTag && mMidTag == rMidTag) {
                moveAble = 1;
            }
            
            if (mMidTag == lTopTag && mMidTag == lMidTag) {
                moveAble = 1;
            }
            
            if (mMidTag == rTopTag && mMidTag == rMidTag) {
                moveAble = 1;
            }
        }
        
    }
    
    NSLog(@"%d", moveAble);
    
    //    for (id keys in [sprites allKeys]) {
    //        NSLog(@"%@, %@ \n", keys, [sprites objectForKey:keys]);
    //    }
    
    if (moveAble == 0) {
        return NO;
    }else{
        return YES;
    }
    
    moveAble = 0;
}

- (NSMutableArray *) removeRepeatNumber:(NSMutableArray *)array //将NSMutableArray中重复的值移除
{
    NSString *firstNum;
    NSString *secondNum;
    NSString *lastNum;
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    for (int i=0; i<array.count-1; i++) {
        firstNum = [array objectAtIndex:i];
        secondNum = [array objectAtIndex:i+1];
        if (!([firstNum isEqualToString:secondNum])) {
            [tempArray addObject:firstNum];
        }
        lastNum = secondNum;
    }
    
    [tempArray addObject:lastNum];
    
    return tempArray;
}

- (void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    int curX, curY, curTag;
    NSString *curBoxName, *curTagName;
    CCSprite *sprite;
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    curX = 10 - (480 - (int)location.x) / 48;
    curY = 6  - (304 - (int)location.y) / 48;
    curTag = (curY - 1) * 10 + curX;
    sprite = (CCSprite *)[self getChildByTag:curTag];
    curBoxName = [NSString stringWithFormat:@"%d", sprite.texture.name];
    curTagName = [NSString stringWithFormat:@"%d", curTag];
    [_boxTagArray addObject:curTagName];
    [_boxNameArray addObject:curBoxName];
    sprite.scale = 1.20;
    sprite.zOrder = 1;
    sprite.opacity = 150;
    
}

- (void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [touches anyObject];
    
    if (touch.tapCount == 1 && [_boxTagArray count] == 0 && [_boxNameArray count] == 0) {
        return;
    }
    
    int moved = 0;
    CCSprite *sprite;
    
    _boxNameArray = [self removeRepeatNumber:_boxNameArray];
    _boxTagArray  = [self removeRepeatNumber:_boxTagArray];
    
    for (int i=0; i<_boxTagArray.count; i++) {
        if ([self compareArray] && [self countTag] && [self isNeighbor] && [self isNotRepeat]){
            sprite = (CCSprite *)[self getChildByTag:[[_boxTagArray objectAtIndex:i] intValue]];
            [self removeChild:sprite cleanup:YES];
            moved = 1;
        }else {
            sprite = (CCSprite *)[self getChildByTag:[[_boxTagArray objectAtIndex:i] intValue]];
            sprite.scale = 1;
            sprite.zOrder = 0;
            sprite.opacity = 255;
            moved = 0;
        }
    }
    
    if (moved == 1) {
        
        int firstColNum;
        int secondColNum;
        int key, value;
        
        NSArray *keys;
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        int count = 0;
        
        for (int i=0; i<_boxTagArray.count; i++) {
            
            firstColNum  = [[_boxTagArray objectAtIndex:i] intValue] % 10;
            
            if (firstColNum == 0) {
                firstColNum = 10;
            }
            
            for (int j=0; j<_boxTagArray.count; j++) {
                
                secondColNum = [[_boxTagArray objectAtIndex:j] intValue] % 10;
                
                if (secondColNum == 0) {
                    secondColNum = 10;
                }
                
                if (firstColNum == secondColNum) {
                    count = count + 1;
                }
            }
            
            NSString *colIndex = [NSString stringWithFormat:@"%d", firstColNum];
            NSString *colCount = [NSString stringWithFormat:@"%d", count];
            [dict setObject:colCount forKey:colIndex];
            count = 0;
        }
        
        keys = [dict allKeys];
        
        for (int i=0;i<[keys count];i++){
            key = [[keys objectAtIndex:i] intValue];
            value = [[dict objectForKey:[keys objectAtIndex:i]] intValue];
            
            for (int j=0; j<value; j++) {
                
                int x = key * 48 - 24;
                int y = (j + 7) * 48 - 24;
                int tag = key + ((j+6) * 10);
                
                [self addBoxesSetX:x SetY:y TagId:tag];
            }
            
            int filledCount = 0;
            
            for (int k=key+60; k<key+120; k=k+10) {
                sprite = (CCSprite *)[self getChildByTag:k];
                if (sprite != nil) {
                    filledCount = filledCount + 1;
                }
            }
            
            int movedCount = 0;
            
            for (int l=key; l<key+120+filledCount*48; l=l+10) {
                sprite = (CCSprite *)[self getChildByTag:l];
                if (sprite == nil) {
                    movedCount = movedCount + 1;
                }
                
                if (movedCount > 0) {
                    id actionMove = [CCMoveTo actionWithDuration:0.5 position:ccp(sprite.position.x, sprite.position.y - movedCount * 48)];
                    [sprite runAction:[CCSequence actions:actionMove, nil]];
                    sprite.tag = sprite.tag - movedCount * 10;
                }
            }
        }
        
        self.score = self.score + _boxTagArray.count;
        [_hud scoreChanged:_score];
    }
    
    [_boxNameArray removeAllObjects];
    [_boxTagArray removeAllObjects];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"touch.wav"];
    
    if ([self removeAble] == NO) {
        
        [self removeAllChildrenWithCleanup:(YES)];
        
        int x, y;
        int tag = 1;
        for (y = 24; y <= 264; y = y + 48) {
            for (x = 24; x <= 488; x = x + 48) {
                [self addBoxesSetX:x SetY:y TagId:tag];
                tag ++;
            }
        }
    }
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
    
    [_boxNameArray release];
    _boxNameArray = nil;
    
    [_boxTagArray release];
    _boxTagArray = nil;
    
    self.hud = nil;
}

#pragma mark GameKit delegate

- (void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    [[app navController] dismissModalViewControllerAnimated:YES];
}

- (void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}
@end
