function tpt = computeThroughput(n_FBSs, bw, sinr)
    
    for i=1:n_FBSs
%         [ sinr, PL ] = SINR_FBS( n_FBSs, f, FBS );
        tpt(i) = real(TheoreticalCapacity(bw, sinr(i))/1e6); % Mbps
    end
end