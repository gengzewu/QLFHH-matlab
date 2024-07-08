classdef HHQLF < ALGORITHM
    % <multi> <real/integer/label/binary/permutation> <constrained/none>
    % HHQLMOPh


    methods
        function main(Algorithm,Problem)
            %% Generate random population
            Iter = 100;
            Pop= Problem.Initialization();
            Population = Initspea2(Problem,Pop,Iter) ;
            [Rate,Acc] = Algorithm.ParameterSet(0.8,0.4);
            %             Population = LLspea2(Problem,Population);
            %             Population = initimprove(Problem,Population);
            gamma = 0.95;
            q_table = zeros(3,3);        % 初始化Q表，Q值为0
            actions = ["IBEA" "SPEA2" "NSGAII"];
            reward_decay = gamma; %折扣因子
            %             s = randi(3);
            [FrontNo,MaxFNo] = NDSort(Population.objs,Population.cons,Problem.N);
            MF1 = MaxFNo;
            s = State(MF1);
            Problem.FE = Problem.FE - Iter*Problem.N ;
            %% Optimization
            while Algorithm.NotTerminated(Population)
                alpha = 1 - (0.9 * (Problem.FE / Problem.maxFE));
                epsilon = 0.5 / (1+exp((10*(Problem.FE-0.6*Problem.maxFE))/Problem.maxFE));
                optimum = Problem.GetOptimum(Problem.N);
                %                 GD_old_val = GD(Population,optimum);
                Pop_in = Population;
                IGD_old = IGD(Pop_in,optimum);
                HV_old = HV(Pop_in,optimum);
                sp_old = Spacing(Pop_in);
                %% 动作选择
                index = find(q_table(s,:) == max(q_table(s,:)));
                %                 if Problem.FE < 0.9 * Problem.maxFE
                %                 lamda = q_table(s,index)/(sum(q_table(s,:)));
%                 if Problem == IMOP3
%                     n = 2;
%                 else
                    %利用奖励值最大的动作
                    if rand() < epsilon
                        n = randi(size(q_table,2));
                    else
                        if rand() < 0.8 && size(index,2) == 1
                            n = index(1);
                        else
                            n = ReRouletteWheelSelection(1,q_table(s,:));
                        end
                    end
%                 end
                %% 执行所选动作
                action = actions(n);
                switch action
                    case "IBEA"
                        Pop_out = FLLibea(Problem,Population,Rate,Acc);
                    case "SPEA2"
                        Pop_out = FLLspea2(Problem,Population,Rate,Acc);
                    case "NSGAII"
                        Pop_out = FLLnsgaii(Problem,Population,Rate,Acc);
                end

                %                 Population = new_pop;
                %% 计算IGD和HV值
                IGD_new = IGD(Pop_out,optimum);
                HV_new =  HV(Pop_out,optimum);
                sp_new = Spacing(Pop_out);
                %                 if IGD_new_val >= IGD_old_val || HV_new <= HV_old
                if HV_new > HV_old 
                    Population = Pop_out;
                else
                    Population = Pop_in;
                end
                theta = 0.0075;
                %% 获取奖励值
                if HV_new > HV_old
                    if ((HV_new - HV_old)/HV_old) >= theta
                        reward = 2;
                    elseif  HV_new < HV_old
                        reward = -1;
                    else
                        reward = 0;
                    end
                else
                    if (IGD_old - IGD_new)/IGD_new >= theta
                        reward = 1;
                    elseif  IGD_old < IGD_new
                        reward = -1;
                    else
                        reward = 0;
                    end
                end
                 %% 下一个状态
                [FrontNo,MaxFNo] = NDSort(Population.objs,Population.cons,Problem.N);
                MF = MaxFNo;
                next_s = State(MF);
                %% 更新Q表
                if action == "IBEA"
                    a = 1;
                elseif action == "SPEA2"
                    a = 2;
                elseif action == "NSGAII"
                    a = 3;
                end
                q_table(s,a) = q_table(s,a) + alpha * (reward + reward_decay * max(q_table(next_s,:)) -  q_table(s,a));
                s = next_s;
            end
        end
    end
end