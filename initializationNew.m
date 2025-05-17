% % 混沌映射种群初始化
% function Positions=initializationNew(SearchAgents_no,dim,ub,lb)
% 
% if(max(size(ub)) == 1)
%    ub = ub.*ones(1,dim);
%    lb = lb.*ones(1,dim);  
% end
% a=0.4999;
% x0=rand;
% for i=1:SearchAgents_no
% 	for j= 1:dim
% 		if x0<a
% 			x=x0/a;
% 		else
% 			x=(1-x0)/(1-a);
% 		end
% 		Positions(i,j)=x*(ub(j)-lb(j))+lb(j);
% 	end
% end
% 
% end

% % 混沌映射种群初始化
% function Positions=initializationNew(SearchAgents_no,dim,ub,lb)
% 
% if(max(size(ub)) == 1)
%    ub = ub.*ones(1,dim);
%    lb = lb.*ones(1,dim);  
% end
% r=0.6;
%        TLC = rand(SearchAgents_no, dim);
%        % r = rand;
%        % while r == 0 || r == 1
%        %       r = rand;
%        % end
%        % r = 4 * r;
%        % LT = rand(SearchAgents_no, dim);
% 
% % a=0.4999;
% % x0=rand;
% for i=1:SearchAgents_no
% 	for j= 2:dim
% 		if TLC(i, j-1) < 0.5
%                    TLC(i,j)=cos(pi*(2 * r *TLC(i,j-1)+ 4*(1-r)*TLC(i,j-1)*(1-TLC(i,j-1)-0.5))); 
%                else
%                    TLC(i,j)=cos(pi*(2 * r *(1-TLC(i,j-1))+ 4*(1-r)*TLC(i,j-1)*(1-TLC(i,j-1)-0.5))); 
%                end
%            end
%        end
%        Positions(i,j) = TLC(i,j);
% 
% end

% 混沌映射种群初始化
function Positions=initializationNew(SearchAgents_no,dim,ub,lb)

if(max(size(ub)) == 1)
   ub = ub.*ones(1,dim);
   lb = lb.*ones(1,dim);  
end
a=0.5;
Bernoulli = rand(SearchAgents_no, dim);
       for i=1:SearchAgents_no
           for j=2:dim
               if (Bernoulli(i,j-1)<=(1-a)) && (( Bernoulli(i,j-1)>0))
                   Bernoulli(i,j)= Bernoulli(i,j-1)/(1-a);
               elseif (Bernoulli(i,j-1)<=1) && (( Bernoulli(i,j-1)>(1-a)))
                   Bernoulli(i,j)=(Bernoulli(i,j-1)-1+a)/a;
               end
           end
       end
       Positions = Bernoulli;
