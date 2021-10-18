function diff_fab = usim(fa, f)
% 初始化
diff_fab = 0;
N = length(f);
for i = 1 : N
    fb = f{i};
    % 计算差分结果
    diff_ab = usimole(fa, fb);
    % 组合
    diff_fab = diff_fab + diff_ab;
end