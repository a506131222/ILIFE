//
//  ZJMProblemFeedbackVC.m
//  llifeRobot
//
//  Created by 张佳满 on 2017/11/24.
//  Copyright © 2017年 ZJM. All rights reserved.
//

#import "ZJMProblemFeedbackVC.h"
#import "ACFeedBack.h"
#import "ZJMTDeviceLIstCell.h"
#import "ZJMImagePreviewVC.h"

#define LimitMaxWord 140

@interface ZJMProblemFeedbackVC ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailTF;
@property (weak, nonatomic) IBOutlet UIButton *photoBtn;
@property (weak, nonatomic) IBOutlet UIButton *photoBtn2;

@property (weak, nonatomic) IBOutlet UITextView *contextTextView;
@property (weak, nonatomic) IBOutlet UILabel *numberLab;
@property (weak, nonatomic) IBOutlet UIButton *choiceBtn;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *placeLab;
@property (weak, nonatomic) IBOutlet UITableView *deviceListTableView;
@property (nonatomic,strong)NSMutableArray *LabelList;
@property (nonatomic,copy)NSString *deviceName;
@property (weak, nonatomic) IBOutlet UITextField *deviceTF;
@property (weak, nonatomic) IBOutlet UIButton *deleBtn1;
@property (weak, nonatomic) IBOutlet UIButton *deleBtn2;

@end

@implementation ZJMProblemFeedbackVC
{
    NSString *base64Sting;
    NSMutableArray *images;
    NSMutableArray *editImages;
    MBProgressHUD *mbpHud;
}

-(NSMutableArray *)LabelList{
    if (_LabelList ==nil) {
        _LabelList = [NSMutableArray array];
    }
    return _LabelList;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [IQKeyboardManager sharedManager].enable = NO;
}
-(void)viewWillAppear:(BOOL)animated{
    self.deviceListTableView.hidden=YES;
    [IQKeyboardManager sharedManager].enable = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.deleBtn1.hidden = YES;
    self.deleBtn2.hidden = YES;
    [self.emailTF becomeFirstResponder];
    self.emailTF.inputView =[[UIView alloc]initWithFrame:CGRectZero];
    // Do any additional setup after loading the view from its nib.
    [self.deviceListTableView registerNib:[UINib nibWithNibName:@"ZJMTDeviceLIstCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    [IQKeyboardManager sharedManager].enable = NO;
    self.placeLab.enabled = NO;
    self.emailTF.tintColor = [UIColor redColor];
    self.contextTextView.tintColor = [UIColor redColor];
    [self setRightBtn];
    [self setViewLayerView:self.emailTF];
    [self setViewLayerView:self.contextTextView];
    [self setViewLayerView:self.bottomView];
    self.emailTF.layer.cornerRadius=5;
    self.choiceBtn.layer.cornerRadius=5;
    self.photoBtn2.hidden=YES;
    _contextTextView.delegate=self;
    self.emailTF.placeholder = NSLocalizedString(@"Please Enter E-mail Address", nil);
    self.deviceTF.placeholder = NSLocalizedString(@"Please Choose Robot Model", nil);
    self.deviceTF.font = [UIFont systemFontOfSize:15];
    [self.choiceBtn setTitle:NSLocalizedString(@"Choose", nil) forState:UIControlStateNormal];
    self.numberLab.text =@"140/140";
    images = [NSMutableArray array];
    editImages = [NSMutableArray array];
    
    self.placeLab.text = NSLocalizedString(@"Please Describe Your Trouble", nil);
    self.LabelList = [@[@"X420",@"X430",@"X660",@"X660HF",@"X610",@"X620",@"X782",@"X785",@"X786",@"X787",@"X790",@"X800",@"X900",@"X910"]mutableCopy];
    
    [self.view bringSubviewToFront:self.deviceListTableView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showKeyboard)];
    [self.emailTF addGestureRecognizer:tap];
    self.deviceTF.enabled=NO;
}

-(void)setViewLayerView:(UIView *)textView{
    textView.layer.borderColor = HexColor(0xDADADA).CGColor;
    textView.layer.borderWidth=1.0;
}
-(void)showKeyboard{
    self.emailTF.inputView=nil;
    [self.emailTF reloadInputViews];
    [self.emailTF becomeFirstResponder];
}
-(void)keyboardWillHide{
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

#pragma mark - 弹出表格
-(void)showTableView{
    _deviceListTableView.hidden=NO;
}


#pragma mark - 右边按钮
-(void)setRightBtn{
    
    UIButton* rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0,0,60,30)];
    [rightButton setTitle:NSLocalizedString(@"Submit", nil) forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(submitQuestion)forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem= rightItem;
    
}

- (IBAction)deleBtn1:(UIButton *)sender {
    self.deleBtn2.hidden = YES;
    [editImages removeObjectAtIndex:0];
    if (images.count == 2) {
        [images removeObjectAtIndex:0];
        [self.photoBtn2 setBackgroundImage:[UIImage imageNamed:@"评论-添加图片"] forState:UIControlStateNormal];
        [self.photoBtn setBackgroundImage:images[0] forState:UIControlStateNormal];
    }else{
        [images removeObjectAtIndex:0];
        self.photoBtn2.hidden = YES;
        self.deleBtn1.hidden = YES;
        [self.photoBtn setBackgroundImage:[UIImage imageNamed:@"评论-添加图片"] forState:UIControlStateNormal];
    }
    
}

- (IBAction)deleBtn2:(id)sender {
    self.deleBtn2.hidden = YES;
    [editImages removeObjectAtIndex:1];
    [images removeObjectAtIndex:1];
    [self.photoBtn2 setBackgroundImage:[UIImage imageNamed:@"评论-添加图片"] forState:UIControlStateNormal];
}



- (IBAction)emailTF:(UITextField *)sender {
    self.deviceTF.enabled=YES;
    [self.deviceTF becomeFirstResponder];
    [self showTableView];
}
- (IBAction)deviceTF:(UITextField *)sender {
    [self.contextTextView becomeFirstResponder];
    self.deviceListTableView.hidden=YES;
}

#pragma mark- 选择按钮事件
- (IBAction)showTable:(UIButton *)sender {
    self.deviceListTableView.hidden=! self.deviceListTableView.hidden;
}

#pragma mark - 邮箱事件
- (IBAction)hiddenTableView:(UIButton *)sender {
    self.deviceListTableView.hidden=YES;
    [self.contextTextView becomeFirstResponder];
}

#pragma mark - 设备文本事件
- (IBAction)mailTF:(UITextField *)sender {
    [self.deviceTF becomeFirstResponder];
}

#pragma mark - 邮箱弹出键盘
- (IBAction)showKeyboard:(UIButton *)sender {
    [self showKeyboard];
}
#pragma mark - 上传图片事件
- (IBAction)uploadPictures:(UIButton *)sender{
    if (images.count==0 ||(sender.tag == 3 && images.count == 1)){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Upload Image", nil)                                                                            message:nil                                                           preferredStyle:UIAlertControllerStyleActionSheet];
        NSMutableAttributedString *alertControllerStr = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Upload Image", nil)];
        [alertControllerStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:19] range:NSMakeRange(0, 4)];
        [alertController setValue:alertControllerStr forKey:@"attributedTitle"];
        
        [alertController addAction: [UIAlertAction actionWithTitle: NSLocalizedString(@"Take Photo", nil) style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self presentViewController:[PhotoManager shareManager].camera animated:YES completion:nil];
            
        }]];
        [alertController addAction: [UIAlertAction actionWithTitle:NSLocalizedString(@"From Photo Library", nil) style: UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self presentViewController:[PhotoManager shareManager].pickingImageView animated:YES completion:nil];
            
        }]];
        [alertController addAction: [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style: UIAlertActionStyleCancel handler:nil]];
        
        [self presentViewController: alertController animated: YES completion: nil];
    }else{
        ZJMImagePreviewVC *preVC = [[ZJMImagePreviewVC alloc]init];
        preVC.title =NSLocalizedString(@"Preview", nil);
        preVC.image = editImages[sender.tag-2];
        [self.navigationController pushViewController:preVC animated:YES];
    }

    if (sender.tag==2) {
        
        [PhotoManager shareManager].configureBlock = ^(id image){
            if(image == nil)
            {
                
            }
            else{
                [editImages addObject:image];
                image = [image imageWithSize:CGSizeMake(SCREENWEIGHT,SCREENHEIGHT)];
                NSData *data  = UIImageJPEGRepresentation(image, 0.9);
                base64Sting = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                [self.photoBtn setBackgroundImage:image forState:UIControlStateNormal];
                self.deleBtn1.hidden = NO;
                self.photoBtn2.hidden=NO;
                if (images) {
                    [images removeAllObjects];
                }
                [images addObject:image];
                
            }
        };
    }
    else if (sender.tag==3){
        [PhotoManager shareManager].configureBlock = ^(id image){
            if(image == nil)
            {
                
            }else{
                [editImages addObject:image];
                image = [image imageWithSize:CGSizeMake(SCREENWEIGHT, SCREENHEIGHT)];
                
                NSData *data  = UIImageJPEGRepresentation(image, 0.9);
                base64Sting = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                self.deleBtn2.hidden = NO;
                [self.photoBtn2 setBackgroundImage:image forState:UIControlStateNormal];
                if (images.count==2) {
                    [images removeObjectAtIndex:1];
                }
                [images addObject:image];
                
            }
        };
    }
}

#pragma mark - 提交事件
-(void)submitQuestion{
    
    if (!(self.emailTF.text.length>0)) {
        
        [self showHudWithString:NSLocalizedString(@"Please Enter E-mail Address", nil)];
        return;
    } else if ([self isValidateEmail:_emailTF.text] == NO) {
        
        [self showHudWithString:NSLocalizedString(@"Wrong Email Format", nil)];
        return;
    }else if (!(self.deviceTF.text.length>0)){
        [self showHudWithString:NSLocalizedString(@"Please Choose Robot Model", nil)];
        return;
    }
    else if (self.contextTextView.text.length==0) {
        
        [self showHudWithString:NSLocalizedString(@"Please Describe Your Trouble",nil)];
        return;
    }else{
        
        ACFeedBack *feedback = [[ACFeedBack alloc] init];
        [feedback addFeedBackWithKey:feekBackMail value:_emailTF.text];
        [feedback addFeedBackWithKey:feedBackText value:_contextTextView.text];
        [feedback addFeedBackWithKey:@"deviceType" value:_deviceName];
        if (images.count >0) {
            [feedback addFeedbackPictures:images forKey:feekBackPictures];
        }
        [self isLoading];
        [ACFeedBackManager submitFeedBack:feedback callback:^(BOOL isSuccess, NSError *error) {
            [self finish];
            if (!error) {
                if (isSuccess==YES) {
                    [self showHudWithString:NSLocalizedString(@"Submission Done", nil)];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self.navigationController popViewControllerAnimated:YES];
                    });
                    
                }else{
                    [self showHudWithString:NSLocalizedString(@"Submission Failed, Please Check Network", nil)];
                }
            }else{
                [self showHudWithString:NSLocalizedString(@"Submission Failed, Please Check Network", nil)];
            }
        }];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.LabelList count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ZJMTDeviceLIstCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    cell.deviceLab.text = self.LabelList[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return SCREENHEIGHT*0.05;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.deviceName = _LabelList[indexPath.row];
    self.deviceTF.text=self.deviceName;
    self.deviceListTableView.hidden=YES;
}

#pragma mark - UITextViewDelegate
- (void) textViewDidChange:(UITextView *)textView{
    
    if ([textView.text length] == 0) {
        
        [self.placeLab setHidden:NO];
    }else{
        
        [self.placeLab setHidden:YES];
    }
}


-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    return YES;
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.emailTF resignFirstResponder];
    [self.deviceTF resignFirstResponder];
    [self.contextTextView resignFirstResponder];
    return YES;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSString *str = [NSString stringWithFormat:@"%@%@", textView.text, text];
    NSString *textStr = [textView.text stringByReplacingCharactersInRange:range withString:text];
    //收起键盘
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    self.numberLab.text = [NSString stringWithFormat:@"%ld/140",LimitMaxWord-textStr.length];
    if (str.length > LimitMaxWord)
    {
        [self.contextTextView resignFirstResponder];
        NSRange rangeIndex = [str rangeOfComposedCharacterSequenceAtIndex:LimitMaxWord-1];
        
        if (rangeIndex.length == 1)//字数超限
        {
            textView.text = [str substringToIndex:LimitMaxWord];
            
        }else{
            NSRange rangeRange = [str rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, LimitMaxWord)];
            textView.text = [str substringWithRange:rangeRange];
        }
        
        [self showHudWithString:NSLocalizedString(@"Words exceed the Limit", nil)];
        self.numberLab.text = [NSString stringWithFormat:@"%d/140",0];
        return NO;
    }
    return YES;
}

#pragma mark - 点击空白隐藏键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.emailTF resignFirstResponder];
    [self.deviceTF resignFirstResponder];
    [self.contextTextView resignFirstResponder];
    self.deviceListTableView.hidden=YES;
    [self.view endEditing:YES];
}

#pragma mark - Mailbox format
- (BOOL)isValidateEmail:(NSString *)email{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}

-(void)isLoading{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        AppDelegate *dele = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        mbpHud = [[MBProgressHUD alloc]initWithView:dele.window];
        float time = mbpHud.minShowTime;
        NSLog(@"%f",time);
        [dele.window addSubview:mbpHud];
        [mbpHud show:YES];
        
    });
}
-(void)finish{
    mbpHud.hidden = YES;
    [mbpHud removeFromSuperview];
    mbpHud=nil;
}


@end
