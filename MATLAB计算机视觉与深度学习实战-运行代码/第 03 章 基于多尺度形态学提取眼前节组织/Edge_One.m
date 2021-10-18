function Gf = Edge_One(G, u)
if nargin < 2
    % Ĭ�ϲ���
    u = rand(1, length(G));
    u = u/sum(u(:));
end
Gf = zeros(size(G{1})); 
for i = 1 : length(G)
    % ��Ȩ���
    Gf = Gf + u(i)*double(G{i});
end
% ͳһ����
Gf = im2uint8(mat2gray(Gf)); 