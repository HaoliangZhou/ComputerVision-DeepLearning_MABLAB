function [Gi, ng] = Multi_Process(I, g, n)
% 默认参数检测
if nargin < 3
    n = 6;
end
% 初始化
ng = g;
for i = 1:n
    % 膨胀
    ng = imdilate(ng, g);
end
% 依次执行开、膨胀、闭、腐蚀形态学操作
Gi1 = imopen(I, ng);
Gi1 = imdilate(Gi1, ng);
Gi2 = imclose(I, ng);
Gi2 = imerode(Gi2, ng);
% 差分
Gi = imsubtract(Gi1, Gi2);