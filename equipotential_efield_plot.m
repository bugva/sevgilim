% Eş potansiyel ve E-alan çizgileri (seyrek gösterim)
% Başlangıç noktası: (26,10), bitiş noktası: (2,10)

clear; clc; close all;

%% Kullanıcı ayarları
dataFile = '/home/ubuntu/.cursor/projects/workspace/uploads/equipotential_data_cleaned.csv';
startPoint = [26, 10];
endPoint   = [2, 10];

% E-alan oku yoğunluğunu azaltmak için alt örnekleme adımı
quiverStep = 8;

try
    [x, y, V] = parseEquipotentialCsv(dataFile);
catch ME
    error('Veri okunamadi/parselenemedi: %s', ME.message);
end

if isempty(x) || isempty(y) || isempty(V)
    error('CSV icinden gecerli nokta okunamadi.');
end

%% Interpolasyon ızgarası
xMin = floor(min(x)); xMax = ceil(max(x));
yMin = floor(min(y)); yMax = ceil(max(y));

nx = 180; ny = 140;
xq = linspace(xMin, xMax, nx);
yq = linspace(yMin, yMax, ny);
[X, Y] = meshgrid(xq, yq);

F = scatteredInterpolant(x, y, V, 'natural', 'none');
Vq = F(X, Y);

%% Potansiyel konturları
vMin = min(V);
vMax = max(V);
contourLevels = linspace(vMin, vMax, 10);

figure('Color', 'w');
hold on; grid on; box on;

[C, hContour] = contour(X, Y, Vq, contourLevels, 'LineWidth', 1.2);
clabel(C, hContour, 'Color', [0.2 0.2 0.2], 'FontSize', 8);
colormap(turbo);
c = colorbar;
c.Label.String = 'Potansiyel V (Volt)';

%% E-alan: E = -grad(V)
dx = xq(2) - xq(1);
dy = yq(2) - yq(1);
[dVdy, dVdx] = gradient(Vq, dy, dx);
Ex = -dVdx;
Ey = -dVdy;

% NaN bölgelerinden kaçınmak için maske
valid = ~isnan(Ex) & ~isnan(Ey);
Ex(~valid) = 0;
Ey(~valid) = 0;

% Seyrek vektör gösterimi (çok sık/dik görünmemesi için)
idxX = 1:quiverStep:nx;
idxY = 1:quiverStep:ny;
Xv = X(idxY, idxX);
Yv = Y(idxY, idxX);
Exv = Ex(idxY, idxX);
Eyv = Ey(idxY, idxX);

q = quiver(Xv, Yv, Exv, Eyv, 1.2, 'k', 'LineWidth', 0.9);
q.MaxHeadSize = 0.7;

% Birkaç E-alan çizgisi (yaklaşık diklik kuralını görselleştirmek için)
seedX = [26, 24, 22, 20];
seedY = [10, 10, 10, 10];
hStream = streamline(X, Y, Ex, Ey, seedX, seedY);
set(hStream, 'Color', [0.85 0.1 0.1], 'LineWidth', 1.3);

%% İstenen başlangıç / bitiş noktaları
hStart = plot(startPoint(1), startPoint(2), 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 8);
hEnd = plot(endPoint(1), endPoint(2), 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 8);
text(startPoint(1)+0.4, startPoint(2)+0.35, 'Baslangic (26,10)', ...
    'Color', 'r', 'FontSize', 9, 'FontWeight', 'bold');
text(endPoint(1)+0.4, endPoint(2)+0.35, 'Bitis (2,10)', ...
    'Color', 'b', 'FontSize', 9, 'FontWeight', 'bold');

%% Hata metriği (Leave-One-Out RMSE) ve grafiğe yazdırma
rmseVal = looRmse(x, y, V);
plotTitle = sprintf('Es Potansiyel + Seyrek E-Field (LOO RMSE = %.3f V)', rmseVal);
title(plotTitle, 'FontWeight', 'bold');

txt = sprintf('Hata (LOO RMSE): %.3f V', rmseVal);
text(xMin + 0.6, yMax - 0.9, txt, ...
    'BackgroundColor', [1 1 1], 'EdgeColor', [0.2 0.2 0.2], ...
    'Margin', 4, 'FontSize', 9);

xlabel('x');
ylabel('y');
axis equal;
xlim([xMin xMax]);
ylim([yMin yMax]);
hStreamLegend = hStream(1);
legend([hContour, q, hStreamLegend, hStart, hEnd], ...
    {'Es potansiyel', 'E-field yonleri', 'E-field cizgileri', 'Baslangic', 'Bitis'}, ...
    'Location', 'southoutside', 'Orientation', 'horizontal');
hold off;

fprintf('Toplam %d nokta okundu.\n', numel(V));
fprintf('Leave-One-Out RMSE: %.4f V\n', rmseVal);

%% -------- Yerel fonksiyonlar --------
function [x, y, V] = parseEquipotentialCsv(filePath)
    raw = readcell(filePath, 'Delimiter', ',', 'TextType', 'string');
    if isempty(raw) || size(raw,1) < 2 || size(raw,2) < 2
        error('CSV formati beklenenden farkli.');
    end

    header = raw(1, 2:end);
    nCols = numel(header);

    colV = nan(1, nCols);
    for c = 1:nCols
        h = string(header{c});
        tok = regexp(h, 'V\s*=\s*([0-9]+\.?[0-9]*)', 'tokens', 'once');
        if ~isempty(tok)
            colV(c) = str2double(tok{1});
        end
    end

    x = [];
    y = [];
    V = [];

    for r = 2:size(raw,1)
        for c = 2:size(raw,2)
            if c-1 > nCols || isnan(colV(c-1))
                continue;
            end
            cellVal = raw{r,c};
            if ismissing(cellVal) || (isstring(cellVal) && strlength(cellVal) == 0)
                continue;
            end

            s = string(cellVal);
            tok = regexp(s, '\(\s*([-+]?[0-9]*\.?[0-9]+)\s*,\s*([-+]?[0-9]*\.?[0-9]+)\s*\)', ...
                'tokens', 'once');
            if isempty(tok)
                continue;
            end

            xi = str2double(tok{1});
            yi = str2double(tok{2});
            if ~isnan(xi) && ~isnan(yi)
                x(end+1,1) = xi; %#ok<AGROW>
                y(end+1,1) = yi; %#ok<AGROW>
                V(end+1,1) = colV(c-1); %#ok<AGROW>
            end
        end
    end
end

function rmseVal = looRmse(x, y, V)
    n = numel(V);
    pred = nan(n,1);

    for i = 1:n
        keep = true(n,1);
        keep(i) = false;

        Fi = scatteredInterpolant(x(keep), y(keep), V(keep), 'natural', 'none');
        pred(i) = Fi(x(i), y(i));
    end

    valid = ~isnan(pred);
    if ~any(valid)
        rmseVal = NaN;
        return;
    end

    err = pred(valid) - V(valid);
    rmseVal = sqrt(mean(err.^2));
end
