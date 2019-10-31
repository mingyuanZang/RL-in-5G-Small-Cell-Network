function  sinr_BS = SINR_BS( BS_location, BS, FBS_location, f, n_FBSs, PTx)
  sumP = 0;
 for i=1:n_FBSs
              d = norm(FBS_location(:,i)-BS_location);
%               PL(i, j) = 37 + 20*log10(f) + 20*log10(d/1610);
              PL(i) = 20 + 20*log10(f) + 20*log10(d/1610);
              if(PTx(i)>0)
                P(i) = PTx(i) - PL(i);%interference
              else P(i) = 0;
              end
              sumP = sumP + P(i);
 end
     sinr_BS = BS.PTdBm/sumP;
end

