function Offspring = FDVoperator(Problem,Rate,Acc,OffDec,OffVel)

    %% Fuzzy Evolution Sub-stages Division
    Total = 1;
    S = floor(sqrt((2*Rate*Total) / Acc));
    Step = zeros(1,S+2);  % Step(1)=0��Step(S+2) is the compensation step
    for i = 1 : S
        Step(i+1) = (S*i-i*i/2)*Acc;
    end
    Step(S+2) = Rate*Total;  % compensation step

    %% Fuzzy Operation
    R    = Problem.upper-Problem.lower;
    iter = Problem.FE/Problem.maxFE;  % step=[0,0.6,0.8,0.8]
    for i = 1 : S+1
        if iter>Step(i) && iter<=Step(i+1)
            gamma_a = R*10^-i.*floor(10^i*R.^-1.*(OffDec-Problem.lower)) + Problem.lower;
            gamma_b = R*10^-i.*ceil(10^i*R.^-1.*(OffDec-Problem.lower)) + Problem.lower;
            miu1    = 1./(OffDec-gamma_a);
            miu2    = 1./(gamma_b-OffDec);
            logical = miu1-miu2>0;
            OffDec  = gamma_b;
            OffDec(logical) = gamma_a(logical);
        end
    end
    if nargin > 4
        Offspring = Problem.Evaluation(OffDec,OffVel);
    else
        Offspring = Problem.Evaluation(OffDec);
    end
end