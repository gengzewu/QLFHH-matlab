function S = Statetest(prePop,Population,optimum)
%     w1 = 0.35;
%     w2 = 0.35;
%     w3 = 1 - w2 - w1;
    S_1 = Spacing(Population);
    S_2 = DM(Population,optimum);
    S_3 = IGD(Population,optimum);
    S_1_ = Spacing(prePop);
    S_2_ = DM(prePop,optimum);
    S_3_ = IGD(prePop,optimum);
    P1 = (S_1_ - S_1) / S_1_;
    P2 = (S_2 - S_2_) / S_1_;
    P3 = (S_3_ - S_3) / S_3_;

    if P3 < P1 && P3 < P2
        S = 1;
    elseif P1 < P2 && P1 < P3
        S = 2;
    elseif P2 < P1 && P2 < P3
        S = 3;
    else 
        S = 4;
    end
%     S_4 = w1 * S_1 + w2 * S_2 + w3 * S_3;  
%     if S_4 > 0.3
%         S = 1;
%     elseif S_4 < 0.3 && S_4 > 0.15
%         S = 2;
%     else
%         S = 3;
%     end
        
end
