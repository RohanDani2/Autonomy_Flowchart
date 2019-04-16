function [costs, mapGrid] = buildMapTest(pos, theta, detectedList, scale, goal, vehicleRad,...
                                        limit, mode)
       
    tic
    mapDim = [80 40]; %[40 20]; % must be equalivant in initialize.m
    
    persistent mapGridP
    if isempty(mapGridP)
        mapGridP = zeros(mapDim(2)-1, mapDim(1)-1);
    end
    
    %% Orient polar list and convert to certesian 
    if mode == 0
        detectedList(:,1) = detectedList(:,1) + theta - pi/2;
        [detX, detY] = pol2cart(detectedList(:,1), detectedList(:,2));
        detectedList = [detX detY];
    end
    
    %% Translate cartesian list 
    offset = 1.2; % MOVE to simulink level: measurement lidar to midpoint in decimeter 
    if mode == 0
        detectedList(:,1) = detectedList(:,1) + scale*pos(1) + scale*offset*cos(theta); 
        detectedList(:,2) = detectedList(:,2) + scale*pos(2) + scale*offset*sin(theta); 
    end
    
    %% Round lidar data, add limit, eliminate duplicates 
    roundedLimitUnique = 0;
    if mode == 0
        rounded = round(detectedList);
        roundedLimit = vertcat(limit(:,1:2), rounded);
        roundedLimitUnique = unique(roundedLimit, 'rows');
    end

    %% Eliminate points outside limit 
    if mode == 0
        roundedLimitUnique(roundedLimitUnique(:, 1) <= 0, :) = [];
        roundedLimitUnique(roundedLimitUnique(:, 1) > mapDim(1)*scale-scale, :) = [];
        roundedLimitUnique(roundedLimitUnique(:, 2) <= 0, :) = [];
        roundedLimitUnique(roundedLimitUnique(:, 2) > mapDim(2)*scale-scale, :) = [];
    end
    
    %% Eliminate Nan values and add limit 
    if mode == 1
        detectedListTemp = detectedList;
        detectedListTemp(isnan(detectedListTemp(:,1)), :) = [];
        roundedLimitUnique = [limit(:,1:2); detectedListTemp(:,1:2)];
    end
    
    %% Convert list to grid 
    limitGrid = list2grid(roundedLimitUnique(:,1), roundedLimitUnique(:,2), mapDim(1)*scale-scale, mapDim(2)*scale-scale);
    
    %% Inflate points 
    tic
    inflated = inflate2(limitGrid, vehicleRad*scale);
    time = toc;
    fprintf('inflation completed in %f seconds\n', time)
    
    %% (NOT NEEDED) Compress 1e-3 m grid to 1e-1 m grid
    % divide lidar points by 100
    % don't apply scale in buildMap
    % round and eliminate duplicates, use high inflation n
    % could be slower due to high inflation n 
    if mode == 0
        tic
        mapGridNew = compress2(inflated, mapDim-1, scale);
        time = toc;
        fprintf('compression completed in %f seconds\n', time)
    else 
        mapGridNew = inflated;
    end
    
    
    %% Persist grid and average with new 
    if mode == 0
        alpha = 0.8; beta = 0.2;
    else
        alpha = 0.99; beta = 0.01;
    end
    mapGridP = alpha*mapGridP + beta*mapGridNew;
    mapGrid = mapGridP;
    
    %% Convert probability grid to list for d*
    mapList = grid2list(mapGrid);
    
    % convert into 1-by vector: size pos goal mapList1:end
    costsTemp = vertcat([numel(mapList)/3 0 0], [pos 0], [goal 0], mapList);
    costs = reshape(costsTemp.',1,numel(costsTemp));
   
    tic