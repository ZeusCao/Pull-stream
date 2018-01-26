//
//  PLPlayerViewController.m
//  直播test
//
//  Created by Zeus on 2017/7/24.
//  Copyright © 2017年 Zeus. All rights reserved.
//

#import "PLPlayerViewController.h"
#define KScreenWidth [UIScreen mainScreen].bounds.size.width
#define KScreenHeight [UIScreen mainScreen].bounds.size.height

@interface PLPlayerViewController () <PLPlayerDelegate>

@property (nonatomic, assign) NSInteger playStatus; // 播放 0；暂停 1；

@property (nonatomic, strong) UISlider *volumeSlider; // 音量滑条

@property (nonatomic, strong) UIButton *soundButton; // 静音开关

@property (nonatomic, assign) BOOL isClose;


@end

@implementation PLPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 初始化
    [self initMyQNPlayer];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithTitle:@"暂停" style:UIBarButtonItemStylePlain target:self action:@selector(rightAction:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(leftAction:)];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    
    
}


#pragma mark --- 初始化 ---
- (void)initMyQNPlayer
{
    // 初始化 PLPlayerOption 对象
    PLPlayerOption *option = [PLPlayerOption defaultOption];
    // 需要更改的option属性键所对应的值
    [option setOptionValue:@15 forKey:PLPlayerOptionKeyTimeoutIntervalForMediaPackets];
    
    // 播放URL RTMPrtmp://http://pili-live-hls.tv.mygrowth.cn/voide/zhubo111.m3u8
    NSURL *url = [NSURL URLWithString:@"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"];
   // NSURL *url = [NSURL URLWithString:@"http://pili-live-hls.tv.mygrowth.cn/voide/zhubo111.m3u8"];
    // 播放本地文件
    //NSURL *url = [[NSBundle mainBundle]URLForResource:@"本地文件" withExtension:nil];
    
    self.player = [PLPlayer playerWithURL:url option:option];
    self.player.delegate = self;
    self.player.playerView.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64);
    [self.view addSubview:self.player.playerView];
    [self.view sendSubviewToBack:self.player.playerView];
    
    // 支持后台播放( 需要注意的是在后台播放时仅有音频，视频会在回到前台时继续播放。)
    self.player.backgroundPlayEnable = YES;
    [[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    self.playStatus = 0;
    // 开始播放
    [self.player play];
    
    
    // 播放开始前显示的图片
    //    self.player.launchView;
    
    // 当前播放时间
    //    self.player.currentTime;
    // 总播放时间
    //    self.player.totalDuration;
        
    // 是否开启重连，默认NO
    self.player.autoReconnectEnable = YES;

    // 设置画面旋转模式 仅对 rtmp/flv 直播与 ffmpeg 点播有效
    self.player.rotationMode = PLPlayerNoRotation;
    
    // 是否渲染画面 默认YES
    self.player.enableRender = YES;

    // 音量控制
    [self setMySoundButton];
    
    // 下载速度
    [self myDownloadSpeed];
    
    
}

#pragma mark --- 实现 <PLPlayerDelegate> ---
// 控制流状态的变更
- (void)player:(PLPlayer *)player statusDidChange:(PLPlayerStatus)state
{
    // 这里会返回流的各种状态，你可以根据状态做 UI 定制及各类其他业务操作
    // 除了 Error 状态，其他状态都会回调这个方法
    // 开始播放，当连接成功后，将收到第一个 PLPlayerStatusCaching 状态
    // 第一帧渲染后，将收到第一个 PLPlayerStatusPlaying 状态
    // 播放过程中出现卡顿时，将收到 PLPlayerStatusCaching 状态
    // 卡顿结束后，将收到 PLPlayerStatusPlaying 状态
    NSLog(@"控制流状态变更 ---- %ld", state);
    NSString *playStatus = [NSString string];
    switch (state) {
        case 0:
            playStatus = @"未知状态";
            break;
        case 1:
            playStatus = @"正在准备播放";
            break;
        case 2:
            playStatus = @"准备开始播放";
            break;
        case 3:
            playStatus = @"响应主播断流";
            break;
        case 4:
            playStatus = @"正在播放";
            break;
        case 5:
            playStatus = @"暂停状态";
            break;
        case 6:
            playStatus = @"停止状态";
            break;
        case 7:
            playStatus = @"错误状态";
            break;
        default:
            break;
    }

}

//error 状态回调
//当因为网络异常而触发了播放断开时，会通过 error Delegate 回调触发
- (void)player:(PLPlayer *)player stoppedWithError:(NSError *)error
{
    // 当发生错误，停止播放时，会回调这个方法
}

// 当解码器发生错误时，会回调这个方法
- (void)player:(PLPlayer *)player codecError:(NSError *)error
{
    // 当 videotoolbox 硬解初始化或解码出错时
    // error.code 值为 PLPlayerErrorHWCodecInitFailed/PLPlayerErrorHWDecodeFailed
    // 播发器也将自动切换成软解，继续播放
    
    //对于错误的处理，不建议触发了一次 error 后就断掉，最好可以在此时尝试调用 -play 方法进行有限次数的重连。
}

#pragma mark --- 音量控制 ---
- (void)setMySoundButton
{
    
    // 音量开关
    self.soundButton = [[UIButton alloc]initWithFrame:CGRectMake(KScreenWidth - 80, 100, 30, 30)];
    [self.soundButton setImage:[UIImage imageNamed:@"unclose_vol"] forState:UIControlStateNormal];
    [self.soundButton addTarget:self action:@selector(closeSound) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:self.soundButton];
    self.isClose = NO;
    
    // 音量条
    self.volumeSlider = [[UISlider alloc]initWithFrame:CGRectMake(50, KScreenHeight - 100, 250, 30)];
    self.volumeSlider.minimumTrackTintColor = [UIColor cyanColor];
    self.volumeSlider.maximumTrackTintColor = [UIColor lightGrayColor];
    self.volumeSlider.minimumValue = 0;
    self.volumeSlider.maximumValue = 1;
    // 设置音量，范围是0-1.0，默认1.0
    [self.player setVolume:0.5];
    // 获取音量
    float volume = [self.player getVolume];
    self.volumeSlider.value = 0.3;
    self.volumeSlider.continuous = NO; // 设置为NO 等待用户滑动完成并松手后 触发事件
    [self.volumeSlider addTarget:self action:@selector(volumeSliderAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_volumeSlider];
   
}

// 音量调节
- (void)volumeSliderAction:(UISlider *)slider
{
    // 设置音量，范围是0-1.0，默认1.0
    [self.player setVolume:slider.value];
    if (slider.value == 0) {
        [self.soundButton setImage:[UIImage imageNamed:@"close_vol"] forState:UIControlStateNormal];
    }
    else{
        [self.soundButton setImage:[UIImage imageNamed:@"unclose_vol"] forState:UIControlStateNormal];
    }
}



// 静音开关键
- (void)closeSound
{
    self.isClose = !self.isClose;
    if (self.isClose) {
        [self.player setVolume:0];
        self.volumeSlider.value = 0;
        // 是否需要静音 PLPlayer，默认值为NO
        self.player.mute = YES;
        [self.soundButton setImage:[UIImage imageNamed:@"close_vol"] forState:UIControlStateNormal];
    }
    else
    {
        [self.player setVolume:0.3];
        self.volumeSlider.value = 0.3;
        self.player.mute = NO;
        [self.soundButton setImage:[UIImage imageNamed:@"unclose_vol"] forState:UIControlStateNormal];
    }
}

#pragma mark --- 下载速度 --
- (void)myDownloadSpeed
{
    UILabel *speedLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 80, 60, 20)];
    speedLabel.textColor = [UIColor whiteColor];
    speedLabel.text= [NSString stringWithFormat:@"下载速率：%.2f kb/s", self.player.downSpeed];
    [self.view addSubview:speedLabel];
}




#pragma mark --- 开始暂停按钮 ---
- (void)rightAction:(UIBarButtonItem *)rightBarButton
{
    if (self.playStatus == 0) {
        rightBarButton.title = @"播放";
        self.playStatus = 1;
        [self.player stop];
    }
    else
    {
        rightBarButton.title = @"暂停";
        self.playStatus = 0;
        [self.player play];
    }
}

#pragma mark --- 返回按钮 ---
- (void)leftAction:(UIBarButtonItem *)letButton
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end

