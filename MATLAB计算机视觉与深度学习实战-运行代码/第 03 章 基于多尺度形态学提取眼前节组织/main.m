% 清理工作空间
clc; clear all; close all;
% 检查预处理文件
if exist(fullfile(pwd, 'dt.mat'), 'file')
    load(fullfile(pwd, 'dt.mat'));
    figure;  imshow(result, []);
    return;
end
% 读取图片
Img = imread('images\image.bmp');
% 计算1~5的算子结果
Gf1 = Main_Process(Img, 1);
Gf2 = Main_Process(Img, 2);
Gf3 = Main_Process(Img, 3);
Gf4 = Main_Process(Img, 4);
Gf5 = Main_Process(Img, 5);
% 整合到cell
G{1} = Gf1;
G{2} = Gf2;
G{3} = Gf3;
G{4} = Gf4;
G{5} = Gf5;
% 计算系数
ua1 = Coef(Gf1, G);
ua2 = Coef(Gf2, G);
ua3 = Coef(Gf3, G);
ua4 = Coef(Gf4, G);
ua5 = Coef(Gf5, G);
% 组合
u = [ua1, ua2, ua3, ua4, ua5];
% 权重
u = u/sum(u);
% 加权融合
Gf = Edge_One(G, u);
% 显示结果
result = Gf5;
figure;  imshow(Img, []);
figure;  imshow(result, []);