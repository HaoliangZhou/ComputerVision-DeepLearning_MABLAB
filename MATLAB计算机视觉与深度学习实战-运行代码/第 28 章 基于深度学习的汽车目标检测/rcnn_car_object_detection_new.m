clc; clear all; close all;
%% ��������
% vehicleDataset��һ��dataset�������ͣ���һ����ͼƬ�����·�����ڶ�����ͼƬ��С������λ��
data = load('fasterRCNNVehicleTrainingData.mat');
vehicleDataset = data.vehicleTrainingData;
% ��ʾ���ݽṹ
vehicleDataset(1:4,:)
% �������ݼ�Ŀ¼
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
% �����ݻ���������
% ǰ70%����������ѵ��������30%���ڲ���
idx = floor(0.7 * height(vehicleDataset));
trainingData = vehicleDataset(1:idx,:);
testData = vehicleDataset(idx:end,:);

%% ����ṹ���
% ����㣬��С������Լ32*32
inputLayer = imageInputLayer([32 32 3]);
% �м��
% �����������
filterSize = [3 3];
numFilters = 32;
middleLayers = [
    % ���+����
    convolution2dLayer(filterSize, numFilters, 'Padding', 1)
    reluLayer()
    % ���+����+�ػ�
    convolution2dLayer(filterSize, numFilters, 'Padding', 1)
    reluLayer()
    maxPooling2dLayer(3, 'Stride',2)
    ];
% �����
finalLayers = [
    % ����һ������64�������ȫ���Ӳ�
    fullyConnectedLayer(64)
    % ����һ��������ReLU��
    reluLayer
    % ����ȫ���Ӳ㣬�����ж�ͼƬ�Ƿ����������
    fullyConnectedLayer(width(vehicleDataset))
    % ���softmax��classification��
    softmaxLayer
    classificationLayer
    ];
% ������в�
layers = [
    inputLayer
    middleLayers
    finalLayers
    ]
%% ����ѵ������
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
%% ѵ��Faster R-CNN
% ����ģ�͵ı��ش洢
doTrainingAndEval = true;
if doTrainingAndEval
    % ����ê�㣬��ִ��ѵ��
    rng(0);
    detector = trainFasterRCNNObjectDetector(trainingData, layers, options, ...
        'NegativeOverlapRange', [0 0.3], ...
        'PositiveOverlapRange', [0.6 1], ...
        'BoxPyramidScale', 1.2);
else
    % ֱ������
    detector = data.detector;
end

%% ���Խ��
I = imread('highway.png');
% ���м���������Ŀ��λ�ú͵÷�
[bboxes, scores] = detect(detector, I);
% ��ͼ���ϱ�Ǵ�ʶ���С����
I = insertObjectAnnotation(I, 'rectangle', bboxes, scores);
figure
imshow(I)
%% ����ѵ��Ч��
if doTrainingAndEval
    resultsStruct = struct([]);
    for i = 1:height(testData)
        % ��ȡ����ͼƬ
        I = imread(testData.imageFilename{i});
        % ����RCNN�����
        [bboxes, scores, labels] = detect(detector, I);
        % ������浽�ṹ��
        resultsStruct(i).Boxes = bboxes;
        resultsStruct(i).Scores = scores;
        resultsStruct(i).Labels = labels;
    end
    % ���ṹ��ת��Ϊtable��������
    results = struct2table(resultsStruct);
else
    % ֱ�Ӽ���֮ǰ�����õ�����
    results = data.results;
end
% �Ӳ�����������ȡ������С��λ��
expectedResults = testData(:, 2:end);
%����ƽ����ȷ���������Ч��
[ap, recall, precision] = evaluateDetectionPrecision(results, expectedResults);
% �����ٻ���-��ȷ������
figure
plot(recall, precision)
xlabel('Recall')
ylabel('Precision')
grid on
title(sprintf('Average Precision = %.2f', ap))