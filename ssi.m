g = uigetdir('C:\','Select folder with WAV files to analyse');
c = g;
c = [c '\'];
g = ['dir /b ' g '\*.wav'];
[s w1] =        system(g);
fnd =           find(double(w1)==10);
start_index =   1;
fid =           fopen('ssi.xls','a');

for i = 1:length(fnd)
 clear weiner prob;
 name =          w1(start_index:fnd(i)-1);
 start_index =   fnd(i)+1;
 % read the sound file
 [x fs] =  wavread([c name]);
 % FFT windows!
 %w =    hamming(100); %100 point hamming window
 %w =    100; %100 point rectangular window
 %w =    hamming(250); %250 point hamming window
 %w =    250; %250 point rectangular window
 %w =    hamming(500); %500 point hamming window
 %w =    500; %500 point rectangular window
 w =    hamming(fs/50); %vary the hamming window length according to fs
 %w =    fs/50;%vary the rectangular window length according to fs
 %w =    hamming(fs/100); %vary the hamming window length according to fs
 %w =    fs/100;%vary the rectangular window length according to fs
 nfft = 1042;
 spgm = specgram(x,nfft,fs,w);
 
 if(find(spgm == 0))
     [row col] =     find(spgm == 0);
      spgm(row,col)= eps;
 end

  y = abs(spgm).^2;
  mp = y;
  column_power = sum(mp);
  for i = 1:size(mp,2)
      prob(:,i) = mp(:,i)/column_power(i);
  end
  
  [R,C] = size(prob);
  
  for z = 1:C
      for j = R:-1:1
          if (prob(j,z)>.0001)              
              weiner(z) = sum(log(prob(1:j,z))/j)-log(sum(prob(1:j,z))/j); %calculate weiner/SFM for that 'window'  
             break;
          end
      end
  end
  
  plot(weiner,'k');
  figure(2);
  %print('-djpeg',[name,' - SSI.jpeg']);
  specgram(x,nfft,fs,w);
   
  wmean =  mean(weiner); %mean SFM/weiner entropy across windows
  wstd =   std(weiner); %the standard deviation of the SFMs/weiner entropy across windows
  wratio = wstd/wmean;
  ssv =    var(weiner); %effectively the same as = sum( ((weiner-((sum(weiner))/(length(weiner)))).^2) / (length(weiner)) );
      
  fprintf(fid,'%s\t %4.4f\t %4.4f\t %4.4f\t %4.4f\n',name,wmean,wstd,wratio,ssv); %doesn't add column headings!
end

fclose('all');