function [n_UEs UE_location] = UEPara(t)

x = 0;
y = 0;
    
    if(t < 180 && t>=0)
          n_UEs = 40;
    elseif (t < 420 && t >= 180)
          n_UEs = 10;
    elseif (t < 480 && t >= 420)
          n_UEs = 40;
    elseif (t < 540 && t >= 480)
          n_UEs = 270;  
    elseif (t < 600 && t >= 540)
          n_UEs = 400;
    elseif (t < 660 && t >= 600)
          n_UEs = 500;
    elseif (t < 720 && t >= 660)
          n_UEs = 470;
    elseif (t < 780 && t >= 720)
          n_UEs = 435;
    elseif (t < 840 && t >= 780)
          n_UEs = 470;
    elseif (t < 900 && t >= 840)
          n_UEs = 315;
    elseif (t < 960 && t >= 900)
          n_UEs = 440;
    elseif (t < 1080 && t >= 960)
          n_UEs = 365;
    else 
          n_UEs = 100;
    end
    
    n_UEs = random('Poisson',n_UEs);
        for j=1:n_UEs
                UE(j).x = 3000*rand(1,1);
                UE(j).y = 3000*rand(1,1);%generate the fbs location randomly, range: 0-1km
                x(j)= UE(j).x;
                y(j)= UE(j).y;
        end
    UE_location = [x; y];
%         figure;
%         plot(UE_location(1,:),UE_location(2,:),'*r');
%         hold on;
 end

