% Modulacion/Demodulacion PSK. Se agrega ruido y se ve el diagrama de
% constelaciones
% Alumno: Villalba Julian. ajulianvillalba@gmail.com 
% Profesor: Eneas N. Morel
vec = [0,0,1,0,1,1,1,1,0,0];

x = length(vec);

ph=pi/2;
Amp=1;
fc=80;
Fs = 1/0.00001;

t = 0:1/Fs:x/100 - 1/Fs;

%% Impulsos Unipolar NRZ

    bits = [];
    for n=1:x
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
 for k=1:x
       if vec(k)==1
           y=Amp*cos(2*pi*fc*t);
      
       else vec(k)==0
           y=Amp*cos(2*pi*fc*t + ph);
         
       end
            mod = [mod y];
 end
 %mod=awgn(mod, 10);  %Meto ruido blanco

%% Demodulacion
t2=0:1/Fs:length(mod)/100000 - 1/Fs;
xmod=length(mod);
muestras=xmod/x;
vdemo=[];
for l=1:muestras:xmod           %By Tomas
   if mod(l)>0.1
       bit = ones(1,100);       
       vdemo= [vdemo bit];      
   else                         
        bit = zeros(1,100);
        vdemo = [vdemo bit];
   end
end


 scatterplot(vdemo);grid on; %Diagrama de constelaciones
 title('Diagrama de Constelaciones')
%% Graficos

figure(1)
subplot(311)
plot(bits,'LineWidth',1.5)
title('Pulsos');
axis([0 100*x -Amp Amp]);

subplot(312)
plot(mod,'LineWidth',1.5)
title('Modulacion PSK');
axis([0 36000 -Amp Amp]);
subplot(313)
plot(vdemo,'LineWidth',1.5)
title('Demodulacion PSK');
axis([0 100*x -Amp Amp]);


