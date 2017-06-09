//
//  NewInputVC.m
//  ASByrApp
//
//  Created by Andy on 2017/3/10.
//  Copyright © 2017年 andy. All rights reserved.
//

#import "WFPostVC.h"
#import "WFAccessoryView.h"
#import "WFEmotionInput.h"
#import "WFArticleApi.h"
#import "WFAttachmentApi.h"
#import "WFModels.h"
#import "Masonry.h"
#import "YYText.h"
#import "MBProgressHUD.h"

@interface WFPostVC () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, YYTextViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIBarButtonItem *sendBtn;

@property (nonatomic, strong) UITextField *titleInput;

@property (nonatomic, strong) YYTextView *textView;

@property (nonatomic, strong) YYTextView *preshowView;

@property (nonatomic, strong) UIImagePickerController *imagePicker;

@property (nonatomic, strong) WFAttachmentApi *attachmentApi;

@property (nonatomic, strong) WFArticleApi *articleApi;

@property (nonatomic, strong) WFAttachment *attachment;

@property (nonatomic, strong) WFArticle *replyTo;

@property (nonatomic, strong) WFEmotionInput *emotionInputView;

@property (nonatomic, strong) MBProgressHUD *uploadHud;

@property (nonatomic, strong) MBProgressHUD *postHud;

@end

@implementation WFPostVC

- (instancetype)init {
    return [self initWithReplyArticle:nil];
}

- (instancetype)initWithParams:(NSDictionary *)params {
    if ([params objectForKey:@"article"]) {
        return [self initWithReplyArticle:params[@"article"] input:params[@"input"]];
    } else {
        return [self init];
    }
}

- (instancetype)initWithReplyArticle:(WFArticle *)article {
    return [self initWithReplyArticle:article input:nil];
}

- (instancetype)initWithReplyArticle:(WFArticle *)article input:(NSString *)input {
    self = [super init];
    if (self != nil) {
        self.replyTo = article;
        self.titleInput.text = [NSString stringWithFormat:@"Re:%@", article.title];
        self.titleInput.enabled = NO;
        if (input)
            [self.textView insertText:input];
        if (self.replyTo)
            [self.textView insertText:[NSString stringWithFormat:@"\n\n【 在 %@ 的大作中提到: 】\n%@", self.replyTo.user.user_name, self.replyTo.content]];
        
        self.textView.selectedRange = NSMakeRange(input.length, 0);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = self.sendBtn;
    //self.inputView
    [self.scrollView addSubview:self.titleInput];
    [self.scrollView addSubview:self.textView];
    [self.scrollView addSubview:self.preshowView];
    [self.view addSubview:self.scrollView];
    [self.view setNeedsUpdateConstraints];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.textView becomeFirstResponder];
    
}
- (void)updateViewConstraints {
    
    [self.titleInput mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.textView.mas_width);
        make.height.equalTo(@(30));
        make.centerX.equalTo(self.textView);
        make.top.equalTo(self.scrollView.mas_top).offset(8);
    }];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleInput.mas_bottom).offset(1);
        make.bottom.left.equalTo(self.scrollView).offset(8);
        make.width.equalTo(self.scrollView).sizeOffset(CGSizeMake(-16, -39));
    }];
    
    [self.preshowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.textView.mas_right).offset(16);
        make.top.bottom.equalTo(self.scrollView).offset(8);
        make.right.equalTo(self.scrollView).offset(-8);
        make.size.equalTo(self.scrollView).sizeOffset(CGSizeMake(-16, -16));
    }];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.left.equalTo(self.view);
        make.height.equalTo(@(self.view.frame.size.height - 64));
    }];
    
    [super updateViewConstraints];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - YYTextViewDelegate

- (void)textViewDidChange:(YYTextView *)textView {
    if (textView == self.textView) {
        [self.preshowView setText:self.textView.text];
    }
}

#pragma  mark - UIScrollViewDelegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    NSLog(@"end");
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"scrolling");
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x > 0) {
        [self.textView resignFirstResponder];
    }
}
# pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(nonnull NSDictionary<NSString *,id> *)info {
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];

    
    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSString *imageName = [[info objectForKey:UIImagePickerControllerReferenceURL] lastPathComponent];
    
    NSURL *fileUrl = wf_saveImage(img, imageName);
    /*
    __weak typeof(self)wself = self;
    [self.attachmentApi addAttachmentWithBoard:self.replyTo.board_name file:fileUrl successBlock:^(NSInteger statusCode, id response) {
        __strong typeof(wself)sself = wself;
        if (sself) {
            sself.attachment = response;
            sself.ubbParser.attachment = response;
            sself.textView.text = [NSString stringWithFormat:@"%@[upload=%ld][/upload]\n", sself.textView.text, sself.attachment.file.count];
            sself.textView.selectedRange = NSMakeRange(0, 0);
            [sself.uploadHud hide:YES];
        }
    } failureBlock:^(NSInteger statusCode, id response) {
        __strong typeof(wself)sself = wself;
        if (sself) {
            [sself.uploadHud hide:YES];
        }
        NSLog(@"%@", response);
    }];*/
    

}


# pragma mark - Private methods

- (void)send {
    __weak typeof(self) wself = self;
    [self.articleApi postArticleWithBoard:self.replyTo.board_name title:@"" content:self.textView.text reid:self.replyTo.aid successBlock:^(NSInteger statusCode, id response) {
        
        wf_showHud(wself.view, @"回复成功", 1);
        [wself.navigationController popViewControllerAnimated:YES];
    } failureBlock:^(NSInteger statusCode, id response) {
        wf_showHud(wself.view, @"回复失败", 1);
    }];
}

- (void)addPhoto {
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

- (void)addEmotion {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.35];
    
    [self.textView resignFirstResponder];
    self.textView.inputView = self.textView.inputView ? nil : self.emotionInputView;
    [self.textView becomeFirstResponder];
    
    [UIView commitAnimations];
}

# pragma makr - Setters and Getters

- (UIBarButtonItem*)sendBtn {
    if (_sendBtn == nil) {
        _sendBtn = [[UIBarButtonItem alloc] init];
        _sendBtn.title = @"发送";
        _sendBtn.target = self;
        _sendBtn.action = @selector(send);
    }
    return _sendBtn;
}

- (UIImagePickerController*)imagePicker {
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
    }
    return _imagePicker;
}


- (UIScrollView*)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.backgroundColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.00];
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (YYTextView*)textView {
    if (_textView == nil) {
        _textView = [[YYTextView alloc] init];
        _textView.textAlignment = NSTextAlignmentNatural;
        _textView.placeholderFont = [UIFont fontWithName:WFFontName size:14];
        _textView.placeholderText = @"输入帖子内容";
        WFAccessoryView *accessoryView = (WFAccessoryView*)[[NSBundle mainBundle] loadNibNamed:@"WFAccessoryView" owner:nil options:nil][0];
        
        __weak typeof(self)wself = self;
        accessoryView.addPhotoBlock = ^(id context){
            __strong typeof(wself)sself = wself;
            if (sself) {
                [sself addPhoto];
            }
        };
        
        accessoryView.addEmotionBlock = ^(id context){
            __strong typeof(wself) sself = wself;
            if (sself) {
                [sself addEmotion];
            }
        };
        
        accessoryView.dismissBlock = ^(id context){
            __strong typeof(wself)sself = wself;
            if (sself) {
                [sself.textView resignFirstResponder];
            }
        };
        _textView.delegate = self;
        _textView.inputAccessoryView = accessoryView;
        [_textView setFont:[UIFont fontWithName:WFFontName size:14]];
        _textView.backgroundColor = [UIColor whiteColor];
    }
    return _textView;
}

- (WFEmotionInput*)emotionInputView {
    if (_emotionInputView == nil) {
        _emotionInputView = [[NSBundle mainBundle] loadNibNamed:@"WFEmotionInput" owner:nil options:nil][0];
        
        __weak typeof(self)wself = self;
        _emotionInputView.addEmotionBlock = ^(id context){
            __strong typeof(wself) sself = wself;
            if (sself) {
                [sself.textView insertText:context];
            }
        };
    }
    return _emotionInputView;
}

- (UITextField*)titleInput {
    if (_titleInput == nil) {
        _titleInput = [UITextField new];
        _titleInput.placeholder = @" 输入标题";
        _titleInput.font = [UIFont fontWithName:WFFontName size:14];
        _titleInput.backgroundColor = [UIColor whiteColor];
    }
    return _titleInput;
}

- (YYTextView*)preshowView {
    if (_preshowView == nil) {
        _preshowView = [[YYTextView alloc] init];
        _preshowView.placeholderText = @"预览";
        _preshowView.editable = NO;
        _preshowView.placeholderFont = [UIFont fontWithName:WFFontName size:14];
        //_preshowView.textParser = self.ubbParser;
        _preshowView.font = [UIFont fontWithName:WFFontName size:14];
        _preshowView.backgroundColor = [UIColor whiteColor];
    }
    return _preshowView;
}

- (WFAttachmentApi*)attachmentApi {
    if (_attachmentApi == nil) {
        _attachmentApi = [[WFAttachmentApi alloc] initWithAccessToken:[WFToken shareToken].accessToken];
    }
    return _attachmentApi;
}

- (WFArticleApi*)articleApi {
    if (_articleApi == nil) {
        _articleApi = [[WFArticleApi alloc] initWithAccessToken:[WFToken shareToken].accessToken];
    }
    return _articleApi;
}

- (WFAttachment*)attachment {
    if (_attachment == nil) {
        _attachment = [WFAttachment new];
    }
    return _attachment;
}


- (MBProgressHUD*)uploadHud {
    if (_uploadHud == nil) {
        _uploadHud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    }
    [_uploadHud show:YES];
    return _uploadHud;
}

- (MBProgressHUD*)postHud {
    if (_postHud == nil) {
        _postHud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        _postHud.mode = MBProgressHUDModeText;
    }
    [_postHud show:YES];
    return _postHud;
}

@end

@implementation WFPostVC (WFRouter)

- (instancetype) initWithParams:(NSDictionary *)params {
    id replyTarget = [params objectForKey:@"article"];
    id inputed     = [params objectForKey:@"input"];
    if ([replyTarget isMemberOfClass:[WFArticle class]]) {
        return [self initWithReplyArticle:replyTarget input:inputed];
    }
    return [self init];
}

@end
