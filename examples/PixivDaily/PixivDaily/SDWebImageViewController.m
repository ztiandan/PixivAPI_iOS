//
//  SDWebImageViewController.m
//  PixivDaily
//
//  Created by Zhou Hao on 14-8-29.
//  Copyright (c) 2014年 Kastark. All rights reserved.
//

#import "SDWebImageViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SDWebImageViewController () <UIScrollViewDelegate, UISplitViewControllerDelegate>

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic) float minZoomScale;

@end

@implementation SDWebImageViewController

#pragma mark - View

- (void)singelTap:(UITapGestureRecognizer *)sender
{
    NSLog(@"singelTap");
    [self.navigationController setNavigationBarHidden:!self.navigationController.isNavigationBarHidden animated:YES];
}

- (void)doubleTap:(UITapGestureRecognizer *)sender
{
    NSLog(@"doubleTap");
    self.scrollView.zoomScale = (self.scrollView.zoomScale!=self.minZoomScale) ? self.minZoomScale : 1.0;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
    
    // single/double tap gesture
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singelTap:)];
    singleTapGesture.numberOfTapsRequired = 1;
    [self.scrollView addGestureRecognizer:singleTapGesture];
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [self.scrollView addGestureRecognizer:doubleTapGesture];
    [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
}

- (void)startDonwloadImage
{
    self.image = nil;
    
    if (self.imageURL) {
        [self.spinner startAnimating];
        NSLog(@"download: %@", self.imageURL);
        
        [self.imageView sd_setImageWithURL:self.imageURL
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                     self.image = image;
                                 }];
    }
}

#pragma mark - ScrollView

- (void)setScrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
    _scrollView.maximumZoomScale = 2.0;
    _scrollView.delegate = self;
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    [self startDonwloadImage];
}

- (UIImageView *)imageView
{
    if (!_imageView) _imageView = [[UIImageView alloc] init];
    return _imageView;
}

- (UIImage *)image
{
    return self.imageView.image;
}

// Zoom to show as much image as possible
// http://stackoverflow.com/questions/14471298/zooming-uiimageview-inside-uiscrollview-with-autolayout
- (void)initZoom
{
    self.minZoomScale = 1.0;
    float minZoom = MIN(self.view.bounds.size.width / self.imageView.image.size.width,
                        self.view.bounds.size.height / self.imageView.image.size.height);
    if (minZoom > 1) return;
    
    self.scrollView.minimumZoomScale = minZoom;
    self.scrollView.zoomScale = minZoom;
    self.minZoomScale = minZoom;
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
    self.imageView.frame = CGRectMake(0,0,image.size.width,image.size.height);
    [self.spinner stopAnimating];
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
    [self initZoom];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self initZoom];
}

#pragma mark UISplitViewControllerDelegate

- (void)awakeFromNib
{
    self.splitViewController.delegate = self;
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation);
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"Menu";
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.navigationItem.leftBarButtonItem = nil;
}

@end
