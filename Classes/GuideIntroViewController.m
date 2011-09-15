    //
//  GuideIntroViewController.m
//  iFixit
//
//  Created by David Patierno on 8/9/10.
//  Copyright 2010 iFixit. All rights reserved.
//

#import "GuideIntroViewController.h"
#import "Guide.h"
#import "GuideImageViewController.h"
#import "UIButton+WebCache.h"
#import "Config.h"

@implementation GuideIntroViewController

@synthesize delegate, headerImageIFixit, headerImageMake, swipeLabel;
@synthesize guide, device, mainImage, webView, imageSpinner, imageVC, huge, html;

static CGRect frameView;

// Load the view nib and initialize the guide.
+ (id)initWithGuide:(Guide *)guide {
	frameView = CGRectMake(0.0f,    0.0f, 1024.0f, 768.0f);

    NSString *nib = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"GuideIntroView" : @"SmallGuideIntroView";
	GuideIntroViewController *vc = [[GuideIntroViewController alloc] initWithNibName:nib bundle:nil];
	
	vc.guide = guide;
    vc.huge = nil;
	
    return [vc autorelease];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the appropriate header image.
    if ([Config currentConfig].site == ConfigMake || [Config currentConfig].site == ConfigMakeDev) {
        headerImageMake.hidden = NO;
        swipeLabel.textColor = [UIColor redColor];
    }
    else if ([Config currentConfig].site == ConfigIFixit || [Config currentConfig].site == ConfigIFixitDev) {
        headerImageIFixit.hidden = NO;
    }
    
    // Hide the swipe label if there are no steps.
    if (![guide.steps count])
        swipeLabel.hidden = YES;
    
    // Set the background color, softening black and white by 5%.
    UIColor *bgColor = [Config currentConfig].backgroundColor;
    /*
    if ([bgColor isEqual:[UIColor blackColor]])
        bgColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.05 alpha:1.0];
    else if ([bgColor isEqual:[UIColor whiteColor]])
        bgColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
     */
    
    self.view.backgroundColor = bgColor;
	webView.backgroundColor = bgColor;
	
	// Load the intro contents as HTML.
	NSString *header = [NSString stringWithFormat:@"<html><head><style type=\"text/css\"> %@ </style></head><body class=\"%@\">",
                        [Config currentConfig].introCSS,
                        (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"big" : @"small"];
	NSString *footer = @"</body></html>";

	NSString *body = guide.introduction_rendered;
   //NSString *body = guide.introduction;
	
    self.html = [NSString stringWithFormat:@"%@%@%@", header, body, footer];
	[webView loadHTMLString:html baseURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@", [Config host]]]];
    
	[device setText:guide.device];

    // Disable bounce scrolling.
    /*
    for (id subview in webView.subviews)
        if ([[subview class] isSubclassOfClass:[UIScrollView class]])
            ((UIScrollView *)subview).bounces = NO;
     */
    
    [mainImage setImageWithURL:[guide.image URLForSize:@"standard"] placeholderImage:nil];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

   if (navigationType != UIWebViewNavigationTypeLinkClicked)
      return YES;
   
   // Load all URLs in Safari.
   [[UIApplication sharedApplication] openURL:[request URL]];
   return NO;
   
}

// Because the web view has a white background, it starts hidden.
// After the content is loaded, we wait a small amount of time before showing it to prevent flicker.
- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[self performSelector:@selector(showWebView:) withObject:nil afterDelay:0.2];
}
- (void)showWebView:(id)sender {
	webView.hidden = NO;	
}

- (IBAction)zoomImage:(id)sender {
   
    // Disabled on the intro.
    return;

}
- (void)hideGuideImage:(id)object {
	[UIView beginAnimations:@"ImageView" context:nil];
	[UIView setAnimationDuration:0.3];
	mainImage.transform = CGAffineTransformMakeScale(1,1);
	imageVC.view.alpha = 0;
	[UIView commitAnimations];
    
    [self performSelector:@selector(removeImageVC) withObject:nil afterDelay:0.5];
}

- (void)removeImageVC {
    [imageVC.view removeFromSuperview];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}
- (void)layoutLandscape {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return;
    
    // These dimensions represent the object's position BEFORE rotation,
    // and are automatically tweaked during animation with respect to their resize masks.
    mainImage.frame = CGRectMake(40, 40, 200, 150);
    webView.frame = CGRectMake(240, 0, 238, 245);
}
- (void)layoutPortrait {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return;
    
    // These dimensions represent the object's position BEFORE rotation,
    // and are automatically tweaked during animation with respect to their resize masks.
    mainImage.frame = CGRectMake(60, 10, 200, 150);
    webView.frame = CGRectMake(0, 168, 320, 228);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        [self layoutLandscape];
    }
    else {
        [self layoutPortrait];
    }
    
    // Re-flow HTML
    [webView loadHTMLString:html baseURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@", [Config host]]]];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    self.guide = nil;
    self.huge = nil;
    webView.delegate = nil;
    self.mainImage = nil;
    self.html = nil;
    [super dealloc];
}


@end