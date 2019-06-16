%dirname = uigetdir('C:\','Select folder with WAV files to analyse');
files = dir('*wav');
HNR =   textread('HNR-results.txt', '%s');

% do analyses and plots
for i=1:numel(files);
    %
    % start analyses
    %
    
    % load & read file
    name =      files(i).name;
    [wave,fs] = wavread(name);
    x =         wave;

    % use Higuchi method to estimate FD of the wave
    fd =        higuchi(x);
    
    % use NLD method to estimate FD of the wave
    nldfd =     nld(x);
    
    % compute SFM/Wiener entropy
    [lSFM,SSV] = sfm_ssi(x);
    
    % get HNR from Praat output file
    id =        find(cellfun(@(o) isequal(o, name), HNR));
    thisHNR =   HNR{id+1};
    writeHNR =  HNR(id+1);
    
    % write out of loop
    nameOut(i) =    {name};
    fdOut(i) =      fd;
    nldfdOut(i) =   nldfd;
    sfmOut(i) =     lSFM;
    ssvOut(i) =     SSV;
    hnrOut(i) =     writeHNR;
    
    %
    % start plots
    % (inefficient at the moment, sorry)
    %
    %
%     % plot waveform
%     t = 0:1/fs:(length(wave)-1)/fs;
%     plot(t,wave);
%     xlabel('Time (sec)','FontSize',16);
%     ylabel('Amplitude (dB)','FontSize',16);
%     title([name,' - waveform'],'FontSize',20);
%     ylim=get(gca,'YLim');
%     xlim=get(gca,'XLim');
%     text(xlim(2),ylim(2),{'FD=',fd,'','SFM=',lSFM,'','SSV=',SSV,'','HNR=',thisHNR},...
%     'VerticalAlignment','top',...
%     'HorizontalAlignment','left');
%     print('-djpeg',[name,' - waveform.jpeg']); % saves waveform as jpeg image w/ it's filename
% 
%     % plot fft
%     x =     wave;
%     nfft =  2^(nextpow2(length(x))); % use the next highest power of 2 greater than or equal to length(x) to calculate fft
%     fftx =  fft(x,nfft); % take fft, padding with zeros so that length(fftx) is equal to nfft 
%     NumUniquePts = ceil((nfft+1)/2);
%     fftx =  fftx(1:NumUniquePts); % fft is symmetric, throw away second half 
%     mx =    abs(fftx)/length(x);
%     mx =    mx.^2;
%     if rem(nfft, 2) % exclude Nyquist point
%       mx(2:end)=mx(2:end)*2;
%     else
%       mx(2:end-1)=mx(2:end -1)*2;
%     end
%     % multiply mx by 2 to correct energy
%     f =     (0:NumUniquePts-1)*fs/nfft;
%     plot(f,mx); % plots fft
%     xlabel('Frequency (Hz)','FontSize',16);
%     ylabel('Power','FontSize',16);
%     title([name,' - fourier transform'],'FontSize',20);
%     ylim=get(gca,'YLim');
%     xlim=get(gca,'XLim');
%     text(xlim(2),ylim(2),{'FD=',fd,'','SFM=',lSFM,'','SSV=',SSV,'','HNR=',thisHNR},...
%     'VerticalAlignment','top',...
%     'HorizontalAlignment','left');
%     print('-djpeg',[name,' - fourier transform.jpeg']); % saves fft as jpeg image w/ it's filename
% 
%     % plot spectrogram
%     spectrogram(x,256,128,nfft,fs);
%     view(-90,90);
%     set(gca,'ydir','reverse');
%     title([name,' - spectrogram'],'FontSize',20);
%     ylabel('Time (sec)','FontSize',16);
%     xlabel('Frequency (Hz)','FontSize',16);
%     ylim=get(gca,'YLim');
%     xlim=get(gca,'XLim');
%     text(xlim(2),ylim(2),{'FD=',fd,'','SFM=',lSFM,'','SSV=',SSV,'','HNR=',thisHNR},...
%     'VerticalAlignment','top',...
%     'HorizontalAlignment','left');
%     print('-djpeg',[name,' - spectrogram.jpeg']); % saves spectrogram as jpeg image w/ it's filename
%     
end;

% write results out to excel
xlswrite('Results.xlsx',{'Name'},1,'A1');
xlswrite('Results.xlsx',nameOut,1,'B1');
xlswrite('Results.xlsx',{'HFD'},1,'A2');
xlswrite('Results.xlsx',fdOut,1,'B2');
xlswrite('Results.xlsx',{'NLDFD'},1,'A3');
xlswrite('Results.xlsx',nldfdOut,1,'B3');
xlswrite('Results.xlsx',{'SFM'},1,'A4');
xlswrite('Results.xlsx',sfmOut, 1, 'B4');
xlswrite('Results.xlsx',{'SSI'},1,'A5');
xlswrite('Results.xlsx',ssvOut,1,'B5');
xlswrite('Results.xlsx',{'HNR'},1,'A6');
xlswrite('Results.xlsx',hnrOut,1,'B6');