function scale, im
  return, 255 * ((im - min(im))/(max(im)-min(im)))

end