%% FRA271 Lab 1 - Slide potentiometer: plot + linear fit
% โครงสร้างไฟล์: คอลัมน์ 1 = Distance (mm)
%                2-4 = type A ครั้งที่ 1-3, 5 = ค่าเฉลี่ย A
%                6-8 = type B ครั้งที่ 1-3, 9 = ค่าเฉลี่ย B
% ผลลัพธ์: type ละ 2 กราฟ (Trials 1-3, Average + fit) และกราฟเปรียบเทียบ A กับ B อีก 1 กราฟ
clear; clc; close all;

file = 'slide.csv';       % เปลี่ยนชื่อไฟล์ให้ตรงกับที่เซฟไว้

%% 1) อ่านข้อมูล
raw = readcell(file);
M   = cell2mat(raw(2:end, 1:9));      % ตัดแถวหัวตารางออก
x   = M(:, 1);                        % ระยะเลื่อน (mm)

runs.A = M(:, 2:4);       % คอลัมน์ 2-4 ในไฟล์
runs.B = M(:, 6:8);       % คอลัมน์ 6-8 ในไฟล์

types = {'A', 'B'};

%% 2) ช่วงที่ใช้ fit เส้นตรง [เริ่ม สิ้นสุด] หน่วย mm
segs.A = [5 25; 30 55];   % type A มีสองช่วงชัน
segs.B = [10 50];         % type B ช่วงเดียว (ตัดปลายทั้งสองด้านออก)

%% 3) ตั้งค่าสีและรูปแบบเส้น
trialColors = [0.000 0.447 0.741;     % ครั้งที่ 1 สีน้ำเงิน
               0.850 0.325 0.098;     % ครั้งที่ 2 สีส้ม
               0.466 0.674 0.188];    % ครั้งที่ 3 สีเขียว
markers   = {'o', 's', '^'};
fitColors = [0.850 0.325 0.098;       % fit ช่วงที่ 1
             0.000 0.447 0.741];      % fit ช่วงที่ 2
LSB = 3.3 / 4096;                     % ADC 12 บิต, Vref 3.3 V

%% 4) วนทำทีละ type
for k = 1:2
    t = types{k};
    Y = runs.(t);

    % ---------- กราฟที่ 1: ครั้งที่ 1, 2, 3 ----------
    figure('Name', ['Slide ' t ' - Trials'], 'Position', [100 100 800 500]);
    hold on; grid on; set(gca, 'XMinorGrid', 'on', 'YMinorGrid', 'on'); set(gca, 'XMinorGrid', 'on', 'YMinorGrid', 'on'); box on;

    for r = 1:3
        plot(x, Y(:, r), ['-' markers{r}], ...
            'Color', trialColors(r,:), 'MarkerFaceColor', trialColors(r,:), ...
            'MarkerSize', 6, 'LineWidth', 1.3, ...
            'DisplayName', sprintf('Trial %d', r));
    end

    xlabel('Slider position (mm)');
    ylabel('Output voltage (V)');
    title(sprintf('Slide potentiometer type %s: Trials 1-3', t));
    legend('Location', 'best');
    xlim([0 60]); ylim([-0.1 3.5]); xticks(0:5:60);

    exportgraphics(gcf, sprintf('slide_%s_trials.png', t), 'Resolution', 300);

    % ---------- กราฟที่ 2: ค่าเฉลี่ย + SD + fit ----------
    m = mean(Y, 2);           % ค่าเฉลี่ย 3 ครั้ง
    s = std(Y, 0, 2);         % SD แบบหารด้วย n-1
    avg.(t) = m;
    sd.(t)  = s;

    figure('Name', ['Slide ' t ' - Average'], 'Position', [150 150 800 500]);
    hold on; grid on; set(gca, 'XMinorGrid', 'on', 'YMinorGrid', 'on'); set(gca, 'XMinorGrid', 'on', 'YMinorGrid', 'on'); box on;

    errorbar(x, m, s, 'ko-', 'MarkerFaceColor', 'k', 'MarkerSize', 5, ...
        'LineWidth', 1.3, 'DisplayName', 'Average \pm SD');

    S  = segs.(t);
    FS = max(m) - min(m);     % full scale ของ type นี้

    fprintf('\n===== Slide type %s =====\n', t);
    fprintf('%-9s %-24s %-8s %-10s %-10s\n', 'Range', 'Equation (V)', 'R^2', 'NL (%FS)', 'Res (mm)');

    for i = 1:size(S, 1)
        lo  = S(i,1);
        hi  = S(i,2);
        idx = (x >= lo) & (x <= hi);

        p    = polyfit(x(idx), m(idx), 1);       % p(1) = sensitivity (V/mm), p(2) = intercept
        yfit = polyval(p, x(idx));

        R2  = 1 - sum((m(idx) - yfit).^2) / sum((m(idx) - mean(m(idx))).^2);
        NL  = max(abs(m(idx) - yfit)) / FS * 100;
        res = LSB / abs(p(1));

        plot(x(idx), yfit, '--', 'Color', fitColors(i,:), 'LineWidth', 2, ...
            'DisplayName', sprintf('Fit %d-%d mm: V = %.4fx %+.3f (R^2 = %.4f)', ...
            lo, hi, p(1), p(2), R2));

        fprintf('%2d-%-6d V = %+.4fx %+.3f    %.4f   %-10.2f %-10.4f\n', ...
            lo, hi, p(1), p(2), R2, NL, res);
    end

    i30 = (x == 30);
    fprintf('At 30 mm (50%% travel): %.3f V = %.1f%% of Vmax\n', m(i30), m(i30) / max(m) * 100);
    fprintf('Mean SD = %.4f V, Max SD = %.4f V at %d mm\n', mean(s), max(s), x(find(s == max(s), 1)));

    xlabel('Slider position (mm)');
    ylabel('Output voltage (V)');
    title(sprintf('Slide potentiometer type %s: Average of 3 trials', t));
    legend('Location', 'best');
    xlim([0 60]); ylim([-0.1 3.5]); xticks(0:5:60);

    exportgraphics(gcf, sprintf('slide_%s_average.png', t), 'Resolution', 300);
end

%% 5) กราฟเปรียบเทียบค่าเฉลี่ย type A กับ type B
figure('Name', 'Slide A vs B', 'Position', [200 200 800 500]);
hold on; grid on; set(gca, 'XMinorGrid', 'on', 'YMinorGrid', 'on'); box on;

errorbar(x, avg.A, sd.A, 'o-', 'Color', trialColors(1,:), 'MarkerFaceColor', trialColors(1,:), ...
    'LineWidth', 1.5, 'DisplayName', 'Type A');
errorbar(x, avg.B, sd.B, 's-', 'Color', trialColors(2,:), 'MarkerFaceColor', trialColors(2,:), ...
    'LineWidth', 1.5, 'DisplayName', 'Type B');
xline(30, '--', '30 mm (50%)', 'HandleVisibility', 'off');

xlabel('Slider position (mm)');
ylabel('Output voltage (V)');
title('Slide potentiometer: Type A vs Type B (average of 3 trials)');
legend('Location', 'southeast');
xlim([0 60]); ylim([-0.1 3.5]); xticks(0:5:60);

exportgraphics(gcf, 'slide_A_vs_B.png', 'Resolution', 300);
