function y = getStep(n,d)
% Nominator coefficients
% n = [8];
% Denominator coefficients
% d = [1 2 10 8];
% y = getStep([8],[1 2 10 8]);
sys = tf(n,d);
t = linspace(0,10,400);
y = step(sys,t);
end