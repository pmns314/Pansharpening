function histogram_matching,Pan, Pan_smooth, I_L
  sigma_P = stddev(Pan_smooth)
  mu_P = mean(Pan_smooth)
  sigma_I = stddev(I_L)
  mu_I = mean(I_L)
  P_i = (Pan - mu_P) * (sigma_I/sigma_P) + mu_I
  return, P_i
end