//
//  SortTableView.h
//  SortTableView
//
//  Created by 庄晓伟 on 17/1/18.
//  Copyright © 2017年 Zhuang Xiaowei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SortTableView;

@protocol SortTableViewDelegate <NSObject>

- (void)tableView:(ALSortTableView *)tableView willBeginMoveAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(SortTableView *)tableView moveAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath;

@end

@interface SortTableView : UITableView

@property (nonatomic, weak) id<SortTableViewDelegate>               moveDelegate;

- (void)allowsMoveTableViewCellWhenLongPress;
- (void)disableMoveTableViewCellWhenLongPress;

@end
