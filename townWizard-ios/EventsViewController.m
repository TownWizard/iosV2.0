//
//  EventsViewController.m
//  townWizard-ios
//
//  Created by Evgeniy Kirpichenko on 10/24/12.
//
//

#import "EventsViewController.h"
#import "EventsView.h"
#import "EventCell.h"
#import "EventsViewer.h"
#import "EventSectionHeader.h"
#import "EventCategory.h"
#import "InputBar.h"
#import "PMCalendar.h"
#import "EventDetailsViewController.h"
#import "NSDate+Formatting.h"
#import "UIImageView+WebCache.h"
#import "UIView+Extensions.h"

#define ALL_EVENTS_TEXT @"ALL EVENTS"

@interface EventsViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, PMCalendarControllerDelegate>

@property (nonatomic, strong) PMCalendarController *calendar;
@property (nonatomic, retain) NSDateFormatter *sectionDateFormatter;

- (void)setupCotrols;

@end

@implementation EventsViewController

#pragma mark -
#pragma mark life cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.trackedViewName = @"Events screen";
    [self setupCotrols];
    eventsHelper = [[EventsHelper alloc] initWithDelegate:self];
    [eventsHelper loadEventsData];
}

- (void)setupCotrols
{
    featuredEventsViewer.delegate = self;
    self.calendar = [[[PMCalendarController alloc] initWithThemeName:@"apple calendar"] autorelease];
    self.calendar.delegate = self;
    self.calendar.mondayFirstDayOfWeek = NO;
    [self.eventsTypeButton setTitle:ALL_EVENTS_TEXT forState:UIControlStateNormal];
    NSString *newDatePeriod = [NSDate stringFromPeriod:[NSDate date]
                                                   end:[NSDate date]];
    [self.calendarButton setTitle:newDatePeriod forState:UIControlStateNormal];
    self.sectionDateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [self.sectionDateFormatter setDateFormat:@"EEEE LLL dd"];    
}

- (void)eventTouched:(Event *)event
{
    EventDetailsViewController *eventDetails = [EventDetailsViewController new];
    [eventDetails loadWithEvent:event];
    [self.navigationController pushViewController:eventDetails animated:YES];
    [eventDetails updateBannerImage:_bannerImageView.image urlString:eventsHelper.bannerUrlString];
    [eventDetails release];
}

- (IBAction)bannerButtonPressed:(id)sender
{
    [[AppActionsHelper sharedInstance] openUrl:eventsHelper.bannerUrlString
                             fromNavController:self.navigationController];
}

- (IBAction)categoriesButtonPressed:(id)sender
{
    InputBar *actionSheet = [[InputBar alloc] initWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n\n"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                     destructiveButtonTitle:nil
                                          otherButtonTitles:nil];
    [actionSheet initWithDelegate:self andPickerValue:eventsHelper.currentCategory+1];
    [actionSheet showInView:[self.view window]];
}

- (IBAction)dateSelectButtonPressed:(id)sender
{
    [self.calendar presentCalendarFromRect:CGRectMake(0, 0, 320, 0)
                                    inView:self.view
                  permittedArrowDirections:PMCalendarArrowDirectionAny
                                  animated:YES];
}
#pragma mark EventsHelperDelegate methods

- (void)didLoadFeaturedEvents:(NSArray *)events
{
    [featuredEventsViewer setRootView:eventsList];
    [featuredEventsViewer displayEvents:events];
}

- (void)eventsFiltered
{
    [eventsList reloadData];
}

- (void)bannerFounded:(NSURL *)bannerUrl
{
    [_bannerImageView setImageWithURL:bannerUrl placeholderImage:nil
                              options:SDWebImageRetryFailed];
}

#pragma mark PMCalendarControllerDelegate methods

- (void)calendarController:(PMCalendarController *)calendarController
           didChangePeriod:(PMPeriod *)newPeriod
{
    NSLog(@"Event period changed");
}

- (BOOL)calendarControllerShouldDismissCalendar:(PMCalendarController *)calendarController
{
    if(!calendarController.isCalendarCanceled)
    {
        NSString *newDatePeriod = [NSDate stringFromPeriod:calendarController.period.startDate
                                                       end:calendarController.period.endDate];
        [self.calendarButton setTitle:newDatePeriod forState:UIControlStateNormal];
        eventsHelper.currentStart = calendarController.period.startDate;
        eventsHelper.currentEnd = calendarController.period.endDate;
        [eventsHelper loadEventsWithDatePeriod:self.calendar.period.startDate
                                       endDate:self.calendar.period.endDate];
    }
    return YES;
}

#pragma mark -
#pragma mark UIPickerView Delegate/Datasource methods

- (void)actionSheet:(UIActionSheet *)aActionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = ALL_EVENTS_TEXT;
    if(eventsHelper.currentCategory >= 0)
    {
        EventCategory *category = [eventsHelper.categotiesList objectAtIndex:eventsHelper.currentCategory];
        title = [category.title uppercaseString];
    }
    [self.eventsTypeButton setTitle:title forState:UIControlStateNormal];
    [eventsHelper filterEventsByCategoryAndDate];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(eventsHelper.categotiesList)
    {
        return eventsHelper.categotiesList.count+1;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    if(row == 0)
    {
        return ALL_EVENTS_TEXT;
    }
    else
    {
        EventCategory *category = [eventsHelper.categotiesList objectAtIndex:row-1];
        return [category.title uppercaseString];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
    eventsHelper.currentCategory = row-1;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [eventsHelper.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDate *dateRepresentingThisDay = [eventsHelper.sortedDays objectAtIndex:section];
    NSArray *eventsOnThisDay = [eventsHelper.sections objectForKey:dateRepresentingThisDay];
    return [eventsOnThisDay count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDate *dateRepresentingThisDay = [eventsHelper.sortedDays objectAtIndex:section];
    return [self.sectionDateFormatter stringFromDate:dateRepresentingThisDay];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"EventCell";
    EventCell *cell = (EventCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [EventCell loadFromXib];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    [cell updateWithEvent:[eventsHelper eventForIndexPath:indexPath]];
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self eventTouched:[eventsHelper eventForIndexPath:indexPath]];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSDate *dateRepresentingThisDay = [eventsHelper.sortedDays objectAtIndex:section];
    NSString *title = [self.sectionDateFormatter stringFromDate:dateRepresentingThisDay];
    CGRect headerFrame = CGRectMake(0, 0, [tableView frame].size.width, [tableView sectionHeaderHeight]);
    EventSectionHeader *header = [[EventSectionHeader alloc] initWithFrame:headerFrame];
    [[header title] setText:[title uppercaseString]];
    return [header autorelease];
}


- (void)viewDidUnload
{
    [featuredEventsViewer release];
    featuredEventsViewer = nil;
    [eventsList release];
    eventsList = nil;
    [eventsHelper release];
    [self setEventsTypeButton:nil];
    [self setCalendarButton:nil];
    [self setBannerImageView:nil];
    [super viewDidUnload];
}

- (void)dealloc
{
    [featuredEventsViewer release];
    [eventsList release];
    [_eventsTypeButton release];
    [_calendarButton release];
    [_bannerImageView release];
    [eventsHelper release];
    [super dealloc];
}


@end
