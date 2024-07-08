function s = State(MaxFront)
if MaxFront == 1
    s = 3;
elseif MaxFront == 3 || MaxFront == 2
    s = 2;
elseif MaxFront >= 3    
    s = 1;
end
end

% function s = State(npop1,npop2)
%     if npop1 < npop2
%         s = 1;
%     elseif npop1 == npop2
%         s = 2;
%     else 
%         s = 3; 
%     end
% end