% �������ռ�
clc; clear all; close all;
% ���Ԥ�����ļ�
if exist(fullfile(pwd, 'dt.mat'), 'file')
    load(fullfile(pwd, 'dt.mat'));
    figure;  imshow(result, []);
    return;
end
% ��ȡͼƬ
Img = imread('images\image.bmp');
% ����1~5�����ӽ��
Gf1 = Main_Process(Img, 1);
Gf2 = Main_Process(Img, 2);
Gf3 = Main_Process(Img, 3);
Gf4 = Main_Process(Img, 4);
Gf5 = Main_Process(Img, 5);
% ���ϵ�cell
G{1} = Gf1;
G{2} = Gf2;
G{3} = Gf3;
G{4} = Gf4;
G{5} = Gf5;
% ����ϵ��
ua1 = Coef(Gf1, G);
ua2 = Coef(Gf2, G);
ua3 = Coef(Gf3, G);
ua4 = Coef(Gf4, G);
ua5 = Coef(Gf5, G);
% ���
u = [ua1, ua2, ua3, ua4, ua5];
% Ȩ��
u = u/sum(u);
% ��Ȩ�ں�
Gf = Edge_One(G, u);
% ��ʾ���
result = Gf5;
figure;  imshow(Img, []);
figure;  imshow(result, []);