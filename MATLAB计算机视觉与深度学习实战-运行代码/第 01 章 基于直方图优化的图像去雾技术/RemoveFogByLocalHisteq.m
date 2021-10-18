function In = RemoveFogByLocalHisteq(I, flag)

g1 = GetLocalHisteq(I(:, :, 1));
g2 = GetLocalHisteq(I(:, :, 2));
g3 = GetLocalHisteq(I(:, :, 3));

In = cat(3, g1, g2, g3);

if flag
    figure;
    subplot(2, 2, 1); imshow(I); title('ԭͼ��', 'FontWeight', 'Bold');
    subplot(2, 2, 2); imshow(In); title('������ͼ��', 'FontWeight', 'Bold');
    Q = rgb2gray(I);
    W = rgb2gray(In);
    subplot(2, 2, 3); imhist(Q, 64); title('ԭ�Ҷ�ֱ��ͼ', 'FontWeight', 'Bold');
    subplot(2, 2, 4); imhist(W, 64); title('�����ĻҶ�ֱ��ͼ', 'FontWeight', 'Bold');
end

function g = GetLocalHisteq(I)
% �ԻҶ�ͼ�񣬽��оֲ�ֱ��ͼ���⻯
% ���������
%  I����ͼ�����
% ���������
%  g�������ͼ��
% ���ÿ⺯��adapthisteq��ִ�оֲ����⻯��ǿ
g = adapthisteq(I,'clipLimit',0.02,'Distribution','rayleigh');