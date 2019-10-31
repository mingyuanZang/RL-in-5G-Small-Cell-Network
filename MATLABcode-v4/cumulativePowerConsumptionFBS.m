function P = cumulativePowerConsumptionFBS(t, f, n_UEs, UE_location, UE_Number_per_FBS)
%     t=600;
for t = 1:24
    [n_UEs UE_location] = new_UEPara(t);
    num = size(UE_location,2);
    n_FBSs = 16;
    f = 0.9;
    d1 = 0;
    d2 = 0;
    sumP_same_cell = 0;
    sumP = zeros(1, 24);
    UE_connect_to_BS = 0;
    current_action = zeros(1,n_FBSs);
    current_action(1,7) = 1;
    current_action(1,8) = 1;
    [FBS_location FBS] = FemtoStationPara(n_FBSs);
    [UE_Number_per_FBS, distributed_UE_location] = k_means(t, FBS_location, UE_location, n_FBSs, n_UEs); 
    UE_Number_per_FBS_t{t} = num2cell(UE_Number_per_FBS);
    nUE_per_FBS = UE_Number_per_FBS;
     for i=1:n_FBSs
        M = nUE_per_FBS(i);
        for m=1:M
            PTx(m) = 0.3 + 0.2*rand(1,1);
            for k=1:M
                if m~=k
                    a = cell2mat(distributed_UE_location{i}(:,m));
                    b = cell2mat(distributed_UE_location{i}(:,k));
                    diff = a-b;
                    d1 = norm(diff);
%                      d1 = norm(UE_location(:,m)-UE_location(:,k));
                     PL1(m, k) = 1+ 20*log10(f) + 20*log10(d1/1610);
%                      P1(m, k) = PTx(m) - PL1(m, k);
                else 
                    PL1(m, k) = 0;
                end
            end
           
%             for j = 1:n_FBSs
%                if i~=j
%                     N = nUE_per_FBS(j);
%                     if current_action(j) ==0
%                         for n = 1:N
%                             PTx(n) = 2;
%                             a = cell2mat(distributed_UE_location{i}(:,m));
%                             b = cell2mat(distributed_UE_location{i}(:,n));
%                             diff = a-b;
%                             d2 = norm(diff);
%     %                         d2 = norm(UE_location(:,m)-UE_location(:,n));
%                             PL2(m, n) = 5+ 20*log10(f) + 5*log10(d2/1610);
% %                             P2(m, n) = PTx(n) - PL2(m, n);
%                         end
%                         display(sum(PL2(m)));
%                         sumP_other_cell = sumP_other_cell + 2 - sum(PL2(m));
%                     else 
%                         UE_connect_to_BS = UE_connect_to_BS + N;
%                     end 
                sumP_same_cell = sumP_same_cell + PTx(m) - sum(PL1(m));
        end
         
                if current_action(1, i) ==0
                    N = nUE_per_FBS(i);
                    UE_connect_to_BS = UE_connect_to_BS + N;
                    UE_to_BS(t) = UE_connect_to_BS;
                end
     end
     sumP(t) = sum(sumP_same_cell);
     P(t) = sumP(t) +15 - 0.17*15 + 2*UE_to_BS(t);
     if t==1
         a = [-15000, -15000+P(t)];
         maximum = max(a);
         b = [15000, maximum];
         minimum(t) = min(b);
     else
         Pt = minimum(t-1)+P(t);
         a = [Pt, 15000];
         maximum = max(a);
         b = [15000, maximum];
         minimum(t) = min(b);
     end
     if (t>1 && minimum(t-1) == -15000 && minimum(t) == 0)
         index_min_number_FBS = find(UE_Number_per_FBS == min(UE_Number_per_FBS));
         current_action(1, index_min_number_FBS) = 1;
     else 
         index_min_number_FBS = find(UE_Number_per_FBS == min(UE_Number_per_FBS));
         current_action(1, index_min_number_FBS) = 0;
     end
end 
figure;
plot(P,'-b');
end

