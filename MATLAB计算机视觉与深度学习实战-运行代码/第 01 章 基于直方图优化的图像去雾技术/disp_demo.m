clc; clear all; close all;
I = imread('tire.tif');
J = histeq(I);
figure; 
subplot(2, 2, 1); imshow(I, []); title('ԭͼ');
subplot(2, 2, 2); imshow(J, []); title('ԭͼ���⻯���ͼ��');
subplot(2, 2, 3); imhist(I, 64); title('ԭͼ��ֱ��ͼ');
subplot(2, 2, 4); imhist(J, 64); title('���⻯���ֱ��ͼ');