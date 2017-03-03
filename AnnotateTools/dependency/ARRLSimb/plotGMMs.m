function plotGMMs(X, mu1, sigma1, mu2, sigma2, xgrid, strTitle)
    
    figure(1); clf;
    plot(X);
    if ~isempty(strTitle)
        title(strTitle);
    end
    figure(2); clf;
    [counts, centers] = hist(X,xgrid);
    bar(centers,counts)
    if ~isempty(strTitle)
        title(strTitle);
    end

    [~, minI] = min(abs(xgrid-mu1));
    mu1 = xgrid(minI);
    [~, minI] = min(abs(xgrid-mu2));
    mu2 = xgrid(minI);
    
    hold on
    y = pdf('Normal', xgrid, mu1, sigma1);
    peak_x = find(xgrid==mu1);
    peak_y = mean(counts(peak_x-1:peak_x+1)); 
    y = y * peak_y / max(y);
    plot(xgrid, y, 'LineWidth', 3)
    xlabel('Value'); ylabel('Count');
    y = pdf('Normal', xgrid, mu2, sigma2);
    peak_x = find(xgrid==mu2);
    peak_y = mean(counts(peak_x-1:peak_x+1)); 
    y = y * peak_y / max(y);
    plot(xgrid, y, 'LineWidth', 3)
    xlabel('Value'); ylabel('Count');
    hold off
end