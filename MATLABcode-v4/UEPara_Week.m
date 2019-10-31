function [n_UEs UE_location] = UEPara_Week(t)

x = 0;
y = 0;
time = 0;
    if(t<=120)
        time = rem(t, 24);
        if(time < 3 && time>=0)
              n_UEs = 40;
        elseif (time < 7 && time >= 3)
              n_UEs = 10;
        elseif (time < 8 && time >= 7)
              n_UEs = 40;
        elseif (time < 9 && time >= 8)
              n_UEs = 270;  
        elseif (time < 10 && time >= 9)
              n_UEs = 400;
        elseif (time < 11 && time >= 10)
              n_UEs = 500;
        elseif (time < 12 && time >= 11)
              n_UEs = 470;
        elseif (time < 13 && time >= 12)
              n_UEs = 435;
        elseif (time < 14 && time >= 13)
              n_UEs = 470;
        elseif (time < 15 && time >= 14)
              n_UEs = 315;
        elseif (time < 16 && time >= 15)
              n_UEs = 440;
        elseif (time < 17 && time >= 16)
              n_UEs = 365;
        else 
              n_UEs = 100;
        end
    elseif ((t<=128 && t<137) || (t<=140 && t>=138) || (t<=152 && t<161) || (t<=164 && t>=162))
        n_UEs = 100;
    elseif (t==137 || t==161)
        n_UEs = 150;
    elseif (t==141 || t==165)
        n_UEs = 200;
    else
        n_UEs = 40;
    end
    
        for j=1:n_UEs
                UE(j).x = 1000*rand(1,1);
                UE(j).y = 1000*rand(1,1);%generate the fbs location randomly, range: 0-1km
                x(j)= UE(j).x;
                y(j)= UE(j).y;
        end
    UE_location = [x; y];
%         figure;
%         plot(UE_location(1,:),UE_location(2,:),'*r');
%         hold on;
 end

