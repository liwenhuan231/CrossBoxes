//
//  GameLayer.h
//  CrossBoxes
//
//  Created by Roger on 12-8-26.
//  Copyright __MyCompanyName__ 2012年. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

@interface GameHud : CCLayer
{
    CCLabelTTF *label;
}

- (void) scoreChanged: (int) score;

@end

// GameLayer
@interface GameLayer : CCLayerColor <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>
{
    
    NSMutableArray  *_boxTagArray;
    NSMutableArray  *_boxNameArray;
    GameHud   *_hud;
    
    int _score;

}

@property (nonatomic, retain) NSMutableArray    *boxTagArray;
@property (nonatomic, retain) NSMutableArray    *boxNameArray;
@property (nonatomic, retain) GameHud     *hud;

@property (nonatomic, assign) int score;


// returns a CCScene that contains the GameLayer as the only child
+(CCScene *) scene;

@end
