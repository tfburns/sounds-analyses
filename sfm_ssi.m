function [lSFM,SSV] = sfm_ssi(x)
% input:    x       data
% output:   lSFM    the spectral flatness measure/Wiener entropy on an expanded dynamic range (logarithmic scale) of x
%           SSV     the spectral structure variation/spectral structure index of x

% compute SFM/Wiener entropy
%windows =        hamming(45); % set hamming window for fft
%for w = 1:45:numel(x);
%    xw(w) =      windows.*x(w:w+windows);
%end;
xw =             x; % comment this line out when trying hamming windowing
nfft =           2^(nextpow2(length(xw))); % use the next highest power of 2 greater than or equal to length(x) to calculate fft
fftx =           fft(xw,nfft); % take fft, padding with zeros so that length(fftx) is equal to nfft 
NumUniquePts =   ceil((nfft+1)/2);
fftx =           fftx(1:NumUniquePts); % fft is symmetric, throw away second half 
mx =             abs(fftx)/length(xw);
s =              mx.^2;
if rem(nfft, 2) % exclude Nyquist point
  s(2:end) = s(2:end)*2;
else
  s(2:end-1) = s(2:end -1)*2;
end

geomMean =   exp(mean(log(s)));
arithMean =  mean(s);
SFM =        geomMean./arithMean; % SFM/Wiener entropy for fft(x)
lSFM =       log(SFM); % expand dynamic range: log it

% (SSI RECTANGULAR WINDOWS) compute SFM/Wiener entropy for specified time windows over whole signal
SSVwindowsize =   100; % I have set this somewhat arbitarily, discussion needed
cSSV =            chunkify(xw,SSVwindowsize); % split signal into rectangular windows

for i = 1:numel(cSSV);
    e =           cSSV{i};
    % give all silent epochs an SFM 
     if mean(e) <= 0
         wSSV(i) = 0;
     else
    % place-holder for hamming windowing of signal window
    nnfft =           2^(nextpow2(length(e))); % use the next highest power of 2 greater than or equal to length(x) to calculate fft
    ffftx =           fft(e,nnfft); % take fft, padding with zeros so that length(fftx) is equal to nfft 
    NNumUniquePts =   ceil((nnfft+1)/2);
    ffftx =           ffftx(1:NNumUniquePts); % fft is symmetric, throw away second half 
    mmx =             abs(ffftx)/length(e);
    ss =              mmx.^2;
    if rem(nnfft, 2) % exclude Nyquist point
        ss(2:end) = ss(2:end)*2;
    else
        ss(2:end-1) = ss(2:end -1)*2;
    end
    % calculate SFM for window
    ggeomMean =   exp(mean(log(ss)));
    aarithMean =  mean(ss);
    wSSV(i) =     ggeomMean./aarithMean; % SFM/Wiener entropy for fft(x{timewindow})
    end;
end;

% (SSI HAMMING WINDOWS) compute SFM/Wiener entropy for specified time windows over whole signal
% SSVwindowsize =   45; % I have set this somewhat arbitarily, discussion needed
% hammingWindow =   hamming(SSVwindowsize);
% cSSV =            enframe(x,hammingWindow); % split signal into hamming windows
% totalrow =        size(cSSV,1);
% 
% for i = 1:totalrow;
%     e =           cSSV(i,1:SSVwindowsize);
%     % give all silent epochs an SFM 
%     if mean(e) <= 0
%          wSSV(i) = 0;
%     else
%     % calculate fft for window
%     nnfft =           2^(nextpow2(length(e))); % use the next highest power of 2 greater than or equal to length(x) to calculate fft
%     ffftx =           fft(e,nnfft); % take fft, padding with zeros so that length(fftx) is equal to nfft 
%     NNumUniquePts =   ceil((nnfft+1)/2);
%     ffftx =           ffftx(1:NNumUniquePts); % fft is symmetric, throw away second half 
%     mmx =             abs(ffftx)/length(e);
%     ss =              mmx.^2;
%     if rem(nnfft, 2) % exclude Nyquist point
%         ss(2:end) = ss(2:end)*2;
%     else
%         ss(2:end-1) = ss(2:end -1)*2;
%     end
%     % calculate SFM for window
%     ggeomMean =   exp(mean(log(ss)));
%     aarithMean =  mean(ss);
%     wSSV(i) =     ggeomMean./aarithMean; % SFM/Wiener entropy for fft(x{timewindow})
%     end;
% end;

wSSV(isnan(wSSV)) =     [];
lSSV =                  log(wSSV); % log to expand dynamic range
lSSV(isinf(lSSV))=      0; % sets all Infs to 0

% (SSI RECTANGULAR WINDOW) compute SSV/SSI
SSV = sum( ((lSSV-((sum(lSSV))/(length(cSSV)))).^2) / (length(cSSV)) );

% (SSI HAMMING WINDOW) compute SSV/SSI
% SSV = sum( ((lSSV-((sum(lSSV))/(length(totalrow)))).^2) / (length(totalrow)) );
