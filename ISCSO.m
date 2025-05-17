function [Best_Score,BestFit,Convergence_curve]=ISCSO(SearchAgents_no,Max_iter,lb,ub,dim,fobj)
BestFit=zeros(1,dim);
Best_Score=inf;
%% 
Positions=initializationNew(SearchAgents_no,dim,ub,lb);
Convergence_curve=zeros(1,Max_iter);
% counter=0;
t=0;
p=[1:360];
C = 0.01;
while t<Max_iter
    t
    for i=1:size(Positions,1)
        Flag4ub=Positions(i,:)>ub;
        Flag4lb=Positions(i,:)<lb;
        Positions(i,:)=(Positions(i,:).*(~(Flag4ub+Flag4lb)))+ub.*Flag4ub+lb.*Flag4lb;
        fitness=fobj(Positions(i,:));
        if fitness<Best_Score
            Best_Score=fitness;
            BestFit=Positions(i,:);
        end
    end
    S=2;                                    %%% S is maximum Sensitivity range 
    rg=S-((S)*t/(Max_iter));                %%%% guides R
   for i=1:size(Positions,1)
        r=rand*rg;
        R=((2*rg)*rand)-rg;                 %%%%   controls to transtion phases  
        for j=1:size(Positions,2)
        teta=RouletteWheelSelection(p);
           if((-1<=R)&&(R<=1))              %%%% R value is between -1 and 1
				% 
				Rindex=randi(SearchAgents_no);
				Xrnd=Positions(Rindex,j);
				Xlevy=Levy(1)*(Xrnd-BestFit(j));
				Positions(i,j)=BestFit(j)+abs(BestFit(j)-Xlevy)*rand*cos(teta);
                % Rand_position=abs(rand*BestFit(j)-Positions(i,j));
                % q = (BestFit(j)-Positions(i,j));
                % e = cos(pi/2*rand)*C*(q-((q)*j/(size(Positions,2)))-1);
                % Positions(i,j)=BestFit(j)+e*Rand_position*cos(teta);
           else 
				%% 
				Rindex=randi(SearchAgents_no);
				Xrnd=Positions(Rindex,j);
				if rand>0.5
					bf=1;
				else
					bf=2;
				end
				Rmv=(Xrnd+BestFit(j))/2;
				% Positions(i,j)=BestFit(j)+(BestFit(j)-bf*Rmv);
                aii=BestFit(j)+(BestFit(j)-1*Rmv);
                aij=BestFit(j)+(BestFit(j)-2*Rmv);
                % 
                % Positions(i,j)=BestFit(j)+(BestFit(j)-Xrnd)*(-1+2*rand);
                bjj=BestFit(j)+(BestFit(j)-Xrnd)*(-1+2*rand);

                if(aii>bjj)
                   aii=bjj;
                end

                cxx=aii+(rand*2-1)*(BestFit(j)-aii);
                if(aii>cxx)
                    aii=cxx;
                end
                if(Positions>aii)
                Positions(i,j)=aii;
                end
                %
                % Positions(i,j)=BestFit(j)+

            end
        end
         %% Random opposition-based learning strategy
        Xnew = lb+ub-rand*Positions(i,:);
        if fobj(Xnew)<fobj(Positions(i,:))
            Positions(i,:)=Xnew;
        end
        % %% Restart strategy
        % fv4=fobj(Positions(i,:));
        % if fv4 < Best_Score 
        %     counter = 0;
        % else
        %     counter= counter + 1;
        % end
        % if counter > log(t)  % Restart mechanism judgment, considering the number of iterations 1,2,5,10,15,... it/10,log(it)
        %     t1 = zeros(1,dim); t2 = zeros(1,dim);
        %     t1(1,:) = (ub-lb)*rand+lb;
        %     t2(1,:) = (ub+lb)*rand-Positions(i,:);
        %     Flag4ub=t2(1,:)>ub;
        %     Flag4lb=t2(1,:)<lb;
        %     t2(1,:)=(t2(1,:).*(~(Flag4ub+Flag4lb)))+ub.*Flag4ub+lb.*Flag4lb;
        %     if fobj(t1) < fobj(t2)
        %         Positions(i,:) = t1(1,:);
        %     else
        %         Positions(i,:) = t2(1,:);
        %     end
        %     counter = 0;
        % end
    end
    t=t+1;
    Convergence_curve(t)=Best_Score;
end
end

% Draw n samples for the Levy flight from the Levy distribution
function L=Levy(d)
beta=3/2;
sigma=(gamma(1+beta)*sin(pi*beta/2)/(gamma((1+beta)/2)*beta*2^((beta-1)/2)))^(1/beta);
% Mantegna's algorithm for Levy random numbers
u=randn(1,d)*sigma;
v=randn(1,d);
step=u./abs(v).^(1/beta);
L=0.02*step*0.35;             % Final Levy steps
end