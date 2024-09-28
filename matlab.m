data = readtable('traffic_flow.csv');
time = datetime(data.Time, 'InputFormat', 'HH:mm');
total_traffic = data.TotalTraffic;
hours = hour(time) + minute(time) / 60;
X = [ones(length(hours), 1), hours];
coefficients = X \ total_traffic;
predicted_traffic = X * coefficients;
residuals = total_traffic - predicted_traffic;
rss = sum(residuals.^2);
tss = sum((total_traffic - mean(total_traffic)).^2);
rsq = 1 - rss / tss;
mse = mean(residuals.^2);
mae = mean(abs(residuals));
rmse = sqrt(mse);

hourly_bins = floor(hours);
mean_traffic_per_hour = accumarray(hourly_bins+1, total_traffic, [], @mean);
unique_hours = unique(hourly_bins);

figure;
scatter(hours, total_traffic, 50, 'b', 'filled');
hold on;
plot(hours, predicted_traffic, 'r', 'LineWidth', 2);
xlabel('Time of Day (Hours)');
ylabel('Total Traffic Count');
title('Actual vs Predicted Traffic Flow');
legend('Actual Traffic', 'Predicted Traffic');
grid on;

figure;
bar(unique_hours, mean_traffic_per_hour, 'FaceColor', [0.2, 0.6, 0.5]);
xlabel('Hour of Day');
ylabel('Average Traffic Count');
title('Average Traffic Count per Hour');
grid on;

figure;
histogram(residuals, 10, 'FaceColor', [0.8, 0.3, 0.2]);
xlabel('Residual (Actual - Predicted)');
ylabel('Frequency');
title('Residual Distribution');
grid on;

mean_error_per_hour = accumarray(hourly_bins+1, residuals, [], @mean);
figure;
plot(unique_hours, mean_error_per_hour, '-o', 'LineWidth', 2, 'Color', 'm');
xlabel('Hour of Day');
ylabel('Mean Error');
title('Mean Error per Hour');
grid on;

std_error_per_hour = accumarray(hourly_bins+1, residuals, [], @std);
figure;
errorbar(unique_hours, mean_traffic_per_hour, std_error_per_hour, '-s', ...
         'MarkerSize', 8, 'MarkerEdgeColor', 'red', 'LineWidth', 2);
xlabel('Hour of Day');
ylabel('Average Traffic Count with Std Dev');
title('Traffic Flow with Error Bars');
grid on;

[sorted_traffic, sort_idx] = sort(total_traffic, 'descend');
sorted_time = hours(sort_idx);

figure;
plot(sorted_time, sorted_traffic, '-*', 'Color', [0.1, 0.4, 0.7], 'LineWidth', 1.5);
xlabel('Time of Day (Hours)');
ylabel('Sorted Traffic Count');
title('Sorted Traffic Count over Time');
grid on;

quartiles = quantile(total_traffic, [0.25, 0.5, 0.75]);
figure;
boxplot(total_traffic, 'Labels', {'Traffic Data'});
title('Traffic Data Distribution');
grid on;

fprintf('Intercept: %.2f\n', coefficients(1));
fprintf('Slope: %.2f (Vehicles per Hour)\n', coefficients(2));
fprintf('R-squared: %.4f\n', rsq);
fprintf('Mean Squared Error: %.2f\n', mse);
fprintf('Mean Absolute Error: %.2f\n', mae);
fprintf('Root Mean Squared Error: %.2f\n', rmse);
fprintf('Traffic Quartiles: Q1 = %.2f, Median = %.2f, Q3 = %.2f\n', ...
         quartiles(1), quartiles(2), quartiles(3));

corr_coef = corr(hours, total_traffic);
fprintf('Correlation between Time and Traffic Count: %.4f\n', corr_coef);
