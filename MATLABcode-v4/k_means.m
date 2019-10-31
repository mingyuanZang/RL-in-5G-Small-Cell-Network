function [UE_Number_per_FBS, distributed_UE_location] = k_means(t, FBS_location, UE_location, n_FBSs, n_UEs) 
t=100;
[n_UEs UE_location] = UEPara(t);
num = size(UE_location,2);
n_FBSs = 10;
[FBS_location FBS] = FemtoStationPara(n_FBSs);
[BS_location BS] = BaseStationPara( 0, 0, 20 );

%% plot the initial cell
figure; 
plot(FBS_location(1,:),FBS_location(2,:),'d', 'MarkerSize',8);
hold on;
plot(BS_location(1,:),BS_location(2,:),'s', 'MarkerSize',8);
hold on;
distributed_UE_location ={};

%% cluster (no loop)
for i=1:n_FBSs
    u_old(:,i) =  FBS_location(:,i);  
end

    for j=1:num     
        for i=1:n_FBSs
            distance(i) = norm(UE_location(:,j)-u_old(:,i));
        end
        [val, ix] = min(distance);
        c(j) = ix;
    end
%     [~,index] = find(c==1);
    for i=1:n_FBSs
            number = 0;
            distributed_UE_location{i} = zeros(2,n_UEs);
            [~,index] = find(c==i);
            ind(i) = size(index, 2);
            number = ind(i);
            for k=1:500
                if(k<=number)
                    in = index(k);
                     UE_location_per_FBS(1, k) = UE_location(1,in);
                     UE_location_per_FBS(2, k) = UE_location(2,in);
                    else 
                     UE_location_per_FBS(1, k) = 0;
                     UE_location_per_FBS(2, k) = 0;
                end
            end
            if ind(i)>4
                for iter =1: (ind(i)-4)
                    in = index(iter);
                    UE_location_per_BS(1, iter) = UE_location(1,in);
                    UE_location_per_BS(2, iter) = UE_location(2,in);
                     hold on,
                    plot(UE_location_per_BS(1,iter),UE_location_per_BS(2,iter),'or', 'MarkerSize',8); 
                end
%                 index(i) = 4;
            end
            UE_location_per_FBS_cell = num2cell(UE_location_per_FBS);
            distributed_UE_location{i} = UE_location_per_FBS_cell;
            u_new(:,i) = sum(UE_location(:,index),2)/length(index);
              hold on,
            plot(UE_location(1,index),UE_location(2,index),'*', 'MarkerSize',8); 

           
    end
  UE_Number_per_FBS = ind;
% for i=1:n_FBSs
%     hold on,
%     plot(u_new(1, i), u_new(2, i), 'o');
% end
end

