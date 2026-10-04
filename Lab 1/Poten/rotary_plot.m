%% FRA271 Lab 1 - Rotary potentiometer: แยกกราฟแต่ละ type
% แต่ละ type (A, B, C) จะได้ 2 กราฟ
%   1) ครั้งที่ 1, 2, 3 อยู่ในกราฟเดียวกัน
%   2) ค่าเฉลี่ย 3 ครั้ง + error bar (SD) + เส้น fit
% รวมทั้งหมด 6 กราฟ และเซฟเป็นไฟล์ .png 6 ไฟล์
clear; clc; close all;

file = 'rotary.csv';      % เปลี่ยนชื่อไฟล์ให้ตรงกับที่เซฟไว้

%% 1) อ่านข้อมูล
raw = readcell(file);
x   = str2double(erase(string(raw(2:end,1)), '%'));     % '25%' -> 25
M   = cell2mat(raw(2:end, 2:13));

runs.A = M(:, 1:3);       % คอลัมน์ 2-4 ในไฟล์
runs.B = M(:, 5:7);       % คอลัมน์ 6-8 ในไฟล์
runs.C = M(:, 9:11);      % คอลัมน์ 10-12 ในไฟล์

types = {'A', 'B', 'C'};

%% 2) ช่วงที่ใช้ fit เส้นตรง [เริ่ม สิ้นสุด] หน่วย %
segs.A = [15 50; 55 90];  % type A มีสองช่วงชัน
segs.B = [15 90];         % type B ช่วงเดียว
segs.C = [10 35; 40 85];  % type C มีสองช่วงชัน

%% 3) ตั้งค่าสีและรูปแบบเส้น
trialColors = [0.000 0.447 0.741;     % ครั้งที่ 1 สีน้ำเงิน
               0.850 0.325 0.098;     % ครั้งที่ 2 สีส้ม
               0.466 0.674 0.188];    % ครั้งที่ 3 สีเขียว
markers   = {'o', 's', '^'};
fitColors = [0.850 0.325 0.098;       % fit ช่วงที่ 1
             0.000 0.447 0.741];      % fit ช่วงที่ 2
LSB = 3.3 / 4096;                     % ADC 12 บิต, Vref 3.3 V

%% 4) วนทำทีละ type
for k = 1:3
    t = types{k};
    Y = runs.(t);

    % ---------- กราฟที่ 1: ครั้งที่ 1, 2, 3 ----------
    figure('Name', ['Type ' t ' - Trials'], 'Position', [100 100 800 500]);
    hold on; grid on; box on;  grid minor ;

    for r = 1:3
        plot(x, Y(:, r), ['-' markers{r}], ...
            'Color', trialColors(r,:), 'MarkerFaceColor', trialColors(r,:), ...
            'MarkerSize', 6, 'LineWidth', 1.3, ...
            'DisplayName', sprintf('Trial %d', r));
    end

    xlabel('Rotational travel (%)');
    ylabel('Output voltage (V)');
    title(sprintf('Rotary potentiometer type %s: Trials 1-3', t));
    legend('Location', 'best');
    xlim([0 100]); ylim([-0.1 3.5]); xticks(0:10:100);

    exportgraphics(gcf, sprintf('rotary_%s_trials.png', t), 'Resolution', 300);

    % ---------- กราฟที่ 2: ค่าเฉลี่ย + SD + fit ----------
    m = mean(Y, 2);           % ค่าเฉลี่ย 3 ครั้ง
    s = std(Y, 0, 2);         % SD แบบหารด้วย n-1

    figure('Name', ['Type ' t ' - Average'], 'Position', [150 150 800 500]);
    hold on; grid on; box on;

    errorbar(x, m, s, 'ko-', 'MarkerFaceColor', 'k', 'MarkerSize', 5, ...
        'LineWidth', 1.3, 'DisplayName', 'Average \pm SD');

    S  = segs.(t);
    FS = max(m) - min(m);     % full scale ของ type นี้

    fprintf('\n===== Type %s =====\n', t);
    fprintf('%-9s %-24s %-8s %-10s %-10s\n', 'Range', 'Equation (V)', 'R^2', 'NL (%FS)', 'Res (%)');

    for i = 1:size(S, 1)
        lo  = S(i,1);
        hi  = S(i,2);
        idx = (x >= lo) & (x <= hi);

        p    = polyfit(x(idx), m(idx), 1);       % p(1) = sensitivity, p(2) = intercept
        yfit = polyval(p, x(idx));

        R2  = 1 - sum((m(idx) - yfit).^2) / sum((m(idx) - mean(m(idx))).^2);
        NL  = max(abs(m(idx) - yfit)) / FS * 100;
        res = LSB / abs(p(1));

        plot(x(idx), yfit, '--', 'Color', fitColors(i,:), 'LineWidth', 2, ...
            'DisplayName', sprintf('Fit %d-%d%%: V = %.4fx %+.3f (R^2 = %.4f)', ...
            lo, hi, p(1), p(2), R2));

        fprintf('%3d-%-5d V = %+.4fx %+.3f    %.4f   %-10.2f %-10.4f\n', ...
            lo, hi, p(1), p(2), R2, NL, res);
    end

    i50 = (x == 50);
    fprintf('At 50%% travel: %.3f V = %.1f%% of Vmax\n', m(i50), m(i50) / max(m) * 100);

    xlabel('Rotational travel (%)');
    ylabel('Output voltage (V)');
    title(sprintf('Rotary potentiometer type %s: Average of 3 trials', t));
    legend('Location', 'best');
    xlim([0 100]); ylim([-0.1 3.5]); xticks(0:10:100);

    exportgraphics(gcf, sprintf('rotary_%s_average.png', t), 'Resolution', 300);
end