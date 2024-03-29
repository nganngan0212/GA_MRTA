
% adjust solution to be feasible
function newSol = Feasibilization(sol, model, beta)
    
    numTask = length(model.tasks);
    
    task_check = [];
    
    newSol = sol;

    % create the list for count the number of holders for each task
    for i = 1:numTask
        
        task_check(i).id = model.tasks(i).id;
        task_check(i).holder = [];

        for j = 1 : model.N % model.N is number of agent
            
            for k = 1 : length(sol.agents(j).task) % for each task in agent(j)
               if sol.agents(j).task(k) == task_check(i).id 
                    task_check(i).holder = [task_check(i).holder, j];
                    break;
               end
            end
        end
    end
    
    % Adjust the solution due to the list
    for i = 1:numTask

        % disp("Working with list agent carry task " + i);
        
        if length(task_check(i).holder) > 1 % if the task is carried by more than one agent
            % use if because this action just keep one agent and remove all
            % other agent
            
            % holder_of_task_display = task_check(i).holder

            prob = zeros(1,length(task_check(i).holder));
            
            for j = 1 : length(task_check(i).holder) % for each holder

                idh = task_check(i).holder(j); % get id of holder
                nh = length(sol.agents(idh).task); % number of tasks carried by this holder

                prob(j) = exp(-beta*nh); % probability of agent choosed to keep the task
            end

            prob = prob/sum(prob); % standardlization
            ic = RouletteWheelSelection(prob);
            % holder = task_check(i).holder
            % keep_position = ic

            idx = task_check(i).holder; 
            idx(ic) = []; % idx is list of agent should be drop the task
            
            % agents_chosed_to_removed = idx
            % id_task_remove = task_check(i).id

            for in = 1 : length(idx)
                % before_remove = newSol.agents(in).task
                for k = 1 : length(newSol.agents(in).task)
                    % before_remove = newSol.agents(in).task
                    % checking_with_task = task_check(i).id 

                    if newSol.agents(in).task(k) == task_check(i).id % delete task in agent solution
                        
                        if k == 1
                            newSol.agents(in).task = [newSol.agents(in).task(2:end)];
                            % after_remove = newSol.agents(in).task
                            break;
                        elseif k == length(newSol.agents(in).task)
                            newSol.agents(in).task = [newSol.agents(in).task(1:k-1)];
                            % after_remove = newSol.agents(in).task
                            break;
                        else
                            newSol.agents(in).task = [newSol.agents(in).task(1:k-1), newSol.agents(in).task(k+1:end)];
                            % after_remove = newSol.agents(in).task
                            break;
                        end
                        % after_remove = newSol.agents(in).task
                    end
                end

            end
        end

        if length(task_check(i).holder) < 1 % if this task is not carried by any agents
            % disp("Find a lonely task => " + task_check(i).id);
            prob_a = []; % prob of agents to carry this task

            for it = 1:length(newSol.agents)
                nh = length(newSol.agents(it).task); % number of tasks carried by this holder
                prob_a(it) = exp(-beta*nh); % probability of agent choosed to keep the task
            end
            
            prob_a = prob_a/sum(prob_a); % standardlization
            icd = RouletteWheelSelection(prob_a); % id of chosed agent
            
            % disp("Add to agent: " + icd);
            % disp("Before add: " + num2str([newSol.agents(icd).task(:)]));
                        
            newSol.agents(icd).task = [newSol.agents(icd).task, task_check(i).id]; % add this task to agent
            task_check(i).holder = icd;
            
            % disp("After add: " + num2str([newSol.agents(icd).task(:)]));
        end

    end

end