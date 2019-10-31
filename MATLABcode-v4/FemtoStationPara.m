function [FBS_location FBS] = FemtoStationPara(n_FBSs, actions_tpc)
    actions_tpc = [-20 15 39];
    for j=1:n_FBSs 
            FBS(j).PTdBm = datasample(actions_tpc,1); % Assign Tx Power
            %FBS(j). tpt = compute_throughput_from_sinr(FBS, powerMatrix, noise); %compute throughput
            FBS(j).BW = 20e6;
            FBS(j).x = 3000*rand(1,1);
            FBS(j).y = 3000*rand(1,1);%generate the fbs location randomly, range: 0-5km
           x(j)= FBS(j).x;
           y(j)= FBS(j).y;
    end
    FBS_location = [x; y];
%     display(FBS_location(:,1));
%      figure; 
%      plot(FBS_location(1,:),FBS_location(2,:),'sqb');
%      hold on;
end

