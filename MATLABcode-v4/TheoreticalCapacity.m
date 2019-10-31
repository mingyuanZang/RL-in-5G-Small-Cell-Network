function Cap = TheoreticalCapacity(BW, sinr)

    Cap = BW * log2(1 + sinr);

end
