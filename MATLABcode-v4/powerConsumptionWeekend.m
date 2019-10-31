     clc;
     clear all; 
% for n_FBSs = 10:20:130
    n_FBSs = 16;
    actions_tpc = [-20 15 39];
    x = 0;%location of BS
    y = 0;
    MPTdBm = 58;
    f = 2;
    T = 0;
     [FBS_location FBS] = FemtoStationPara(n_FBSs, actions_tpc);
     [BS_location BS] = BaseStationPara( x, y, MPTdBm);
   
    gamma = 0.5;
    alpha = 0.5;                 % Learning Rate
%     MAX_CONVERGENCE_TIME = 720;
    MAX_CONVERGENCE_TIME = 168;
    MIN_SAMPLE_CONSIDER = MAX_CONVERGENCE_TIME/2 + 1;
    MAX_LEARNING_ITERATIONS = 1;  
    initial_epsilon = 1;    % Initial Exploration coefficient
    updateMode = 1;         % s0: epsilon = initial_epsilon / t ; 1: epsilon = epsilon / sqrt(t)
    Tmax = 1;
    

   [totalPowerConsumption, Qval, cumulativePowerConsumption] = QlearningMethodWeekend(FBS, n_FBSs,...
    FBS_location, BS_location, BS, MAX_CONVERGENCE_TIME, MAX_LEARNING_ITERATIONS, gamma, initial_epsilon, ...
    alpha, updateMode, f, actions_tpc, Tmax)
