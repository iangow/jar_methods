% Matlab program to generate JAR data and estimates
clear;  close all; %clc
% Seeds Mersenne twister random number generator 
rng(4576023, 'twister')
% Sample size
nobs=10000;
% Nx10 Random indpendent normals 
u=normrnd(zeros(nobs,10),1);
% Amount of (equi-)correlation of the normals; could generalize but this is
% simple.
correl=0.0;
S=eye(10)+correl*(ones(10,10)-eye(10));
u = u*chol(S);
u2=normrnd(zeros(nobs,1),1);
% Generate the observable data ...
internat=u(:,3)<-.5;
segments=1*(u(:,4)<norminv(.5))...
         +2*(u(:,4)>=norminv(.5)).*(u(:,4)<norminv(1));
bonus=.1+min(normcdf(u(:,1),.5,1),.8);
pay=.7+.45*abs(0*u2(:,1)+1*u(:,1));
direct=.35*normcdf(u(:,6),1,1);
big4=u(:,7)>-.7;
% Some independent uniform rvs for 
uni1=rand(nobs,1);   uni2=rand(nobs,1);
uni3=rand(nobs,1);   uni4=rand(nobs,1); 
uni5=rand(nobs,1);   uni6=rand(nobs,1);
% Parameter values: e.g., eqn (7)
a0=.5; a1=3.5; a2=3.5;
m0=7; m1=1.5;
b0=20; b1=10;
ph=0.75; pl=0.05;
pi0=.45; r0=60;

B=b0+b1*bonus;   Cm=m0+m1*pay;     
pi=pi0*ones(size(bonus,1),1);
Ca=a0+a1*internat+a2*segments;
fac=(1-pl)/(r0*b0*(1-pi0)*(ph-pl));
bexpect=[fac*[a0*m0 a1*m0 a2*m0 a0*m1 a1*m1 a2*m1] b1/b0]

% Set up solutions  
p_new=1-(Cm./((1-pi).*B));  
alp=min(max((p_new-pl)./(ph-pl),0),1);    
bet=Ca./((ph-pl).*pi.*r0);   
restate=(uni3<bet).*( uni6<(1-(uni4<alp).*ph - (1-(uni4<alp)).*pl) ).*(uni5<pi);
disp(' ')
disp(['Mean Restate   ' num2str(mean(restate))])
disp(['Mean Misstate  ' num2str(mean((uni3<bet)),4)])
disp(['Mean Audit     ' num2str(mean(( uni6<(1-(uni4<alp).*ph - (1-(uni4<alp)).*pl) )),4)])
disp(['Mean Ext Audit ' num2str(mean((uni5<pi)),4)])
disp(' ')
disp('Check Bounds on Probabilities')
[min(p_new) max(p_new)  min(alp) max(alp) min(bet) max(bet) ]
[min((p_new-pl)) max((p_new-pl)) min(ph-pl) max(ph-pl)]
disp(' ')

fid = fopen('jar_restate_10000.csv','w');
fprintf(fid,'%3.1f , %8.5f , %8.5f , %3.1f , %8.5f , %3.1f , %3.1f\n',[restate pay bonus big4 direct internat segments]');
fclose(fid);

% Matlab save 
save('strat_final.mat','restate', 'bonus', 'pay', 'big4', 'direct', 'segments', 'internat', ...
'B', 'Cm', 'pi', 'ph', 'pl', 'b0', 'b1', 'm0', 'm1', 'a0', 'a1', 'a2', 'p_new', 'alp', 'bet') 
disp(' ')

% Some descriptives (Table 1) in Tex
disp('                                 Table 1')
disp(' ')
disp(['\T {\bf RESTATE} &   ' num2str(mean(restate),'%15.3f')  '  \\'])
disp(['                           &   (' num2str(std(restate),'%15.3f') ')  \\[.6em]'])
disp(['    {\bf CEOPAY} &   ' num2str(mean(pay),'%15.2f')   '  \\'])
disp(['                           &   (' num2str(std(pay),'%15.2f')  ')  \\[.6em]'])
disp(['    {\bf CEOBONUS} &   ' num2str(mean(bonus),'%15.2f')     '  \\'])
disp(['                           &   (' num2str(std(bonus),'%15.2f') ')  \\[.6em]'])
disp(['    {\bf BIG4} &   ' num2str(mean(big4),'%15.2f')   '  \\'])
disp(['                           &   (' num2str(std(big4),'%15.2f')  ')  \\[.6em]'])
disp(['    {\bf FINDIRECT} &   ' num2str(mean(direct),'%15.2f') '  \\'])
disp(['                           &   (' num2str(std(direct),'%15.2f')  ')  \\[.6em]'])
disp(['    {\bf SEGMENTS} &   ' num2str(mean(segments),'%15.2f')  '  \\'])
disp(['                           &   (' num2str(std(segments),'%15.2f') ')  \\[.6em]'])
disp(['    {\bf INTERNAT} &   ' num2str(mean(internat ),'%15.2f')  '  \\'])
disp(['                           &   (' num2str(std(internat ),'%15.2f')  ')  \\[.6em]'])
disp(' ')
% Logits - relies on third-party logit.m 

[bhat3 hess3 me31 me32 me3_std]=logit(restate,[ones(nobs,1) pay bonus]);
[bhat3 sqrt(diag(hess3)) me31 me32 me3_std]
me31./me3_std

X=[ones(nobs,1) pay bonus big4 direct internat segments];
[bhat4 hess4 me41 me42 me4_std]=logit(restate,X);
[bhat4 sqrt(diag(hess4)) me41 me42 me4_std]
me41./me4_std

% Store logit results for display
A=[];
for j=1:size(bhat3(:),1)
   A= [A; [[bhat3(j); sqrt(hess3(j,j))]  [me31(j); me3_std(j)] ]];
end
A=[A ; zeros(8,2)] ;
AA=[];
for j=1:size(bhat4(:),1)
   AA= [AA; [[bhat4(j); sqrt(hess4(j,j))]  [me41(j); me4_std(j)] ]];
end
BB=[A AA];

% Print out Table 2
disp(' ')
disp(['\T {\bf Intercept} &   ' num2str(A(1,1),'%15.3f')    '   &  '   ' & '...
      num2str(AA(1,1),'%15.3f')    '   &  '    '  \\'])
disp(['                   &   ' num2str((A(2,1)),'%15.3f') '   &  '   ' & '...
        num2str(AA(2,1),'%15.3f') '   &  '  ' \\[.6em]'])

disp([' {\bf CEOPAY}    &   ' num2str(A(3,1),'%15.3f')    '   &  ' num2str(A(3,2),'%15.3f')    ' & '...
      num2str(AA(3,1),'%15.3f')    '   &  ' num2str(AA(3,2),'%15.3f')    '  \\'])
disp(['                   &   ' num2str((A(4,1)),'%15.3f') '   &  ' num2str((A(4,2)),'%15.3f') ' & '...
        num2str(AA(4,1),'%15.3f') '   &  ' num2str(AA(4,2),'%15.3f') ' \\[.6em]'])

disp([' {\bf CEOBONUS}  &   ' num2str(A(5,1),'%15.3f')     '   &  ' num2str(A(5,2),'%15.3f')     ' & '...
      num2str(AA(5,1),'%15.3f')     '   &  ' num2str(AA(5,2),'%15.3f')     '  \\'])
disp(['                   &   ' num2str((A(6,1)),'%15.3f') '   &  ' num2str((A(6,2)),'%15.3f') ' & '...
        num2str(AA(6,1),'%15.3f') '   &  ' num2str(AA(6,2),'%15.3f') ' \\[.6em]'])

disp([' {\bf BIG4 }  &   ' num2str(A(7,1),'%15.3f')     '   &  ' num2str(A(7,2),'%15.3f')     ' & '...
      num2str(AA(7,1),'%15.3f')     '   &  ' num2str(AA(7,2),'%15.3f')     '  \\'])
disp(['                   &   ' num2str((A(8,1)),'%15.3f') '   &  ' num2str((A(8,2)),'%15.3f') ' & '...
        num2str(AA(8,1),'%15.3f') '   &  ' num2str(AA(8,2),'%15.3f') ' \\[.6em]'])

disp([' {\bf FINDIRECT}  &   ' num2str(A(9,1),'%15.3f')     '   &  ' num2str(A(9,2),'%15.3f')     ' & '...
      num2str(AA(9,1),'%15.3f')     '   &  ' num2str(AA(9,2),'%15.3f')     '  \\'])
disp(['                   &   ' num2str((A(10,1)),'%15.3f') '   &  ' num2str((A(10,2)),'%15.3f') ' & '...
        num2str(AA(10,1),'%15.3f') '   &  ' num2str(AA(10,2),'%15.3f') ' \\[.6em]'])

disp([' {\bf INTERNAT }  &   ' num2str(A(11,1),'%15.3f')     '   &  ' num2str(A(11,2),'%15.3f')     ' & '...
      num2str(AA(11,1),'%15.3f')     '   &  ' num2str(AA(11,2),'%15.3f')     '  \\'])
disp(['                   &   ' num2str((A(12,1)),'%15.3f') '   &  ' num2str((A(12,2)),'%15.3f') ' & '...
        num2str(AA(12,1),'%15.3f') '   &  ' num2str(AA(12,2),'%15.3f') ' \\[.6em]'])

disp([' {\bf SEGMENTS}  &   ' num2str(A(13,1),'%15.3f')     '   &  ' num2str(A(13,2),'%15.3f')     ' & '...
      num2str(AA(13,1),'%15.3f')     '   &  ' num2str(AA(13,2),'%15.3f')     '  \\'])
disp(['                   &   ' num2str((A(14,1)),'%15.3f') '   &  ' num2str((A(14,2)),'%15.3f') ' & '...
        num2str(AA(14,1),'%15.3f') '   &  ' num2str(AA(14,2),'%15.3f') ' \\[.6em]'])

disp(' ')
disp(['Equilibrium Check: ' num2str(sum(abs((1-p_new).*(1-pi).*B -Cm)),'%12.10f')])
disp(['Equilibrium Check: ' num2str(sum(abs(bet.*(1-ph).*pi.*r0 + Ca - bet.*(1-pl).*pi.*r0)),'%12.10f')])  
disp(' ')

% Code for structural models

XX=[internat segments pay bonus big4 direct];
thet0=bexpect(:);
options = optimset('LargeScale','off',...  % Use Medium Scale
                   'Diagnostics','on',...  % Print diagnostic information about the function
                   'Display','off',...    % Display results on each iteration
                   'GradObj','off',...     % User not supplying gradients
                   'Hessian','off',...     % User not supplying Hessian
                   'MaxFunEvals',100000,...  % Maximum number of function evaluations allowed 
                   'MaxIter',10000,...        % Maximum number of iterations allowed
                   'TolFun',1e-9,...         % Termination tolerance on the function value
                   'TolX',1e-9...           % Termination tolerance on x
);
[thet1, f1]=fminsearch('restate_gmm',thet0,options,restate,XX,eye(7),0);
se_x1=sqrt(diag(restate_gmm_stderr(thet1,restate,XX,eye(7),0)));
[thet1 se_x1]
disp(' ')
theta=thet1;

[thet2, f2]=fminsearch('restate_gmm2',thet0,options,restate,XX,eye(13),0);
se_x2=sqrt(diag(restate_gmm_stderr2(thet2,restate,XX,eye(13),0)));
[thet2 se_x2]
disp(' ')
% Constrained Specification

options = optimoptions(@fmincon,'Algorithm','sqp', 'TolFun',1e-9,'TolX',1e-9, 'TolCon',1e-9,'MaxFunEvals',100000,...
     'MaxIter',10000);
[thet3,fval] = fmincon('restate_gmm',thet0,[],[],[],[],[],[],'nonlcon',options,restate,XX,eye(7),0);
disp(' ')
[(thet1(4)/thet1(1)-thet1(5)/thet1(2)) (thet1(4)/thet1(1)-thet1(6)/thet1(3)) (thet1(1)/thet1(2)-thet1(4)/thet1(5)) (thet1(2)/thet1(3)-thet1(5)/thet1(6))]
disp(' ')
[thet3]

Xnum=XX(:,1:3); Xdenom=XX(:,4:end);
numer=thet1(1)+thet1(2)*Xnum(:,1)+thet1(3)*Xnum(:,2)+thet1(4)*Xnum(:,3)+...
    thet1(5)*Xnum(:,1).*Xnum(:,3)+thet1(6)*Xnum(:,3).*Xnum(:,2);
denom= (1+thet1(7)*Xdenom(:,1));
pr0=numer./denom;
pr1=numer;
[mean(pr1) mean(pr0) mean(pr1)/mean(pr0) mean(pr1./pr0)]

numer=thet2(1)+thet2(2)*Xnum(:,1)+thet2(3)*Xnum(:,2)+thet2(4)*Xnum(:,3)+...
    thet2(5)*Xnum(:,1).*Xnum(:,3)+thet2(6)*Xnum(:,3).*Xnum(:,2);
denom= (1+thet2(7)*Xdenom(:,1));
pr0=numer./denom;
pr1=numer;
[mean(pr1) mean(pr0) mean(pr1)/mean(pr0) mean(pr1./pr0)]

break
% Monte Carlo Simulations for SE's; keep X's constant.
%
Nsim=500;
for k=1:Nsim
    uni1=rand(nobs,1);   uni2=rand(nobs,1);
    uni3=rand(nobs,1);   uni4=rand(nobs,1); 
    uni5=rand(nobs,1);   uni6=rand(nobs,1);
    restate=(uni3<bet).*( uni6<(1-(uni4<alp).*ph - (1-(uni4<alp)).*pl) ).*(uni5<pi);
    [thet11(:,k), f11(k)]=fminsearch('restate_gmm',thet0,options,restate,XX,eye(7),0);
    [thet22(:,k), f22(k)]=fminsearch('restate_gmm2',thet0,options,restate,XX,eye(13),0);
    options = optimoptions(@fmincon,'Algorithm','sqp', 'TolFun',1e-9,'TolX',1e-9, 'TolCon',1e-9,'MaxFunEvals',100000,...
          'MaxIter',10000);
    [thet33(:,k), f33(k)] = fmincon('restate_gmm',thet0,[],[],[],[],[],[],'nonlcon',options,restate,XX,eye(7),0);
end
[thet1 se_x1 thet2 se_x2 thet3 std(thet33')']
