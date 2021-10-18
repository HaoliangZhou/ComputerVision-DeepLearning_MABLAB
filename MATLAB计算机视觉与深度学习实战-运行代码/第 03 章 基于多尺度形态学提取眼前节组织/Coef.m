function ua = Coef(fa, f)
% 元素个数
N = length(f);
% 初始化
s = [];
for i = 1 : N
    % 当前结果
    fi = f{i};
    % 交叉差分
    si = supoles(fi, f);
    % 存储
    s = [s si];
end
% 归一化处理
sp = min(s(:));
sa = supoles(fa, f);
ka = sp/sa;
k = 0;
for i = 1 : N
    fb = f{i};
    s = [];
    for i = 1 : N
        fi = f{i};
        % 交叉差分
        si = supoles(fi, f);
        % 存储
        s = [s si];
    end
    % 归一化处理
    sp = min(s);
    sb = supoles(fb, f);
    kb = sp/sa;
    k = k + kb;
end
% 均值
ua = ka/k;