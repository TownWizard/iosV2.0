//
//  PhotoGalleryViewController.m
//  townWizard-ios
//
//  Created by Vilimets Anton on 10/2/12.
//
//

#import "PhotoGalleryViewController.h"
#import "Photo.h"
#import "WebImageGridViewCell.h"
#import "UIImageView+WebCache.h"

@interface PhotoGalleryViewController () <RKObjectLoaderDelegate>
@property (nonatomic, retain) NSArray *photos;
@end

@implementation PhotoGalleryViewController

#pragma mark -
#pragma mark life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[AppActionsHelper sharedInstance] putTWBackgroundWithFrame:_gridView.frame
                                                         toView:self.view];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[self photos] count] == 0) {
        [[RequestHelper sharedInstance] loadPhotosFromCategory:[self category] delegate:self];
        [[self activityIndicator] startAnimating];
    }
    
    [[self gridView] reloadData];
}

- (void)dealloc
{
    [self setCategory:nil];
    [self setGridView:nil];
    [_activityIndicator release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [self setGridView:nil];
    [self setActivityIndicator:nil];
    [super viewDidUnload];
}

#pragma mark -
#pragma mark RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    [[self activityIndicator] stopAnimating];
    [UIAlertView showConnectionProblemMessage];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    [self setPhotos:objects];
    [[self activityIndicator] stopAnimating];
    [[self gridView] reloadData];
}

#pragma mark -
#pragma mark AQGridViewDatasource methods

- (NSUInteger)numberOfItemsInGridView: (AQGridView *) gridView
{
    return [[self photos] count];
}

- (AQGridViewCell *)gridView: (AQGridView *) aGridView cellForItemAtIndex: (NSUInteger) index
{
    static NSString *cellIdentifier = @"gridCell";
    WebImageGridViewCell *cell = (WebImageGridViewCell *)[aGridView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil)
    {
        cell = [[[WebImageGridViewCell alloc] initWithFrame:CGRectMake(0, 0, 100, 100)
                                           reuseIdentifier:cellIdentifier] autorelease];
        [cell setSelectionStyle:AQGridViewCellSelectionStyleNone];
    }
    
    Photo *photo = [[self photos] objectAtIndex:index];
    NSString *thumbUrl = [[photo thumb]
                          stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[cell imageView] setImageWithURL:[NSURL URLWithString:thumbUrl]
                     placeholderImage:nil
                              options:SDWebImageCacheMemoryOnly];
    return cell;
}

#pragma mark -
#pragma mark AQGridViewDelegate

- (void)gridView:(AQGridView *) gridView didSelectItemAtIndex: (NSUInteger) index
{
    [self displayPhotoBrowserWithInitialPageIndex:index];    
}

#pragma mark -
#pragma mark MWPhotoBrowserDelegate methods

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return [[self photos] count];
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    Photo *photoObject = [[self photos] objectAtIndex:index];
    MWPhoto *browserPhoto = [MWPhoto photoWithURL:[NSURL URLWithString:[photoObject picture]]];
    [browserPhoto setCaption:[photoObject name]];
    return browserPhoto;
}

#pragma mark -
#pragma mark helpers

- (void) displayPhotoBrowserWithInitialPageIndex:(NSInteger) index
{
    MWPhotoBrowser *browser = [[[MWPhotoBrowser alloc] initWithDelegate:self] autorelease];
    [browser setWantsFullScreenLayout:YES];
    [browser setDisplayActionButton:NO];
    [browser setInitialPageIndex:index];

    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:browser];
    [self presentViewController:navController animated:YES completion:nil];
    [navController release];
}

@end
