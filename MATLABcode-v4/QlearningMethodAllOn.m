function [Normalized_tpt_experienced_per_fbs, Qval] = QlearningMethodAllOn(FBS, n_FBSs,...
    FBS_location, BS_location, BS, MAX_CONVERGENCE_TIME, MAX_LEARNING_ITERATIONS, gamma, initial_epsilon, ...
    alpha, updateMode, f, Tx_power, Tmax)
%     n_FBSs = 16;
    Tx_power = [12, 15];
    x = 0;%location of BS
    y = 0;
    MPTdBm = 58;
    f = 0.9;
    
    [FBS_location FBS] = FemtoStationParaAllOn(n_FBSs, Tx_power);
    [BS_location BS] = BaseStationPara( x, y, MPTdBm);
    bw_FBS = FBS.BW;
    bw_BS = BS.BW;
    FBS_aux = FBS; %a copy of FBS
    
    
%% Q-Learning variables
    % Actions
    % 对开关cell表示为能量的变化，开：Pmax 关：Pmin
    possible_actions = 1:size(Tx_power,2);
    % Total number of actions
    K = size(possible_actions,2);
    
    initial_action_ix_per_fbs = zeros(1, n_FBSs);
    for i=1:n_FBSs
        [~,index_tpc] = find(Tx_power==FBS_aux(i).PTdBm);
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
%        MAX_CONVERGENCE_TIME = 10;
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

         [n_UEs UE_location] = UEPara_timeRelated(t);
         n_UEs1 = n_UEs(1,1);
         nUE(t) = n_UEs1;
         [UE_Number_per_FBS, distributed_UE_location] = k_meansTimeRelated(t, FBS_location, UE_location, n_FBSs, n_UEs); 

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
                selected_action = selectActionQLearning(Qval{order(i)}, Tx_power, epsilon);
                next_action(order(i)) = selected_action;
%                 ix_action = selected_action;            
%                 current_action(order(i)) = ix_action;
                ix = find(allcombs(:,1) == current_action(order(i)) & allcombs(:,2) == next_action(order(i)));
    
                             
                % Change parameters according to the action obtained
                FBS_aux(order(i)).PTdBm = Tx_power(selected_action);
                % Prepare the next state according to the actions performed on the current state
                [~,index_tpc] = find(Tx_power==FBS_aux(order(i)).PTdBm);
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
  

        
        
        %Update Q  
       if rem(T,10) == 0
         for FBS_i = 1 : n_FBSs             
%              if(nUE(t)>max_nUE)
%                      rw = 0;
%              else 
%                       if (switchingOn(FBS_i) ==1)
%                               rw = PowerConsumption(FBS_i);
%                       elseif switchingOff(FBS_i) ==1
%                               rw = 105.6 + 30;%基站基础能耗+打开能耗
%                       else 
%                           rw = 0;
%                       end
%              end   
               rw = 0;
               Qval{FBS_i}(current_action(order(i)), next_action(order(i))) = ...
                Qval{FBS_i}(current_action(order(i)), next_action(order(i))) + ...
                alpha * (rw + gamma * max(Qval{FBS_i}(next_action(order(i)), :)) - Qval{FBS_i}(current_action(order(i)),current_action(order(i))));
             
%             Qval{FBS_i}(current_action(order(i)), next_action(order(i))) = ...
%                 Qval{FBS_i}(current_action(order(i)), next_action(order(i))) + ...
%                 alpha * (rw + gamma * (max(Qval{FBS_i}(next_action(order(i)), :) - Qval{FBS_i}(current_action(order(i)),:))));
%             Qval{FBS_i}(:, action_ix_per_fbs(FBS_i)) = ...
%                 (1 - alpha) * Qval{FBS_i}(action_ix_per_fbs(FBS_i)) + ...
%                 (alpha * rw + gamma * (max(Qval{FBS_i})));
            tpt_experienced_per_fbs(FBS_i, t) = tpt_FBS(FBS_i);
            Normalized_tpt_experienced_per_fbs(FBS_i, t) = Normalized_tpt_FBS(FBS_i);       %吞吐量问题？
             Total_tpt_experienced_per_fbs(t) = abs(sum(tpt_experienced_per_fbs(:, t))/n_FBSs);
            current_action(order(i)) = next_action(order(i));   
         end
       end
    t=t+1;
     if rem(T, Tmax) ==0
             T = 1;
         else
             T = T+1;
        end
    end
        
  
%     figure;
%     grid on, plot(switchingOnRate);
    figure;
    hold on; plot(Total_tpt_experienced_per_fbs, 'r');
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
%         Q1 = cell2mat(Q(1,:));
%         k = 1;
%         j = 1;
%         for j=1:16:69120
%                 Q1max(k) = max(Q1(:,j));
%                 k = k+1;
%         end
%         k = 1;
%         j = 1;
%         for j=1:3:4320
%             q = [Q1max(1,j), Q1max(1,j+1), Q1max(1,j+2)];
%                 Qmax(k) = max(q);
%                 k = k+1;
%         end
%         grid on, plot(Qmax);

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
