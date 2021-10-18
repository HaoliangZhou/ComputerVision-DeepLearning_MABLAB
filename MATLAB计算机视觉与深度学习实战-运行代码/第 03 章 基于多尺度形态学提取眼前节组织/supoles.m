function Inversef = supoles(fa, f)
% 初始化
Inversef = 0;
N = length(f);
for i = 1 : N
    fb = f{i};
    % 计算相似结果
    diff_fab = usim(fa, f);
    % 组合
    Inversef = Inversef + diff_fab;
end