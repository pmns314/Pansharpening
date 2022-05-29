pro save_image, filename, im
  file_delete, filename, /ALLOW_NONEXISTENT
  WRITE_tiff,filename,im, /double
end