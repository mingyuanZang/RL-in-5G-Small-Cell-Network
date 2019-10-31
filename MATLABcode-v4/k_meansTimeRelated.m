function [UE_Number_per_FBS, distributed_UE_location] = k_meansTimeRelated(t, FBS_location, UE_location, n_FBSs, n_UEs) 

num = size(UE_location{t},2);

distributed_UE_location ={};

%% cluster (no loop)
for i=1:n_FBSs
    u_old(:,i) =  FBS_location(:,i);  
end

    for j=1:num     
        for i=1:n_FBSs
            distance(i) = norm(UE_location{t}(:,j)-u_old(:,i));
        end
        [val, ix] = min(distance);
        c(j) = ix;
    end

    for i=1:n_FBSs
            number = 0;
            distributed_UE_location{i} = zeros(2,n_UEs(t));
            [~,index] = find(c==i);
            ind(i) = size(index, 2);
            number = ind(i);
            for k=1:500
                if(k<=number)
                    in = index(k);
                     UE_location_per_FBS(1, k) = UE_location{t}(1,in);
                     UE_location_per_FBS(2, k) = UE_location{t}(2,in);
                    else 
                     UE_location_per_FBS(1, k) = 0;
                     UE_location_per_FBS(2, k) = 0;
                end
            end
            UE_location_per_FBS_cell = num2cell(UE_location_per_FBS);
            distributed_UE_location{i} = UE_location_per_FBS_cell;
            u_new(:,i) = sum(UE_location{t}(:,index),2)/length(index);

    end
UE_Number_per_FBS = ind;


end

