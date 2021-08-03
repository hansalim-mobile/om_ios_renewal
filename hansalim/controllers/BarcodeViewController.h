//
//  BarcodeViewController.h
//  hansalim
//
//  Created by marco on 2021/06/16.
//

@protocol BarcodeResultDelegate<NSObject>;
@required
-(void) resultBarcode:(NSString *) data;
@end

@interface BarcodeViewController : UIViewController

@property (nonatomic,assign) id<BarcodeResultDelegate> delegate;

@end
