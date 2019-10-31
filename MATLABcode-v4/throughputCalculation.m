clc;
clear all;
actions_tpc = [-20 60 105];
n_FBSs = 16;
x = 0;
y = 0;
MPTdBm = 58;
f = 0.9;
[FBS_location FBS] = FemtoStationPara(n_FBSs, actions_tpc);
[BS_location BS] = BaseStationPara( x, y, MPTdBm);
bw_FBS = FBS.BW;
bw_BS = BS.BW;
for i=1:n_FBSs
     PTx(i) = FBS(i).PTdBm;
end
sinr_FBS = SINR_FBS( n_FBSs, FBS_location,f, PTx);
sinr_BS = SINR_BS(BS_location, BS, FBS_location, f, n_FBSs, PTx);
tpt_BS = TheoreticalCapacity(bw_BS, sinr_BS)/1e6; %Mbps
tpt_FBS = computeThroughput(n_FBSs, bw_FBS, sinr_FBS);
