//
//  PixivIllustCollectionViewController.m
//  PixivDaily
//
//  Created by Zhou Hao on 14-9-12.
//  Copyright (c) 2014年 Kastark. All rights reserved.
//

#import "PixivIllustCollectionViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define FETCH_ILLUST_USER_AGENT @"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.4 (KHTML, like Gecko) Ubuntu/12.10 Chromium/22.0.1229.94 Chrome/22.0.1229.94 Safari/537.4"

@interface PixivIllustCollectionViewController ()

@end

@implementation PixivIllustCollectionViewController

- (void)setIllusts:(NSArray *)illusts
{
    _illusts = illusts;
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.illusts count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Image ColCell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if ([self.illusts count] > 0)
    {
        SAPIIllust *illust = [self.illusts objectAtIndex:indexPath.row];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        cell.backgroundView = imageView;
        
        // download illusts.thumbURL for cell image
        [imageView sd_setImageWithURL:[NSURL URLWithString:illust.thumbURL]
                     placeholderImage:[UIImage imageNamed:@"placeholder"] options:indexPath.row == 0 ? SDWebImageRefreshCached : 0];
    }
    
    return cell;
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    id detail = self.splitViewController.viewControllers[1];
    if ([detail isKindOfClass:[UINavigationController class]]) {
        detail = [((UINavigationController *)detail).viewControllers objectAtIndex:0];
    }
    if ([detail isKindOfClass:[PixivImageViewController class]]) {
        // only on iPad
        [self prepareImageViewController:detail toDisplayPhoto:self.illusts[indexPath.row] mobileSize:NO];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([sender isKindOfClass:[UICollectionViewCell class]]) {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
        if (indexPath) {
            if (([segue.identifier isEqualToString:@"Show Image"]) && ([segue.destinationViewController isKindOfClass:[PixivImageViewController class]])) {
                [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
                [self prepareImageViewController:segue.destinationViewController toDisplayPhoto:self.illusts[indexPath.row] mobileSize:NO];
            }
        }
    }
}

- (void)prepareImageViewController:(PixivImageViewController *)ivc toDisplayPhoto:(SAPIIllust *)illust mobileSize:(BOOL)mobileSize
{
    // set 'Referer' for illust download
    [SDWebImageManager.sharedManager.imageDownloader setValue:illust.refererURL forHTTPHeaderField:@"Referer"];
    [SDWebImageManager.sharedManager.imageDownloader setValue:FETCH_ILLUST_USER_AGENT forHTTPHeaderField:@"User-Agent"];
    SDWebImageManager.sharedManager.imageDownloader.executionOrder = SDWebImageDownloaderLIFOExecutionOrder;
    
    // origin url need get from PAPI.works, so simplely use mobileURL here
    ivc.imageURL = [NSURL URLWithString:illust.mobileURL];
    ivc.illust = illust;
    ivc.title = [NSString stringWithFormat:@"[%@] %@", illust.authorName, illust.title];
}

@end
