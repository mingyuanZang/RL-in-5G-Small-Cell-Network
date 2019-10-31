function [n_UEs UE_location] = UEPara_day(t)

x = 0;
y = 0;
    
    if(t < 3 && t>=0)
          n_UEs = 40;
    elseif (t < 7 && t >= 3)
          n_UEs = 10;
    elseif (t < 8 && t >= 7)
          n_UEs = 40;
    elseif (t < 9 && t >= 8)
          n_UEs = 270;  
    elseif (t < 10 && t >= 9)
          n_UEs = 400;
    elseif (t < 11 && t >= 10)
          n_UEs = 500;
    elseif (t < 12 && t >= 11)
          n_UEs = 470;
    elseif (t < 13 && t >= 12)
          n_UEs = 435;
    elseif (t < 14 && t >= 13)
          n_UEs = 470;
    elseif (t < 15 && t >= 14)
          n_UEs = 315;
    elseif (t < 16 && t >= 15)
          n_UEs = 440;
    elseif (t < 17 && t >= 16)
          n_UEs = 365;
    else 
          n_UEs = 100;
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

