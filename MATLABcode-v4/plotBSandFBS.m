clc;
n_FBSs = 16;
actions_tpc = [-20 60 105];
MPTdBm = 58;
[FBS_location FBS] = FemtoStationPara(n_FBSs, actions_tpc);
figure; 
plot(FBS_location(1,:),FBS_location(2,:),'+');
[BS_location BS] = BaseStationPara(0,0, MPTdBm );
hold on; plot(BS_location(1,:),BS_location(2,:),'sqb');
     