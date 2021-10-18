function H = compute_infos(I)
% ����ͳ������
level = 256;
% ��ʼ��
dat = double(I);
p = zeros(1, level);
for i = 1 : size(dat, 1)
    for j = 1 : size(dat, 2)
        % ���ͳ��ֱ��ͼ
        temp = dat(i,j);
        p(1, temp+1) = p(1, temp+1) + 1;
    end
end
% ��һ��
p = p/(size(dat, 1)*size(dat, 2));
H = 0;
for i = 1 : level
    if p(i) ~= 0
        % �ۼ�ֱ��ͼ
        H = H + p(i)*log2(p(i));
    end
end
% ��Ϣֵ����
H = -H;