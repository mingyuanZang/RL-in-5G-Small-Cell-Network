function selected_action = selectActionQLearning(Qval,actions_tpc, epsilon)

        actions_tpc = [-20 15 39];
        n_FBSs = 16;
        possible_actions = 1:size(actions_tpc,2);
%         Qval = {};
%        for i=1:n_FBSs
%             % Fill the Q-table of each node with 0's 
%             Qval{i} = zeros(size(possible_actions, 2));
%        end

    indexes=[];
    
    % Exploration approach
    %rand('twister',sum(100*clock))
    
    epsilon = 1;

    if rand()>epsilon 
        
        [val,~] = max(max(Qval));
        
        % Check if there is more than one occurrence in order to select a value randomly
        if sum(Qval(:)==val)>1
            for i=1:size(Qval,2)
                if Qval(i) == val, 
                    indexes = [indexes i]; 
                end
            end
            if isempty(indexes)
                [~,index] = max(max(Qval));
            else
                index = randsample(indexes,1);
            end
            
        else
            [~,index] = max(Qval);
        end
        
    else
        index = randi([1 size(Qval,2)], 1, 1);
    end
        i = mod(index, size(actions_tpc,2)); 
         if i == 0, i = size(actions_tpc,2); end  
          selected_action = i;    
end