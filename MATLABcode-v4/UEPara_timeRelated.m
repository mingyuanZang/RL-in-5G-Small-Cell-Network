function [n_UEs UE_location] = UEPara_timeRelated(t)

x = 0;
y = 0;
%  for t =1:1:600   
    if(t < 180 && t>=0)
          n_UEs(t) = 40;
    elseif (t < 420 && t >= 180)
          n_UEs(t) = 10;
    elseif (t < 480 && t >= 420)
          n_UEs(t) = 40;
    elseif (t < 540 && t >= 480)
          n_UEs(t) = 270;  
    elseif (t < 600 && t >= 540)
          n_UEs(t) = 400;
    elseif (t < 660 && t >= 600)
          n_UEs(t) = 500;
    elseif (t < 720 && t >= 660)
          n_UEs(t) = 470;
    elseif (t < 780 && t >= 720)
          n_UEs(t) = 435;
    elseif (t < 840 && t >= 780)
          n_UEs(t) = 470;
    elseif (t < 900 && t >= 840)
          n_UEs(t) = 315;
    elseif (t < 960 && t >= 900)
          n_UEs(t) = 440;
    elseif (t < 1080 && t >= 960)
          n_UEs(t) = 365;
    else 
          n_UEs(t) = 100;
    end
    
%     n_UEs(t) = random('Poisson',n_UEs(t));
    
    arrival_user(t)=random('Poisson',n_UEs(t)/2);
  if (t==1|| n_UEs(t)~=n_UEs(t-1))
        for j=1:n_UEs(t)
                UE(j).x = 3000*rand(1,1);
                UE(j).y = 3000*rand(1,1);%generate the fbs location randomly, range: 0-1km
                x(j)= UE(j).x;
                y(j)= UE(j).y;
        end
    UE_location{t} = [x; y];
  else
      UE_location{t} = UE_location{t-1};
      movingUser(t) = n_UEs(t)-arrival_user(t);
      for j=1:movingUser(t)
          UE(j).x = 800*rand(1,1);
                UE(j).y = 800*rand(1,1);
                 UE_location{t}(1, j) = UE_location{t}(1, j) + UE(j).x;
                 UE_location{t}(2, j) = UE_location{t}(2, j) + UE(j).y;         
      end
      
  end
%  end
%         figure;
%         plot(UE_location{420}(1,:),UE_location{420}(2,:),'or');
%        hold on;plot(UE_location{421}(1,:),UE_location{421}(2,:),'+b');
%         hold on;
 end

