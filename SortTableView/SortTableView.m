//
//  SortTableView.m
//  SortTableView
//
//  Created by 庄晓伟 on 17/1/18.
//  Copyright © 2017年 Zhuang Xiaowei. All rights reserved.
//

#import "SortTableView.h"

@interface SortTableView ()

@property (nonatomic, strong) UITableViewCell               *movingCell;
@property (nonatomic, strong) NSIndexPath                   *beginIndexPath;
@property (nonatomic, strong) NSIndexPath                   *movingIndexPath;
@property (nonatomic, strong) UIView                        *movingView;

@property (nonatomic, assign) CGFloat                       centerOffsetX;
@property (nonatomic, strong) CADisplayLink                 *link;
@property (nonatomic, strong) UILongPressGestureRecognizer  *longPressGesture;

@end

@implementation SortTableView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)allowsMoveTableViewCellWhenLongPress {
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognizer:)];
    [self addGestureRecognizer:longPressGesture];
    _longPressGesture = longPressGesture;
    
    _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(display:)];
    [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)disableMoveTableViewCellWhenLongPress {
    if (_longPressGesture) {
        _longPressGesture.enabled = NO;
        [self removeGestureRecognizer:_longPressGesture];
    }
    if (_link) {
        [_link invalidate];
        _link = nil;
    }
}

- (void)longPressGestureRecognizer:(UIGestureRecognizer *)sender {
    CGPoint locationPoint = [sender locationInView:self];
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            [self __beginLongPressGestureWithLocation:locationPoint];
            break;
        case UIGestureRecognizerStateChanged:
            [self __moveToLocation:locationPoint];
            break;
        case UIGestureRecognizerStateEnded:
            [self __endLongPressGesture];
            break;
        case UIGestureRecognizerStateFailed:
            [self __endLongPressGesture];
            break;
        case UIGestureRecognizerStatePossible:
            NSLog(@"possible  ..");
            break;
        case UIGestureRecognizerStateCancelled:
            [self __endLongPressGesture];
            break;
    }
}

- (void)__beginLongPressGestureWithLocation:(CGPoint)locationPoint {
    _movingIndexPath = [self indexPathForRowAtPoint:locationPoint];
    _beginIndexPath = _movingIndexPath;
    if ([((NSObject *)self.moveDelegate) respondsToSelector:@selector(tableView:willBeginMoveAtIndexPath:)]) {
        [self.moveDelegate tableView:self willBeginMoveAtIndexPath:_beginIndexPath];
    }
    _movingCell = [self cellForRowAtIndexPath:_movingIndexPath];
    _movingView = [_movingCell snapshotViewAfterScreenUpdates:NO];
    _movingCell.hidden = YES;
    _movingView.backgroundColor = [UIColor whiteColor];
    CGRect frame = _movingView.frame;
    _movingView.frame = frame;
    _centerOffsetX = _movingView.center.x - locationPoint.x;
    locationPoint.x += _centerOffsetX;
    _movingView.center = locationPoint;
    [self addSubview:_movingView];
}

- (void)__moveToLocation:(CGPoint)locationPoint {
    if (_movingView == nil) {
        return;
    }
    locationPoint.x += _centerOffsetX;
    CGFloat movingTopPos = locationPoint.y - CGRectGetHeight(_movingView.bounds) / 2;
    if (movingTopPos < CGRectGetHeight(_movingView.bounds) / 2) {
        return;
    }
    locationPoint.x += _centerOffsetX;
    _movingView.center = locationPoint;
    NSIndexPath *indexPath = [self indexPathForRowAtPoint:locationPoint];
    if (indexPath != _movingIndexPath) {
        [self moveRowAtIndexPath:_movingIndexPath toIndexPath:indexPath];
        _movingIndexPath = indexPath;
    }
}

- (void)__endLongPressGesture {
    if (_movingView == nil) {
        return;
    }
    UITableViewCell *cell = [self cellForRowAtIndexPath:_movingIndexPath];
    [UIView animateWithDuration:0.25f animations:^{
        _movingView.frame = cell.frame;
    } completion:^(BOOL finished) {
        cell.hidden = NO;
        [_movingView removeFromSuperview];
        _movingView = nil;
        if ([((NSObject *)self.moveDelegate) respondsToSelector:@selector(tableView:moveAtIndexPath:toIndexPath:)]) {
            [self.moveDelegate tableView:self moveAtIndexPath:_beginIndexPath toIndexPath:_movingIndexPath];
        }
        _movingIndexPath = nil;
        _beginIndexPath = nil;
    }];
}

- (void)display:(CADisplayLink *)link {
    if (_movingView == nil) {
        return;
    }
    CGFloat scrollRange = 50.0f;
    CGFloat maxMoveDistance = 20.0f;
    CGPoint contentOffset = self.contentOffset;
    CGFloat topScrollPosition = contentOffset.y + scrollRange;
    CGFloat bottomScrollPosition = contentOffset.y + CGRectGetHeight(self.bounds) - scrollRange;
    CGPoint movingCenter = _movingView.center;
    CGFloat touchLocationY = movingCenter.y;
    CGFloat offsetY = 0.0f;
    movingCenter.x -= _centerOffsetX;
    [self __moveToLocation:movingCenter];
    movingCenter.x += _centerOffsetX;
    if (touchLocationY < scrollRange) {
        if (contentOffset.y <= 0) {
            return;
        }
        [self setContentOffset:CGPointZero animated:YES];
        return;
    }
    else if (touchLocationY > bottomScrollPosition) {
        if (contentOffset.y + CGRectGetHeight(self.bounds) >= self.contentSize.height) {
            return;
        }
    }
    
    if (touchLocationY > bottomScrollPosition) {
        offsetY = (touchLocationY - bottomScrollPosition) / scrollRange * maxMoveDistance;
    }
    else if (touchLocationY < topScrollPosition) {
        offsetY = -(topScrollPosition - touchLocationY) / scrollRange * maxMoveDistance;
    }
    contentOffset.y += offsetY;
    movingCenter.y += offsetY;
    [self setContentOffset:contentOffset animated:NO];
    _movingView.center = movingCenter;
}

- (void)dealloc {
    if (_link) {
        [_link invalidate];
        _link = nil;
    }
}

@end
