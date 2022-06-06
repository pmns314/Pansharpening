; +
; Procedure For handling Pansharpening through ENVI toolbar
;
;
; :Author: Paolo Mansi, Alessia Carbone, Nina Brolich
; -
pro menu_pansharpening, ev

  widget_control, ev.id, get_uvalue = uvalue
  mycustomchoice = uvalue
  
  
  ENVI_SELECT, fid = fid, pos = pos, dims = dims, title = "Select the Upscaled MS"
  if (fid[0] eq -1) then return
  envi_file_query, fid, fname=fname
  MS = read_tiff(fname)
  
  ENVI_SELECT, fid = fid, pos = pos, dims = dims, title = "Select the PAN"
  if (fid[0] eq -1) then return
  envi_file_query, fid, fname=fname
  PAN = read_tiff(fname)
  
  if (mycustomchoice eq 'BT') then begin
    base = widget_auto_base(title = 'Brovey Transform')

    wl = widget_slabel(base, prompt = 'Function: Brovey')
    sb = widget_base(base, /row, /frame)

    wp = widget_param(sb, prompt = 'Ratio', dt = 5, uvalue = 'value', /auto) 
    sb = widget_base(base, /row, /frame)
    
    wf = widget_outfm(sb, uvalue = 'outf', /auto)
    result = auto_wid_mng(base)
    
    
    if (result.accept eq 0) then return
    
    ratio = double(result.value)
    Brovey, PAN, MS, newdata, RATIO=ratio, /HAZE
 
    s = size(newdata, /dimensions)
    channels = s[0]
    newdata = transpose(newdata)
    for i=0, channels-1 do newdata[*,*,i]=rotate(newdata[*,*,i], -4)
    newdatadescrip = 'Output of Brovey Transform'
    
  endif

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;       Second function
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  if (mycustomchoice eq 'GS') then begin
    base = widget_auto_base(title = 'Gram Schmidt')

    wl = widget_slabel(base, prompt = 'Function: Gram Schmidt')
    sb = widget_base(base, /row, /frame)

    
    wf = widget_outfm(sb, uvalue = 'outf', /auto)
    result = auto_wid_mng(base)
    
    
    if (result.accept eq 0) then return
    
    GS, PAN, MS, newdata
 
    s = size(newdata, /dimensions)
    channels = s[0]
    newdata = transpose(newdata)
    for i=0, channels-1 do newdata[*,*,i]=rotate(newdata[*,*,i], -4)
    newdatadescrip = 'Output of Gram Schmidt'
  
  endif
  

  if (mycustomchoice eq 'GSA') then begin
    ENVI_SELECT, fid = fid, pos = pos, dims = dims, title = "Select the Low Resolution MS"
    if (fid[0] eq -1) then return
    envi_file_query, fid, fname=fname
    MS_LR = read_tiff(fname)

    base = widget_auto_base(title = 'Adaptive Gram Schmidt')

    wl = widget_slabel(base, prompt = 'Function: Adaptive Gram Schmidt')
    sb = widget_base(base, /row, /frame)

  
    wf = widget_outfm(sb, uvalue = 'outf', /auto)
    result = auto_wid_mng(base)
    
    
    if (result.accept eq 0) then return
    
    
    GSA, PAN, MS, MS_LR, newdata
 
    s = size(newdata, /dimensions)
    channels = s[0]
    newdata = transpose(newdata)
    for i=0, channels-1 do newdata[*,*,i]=rotate(newdata[*,*,i], -4)
    newdatadescrip = 'Output of Gram Schmidt'
  
  endif

 if (mycustomchoice eq 'GS_Segm') then begin
    ENVI_SELECT, fid = fid, pos = pos, dims = dims, title = "Select the Low Resolution MS"
    if (fid[0] eq -1) then return
    envi_file_query, fid, fname=fname
    MS_LR = read_tiff(fname)

    base = widget_auto_base(title = 'Adaptive Gram Schmidt')

    wl = widget_slabel(base, prompt = 'Function: Adaptive Gram Schmidt')
    sb = widget_base(base, /row, /frame)

    wp = widget_param(sb, prompt = 'Number Segments', dt = 5, uvalue = 'value', /auto) 
    sb = widget_base(base, /row, /frame)
  
    wf = widget_outfm(sb, uvalue = 'outf', /auto)
    result = auto_wid_mng(base)
    
    
    if (result.accept eq 0) then return
    
    n_segm = double(result.value)

    k_means,MS, segmented, N_SEGM=n_segm
    genLP, PAN, MS, MS_LR, I_LR_input
    gs_segm, MS, PAN, I_LR_input, segmented, newdata

 
    s = size(newdata, /dimensions)
    channels = s[0]
    newdata = transpose(newdata)
    for i=0, channels-1 do newdata[*,*,i]=rotate(newdata[*,*,i], -4)
    newdatadescrip = 'Output of Gram Schmidt'
  
  endif

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;       Save
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  if ((result.outf.in_memory) eq 1) then begin
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;  ENVI_ENTER_DATA enter image data from an array IDL into ENVI Classic memory
      ;  INPUT: Array 2D o 3D to enter into the memory. 
      ;  KEYWORDS:
      ;     1. DESCRIP: specifies a text description of the data, or of the type of processing performed.
      ;     ...
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      envi_enter_data, newdata, descrip = newdatadescrip
      
  endif else begin
      ; result.outf.name contains the path + the name of the save file entered by the user 
      filename = result.outf.name
      
      hdfid = hdf_sd_start(filename, /create)
      hdf_sd_attrset, hdfid, 'Description', newdatadescrip, /STRING

      varid = hdf_sd_create(hdfid, 'NewImage', [dims[2]+1,dims[4]+1], /INT)
      dimid = hdf_sd_dimgetid(varid, 0)
      hdf_sd_dimset, dimid, name='xdim '
      dimid = hdf_sd_dimgetid(varid, 1)
      hdf_sd_dimset, dimid, name='ydim '
      hdf_sd_adddata, varid, newdata
      hdf_sd_attrset, varid, 'Description', newdatadescrip, /STRING 
      hdf_sd_endaccess, varid
      
      hdf_sd_end, hdfid
            
  endelse
  
end
