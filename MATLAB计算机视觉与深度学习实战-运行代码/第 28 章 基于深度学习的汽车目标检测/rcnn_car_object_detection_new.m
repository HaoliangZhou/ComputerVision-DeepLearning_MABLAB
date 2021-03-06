clc; clear all; close all;
%% 加载数据
% vehicleDataset是一个dataset数据类型，第一列是图片的相对路径，第二列是图片中小汽车的位置
data = load('fasterRCNNVehicleTrainingData.mat');
vehicleDataset = data.vehicleTrainingData;
% 显示数据结构
vehicleDataset(1:4,:)
% 设置数据集目录
dataDir = fullfile(toolboxdir('vision'),'visiondata');
vehicleDataset.imageFilename = fullfile(dataDir, vehicleDataset.imageFilename);
% 展示前9幅图片
k = 9;
I=zeros(128,228,3,k);
for i = 1 :  k
    % 读取图片
    tmp = imread(vehicleDataset.imageFilename{i});
    % 添加标识框
    tmp = insertShape(tmp, 'Rectangle', vehicleDataset.vehicle{i});
    I(:,:,:,i) = mat2gray(tmp);
end
% 显示
Is = I;
hfig = figure; montage(Is);
set(hfig, 'Units', 'Normalized', 'Position', [0, 0, 1, 1]);
pause(1);
% 将数据划分两部分
% 前70%的数据用于训练，后面30%用于测试
idx = floor(0.7 * height(vehicleDataset));
trainingData = vehicleDataset(1:idx,:);
testData = vehicleDataset(idx:end,:);

%% 网络结构设计
% 输入层，最小检测对象约32*32
inputLayer = imageInputLayer([32 32 3]);
% 中间层
% 定义卷基层参数
filterSize = [3 3];
numFilters = 32;
middleLayers = [
    % 卷积+激活
    convolution2dLayer(filterSize, numFilters, 'Padding', 1)
    reluLayer()
    % 卷积+激活+池化
    convolution2dLayer(filterSize, numFilters, 'Padding', 1)
    reluLayer()
    maxPooling2dLayer(3, 'Stride',2)
    ];
% 输出层
finalLayers = [
    % 新增一个包含64个输出的全连接层
    fullyConnectedLayer(64)
    % 新增一个非线性ReLU层
    reluLayer
    % 新增全连接层，用于判断图片是否包含检测对象
    fullyConnectedLayer(width(vehicleDataset))
    % 添加softmax和classification层
    softmaxLayer
    classificationLayer
    ];
% 组合所有层
layers = [
    inputLayer
    middleLayers
    finalLayers
    ]
%% 配置训练参数
options = [
     % 第1步，Training a Region Proposal Network (RPN)
    trainingOptions('sgdm', 'MaxEpochs', 10,'InitialLearnRate', 1e-5,'CheckpointPath', tempdir)
    % 第2步，Training a Fast R-CNN Network using the RPN from step 1
    trainingOptions('sgdm', 'MaxEpochs', 10,'InitialLearnRate', 1e-5,'CheckpointPath', tempdir)
    % 第3步，Re-training RPN using weight sharing with Fast R-CNN
    trainingOptions('sgdm', 'MaxEpochs', 10,'InitialLearnRate', 1e-6,'CheckpointPath', tempdir)
    % 第4步，Re-training Fast R-CNN using updated RPN
    trainingOptions('sgdm', 'MaxEpochs', 10,'InitialLearnRate', 1e-6,'CheckpointPath', tempdir)
    ];
%% 训练Faster R-CNN
% 设置模型的本地存储
doTrainingAndEval = true;
if doTrainingAndEval
    % 设置锚点，并执行训练
    rng(0);
    detector = trainFasterRCNNObjectDetector(trainingData, layers, options, ...
        'NegativeOverlapRange', [0 0.3], ...
        'PositiveOverlapRange', [0.6 1], ...
        'BoxPyramidScale', 1.2);
else
    % 直接载入
    detector = data.detector;
end

%% 测试结果
I = imread('highway.png');
% 运行检测器，输出目标位置和得分
[bboxes, scores] = detect(detector, I);
% 在图像上标记处识别的小汽车
I = insertObjectAnnotation(I, 'rectangle', bboxes, scores);
figure
imshow(I)
%% 评估训练效果
if doTrainingAndEval
    resultsStruct = struct([]);
    for i = 1:height(testData)
        % 读取测试图片
        I = imread(testData.imageFilename{i});
        % 运行RCNN检测器
        [bboxes, scores, labels] = detect(detector, I);
        % 结果保存到结构体
        resultsStruct(i).Boxes = bboxes;
        resultsStruct(i).Scores = scores;
        resultsStruct(i).Labels = labels;
    end
    % 将结构体转换为table数据类型
    results = struct2table(resultsStruct);
else
    % 直接加载之前评估好的数据
    results = data.results;
end
% 从测试数据中提取期望的小车位置
expectedResults = testData(:, 2:end);
%采用平均精确度评估检测效果
[ap, recall, precision] = evaluateDetectionPrecision(results, expectedResults);
% 绘制召回率-精确率曲线
figure
plot(recall, precision)
xlabel('Recall')
ylabel('Precision')
grid on
title(sprintf('Average Precision = %.2f', ap))