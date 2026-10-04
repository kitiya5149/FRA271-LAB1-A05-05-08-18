%% FRA271 Lab 1 - Rotary potentiometer: เปรียบเทียบ type A, B, C ในกราฟเดียว
% ใช้ค่าเฉลี่ย 3 ครั้งของแต่ละ type พร้อม error bar (SD)
clear; clc; close all;

file = 'rotary.csv';      % ไฟล์เดียวกับที่ใช้ในสคริปต์ rotary ตัวอื่น

%% 1) อ่านข้อมูล
raw = readcell(file);
x   = str2double(erase(string(raw(2:end,1)), '%'));     % '25%' -> 25
M   = cell2mat(raw(2:end, 2:13));

runs.A = M(:, 1:3);       % คอลัมน์ 2-4 ในไฟล์
runs.B = M(:, 5:7);       % คอลัมน์ 6-8 ในไฟล์
runs.C = M(:, 9:11);      % คอลัมน์ 10-12 ในไฟล์

types   = {'A', 'B', 'C'};
colors  = [0.000 0.447 0.741;     % type A สีน้ำเงิน
           0.850 0.325 0.098;     % type B สีส้ม
           0.929 0.694 0.125];    % type C สีเหลือง
markers = {'o', 's', '^'};

%% 2) พล็อตค่าเฉลี่ยทั้งสาม type
figure('Name', 'Rotary A vs B vs C', 'Position', [100 100 850 520]);
hold on; grid on; set(gca, 'XMinorGrid', 'on', 'YMinorGrid', 'on'); set(gca, 'XMinorGrid', 'on', 'YMinorGrid', 'on'); set(gca, 'XMinorGrid', 'on', 'YMinorGrid', 'on'); set(gca, 'XMinorGrid', 'on', 'YMinorGrid', 'on'); set(gca, 'XMinorGrid', 'on', 'YMinorGrid', 'on'); set(gca, 'XMinorGrid', 'on', 'YMinorGrid', 'on'); box on;

i50 = (x == 50);
fprintf('Voltage at 50%% travel (%% of Vmax):\n');

for k = 1:3
    t = types{k};
    m = mean(runs.(t), 2);        % ค่าเฉลี่ย 3 ครั้ง
    s = std(runs.(t), 0, 2);      % SD แบบหารด้วย n-1

    errorbar(x, m, s, ['-' markers{k}], 'Color', colors(k,:), ...
        'MarkerFaceColor', colors(k,:), 'MarkerSize', 6, 'LineWidth', 1.5, ...
        'DisplayName', sprintf('Type %s (%.1f%% at 50%%)', t, m(i50) / max(m) * 100));

    fprintf('  Type %s: %.3f V = %.1f%%\n', t, m(i50), m(i50) / max(m) * 100);
end

xline(50, '--', '50%', 'HandleVisibility', 'off');

xlabel('Rotational travel (%)');
ylabel('Output voltage (V)');
title('Rotary potentiometer: Type A vs Type B vs Type C (average of 3 trials)');
legend('Location', 'east');
xlim([0 100]); ylim([-0.1 3.5]); xticks(0:10:100);

exportgraphics(gcf, 'rotary_A_B_C.png', 'Resolution', 300);
