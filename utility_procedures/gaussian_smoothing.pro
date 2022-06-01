function gaussian_smoothing, im, ratio

  GNyq = .3
  N = 41
  fcut = 1./ratio
  st_dev = sqrt((N*(fcut/2))^2/(-2*alog(GNyq)))
  return, gauss_smooth(im, st_dev, WIDTH=N, /EDGE_Truncate)


end 