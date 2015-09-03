//
//  SearchResultTV.m
//  AmosSportDiary
//
//  Created by Amos Wu on 15/9/1.
//  Copyright © 2015年 Amos Wu. All rights reserved.
//


#import "SearchResultTV.h"

static NSString* const SearchCellIdentifier = @"searchResultCell";

@interface SearchResultTV ()<UITabBarControllerDelegate, UITabBarDelegate>

@end

@implementation SearchResultTV

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _searchTempDatas && _searchTempDatas.count > 0 ? _searchTempDatas.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SearchCellIdentifier forIndexPath:indexPath];
    
    if (_searchTempDatas.count > 0) {
        NSArray *nameDic = [_searchTempDatas[indexPath.row] allKeys];
        NSArray *typeDic = [_searchTempDatas[indexPath.row] allValues];
        
        cell.textLabel.text = [nameDic firstObject];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.text = [typeDic firstObject];
    }else {
        cell.textLabel.text = [NSString stringWithFormat:@"新建“%@”", _theNewStr];
        cell.textLabel.textColor = [UIColor colorWithRed:0.0000 green:0.5608 blue:0.5176 alpha:1];
        cell.detailTextLabel.text = @"";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_searchTempDatas.count > 0) {
//        NSLog(@"你点了 %@", @(indexPath.row));
        if (self.changeValueBlock) {
            self.changeValueBlock(_searchTempDatas[indexPath.row]);
        }
        
    }else{
//        NSLog(@"新建个啥");
        if (self.createNewBlock) {
            self.createNewBlock(_theNewStr);
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

@end
