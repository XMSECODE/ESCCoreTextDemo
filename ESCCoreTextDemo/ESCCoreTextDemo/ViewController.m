//
//  ViewController.m
//  ESCCoreTextDemo
//
//  Created by xiatian on 2022/1/4.
//

#import "ViewController.h"
#import <CoreText/CoreText.h>
//效果：文字显示超过三行则只显示三行，且在第三行末尾显示...全文字样


static void RunDelegateDeallocCallback( void* refCon ){
    
}

static CGFloat RunDelegateGetAscentCallback( void *refCon ){
    NSTextAttachment *attachment = (__bridge NSTextAttachment *)(refCon);
    return attachment.bounds.size.height;;
}

static CGFloat RunDelegateGetDescentCallback(void *refCon){
    return 0;
}

static CGFloat RunDelegateGetWidthCallback(void *refCon){
    NSTextAttachment *attachment = (__bridge NSTextAttachment *)(refCon);
    return attachment.bounds.size.width;;
}

@interface ViewController ()

@property(nonatomic,weak)UILabel* normalLabel;

@property(nonatomic,weak)UILabel* testLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *string = @"大江东去，浪淘尽，千古风流人物。故垒西边，人道是，💗三国周郎赤壁。乱石穿空，惊涛拍岸，卷起千堆雪。江山如画，一时多少豪杰。遥想公瑾当年，小乔初嫁了，雄姿英发。羽扇纶巾，谈笑间，樯橹灰飞烟灭。故国神游，多情应笑我，早生华发。人生如梦，一尊还酹江月。";
//    NSString *string = @"想去远方的山川，想去海边看海鸥 不管风雨有多少，有你就足够 喜欢看你的嘴角，喜欢看你的眉梢";
    UILabel *normalLabel = [[UILabel alloc] init];
    self.normalLabel = normalLabel;
    [self.view addSubview:self.normalLabel];
    self.normalLabel.frame = CGRectMake(20, 100, 300, 80);
    self.normalLabel.numberOfLines = 3;
    
    self.normalLabel.text = string;
    
    
    UILabel *testLabel = [[UILabel alloc] init];
    self.testLabel = testLabel;
    [self.view addSubview:self.testLabel];
    self.testLabel.frame = CGRectMake(20, 200, 300, 80);
    self.testLabel.numberOfLines = 3;
    self.testLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    NSAttributedString *resultString = [self checkToShowWholeEassyWithString:string];
    self.testLabel.attributedText = resultString;
    
}
// 判断是否显示全文
- (NSAttributedString *)checkToShowWholeEassyWithString:(NSString *)string {
   
    NSMutableAttributedString *attributedString = [[[NSAttributedString alloc]initWithString:string] mutableCopy];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 2;// 字体的行间距
    NSDictionary *attributes = @{
    NSParagraphStyleAttributeName:paragraphStyle};
    [attributedString addAttributes:attributes range:NSMakeRange(0,attributedString.length)];
    self.testLabel.attributedText = attributedString;
    NSArray *lineArray = [self getSeparatedLinesFromText:self.testLabel];
    // 要显示到第三行才进行后面的
    if (lineArray.count < 3) {
        return attributedString;
    }
    NSString *lineEndString = lineArray[1];
    BOOL returnLine = [lineEndString containsString:@"\n"];
    if (returnLine) {
        // 小于一行最大字数 且存在换行，那就直接加全文
        lineEndString = [lineEndString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n"]];
    }
    //计算最大字数
    for (int i = (int)lineEndString.length; i >= 0; i--) {
        //计算
        NSString *tem = [NSString stringWithFormat:@"%@...全文",[lineEndString substringToIndex:i]];
        NSAttributedString *attributedString = [[NSAttributedString alloc]initWithString:tem];
        NSUInteger line = [self getLineWithString:[attributedString mutableCopy]];
        if (line == 1) {
            lineEndString = [lineEndString substringToIndex:i];
            break;
        }
        
    }
    NSString *showText = [NSString stringWithFormat:@"%@%@...全文", lineArray[0], lineEndString];
    //设置label的attributedText
    NSMutableAttributedString *attStr = [[[NSAttributedString alloc]initWithString:showText] mutableCopy];
    [attStr addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0], NSForegroundColorAttributeName:[UIColor blueColor]} range:NSMakeRange(attStr.length-2, 2)];
    [attStr addAttributes:attributes range:NSMakeRange(0,attStr.length)];
    return attStr;
}

- (NSUInteger)getLineWithString:(NSMutableAttributedString *)string {
    CGRect rect = CGRectMake(0, 0, 300, 100);
    CTRunDelegateCallbacks callbacks;
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.dealloc = RunDelegateDeallocCallback;
    callbacks.getAscent = RunDelegateGetAscentCallback;
    callbacks.getDescent = RunDelegateGetDescentCallback;
    callbacks.getWidth = RunDelegateGetWidthCallback;
    NSMutableAttributedString *attStr = [string mutableCopy];
//    [attStr enumerateAttributesInRange:NSMakeRange(0, attStr.length) options:(NSAttributedStringEnumerationReverse | NSAttributedStringEnumerationLongestEffectiveRangeNotRequired) usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
//    }];
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attStr);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0,0,rect.size.width,CGFLOAT_MAX));
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
    CFRelease(path);
    CFRelease(frameSetter);
    CFRelease(frame);
    return lines.count;
}

- (NSArray *)getSeparatedLinesFromText:(UILabel *)label{
    NSString *text = label.text;
    if (text.length == 0) {
        return @[];
    }
    CGRect rect = CGRectMake(0, 0, 300, 100);
    CTRunDelegateCallbacks callbacks;
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.dealloc = RunDelegateDeallocCallback;
    callbacks.getAscent = RunDelegateGetAscentCallback;
    callbacks.getDescent = RunDelegateGetDescentCallback;
    callbacks.getWidth = RunDelegateGetWidthCallback;
    NSMutableAttributedString *attStr = [label.attributedText mutableCopy];
//    [attStr enumerateAttributesInRange:NSMakeRange(0, attStr.length) options:(NSAttributedStringEnumerationReverse | NSAttributedStringEnumerationLongestEffectiveRangeNotRequired) usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        //NSAttachment
//        NSTextAttachment *attachment = [attrs objectForKey:NSAttachmentAttributeName];
//        if (attachment && [attachment isKindOfClass:[NSTextAttachment class]]) {
//            CTRunDelegateRef runDelegate = CTRunDelegateCreate(&callbacks, (__bridge void * _Nullable)(attachment));
//            CFAttributedStringSetAttribute((CFMutableAttributedStringRef)attStr, CFRangeMake(range.location, range.length), kCTRunDelegateAttributeName, runDelegate);
//        }
//    }];
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attStr);
    
    CGMutablePathRef path = CGPathCreateMutable();

    CGPathAddRect(path, NULL, CGRectMake(0,0,rect.size.width,CGFLOAT_MAX));

    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);

    NSMutableArray *linesArray = [[NSMutableArray alloc] init];

    for (id line in lines) {
        CTLineRef lineRef = (__bridge CTLineRef )line;
        CFRange lineRange = CTLineGetStringRange(lineRef);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
        NSString *lineString = [text substringWithRange:range];
        NSMutableString *mLineString = [lineString mutableCopy];
        //需要判断是否为自定义表情
//        NSArray * runs = (__bridge NSArray *)CTLineGetGlyphRuns(lineRef);
        
        [linesArray addObject:mLineString];
    }
    CFRelease(path);
    CFRelease(frameSetter);
    CFRelease(frame);
    return linesArray;
}

@end
