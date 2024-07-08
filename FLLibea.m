function Population = FLLibea(Problem,Population,Rate,Acc)
%% IBEA、
clc;
format compact;%空格紧凑
tic;%记录运行时间 

     kappa = 0.05;  %IBEA算法参数k = 0.05
     Generations   = 1;
     for Gens  = 1 : Generations  
         MatingPool = TournamentSelection(2,Problem.N,-IBEACalFitness(Population.objs,kappa));
         OffDec     = OperatorGA(Problem,Population(MatingPool).decs);
         %% FDV
         if Problem.FE/Problem.maxFE <= Rate
             Offspring = FDVoperator(Problem,Rate,Acc,OffDec);
         else
%              Offspring  = OperatorGA(Problem,Population(MatingPool));
             Offspring = Problem.Evaluation(OffDec);
         end

%          MatingPool = TournamentSelection(2,Problem.N,-IBEACalFitness(Population.objs,kappa));
%          Offspring  = OperatorGA(Problem,Population(MatingPool));
         Population = IBEAEnvironmentalSelection([Population,Offspring],Problem.N,kappa);
%          FunctionValue = Population.objs;
     end
end

function Population = IBEAEnvironmentalSelection(Population,N,kappa)
% The environmental selection of IBEA

    Next = 1 : length(Population);
    [Fitness,I,C] = IBEACalFitness(Population.objs,kappa);
    while length(Next) > N
        [~,x]   = min(Fitness(Next));
        Fitness = Fitness + exp(-I(Next(x),:)/C(Next(x))/kappa);
        Next(x) = [];
    end
    Population = Population(Next);
end


%% 计算每个解的适应度值
function [Fitness,I,C] = IBEACalFitness(PopObj,kappa)
% Calculate the fitness of each solution

    N = size(PopObj,1);
    PopObj = (PopObj-repmat(min(PopObj),N,1))./(repmat(max(PopObj)-min(PopObj),N,1));
    I      = zeros(N);
    for i = 1 : N
        for j = 1 : N
            I(i,j) = max(PopObj(i,:)-PopObj(j,:));
        end
    end
    C = max(abs(I));
    Fitness = sum(-exp(-I./repmat(C,N,1)/kappa)) + 1;
end