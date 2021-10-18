clc; clear all; close all;
videofile = 'viptraffic.avi';
reader = VideoReader(videofile);
opticFlow = opticalFlowHS;
while hasFrame(reader)
    im = readFrame(reader);
    im_gray = rgb2gray(im);
    flow = estimateFlow(opticFlow,im_gray);
    figure(1);
    subplot(1, 2, 1); imshow(im, []); title('原图');
    subplot(1, 2, 2);
    imshow(im)
    hold on
    plot(flow,'DecimationFactor',[5 5],'ScaleFactor',25)
    hold off
    title('光流场标记图');
end