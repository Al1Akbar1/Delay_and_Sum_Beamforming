clc;
clear all;
%% Initialize parameters
Fs=480000;
SoundVelocity=330;
MicDistance=0.05;
t=1:1/Fs:10;
AngleRange=179;
AngleOfRadiationDegree=90;
AngleOfRadiationRad=AngleOfRadiationDegree*pi/180;
f1=5;
f2=3500;
NumOfMicInRow=4;
NumOfMicInCol=1;
InputSignal=randn(1,numel(t));
%InputSignal=sin(2*pi*f2*t);
% figure(1)
% plot(InputSignal);

%% Signal generation
for i=1:NumOfMicInRow
    for j=1:NumOfMicInCol
        TempDelaySample=round(((i-1)*MicDistance*cos(AngleOfRadiationRad)/SoundVelocity+(j-1)*MicDistance*sin(AngleOfRadiationRad)/SoundVelocity)*Fs);
        TempInputSignal=circshift(InputSignal,TempDelaySample);
        RescivedSignal(i,j,1:numel(t))=TempInputSignal;
    end
end

%% Delay computing...
for Angle=1:AngleRange
    AngleR=Angle*pi/180;
    for i=1:NumOfMicInRow
        for j=1:NumOfMicInCol 
            AngleMicDelay(i,j,Angle)=round(Fs*(((i-1)*MicDistance*cos(AngleR)+(j-1)*MicDistance*sin(AngleR))/SoundVelocity));
        end
    end
end

%% Signal correction
Win1=2000;
Win2=1750;
for Angle=1:AngleRange
    SumOfSignals=zeros(1,Win2);
    for i=1:NumOfMicInRow
        for j=1:NumOfMicInCol
            for k=1:Win1
                TempSignal(k)=RescivedSignal(i,j,k);
            end
            CorrectSignal=circshift(TempSignal,-AngleMicDelay(i,j,Angle));
            Signal(1:Win2)=awgn(CorrectSignal(1:Win2),-5);
            SumOfSignals=Signal+SumOfSignals;
        end
    end
    SignalAverage=SumOfSignals/(NumOfMicInCol*NumOfMicInRow);
    SignalPower(Angle)=dot(SignalAverage,SignalAverage);
end

%% Finding angle
for i=1:AngleRange
    if max(SignalPower)==SignalPower(i)
        disp(i);
    end
end
figure(2)
plot(SignalPower);
