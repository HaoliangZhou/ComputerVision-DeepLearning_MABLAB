function diff_ab = usimole(fa, fb)
% �ֱ������Ϣֵ
Ha = compute_infos(fa);
Hb = compute_infos(fb);
% ���Բ��
diff_ab = imabsdiff(Ha, Hb);