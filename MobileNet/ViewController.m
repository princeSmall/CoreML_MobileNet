//
//  ViewController.m
//  MobileNet
//
//  Created by tongle on 2017/9/14.
//  Copyright © 2017年 tong. All rights reserved.
//

#import "ViewController.h"
#import "GoogLeNetPlaces.h"
#import <CoreML/CoreML.h>
#import <Vision/Vision.h>

@interface ViewController ()
@property (nonatomic,strong)UILabel * resultLable;
@property (nonatomic,strong)UILabel * confidenceLabel;
@property (nonatomic,strong)UIImageView * imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.resultLable];
    [self.view addSubview:self.confidenceLabel];
    
    GoogLeNetPlaces * googleModel = [[GoogLeNetPlaces alloc]init];
    // 从生成的类中加载MLModel
    VNCoreMLModel * VNModel = [VNCoreMLModel modelForMLModel:googleModel.model error:nil];
    
    // 创建一个带有 completion handler 的 Vision 请求
    VNCoreMLRequest * VNMLRequest = [[VNCoreMLRequest alloc] initWithModel:VNModel completionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        CGFloat confidence = 0.0f;
        // VNClassificationObservation 有两个属性：
        // 1. identifier - 一个 String
        // 2. confidence - 介于0和1之间的数字
        VNClassificationObservation *tempClassification = nil;
        for (VNClassificationObservation * classification in request.results) {
            if (classification.confidence > confidence) {
                confidence = classification.confidence;
                tempClassification = classification;
            }
        }
        // 在主线程上更新 UI
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.resultLable.text = [NSString stringWithFormat:@"识别结果:%@",tempClassification.identifier];
            self.confidenceLabel.text = [NSString stringWithFormat:@"匹配率:%f",tempClassification.confidence * 100];
        });
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        VNImageRequestHandler * VNImageRequest = [[VNImageRequestHandler alloc]initWithCGImage:self.imageView.image.CGImage options:nil];
        NSError *error = nil;
        [VNImageRequest performRequests:@[VNMLRequest] error:&error];
        if (error) {
            NSLog(@"%@",error.localizedDescription);
        }
    });
    // Do any additional setup after loading the view, typically from a nib.
}
-(UIImageView *)imageView{
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 250)];
        _imageView.image = [UIImage imageNamed:@"pool.jpg"];
    }
    return _imageView;
}
-(UILabel *)resultLable{
    if (_resultLable == nil) {
        _resultLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 270, self.view.frame.size.width, 40)];
        _resultLable.textColor =[UIColor redColor];
        _resultLable.textAlignment = NSTextAlignmentCenter;
    }
    return _resultLable;
}
-(UILabel *)confidenceLabel{
    if (_confidenceLabel == nil) {
        _confidenceLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 300, self.view.frame.size.width, 40)];
        _confidenceLabel.textColor = [UIColor greenColor];
        _confidenceLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _confidenceLabel;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
