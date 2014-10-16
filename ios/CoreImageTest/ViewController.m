//
//  ViewController.m
//  CoreImageTest
//
//  Created by Ding Ma on 2/13/14.
//  Copyright (c) 2014 Ding Ma. All rights reserved.
//

#import "ViewController.h"
#import "ImageTools.h"

#import "LooksCollectionView.h"
#import "ScrollSelectView.h"

#import <Social/Social.h>
#import <QuartzCore/QuartzCore.h>
#import "FBShimmeringView.h"

const int THB_WIDTH = 100;
const int THB_HEIGHT = 100;

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet LooksCollectionView *looksCollectionView;
@property (nonatomic, strong) UIImage *originalSizeImage, *originalImage;
@property (nonatomic, strong) ScrollSelectView *scrollSelectView;
@property (nonatomic, strong) ImageTools *imageTools;
@property (nonatomic, strong) NSMutableDictionary *currentFilter;
@property (strong, nonatomic) IBOutlet UIButton *imagePickerButton;
@property (strong, nonatomic) FBShimmeringView *shimmeringView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    // init filter dictionary
    self.currentFilter = [[NSMutableDictionary alloc] init];
    
    // get image tools
    self.imageTools = [ImageTools sharedImageTools];
    
    // get image directly from file name
    UIImage *image = [UIImage imageNamed:@"image.png"];
    self.originalSizeImage = image;
    self.originalImage = [ImageTools scaleToSize:self.imageView.frame.size image:image];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.image = image;
    
    // init collection view with filtered images
    [self refreshCollectionView];
    
    // init scroll selection view
    [self initScrollCollectionView];
    
    // init buttons
    [self initButtons];
}

- (void)initButtons
{
    self.shimmeringView = [[FBShimmeringView alloc] initWithFrame:self.imagePickerButton.frame];
    self.shimmeringView.shimmering = YES;
    self.shimmeringView.shimmeringSpeed = 100;
    self.shimmeringView.shimmeringOpacity = 0.6;
    [self.view addSubview:self.shimmeringView];
    self.shimmeringView.contentView = self.imagePickerButton;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // register notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lookSelected:) name:@"LOOK_SELECTED" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(valueUpdated:) name:@"VALUE_UPDATED" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollYesClicked:) name:@"SCROLL_YES_CLICKED" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollNoClicked:) name:@"SCROLL_NO_CLICKED" object:nil];
}

- (void)refreshCollectionView
{
    if ([self.looksCollectionView initImages:self.originalSizeImage]) {
        NSLog(@"Images in Looks Collection View are ready.");
    }
}

- (void)initScrollCollectionView
{
    // insert scroll select view
    CGRect tempFrame = [[UIScreen mainScreen] bounds];
    
    // init scroll selection view outside screen
    self.scrollSelectView = [[ScrollSelectView alloc] initWithFrame:CGRectMake(0, tempFrame.size.height, tempFrame.size.width, 100)];
    
    // insert scroll view behind collection view
    [self.view insertSubview:self.scrollSelectView belowSubview:self.looksCollectionView];
}

- (void)newImageLoaded:(NSDictionary *)info
{
    // get image
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (image) {
        // set original size image
        self.originalSizeImage = image;
        
        // get original image
        self.originalImage = [ImageTools scaleToSize:self.imageView.frame.size image:image];
        
        // cross fade image
        [MDAnimation crossFadeExchangeImage:self.imageView image:self.originalImage];
        
        // refresh collection view
        [self refreshCollectionView];
        
        NSLog(@"New image is loaded~");
    }else{
        NSLog(@"There is something wrong when loading new image!");
    }
}

// observer methods==================================
- (void)lookSelected:(NSNotification *)notify
{
    // get params dic
    id params = notify.userInfo;
    
    // set current filter
    self.currentFilter = params;
    
    // hide collection view and show scroll view
    [self hideCollectionView];
    [self.scrollSelectView show:params];
}

- (void)valueUpdated:(NSNotification *)notify
{
    // get params dic
    NSDictionary *params = notify.userInfo;
    
    // set current filter
    self.currentFilter = [NSMutableDictionary dictionaryWithDictionary:params];
    
    // put render to other threads
    dispatch_queue_t globel = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(globel, ^{
        // filter image
        CIFilter *filter = [self.imageTools createFilter:self.currentFilter];
        UIImage *image = [self.imageTools filterImage:self.originalImage filter:filter];
        
        // cross fade image
        [MDAnimation crossFadeExchangeImage:self.imageView image:image];
    });
}

- (void)scrollYesClicked:(NSNotification *)notify
{
    // put render to other threads
    // filter original size image
    dispatch_queue_t globel = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(globel, ^{
        // filter image
        CIFilter *filter = [self.imageTools createFilter:self.currentFilter];
        UIImage *image = [self.imageTools filterImage:self.originalSizeImage filter:filter];
        
        // cross fade image
        self.originalSizeImage = image;
    });
    
    // set current image as original image
    self.originalImage = self.imageView.image;
    
    // refresh collection view
    [self refreshCollectionView];
    
    // hide scroll view
    [self.scrollSelectView hide];
    
    // show collection view
    [self showCollectionView];
    
    // notify "REFRESH_COLLECTIONVIEW_IMAGES"
    [[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_COLLECTIONVIEW_IMAGES" object:nil];
}

- (void)scrollNoClicked:(NSNotification *)notify
{
    // discard current image
    [MDAnimation crossFadeExchangeImage:self.imageView image:self.originalImage];
    
    // hide scroll view
    [self.scrollSelectView hide];
    
    // show collection view
    [self showCollectionView];
}
// ==================================================


// ===================animations=====================
- (void)showCollectionView
{
    // how to get particular constraint in constraints?
    // use firstItem/secondItem/firstAttribute
    NSArray* array = [[NSArray alloc] initWithArray:self.view.constraints];
    [array enumerateObjectsUsingBlock:^(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *stop){
        if ((constraint.firstItem == self.view) && (constraint.secondItem == self.looksCollectionView) && constraint.firstAttribute == NSLayoutAttributeBottom ) {
            constraint.constant = 0;
        }
    }];
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)hideCollectionView
{
    NSArray* array = [[NSArray alloc] initWithArray:self.view.constraints];
    [array enumerateObjectsUsingBlock:^(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *stop){
        if ((constraint.firstItem == self.view) && (constraint.secondItem == self.looksCollectionView) && constraint.firstAttribute == NSLayoutAttributeBottom ) {
            constraint.constant = -110;
        }
    }];
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    }];
}

//- (BOOL)shouldAutorotate
//{
//    return FALSE;
//}

// share picker=================================
- (IBAction)shareWeibo:(id)sender {
    // if users are not logged in, iOS 7 won't jump to log in panel??
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo]) {
        NSLog(@"Weibo is available~");
        
        SLComposeViewController *socialVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeSinaWeibo];
        
        SLComposeViewControllerCompletionHandler block = ^(SLComposeViewControllerResult result) {
            if (result == SLComposeViewControllerResultCancelled) {
                NSLog(@"Cancelled");
            } else {
                NSLog(@"OK");
            }
            [socialVC dismissViewControllerAnimated:YES completion:Nil];
        };
        socialVC.completionHandler = block;
        
        [socialVC setInitialText:@"Thanks Ning and Quan~"];
        [socialVC addImage:self.imageView.image];
//        // this will add a url for your weibo
//        [socialVC addURL:@"www.naruto.at.work.com"];
        
        [self presentViewController:socialVC animated:YES completion:Nil];
    } else {
        NSLog(@"Weibo is not available!");
    }
}
// =============================================

// save picker==================================
- (IBAction)saveImageClicked:(id)sender {
    // store image orientation
    CGFloat imageOrientation = self.originalSizeImage.imageOrientation;
    
    // judge image format
    NSData* data = UIImagePNGRepresentation(self.originalSizeImage);
    if (data) {
        // if it is a PNG
    }else{
        // if it is a JPEG
        data = UIImageJPEGRepresentation(self.originalSizeImage, 1.0);
    }
    
    // save
    UIImage* img = [UIImage imageWithData:data];
    UIImage* fixedOrientationImage = [UIImage imageWithCGImage:img.CGImage scale:img.scale orientation:imageOrientation];    // fix orientation
    UIImageWriteToSavedPhotosAlbum(fixedOrientationImage, self, @selector(image:didFinishSavingWithError:contextInfo:), Nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *msg = Nil;
    error != NULL ? (msg = @"Saving image error!") : (msg = @"Saving image success~");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Saving image result" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
    [alert show];
}

// =============================================

// image picker=================================
- (IBAction)imagePickerClicked:(id)sender {
    // add image picker in modal
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
//    pickerController.allowsEditing = YES;
    
    // get source type
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    }else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        pickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    
    // show image picker in modal
    [self presentViewController:pickerController animated:YES completion:Nil];
}

#pragma -
#pragma image picker delegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:Nil];
    
    // set original image
    [self newImageLoaded:info];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:Nil];
}

// =============================================

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
