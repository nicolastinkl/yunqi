//
//  ChatRecorderView.h
//  Jeans
//
//  Created by Jeans on 3/24/13.
//  Copyright (c) 2013 Jeans. All rights reserved.
//

#import <UIKit/UIKit.h>

    

@interface ChatRecorderView : UIView

@property (retain, nonatomic) IBOutlet UIImageView *peakMeterIV;

@property (retain, nonatomic) IBOutlet UIImageView *trashCanIV;

@property (retain, nonatomic) IBOutlet UIImageView *imagebg;

@property (retain, nonatomic) IBOutlet UILabel *countDownLabel;

//还原界面
- (void)restoreDisplay;

//是否准备删除
- (void)prepareToDelete:(BOOL)_preareDelete;

//是否摇晃垃圾桶
- (void)rockTrashCan:(BOOL)_isTure;

//更新音频峰值
- (void)updateMetersByAvgPower:(float)_avgPower;

@end
