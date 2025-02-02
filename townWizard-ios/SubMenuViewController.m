//
//  SubMenuViewController.m
//  townWizard-ios
//
//  Created by admin on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SubMenuViewController.h"
#import "UIApplication+NetworkActivity.h"
#import "AppDelegate.h"
#import "FacebookPlacesViewController.h"
#import "Partner.h"
#import "Section.h"
#import "PartnerViewController.h"
#import "RequestHelper.h"
#import "UIButton+Extensions.h"
#import "UIAlertView+Extensions.h"
#import "UIBarButtonItem+TWButtons.h"
#import "MBProgressHUD.h"

#define ROOT_URL @"app30a"
#define MAP_URL @"showmap"
#define DETAILS_URL @"showdetails"
#define FBCHECKIN_URL @"fbcheckin"
#define MAIL_URL @"mailto"
#define TEL_URL @"tel"
#define CALL_URL @"makecall"

@interface SubMenuViewController ()
@property(nonatomic, assign) BOOL progressPresented;
@end

@implementation SubMenuViewController


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.navigationBarHidden = NO;
    self.progressPresented = NO;
    back = [[UIBarButtonItem backButtonWithTarget:self action:@selector(goBackPressed:)] retain];
    partnerController = (id)self.navigationController.parentViewController;
    
    [self loadWebViewPage];
}

- (void)loadWebViewPage {
    NSString *urlString = self.url;
    Section *section = [[RequestHelper sharedInstance] currentSection];

    if(section)
    {
        urlString = [self urlFromSection:section];
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy
                                            timeoutInterval:20.];
    [[self webView] loadRequest:urlRequest];
}

- (NSString *)urlFromSection:(Section*)section
{
    NSString *urlString;
    if ([section url] != nil)
    {
        if([self isSectionUrlAbsolute:section.url])
        {
            urlString = section.url;
        }
        else
        {
            urlString = [NSString stringWithFormat:@"%@/%@",
                         [[[RequestHelper sharedInstance] currentPartner] webSiteUrl],
                         [section url]];
        }
    }
    else
    {
        urlString = @"http://www.townwizardoncontainerapp.com";
    }
    
    // bhavan: append latitude/longitude with either "?" or "&" based on if other query string parameters exist
    NSRange searchRange = [urlString rangeOfString:@"?"];
    
    if (searchRange.length != 0)
    {
        // "?" exists, i.e. urlString has other query string paramerts 
        urlString = [urlString stringByAppendingFormat:@"&lat=%f&lon=%f",
                     [AppDelegate sharedDelegate].doubleLatitude,
                     [AppDelegate sharedDelegate].doubleLongitude];
    }
    else
    {
        // "?" is not there; no other query string parameter in urlString
        urlString = [urlString stringByAppendingFormat:@"?lat=%f&lon=%f",
                     [AppDelegate sharedDelegate].doubleLatitude,
                     [AppDelegate sharedDelegate].doubleLongitude];
    }
    return urlString;
}

- (BOOL)isSectionUrlAbsolute:(NSString *)urlString
{
    NSRange range = [urlString rangeOfString:@"http://"];
    return range.length > 0;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] hideNetworkActivityIndicator];
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
    }
}

- (IBAction)goBackPressed:(id)sender
{
    [self.webView stopLoading];
    if(self.webView.canGoBack)
    {
        [self.webView goBack];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)setupLeftButton
{
    if(_webView.canGoBack)
    {
        self.navigationItem.leftBarButtonItem = back;
    }
    else if(!_url && partnerController)
    {
        self.navigationItem.leftBarButtonItem = [UIBarButtonItem
                                                 menuButtonWithTarget:partnerController
                                                 action:@selector(toggleMasterView)];
    }

}

#pragma mark -
#pragma mark webView

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    [self setupLeftButton];

    NSString *requestString = [[request URL] absoluteString];
	NSArray *components = [requestString componentsSeparatedByString:@":"];

    BOOL shouldStartLoad = YES;

    if ([components count] >= 2)
    {
        shouldStartLoad = [self parseUrlComponents:components];
    }

    if (shouldStartLoad)
    {
        [self showProgressHUD];
    }
    
    return shouldStartLoad;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    webView.scalesPageToFit = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self hideProgressHUD];
    [self setupLeftButton];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (error.code == -999)
        return;

    [self hideProgressHUD];

    [UIAlertView showWithTitle:@"Connection error"
                       message:error.localizedDescription
            confirmButtonTitle:@"Ok"];
}






#pragma mark - Private


- (void)showProgressHUD
{
    [[UIApplication sharedApplication] showNetworkActivityIndicator];
    if (! self.progressPresented) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Loading";
        self.progressPresented = YES;
    }
}

- (void)hideProgressHUD
{
    [[UIApplication sharedApplication] hideNetworkActivityIndicator];
    if (self.progressPresented) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.progressPresented = NO;
    }
}

- (BOOL)parseUrlComponents:(NSArray *)components
{
    NSString *rootUrlType = [components[0] lowercaseString];
    NSString *urlType = rootUrlType;
    if([rootUrlType isEqualToString:ROOT_URL])
    {
        urlType = [components[1] lowercaseString];
    }
    return [self actionForUrlType:urlType withComponents:components];
}

- (BOOL)actionForUrlType:(NSString *)urlType withComponents:(NSArray *)components
{
    if( [urlType isEqualToString:CALL_URL])
    {
        [[AppActionsHelper sharedInstance] makeCall:components[2]];
        return NO;
    }
    else if( [urlType isEqualToString:DETAILS_URL])
    {
        return YES;
    }
    else if([urlType isEqualToString:MAP_URL])
    {
        [self showMapWithUrlComponents:components];
        return NO;
    }
    else if([urlType isEqualToString:FBCHECKIN_URL])
    {
        [self fbUrlPressedWithComponents:components];
        return NO;
    }
    else if([urlType isEqualToString:TEL_URL])
    {
        [[AppActionsHelper sharedInstance] makeCall:components[1]];
        return NO;
    }
    else if([urlType isEqualToString:MAIL_URL])
    {
        [self mailUrlPressedWithComponents:components];
        return NO;
    }
    return YES;
}


- (void)showMapWithUrlComponents:(NSArray *)components
{
    NSString *title = @"";
    if(components.count > 4)
    {
        title = components[4];
        title = [[title stringByReplacingOccurrencesOfString:@"+" withString:@" "]
                 stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    }
    
    [[AppActionsHelper sharedInstance] openMapWithTitle:title
                                              longitude:[components[3] doubleValue]
                                               latitude:[components[2] doubleValue] fromNavController:self.navigationController];
}

- (void)mailUrlPressedWithComponents:(NSArray *)components
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        NSString * emailAddress = [components[1]
                                   stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSArray *toRecipients = @[ emailAddress ];
        [mailer setToRecipients:toRecipients];
        [self presentViewController:mailer animated:YES completion:nil];
        [mailer release];
    }
    else
    {
        // [[UIApplication sharedApplication] openURL:[request URL]];
    }    
}

- (void)fbUrlPressedWithComponents:(NSArray *)components
{
    if (![[AppDelegate sharedDelegate].facebookHelper.appId isEqual:@""])
    {
        FacebookPlacesViewController * fpvc = [[FacebookPlacesViewController alloc]
                                               initWithLatitude:
                                               [components[2] doubleValue]
                                               andLongitude:
                                               [components[3] doubleValue]];
      
        [self.navigationController pushViewController:fpvc animated:YES];
        [fpvc release];
    }
    
}
#pragma mark - MFComposeViewControllerDelegate

-(void)mailComposeController:(MFMailComposeViewController *)controller
         didFinishWithResult:(MFMailComposeResult)result
                       error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark CleanUp

-(void)cleanUp
{
    [back release];
    [_url release];
    self.partner = nil;
    self.section = nil;
    self.webView = nil;   
    [[UIApplication sharedApplication] setActivityindicatorToZero];
}

- (void)viewDidUnload
{
    [self cleanUp];
    [super viewDidUnload];
}

- (void)dealloc
{
    [self cleanUp];
    [super dealloc];
}

@end
