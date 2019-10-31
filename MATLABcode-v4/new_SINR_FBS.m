function sinr_FBS = new_SINR_FBS(t, n_FBSs, FBS_location, f, PTx, n_UEs, UE_location, UE_Number_per_FBS, distributed_UE_location)

% n_FBSs = 16;
% actions_tpc = [-20 15 39];
% [FBS_location FBS] = FemtoStationPara(n_FBSs, actions_tpc);
%  for i=1:n_FBSs
%          PTx(i) = FBS(i).PTdBm;
%     end
% f = 0.9;
% t = 1;
% [n_UEs UE_location] = UEPara(t);
% [UE_Number_per_FBS, distributed_UE_location] = k_means(t, FBS_location, UE_location, n_FBSs, n_UEs); 
 for i=1:n_FBSs
     for j=1:n_FBSs
          if i~=j
              d1 = norm(FBS_location(:,j)-FBS_location(:,i));
              
%               PL(i, j) = 37 + 20*log10(f) + 20*log10(d/1610);
              PL1(i, j) = 20 + 20*log10(f) + 20*log10(d1/1610);
              if(PTx(i)>0)
                P(i, j) = PTx(j) - PL1(i, j);
              else P(i, j) = 1;
              end
          else continue;
          end
          sumP(i) = sum(P(i, j));
         
     end
     for k=1:UE_Number_per_FBS
         a = cell2mat(distributed_UE_location{i}(:,k));
         d2 = norm(a-FBS_location(:,i));
         PL2(i, k) = 1 + 20*log10(f) + 20*log10(d2/1610);
          sumP(i) = sumP(i) - PL2(i, k);
     end
     if(PTx(i)>0)
            sinr_FBS(i) = PTx(i)/sumP(i);
          else 
             sinr_FBS(i) = -3;
          end
 end
 
end

