function [BS_location BS] = BaseStationPara( x, y, MPTdBm )

BS.PTdBm = MPTdBm;
BS.BW = 20e6;
BS.x = x;
BS.y = y;
BS_location =  [BS.x; BS.y];
end

