function fd = nld(x)
% input:    x       data
% output:   fd      fractal dimension estimate (using NLD method)

y =      zscore(x); % crude version of amplitude normalization
N =      length(y); % get length of signal
NLDi =   zeros(1,N);

% calculate NLDi with the upper limit of N and lower limit of i=2
for i = 2:N,
    NLDi(i) =    abs(y(i)-y(i-1));
end;

% use complete algorithm and sum NLDi's
NLD =    (1/N)*(sum(NLDi));

% use the power model for NLD to FD conversion
a =      1.9079;
NLDz =   0.097178;
k =      0.18383;
fd =     a*((NLD-NLDz).^k);