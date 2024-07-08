function Population = Initspea2(Problem,Population,Iter)

%% SPEAII算子      
    Generations = Iter;
    %求解初始种群的适应度值
    Fitness    = SPEA2CalFitness(Population.objs);
    %锦标赛选择配对池中个体
    for Gens = 1 :   Generations
        MatingPool = TournamentSelection(2,Problem.N,Fitness);
        Offspring  = OperatorGA(Problem,Population(MatingPool));
        [Population,Fitness] = SPEA2EnvironmentalSelection([Population,Offspring],Problem.N);
%          FunctionValue = Population.objs;
    end
end

%% SPEA2适应度值计算
function Fitness = SPEA2CalFitness(PopObj)
% Calculate the fitness of each solution

    N = size(PopObj,1);

    %% Detect the dominance relation between each two solutions
    Dominate = false(N);
    for i = 1 : N-1
        for j = i+1 : N
            k = any(PopObj(i,:)<PopObj(j,:)) - any(PopObj(i,:)>PopObj(j,:));
            if k == 1
                Dominate(i,j) = true;
            elseif k == -1
                Dominate(j,i) = true;
            end
        end
    end
    
    %% Calculate S(i)
    S = sum(Dominate,2);
    
    %% Calculate R(i)
    R = zeros(1,N);
    for i = 1 : N
        R(i) = sum(S(Dominate(:,i)));
    end
    
    %% Calculate D(i)
    Distance = pdist2(PopObj,PopObj);
    Distance(logical(eye(length(Distance)))) = inf;
    Distance = sort(Distance,2);
    D = 1./(Distance(:,floor(sqrt(N)))+2);
    
    %% Calculate the fitnesses
    Fitness = R + D';
end

%% 环境选择
function [Population,Fitness] = SPEA2EnvironmentalSelection(Population,N)
% The environmental selection of SPEA2

    %% Calculate the fitness of each solution
    Fitness = SPEA2CalFitness(Population.objs);

    %% Environmental selection
    Next = Fitness < 1;
    if sum(Next) < N
        [~,Rank] = sort(Fitness);
        Next(Rank(1:N)) = true;
    elseif sum(Next) > N
        Del  = Truncation(Population(Next).objs,sum(Next)-N);
        Temp = find(Next);
        Next(Temp(Del)) = false;
    end
    % Population for next generation
    Population = Population(Next);
    Fitness    = Fitness(Next);
end

function Del = Truncation(PopObj,K)
% Select part of the solutions by truncation

    %% Truncation
    Distance = pdist2(PopObj,PopObj);
    Distance(logical(eye(length(Distance)))) = inf;
    Del = false(1,size(PopObj,1));
    while sum(Del) < K
        Remain   = find(~Del);
        Temp     = sort(Distance(Remain,Remain),2);
        [~,Rank] = sortrows(Temp);
        Del(Remain(Rank(1))) = true;
    end
end

