//
//  BarcodeViewController.m
//  hansalim
//
//  Created by marco on 2021/06/16.
//

#import "BarcodeViewController.h"

@interface BarcodeViewController() <AVCaptureMetadataOutputObjectsDelegate> {
    
    AVCaptureSession *_session;
    AVCaptureDevice *_device;
    AVCaptureDeviceInput *_input;
    AVCaptureMetadataOutput *_output;
    AVCaptureVideoPreviewLayer *_prevLayer;
    
    UIView *_highlightView;
}

@property (weak, nonatomic) IBOutlet UIView *cameraView;

@end

@implementation BarcodeViewController

- (IBAction)backBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@synthesize cameraView;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self settingCamera];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avCaptureInputPortFormatDescriptionDidChangeNotification:) name:AVCaptureInputPortFormatDescriptionDidChangeNotification object:nil];
}

-(void)avCaptureInputPortFormatDescriptionDidChangeNotification:(NSNotification *)notification {
    CGRect scanRectTransformed = CGRectMake(0, SCREENHEIGHT/2 - ((SCREENHEIGHT/3)/2) - 30, SCREENWIDTH, SCREENHEIGHT/3 );
    _output.rectOfInterest = [_prevLayer metadataOutputRectOfInterestForRect:scanRectTransformed];

}

- (void) settingCamera {
    NSLog(@"SCREENWIDTH [%f], SCREENHEIGHT [%f]", SCREENWIDTH, SCREENHEIGHT);
    NSLog(@"settingCamera height [%f]",self.view.frame.size.height);
    _highlightView = [[UIView alloc] init];
    _highlightView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    _highlightView.layer.borderColor = [UIColor greenColor].CGColor;
    _highlightView.layer.borderWidth = 5;
    [cameraView addSubview:_highlightView];
//    [_highlightView fill_parent];
    
    _session = [[AVCaptureSession alloc] init];
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    if (_input) {
        [_session addInput:_input];
    } else {
        NSLog(@"Error: %@", error);
    }
    
    _output = [[AVCaptureMetadataOutput alloc] init];
    
    

//        CGFloat x = 1;
//        CGFloat y = 0.5;
//        CGFloat height = 2;
    CGRect scanRectTransformed = CGRectMake(0, SCREENHEIGHT/2 - ((SCREENHEIGHT/3)/2) - 30, SCREENWIDTH, SCREENHEIGHT/3 );
    //    metadataOutput.metadataOutputRectOfInterest(for: scanRectTransformed)
//        [_output metadataOutputRectOfInterestForRect:scanRectTransformed];
    
    
    
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [_session addOutput:_output];
    
    _output.metadataObjectTypes = [_output availableMetadataObjectTypes];

    _prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _prevLayer.frame = cameraView.frame;//self.view.bounds;
    _prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill; //  AVLayerVideoGravityResize,AVLayerVideoGravityResizeAspectFill
    
    
    [cameraView.layer addSublayer:_prevLayer];
    
    [_session commitConfiguration];
    [_session startRunning];
    
    [cameraView bringSubviewToFront:_highlightView];
    
    
    
    // 화면에 표기
//    UIView *scanAreaView = [[UIView alloc] init];
//    scanAreaView.layer.borderColor = [UIColor redColor].CGColor;
//    scanAreaView.layer.borderWidth = 4;
//    scanAreaView.frame = scanRectTransformed;
//    [cameraView addSubview:scanAreaView];

    
    /// 카메라 접근 사용자 동의 여부
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(status == AVAuthorizationStatusDenied) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                                 message:@"av_authorization_status_denied_msg".localized
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"확인" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
        }]];
        [self presentViewController:alertController animated:YES completion:^{}];
    }
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//    });
    
}




- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *detectionString = nil;
    NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
                              AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];
    
    for (AVMetadataObject *metadata in metadataObjects) {
        for (NSString *type in barCodeTypes) {
            if ([metadata.type isEqualToString:type]) {
                barCodeObject = (AVMetadataMachineReadableCodeObject *)[_prevLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                highlightViewRect = barCodeObject.bounds;
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                break;
            }
        }
        
        if (detectionString != nil) {
            [_session stopRunning];
            
            if(detectionString.length > 0) {
                [self.delegate resultBarcode:detectionString];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }
    
    _highlightView.frame = highlightViewRect;
}



@end
