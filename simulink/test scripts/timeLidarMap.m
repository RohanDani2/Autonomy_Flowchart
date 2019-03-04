tic
    lidarGrid = lidarList2Grid(lidar_scan);
toc

figure(1)
title ('Full Lidar Scan')
plot(lidar_scan(:,1), lidar_scan(:,2),'b.')

figure(2)
title ('Compressed Lidar Map by 100')
hold on
for j = 1:length(lidarGrid(1,:))
    for k = 1:length(lidarGrid(:,1))
        if (lidarGrid(k,j) == 1)
            plot(j,k,'b.')
        end   
    end
end