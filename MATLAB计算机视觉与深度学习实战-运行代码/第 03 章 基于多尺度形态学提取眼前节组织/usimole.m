function diff_ab = usimole(fa, fb)
% 分别计算信息值
Ha = compute_infos(fa);
Hb = compute_infos(fb);
% 绝对差分
diff_ab = imabsdiff(Ha, Hb);