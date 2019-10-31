     clc;
     clear all; 
% for n_FBSs = 10:20:130
    n_FBSs = 16;
    actions_tpc = [-20 15 39];
    x = 0;%location of BS
    y = 0;
    MPTdBm = 58;
    f = 0.9;
    T = 0;
     [FBS_location FBS] = FemtoStationPara(n_FBSs, actions_tpc);
     [BS_location BS] = BaseStationPara( x, y, MPTdBm);
   
    gamma = 0.4;
    alpha = 0.5;                 % Learning Rate
%     MAX_CONVERGENCE_TIME = 720;
    MAX_CONVERGENCE_TIME = 1440;
    MIN_SAMPLE_CONSIDER = MAX_CONVERGENCE_TIME/2 + 1;
    MAX_LEARNING_ITERATIONS = 1;  
    initial_epsilon = 1;    % Initial Exploration coefficient
    updateMode = 1;         % s0: epsilon = initial_epsilon / t ; 1: epsilon = epsilon / sqrt(t)
    Tmax = 10;
    
%     Tx_power = [15, 39];
% 
%     [Normalized_tpt_experienced_per_fbs, Qval] = QlearningMethodAllOn(FBS, n_FBSs,...
%     FBS_location, BS_location, BS, MAX_CONVERGENCE_TIME, MAX_LEARNING_ITERATIONS, gamma, initial_epsilon, ...
%     alpha, updateMode, f, Tx_power, Tmax);
%     
   [Normalized_tpt_experienced_per_fbs, totalPowerConsumption, Qval, cumulativePowerConsumption] = QlearningMethodTimeRelated(FBS, n_FBSs,...
    FBS_location, BS_location, BS, MAX_CONVERGENCE_TIME, MAX_LEARNING_ITERATIONS, gamma, initial_epsilon, ...
    alpha, updateMode, f, actions_tpc, Tmax);
 
    
%     
% end