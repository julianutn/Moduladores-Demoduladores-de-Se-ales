% Modulacion/Demodulacion FSK. 
% Alumno: Villalba Julian. ajulianvillalba@gmail.com 
% Profesor: Eneas N. Morel

vec = [1,0,1,0,0,1];

xvec = length(vec);

fc = 200;
deltaf=100;
f1=fc-deltaf;
f2=fc+deltaf;
Amp=1;

Fs = 1/0.00001;

t = 0:1/Fs:xvec/10 - 1/Fs;

%% Impulsos Unipolar NRZ

    bits = [];
    for n=1:xvec
        if vec(n) == 0
            bit = zeros(1,100);
            bits = [bits bit];
 
        else vec(n) == 1
            bit = ones(1,100);
            bits = [bits bit];
           
        end        
    end
     

 %% Modulacion 
 mod = [];
 for k=1:xvec
       if vec(k)==1
           y=Amp*cos(2*pi*f1*t);
      
       else vec(k)==0
           y=Amp*cos(2*pi*f2*t);
         
       end
            mod = [mod y];
 end
 %mod=awgn(mod, 10);  %Meto ruido blanco
 %scatterplot(demof)   %Diagrama de constelaciones
%% Demodulacion
Fstop1 = 15;         % First Stopband Frequency
Fpass1 = f1 - 30 ;         % First Passband Frequency
Fpass2 = f1 + 30;        % Second Passband Frequency
Fstop2 = f1 + 200;        % Second Stopband Frequency
Astop1 = 60;          % First Stopband Attenuation (dB)
Apass  = 1;           % Passband Ripple (dB)
Astop2 = 80;          % Second Stopband Attenuation (dB)
match  = 'stopband';  % Band to match exactly

% Construct an FDESIGN object and call its BUTTER method.
h  = fdesign.bandpass(Fstop1, Fpass1, Fpass2, Fstop2, Astop1, Apass, ...
                      Astop2, Fs);
Hd = design(h, 'butter', 'MatchExactly', match);


demof = filter(Hd, mod);

xdemof = length(demof);


acu = 0;
count = 0;
DemoduladaR = [];

for n=1:xdemof+1  
    if (count == xdemof/xvec)
        count = 0;
        acu = (acu/(xdemof/xvec));
        if acu > 0.5
            bitdemo = ones(1,100);
            DemoduladaR = [DemoduladaR bitdemo];
        else 
            bitdemo = zeros(1,100);
            DemoduladaR = [DemoduladaR bitdemo];
            
        end
        acu = 0;
    end
    if n<=xdemof
        count = count + 1;
        acu = (acu + abs(demof(n)));
    end
end
 
%% Graficos
figure(1);
subplot(211)
plot(bits,'LineWidth',1.5)
title('Pulsos');
axis([0 100*xvec -Amp Amp]);

subplot(212)
plot(mod,'LineWidth',1.5);
grid on;
title('Modulada');
axis([0 36000 -Amp Amp]);

figure(2);
subplot(311)
plot(bits,'LineWidth',1.5)
title('Pulsos');
axis([0 100*xvec -Amp Amp]);
subplot(312)
plot(demof,'LineWidth',1.5);
title('Demodulacion FSK')
subplot(313) 
plot(DemoduladaR,'LineWidth',1.5);
title('Demodulacion FSK')


