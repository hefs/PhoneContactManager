//
//  CycleMessageView.m
//  LoanOnlinePreApp
//
//  Created by znkj-iMac-hefs on 2018/12/6.
//  Copyright © 2018 znkj-iMac-hefs. All rights reserved.
//

#import "CycleMessageView.h"

@interface CycleMessageItemView : UICollectionViewCell
@property(nonatomic) UILabel *messageLabel;
@end

@implementation CycleMessageItemView

- (UILabel *)messageLabel{
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.textColor = [UIColor darkTextColor];
        _messageLabel.font = [UIFont systemFontOfSize:14];
        _messageLabel.numberOfLines = 0;
        _messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.contentView addSubview:_messageLabel];
    }
    return _messageLabel;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.messageLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.contentView.frame), CGRectGetHeight(self.contentView.frame));
}
@end

@interface CycleMessageView()<UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>
@property (nonatomic) UICollectionView *contentView;
@property (nonatomic,strong) dispatch_source_t gcdTimer;
@end

@implementation CycleMessageView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [self.contentView registerClass:[CycleMessageItemView class] forCellWithReuseIdentifier:NSStringFromClass([CycleMessageItemView class])];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
//    创建定时器队列
    dispatch_queue_t queue = dispatch_queue_create("Cycle Message", NULL);
    /*
        第一个参数：dispatch_source_type_t type为设置GCD源方法的类型，前面已经列举过了。
        第二个参数：uintptr_t handle Apple的API介绍说，暂时没有使用，传0即可。
        第三个参数：unsigned long mask Apple的API介绍说，使用DISPATCH_TIMER_STRICT，会引起电量消耗加剧，毕竟要求精确时间，所以一般传0即可，视业务情况而定。
        第四个参数：dispatch_queue_t _Nullable queue 队列，将定时器事件处理的Block提交到哪个队列之上。可以传Null，默认为全局队列
     */
    _gcdTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
//    定时器相关参数设置，第二个参数：开始时间 第三个参数：时间间隔 第四个参数：允许误差时间，传0即可
    dispatch_source_set_timer(_gcdTimer, DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC, 0.0 * NSEC_PER_SEC);
    /*
     第一个参数：dispatch_source_t source，...不用说了。
     第二个参数：dispatch_block_t _Nullable handler，定时器执行的动作，需要处理的业务逻辑Block。
     */
    dispatch_source_set_event_handler(_gcdTimer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self automaticScroll];
        });
    });
//    启动定时器
    dispatch_resume(_gcdTimer);
}


/**
 公告自动轮播，2s执行一次
 */
- (void)automaticScroll{
    if (0 == _messages.count){
        return;
    }
    
    int currentIndex = [self currentIndex];
    int targetIndex = currentIndex + 1;
    [self scrollToIndex:targetIndex];
}


/**
 滚动到指定索引

 @param targetIndex 待滚动到的索引位置
 */
- (void)scrollToIndex:(int)targetIndex{
    if (targetIndex >= _messages.count * 100) {
        targetIndex = _messages.count * 100 * 0.5;
        [self.contentView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        return;
    }
    [self.contentView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}


/**
 获取当前显示的公告索引

 @return 索引
 */
- (int)currentIndex{
    int index = 0;
    index = (self.contentView.contentOffset.y + CGRectGetHeight(self.frame) * 0.5) / CGRectGetHeight(self.frame);
    return MAX(0, index);
}

- (UICollectionView *)contentView{
    if (!_contentView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        _contentView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _contentView.delegate = self;
        _contentView.dataSource = self;
        _contentView.scrollEnabled = NO;
        _contentView.showsVerticalScrollIndicator = NO;
        _contentView.showsHorizontalScrollIndicator = NO;
        _contentView.backgroundColor = [UIColor clearColor];
        [self addSubview:_contentView];
    }
    return _contentView;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CycleMessageItemView *itemView = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CycleMessageItemView class]) forIndexPath:indexPath];
    NSInteger index = indexPath.item % _messages.count;
    itemView.messageLabel.text = _messages[index];
    return itemView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger index = indexPath.item % _messages.count;
    if (_CycleMessageClickedHandler) {
        _CycleMessageClickedHandler(index,_messages[index]);
    }
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _messages.count * 100;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
