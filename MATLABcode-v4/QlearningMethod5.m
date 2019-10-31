function [Normalized_tpt_experienced_per_fbs, totalPowerConsumption, Qval, cumulativePowerConsumption] = QlearningMethod5(FBS, n_FBSs,...
    FBS_location, BS_location, BS, MAX_CONVERGENCE_TIME, MAX_LEARNING_ITERATIONS, gamma, initial_epsilon, ...
    alpha, updateMode, f, actions_tpc, Tmax)
%     n_FBSs = 16;
    actions_tpc = [-20 15 39];
    x = 0;%location of BS
    y = 0; 
    MPTdBm = 58;
    f = 0.9;
    
    [FBS_location FBS] = FemtoStationPara(n_FBSs, actions_tpc);
    [BS_location BS] = BaseStationPara( x, y, MPTdBm);
    bw_FBS = FBS.BW;
    bw_BS = BS.BW;
    FBS_aux = FBS; %a copy of FBS
    
    
%% Q-Learning variables
    % Actions
    % 对开关cell表示为能量的变化，开：Pmax 关：Pmin
    possible_actions = 1:size(actions_tpc,2);
    % Total number of actions
    K = size(possible_actions,2);
    
    initial_action_ix_per_fbs = zeros(1, n_FBSs);
    for i=1:n_FBSs
        [~,index_tpc] = find(actions_tpc==FBS_aux(i).PTdBm);
        initial_action_ix_per_fbs(i) = index_tpc;
    end
    % Initialize the indexes of the taken action
    action_ix_per_fbs = initial_action_ix_per_fbs;

%% Initialize Q
       Qval = {};
       for i=1:n_FBSs
            Qval{i} = zeros(size(possible_actions, 2));
       end
%        gamma = 0.9;
%        alpha = 0.5;                 % Learning Rate
%        MAX_CONVERGENCE_TIME = 1440;
%        MIN_SAMPLE_CONSIDER = MAX_CONVERGENCE_TIME/2 + 1;
%        MAX_LEARNING_ITERATIONS = 100;    % Maximu
       selected_action = action_ix_per_fbs;              % Initialize arm selection for each WLAN by using the initial action
       next_action = zeros(1, n_FBSs);
       current_action = selected_action;
       counter_switch_on = zeros(1,n_FBSs);
       counter_switch_off = zeros(1,n_FBSs);
       switchingOnRate = zeros(1, MAX_CONVERGENCE_TIME);
       switchingOffRate = zeros(1, MAX_CONVERGENCE_TIME);
       times_ac_is_seleceted = zeros(n_FBSs, K);     
       transitions_counter = zeros(n_FBSs, K^2);
       allcombs = allcomb(1:K, 1:K);
       Normalized_tpt_off = zeros(1, MAX_CONVERGENCE_TIME);
       UE_on_FBS = zeros(1, MAX_CONVERGENCE_TIME);
       UE_off_FBS = zeros(1, MAX_CONVERGENCE_TIME);
       cumulativePowerConsumption = zeros(1, MAX_CONVERGENCE_TIME);
       cumulativePowerConsumption0 = zeros(1, MAX_CONVERGENCE_TIME);
       cumulativePowerConsumptionDiff = zeros(1, MAX_CONVERGENCE_TIME);
       T= 1;
       Tmax = 10;
       
%% ITERATE UNTIL CONVERGENCE OR MAXIMUM CONVERGENCE TIME               
%     initial_epsilon = 1;    % Initial Exploration coefficient
%     updateMode = 1;         % s0: epsilon = initial_epsilon / t ; 1: epsilon = epsilon / sqrt(t)
initial_epsilon = 1;    % Initial Exploration coefficient
    updateMode = 1;         % s0: epsilon 
    t = 1;
    epsilon = initial_epsilon; 
    cumulative_tpt_experienced_per_fbs = 0;
    for i=1:n_FBSs
             PTx(i) = FBS(i).PTdBm;
    end
     
    while(t < MAX_CONVERGENCE_TIME + 1) 

         [n_UEs UE_location] = UEPara(t);
         n_UEs1 = n_UEs(1,1);
         nUE(t) = n_UEs1;
         [UE_Number_per_FBS, distributed_UE_location] = k_means(t, FBS_location, UE_location, n_FBSs, n_UEs); 

    %% Calc throughput 
        
        sinr_FBS = new_SINR_FBS(t, n_FBSs, FBS_location, f, PTx, n_UEs, UE_location, UE_Number_per_FBS, distributed_UE_location)
        sinr_BS = SINR_BS(BS_location, BS, FBS_location, f, n_FBSs, PTx);
        tpt_BS = TheoreticalCapacity(bw_BS, sinr_BS)/1e6; %Mbps
        tpt_FBS = computeThroughput(n_FBSs, bw_FBS, sinr_FBS);
        tpt_BS_max = 92; %throughput 如何随时间变化？？?暂定92定值。。。
        tpt_FBS_max = max(tpt_FBS);
        tpt_FBS0(:, t) = tpt_FBS;
        
        % Assign turns to FBSs randomly 
        order = randperm(n_FBSs);  

        for i=1:n_FBSs % Iterate sequentially for each agent in the random order                      
      
            learning_iteration = 1;
            while(learning_iteration <= MAX_LEARNING_ITERATIONS)
                % Select an action according to Q-learning policy
                selected_action = selectActionQLearning(Qval{order(i)}, actions_tpc, epsilon);
                next_action(order(i)) = selected_action;
%                 ix_action = selected_action;            
%                 current_action(order(i)) = ix_action;
                ix = find(allcombs(:,1) == current_action(order(i)) & allcombs(:,2) == next_action(order(i)));
                 if ix==2 || ix==3 || ix==4 || ix==6
                    counter_switch_on(i) = counter_switch_on(i) + 1;
                    switchingOn(i, t) = 1;
                elseif ix==4 || ix==7
                     counter_switch_off(i)= counter_switch_off(i) + 1;
                     switchingOff(i, t) = 1;
                else continue;
                end           
                             
                % Change parameters according to the action obtained
                FBS_aux(order(i)).PTdBm = actions_tpc(selected_action);
                % Prepare the next state according to the actions performed on the current state
                [~,index_tpc] = find(actions_tpc==FBS_aux(order(i)).PTdBm);
                initial_action_ix_per_fbs(order(i)) = index_tpc;

                % Update the exploration coefficient according to the inputted mode
                if updateMode == 0
                    epsilon = initial_epsilon / t;
                elseif updateMode == 1 
                    epsilon = initial_epsilon / sqrt(t);
                end
                learning_iteration = learning_iteration + 1;
            end
        end
        
        %calculate power consumption & throughput at time t
        max_nUE = 450; % to simulate drop rate, define max = 400
        Normalized_total_tpt_BS = sum(tpt_BS/tpt_BS_max)*n_FBSs;
        Normalized_tpt_BS =   tpt_BS/tpt_BS_max;
        Normalized_tpt_FBS =   tpt_FBS/tpt_FBS_max;
        if (nUE(t)<=max_nUE)
            L(t) = nUE(t)/max_nUE;
        else L(t) = 1;
        index_switch_off = find(switchingOff(:, t)==1);
        index_switch_on = find(switchingOn(:, t) ==1);
        for index_counter = 1:size(index_switch_on)
            UE_on_FBS(t) = sum(UE_Number_per_FBS(1, index_switch_on(index_counter)));
        end
        for index_counter = 1:size(index_switch_off)
             Normalized_tpt_off(t) = sum(Normalized_tpt_FBS(1, index_switch_off(index_counter)));
             UE_off_FBS(t) = sum(UE_Number_per_FBS(1, index_switch_off(index_counter)));
        end
        end
        switchingOnRate(t) = sum(switchingOn(:,t))/n_FBSs;
        switchingOffRate(t) = sum(switchingOff(t))/n_FBSs;
        PowerConsumption = L(t) * switchingOnRate(t) * (105.6 + 39*Normalized_tpt_FBS);
        totalPowerConsumption(t) = 750 + 600*(1+switchingOffRate(t)) * (1 - L(t)) * Normalized_tpt_BS + switchingOnRate(t)*n_FBSs*30 + sum(PowerConsumption); %关掉微基站后原来其服务用户转到宏基站中
        
        % POWER CONSUMPTION WHEN ALL SMALL CELLS ARE ON 
        PowerConsumption0 = L(t) * (105.6 + 39*Normalized_tpt_FBS);
        totalPowerConsumption0(t) = 750 + 600*Normalized_tpt_BS + sum(PowerConsumption0) + 15*n_FBSs;
        
        cumulativePowerConsumption(t) = sum(totalPowerConsumption);
        cumulativePowerConsumption0(t) = sum(totalPowerConsumption0);
        
        totalPowerConsumptionDiff(t) = totalPowerConsumption0(t) - totalPowerConsumption(t);
        cumulativePowerConsumptionDiff(t) = sum(totalPowerConsumptionDiff);
        
        
        %Update Q  
       if rem(T,10) == 0
         for FBS_i = 1 : n_FBSs             
             if(nUE(t)>max_nUE)
                     rw = 0;
             else 
                      if (tpt_FBS(FBS_i)<=1 || switchingOn(FBS_i) ==1)
                              rw = PowerConsumption(FBS_i);
                      elseif switchingOff(FBS_i) ==1
                              rw = 105.6 + 30;%基站基础能耗+打开能耗
                      else 
                          rw = 0;
                      end
             end   
             
               Qval{FBS_i}(current_action(order(i)), next_action(order(i))) = ...
                Qval{FBS_i}(current_action(order(i)), next_action(order(i))) + ...
                alpha * (rw + gamma * max(Qval{FBS_i}(next_action(order(i)), :)) - Qval{FBS_i}(current_action(order(i)),current_action(order(i))));
             
%             Qval{FBS_i}(current_action(order(i)), next_action(order(i))) = ...
%                 Qval{FBS_i}(current_action(order(i)), next_action(order(i))) + ...
%                 alpha * (rw + gamma * (max(Qval{FBS_i}(next_action(order(i)), :) - Qval{FBS_i}(current_action(order(i)),:))));
%             Qval{FBS_i}(:, action_ix_per_fbs(FBS_i)) = ...
%                 (1 - alpha) * Qval{FBS_i}(action_ix_per_fbs(FBS_i)) + ...
%                 (alpha * rw + gamma * (max(Qval{FBS_i})));
            Normalized_tpt_experienced_per_fbs(FBS_i, t) = Normalized_tpt_FBS(FBS_i);
             Total_normalized_tpt_experienced(t) = sum(Normalized_tpt_experienced_per_fbs(:, t));
            current_action(order(i)) = next_action(order(i));   
         end
    end
        Q(:,:,t) = Qval;
        t = t+1;
        if rem(T, Tmax) ==0
             T = 1;
         else
             T = T+1;
        end
        
    end
%     figure;
%     grid on, plot(switchingOnRate);
%     grid on, plot(cumulativePowerConsumption,'-.');
%     hold on; plot(cumulativePowerConsumption0,'-r');
% hold on; plot(cumulativePowerConsumptionDiff);

%     
%     figure;
%         grid on, plot(totalPowerConsumption ,'-b');
%         hold on; plot(totalPowerConsumption0 ,'-r');
%         figure;
%         grid on; plot(totalPowerConsumptionDiff, '-b');
%         figure;
%         grid on, plot(switchingOnRate ,'-b');
        Q1 = cell2mat(Q(1,:));
        k = 1;
        j = 1;
        for j=1:16:69120
                Q1max(k) = max(Q1(:,j));
                k = k+1;
        end
        k = 1;
        j = 1;
        for j=1:3:4320
            q = [Q1max(1,j), Q1max(1,j+1), Q1max(1,j+2)];
                Qmax(k) = max(q);
                k = k+1;
        end
        grid on, plot(Qmax);

end
%      display(Normalized_tpt_experienced_per_fbs);

%     Qt=cell2num(Q);
%     mQ = max(cell2mat(Q));
% %     Qt = mQ(:,1,:);
%     Qreshape = reshape(mQ,48, 1000);
%         Q2 = permute(mQ(1,:,:), [1 2 3]);
%         figure;
%         grid on, plot(recordT, '-r');
%         grid on, plot(Qreshape(1,:));

%         figure;
%         grid on, plot(Normalized_tpt_experienced_per_fbs(1,:) ,'-b');
