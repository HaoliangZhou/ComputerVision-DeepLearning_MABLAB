clc; clear all; close all;
I = imread('IMG00016.jpg');
bw = im2bw(I, graythresh(I));
figure; 
subplot(1, 2, 1); imshow(I, []); title('ԭͼ��');
subplot(1, 2, 2); imshow(bw, []); title('��ֵ�ָ�ͼ��');