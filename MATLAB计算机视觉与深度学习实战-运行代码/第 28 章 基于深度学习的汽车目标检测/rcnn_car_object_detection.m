clc; clear all; close all;
tic;
%% ��������
% vehicleDataset��һ��dataset�������ͣ���һ����ͼƬ�����·�����ڶ�����ͼƬ��С������λ��
data = load('fasterRCNNVehicleTrainingData.mat');
% ��ȡѵ����
vehicleDataset = data.vehicleTrainingData;
% ��ȡͼƬ·��
dataDir = fullfile(toolboxdir('vision'),'visiondata');
vehicleDataset.imageFilename = fullfile(dataDir, vehicleDataset.imageFilename);
% չʾǰ9��ͼƬ
k = 9;
I=zeros(128,228,3,k);
for i = 1 :  k
    % ��ȡͼƬ
    tmp = imread(vehicleDataset.imageFilename{i});
    % ��ӱ�ʶ��
    tmp = insertShape(tmp, 'Rectangle', vehicleDataset.vehicle{i});
    I(:,:,:,i) = mat2gray(tmp);
end
% ��ʾ
Is = I;
hfig = figure; montage(Is);
set(hfig, 'Units', 'Normalized', 'Position', [0, 0, 1, 1]);
pause(1);
%% ����CNN����
% ����㣬��С������Լ32*32
inputLayer = imageInputLayer([32 32 3]);
% �м��
% �����������
filterSize = [3 3];
numFilters = 32;
middleLayers = [
    % ��һ�֣�ֻ����CNN��ReLU
    convolution2dLayer(filterSize, numFilters, 'Padding', 1)
    reluLayer()
    % �ڶ��֣�����CNN��ReLU��Pooling
    convolution2dLayer(filterSize, numFilters, 'Padding', 1)
    reluLayer()
    maxPooling2dLayer(3, 'Stride',2)
    ];
% �����
finalLayers = [
    % ����һ������64�������ȫ���Ӳ�
    fullyConnectedLayer(64)
    % ����һ��������ReLU��
    reluLayer()
    % ����һ��2�������ȫ���Ӳ㣬�����ж�ͼƬ�Ƿ����������
    fullyConnectedLayer(2)
    % �����softmax��classification��
    softmaxLayer()
    classificationLayer()
    ];
% ������в�
layers = [
    inputLayer
    middleLayers
    finalLayers
    ];
%% ѵ��CNN����
% �����ݻ���������
% ǰ60%����������ѵ��������40%���ڲ���
ind = round(size(vehicleDataset,1) * 0.6);
trainData = vehicleDataset(1 : ind, :);
testData = vehicleDataset(ind+1 : end, :);
% ѵ�����̰���4�����裬ÿ������ʹ�õ����Ĳ�����Ҳ����ʹ��ͬһ������
options = [
    % ��1����Training a Region Proposal Network (RPN)
    trainingOptions('sgdm', 'MaxEpochs', 10,'InitialLearnRate', 1e-5,'CheckpointPath', tempdir)
    % ��2����Training a Fast R-CNN Network using the RPN from step 1
    trainingOptions('sgdm', 'MaxEpochs', 10,'InitialLearnRate', 1e-5,'CheckpointPath', tempdir)
    % ��3����Re-training RPN using weight sharing with Fast R-CNN
    trainingOptions('sgdm', 'MaxEpochs', 10,'InitialLearnRate', 1e-6,'CheckpointPath', tempdir)
    % ��4����Re-training Fast R-CNN using updated RPN
    trainingOptions('sgdm', 'MaxEpochs', 10,'InitialLearnRate', 1e-6,'CheckpointPath', tempdir)
    ];
% ����ģ�͵ı��ش洢
doTrainingAndEval = 1;
if doTrainingAndEval    
    % ѵ�� R-CNN �����磬��ʵ�����繤�����ṩ��3������
    % ��1��trainRCNNObjectDetector��ѵ��������������ָ��proposalFcn
    % ��2��trainFastRCNNObjectDetector���ٶȽϿ죬����ָ��proposalFcn
    % ��3��trainFasterRCNNObjectDetector���Ż��������ܣ�����Ҫָ��proposalFcn
    detector = trainFasterRCNNObjectDetector(trainData, layers, options, ...
        'NegativeOverlapRange', [0 0.3], ...
        'PositiveOverlapRange', [0.6 1], ...
        'BoxPyramidScale', 1.2);
else
    % �����Ѿ�ѵ���õ�������
    detector = data.detector;
end
% ���ٲ���ѵ�����
I = imread('highway.png');
% ���м���������Ŀ��λ�ú͵÷�
[bboxes, scores] = detect(detector, I);
% ��ͼ���ϱ�Ǵ�ʶ���С����
I = insertObjectAnnotation(I, 'rectangle', bboxes, scores);
figure; imshow(I)
%% ����ѵ��Ч��
if doTrainingAndEval
    results = struct;
    for i = 1:size(testData,1)
        % ��ȡ����ͼƬ
        I = imread(testData.imageFilename{i});
        % ����CNN�����
        [bboxes, scores, labels] = detect(detector, I);
        % ������浽�ṹ��
        results(i).Boxes = bboxes;
        results(i).Scores = scores;
        results(i).Labels = labels;
    end
    % ���ṹ��ת��Ϊtable��������
    results = struct2table(results);
else
    % ����֮ǰ�����õ�����
    results = data.results;
end
% �Ӳ�����������ȡ������С��λ��
expectedResults = testData(:, 2:end);
%����ƽ����ȷ���������Ч��
[ap, recall, precision] = evaluateDetectionPrecision(results, expectedResults);
% �����ٻ���-��ȷ������
figure;
plot(recall, precision);
xlabel('Recall');
ylabel('Precision')
grid on;
title(sprintf('Average Precision = %.2f', ap));
toc