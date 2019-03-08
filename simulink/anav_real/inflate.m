function inflated = inflate(points, r, mode)
    % perform object inflation on list of XY coordinates by creating high
    % point-count circles around each point and then rounding the values of
    % said circles. Alternatively use lower point count, don't round and
    % follow up with compression compression functionality
    
    % TODO use sim inflation mode for real as well
    
%     points = [30 25; 31 25; 32 25; 33 25];
%     r = 10;
%     mode = 1;
    
    if mode == 1
        n = 500;
    else
        n = 100;
    end
    
    % generate x, y list representing origin centered circle with radius r
    theta = linspace(0, 2*pi, n);
    x = rot90(r*cos(theta), 3); 
    y = rot90(r*sin(theta), 3);
    circle = horzcat(x, y);
    if mode == 1
        circle = round(circle);
    end

    % add circle around each point in points
    len = size(points, 1);
    inflated = zeros(n*len, 2);
    circleTrans = zeros(n, 2);
    for i = 1:len
        circleTrans(:, 1) = circle(:, 1) + points(i, 1);
        circleTrans(:, 2) = circle(:, 2) + points(i, 2);
        inflated(i+n*(i-1), :) = points(i, :);
        inflated(i+n*(i-1)+1:i+n*(i-1)+n, :) = circleTrans;
    end
    inflated = unique(inflated, 'rows');
    
%     plot(inflated(:,1), inflated(:,2), 'bs')
%     xlim([0 60])
%     ylim([0 40])
end