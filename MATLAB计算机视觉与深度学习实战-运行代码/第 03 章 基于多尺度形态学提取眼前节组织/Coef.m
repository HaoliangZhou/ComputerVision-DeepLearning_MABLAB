function ua = Coef(fa, f)
% Ԫ�ظ���
N = length(f);
% ��ʼ��
s = [];
for i = 1 : N
    % ��ǰ���
    fi = f{i};
    % ������
    si = supoles(fi, f);
    % �洢
    s = [s si];
end
% ��һ������
sp = min(s(:));
sa = supoles(fa, f);
ka = sp/sa;
k = 0;
for i = 1 : N
    fb = f{i};
    s = [];
    for i = 1 : N
        fi = f{i};
        % ������
        si = supoles(fi, f);
        % �洢
        s = [s si];
    end
    % ��һ������
    sp = min(s);
    sb = supoles(fb, f);
    kb = sp/sa;
    k = k + kb;
end
% ��ֵ
ua = ka/k;