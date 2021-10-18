function H = compute_infos(I)
% 设置统计量级
level = 256;
% 初始化
dat = double(I);
p = zeros(1, level);
for i = 1 : size(dat, 1)
    for j = 1 : size(dat, 2)
        % 逐层统计直方图
        temp = dat(i,j);
        p(1, temp+1) = p(1, temp+1) + 1;
    end
end
% 归一化
p = p/(size(dat, 1)*size(dat, 2));
H = 0;
for i = 1 : level
    if p(i) ~= 0
        % 累计直方图
        H = H + p(i)*log2(p(i));
    end
end
% 信息值计算
H = -H;