% Load the data from the CSV file
data = readmatrix('raw_differences.csv');  % Use readmatrix for recent versions of MATLAB

% Compute mean and standard deviation
mu = mean(data);  % Mean of the data
sigma = std(data);  % Standard deviation of the data

% Generate points for the Gaussian distribution curve based on the data
x = linspace(min(data) - 3*sigma, max(data) + 3*sigma, 100);  % Create 100 points for the plot, extended beyond data range
y_data_fit = (1 / (sigma * sqrt(2 * pi))) * exp(-0.5 * ((x - mu) / sigma).^2);  % Gaussian function for the data fit

% Generate the theoretical Gaussian curve (same mu and sigma)
y_theoretical = (1 / (sigma * sqrt(2 * pi))) * exp(-0.5 * ((x - mu) / sigma).^2);  % Same formula, but representing the theoretical distribution

% Plot the Gaussian distribution curve for the data fit
figure;
plot(x, y_data_fit, 'r', 'LineWidth', 2);  % Plot the Gaussian fit in red
hold on;

% Plot the theoretical Gaussian distribution curve (same mu and sigma)
plot(x, y_theoretical, 'b--', 'LineWidth', 2);  % Plot the theoretical curve in blue dashed line

% Add labels and title
title('Gaussian Distribution Fit and Theoretical Curve');
xlabel('Difference');
ylabel('Probability Density');

% Display the mean and standard deviation on the plot
disp(['Mean: ', num2str(mu)]);
disp(['Standard Deviation: ', num2str(sigma)]);

% Add grid and title for better readability
grid on;

% Ensure the plot limits include the full range of the data and the Gaussian curve
xlim([min(data) - 3*sigma, max(data) + 3*sigma]);  % Extend the x-axis beyond the data range
ylim([0, max(y_data_fit) + 0.01]);  % Set y-axis to fit the Gaussian curve

% Display the mean and standard deviation on the plot
text(mu, max(y_data_fit) * 0.9, ['\mu = ', num2str(mu), ', \sigma = ', num2str(sigma)], ...
    'Color', 'red', 'FontSize', 12);

% Add a legend to differentiate the curves
legend('Gaussian Fit', 'Theoretical Gaussian', 'Location', 'Best');
hold off;
