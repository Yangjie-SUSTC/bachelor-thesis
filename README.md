# Image processing MATLAB


## Image correction functions

### cell_seg.m

This MATLAB function used to divide pixels into cells or background, then segment foreground cells and singlet cells for fluorescent field images.

### BF_cell_seg.m

This MATLAB function used to divide pixels into cells or background, then segment foreground cells and singlet cells for bright field images.

### save_mask.m

This MATLAB function used to save the mask created by last function


## Image information getting function

### getFLUOinfo.m

This MATLAB function used to read data saved by image correction function and do statistics analysis, like mean value, std, for foreground cells and selected singlet cells. Finally save data as a structure.


## Image information visualization functions

### plot_sta.m

This MATLAB function used to configure figures save path and selected image evaluation indicator, then call next function to plot all figures.

### plot_cell_staresult.m

This MATLAB function is the specific plot function used to plot figures into specific path, these figures based on selected image evaluation indicator mentioned in main text part.

### plot_score.m

This MATLAB function is the specific plot function used to plot image score and output to input ratio figures into specific path.

### plot_sta_kcl.m

This MATLAB function used to configure figures save path and get fluorescent fading time, then call next function to plot all figures.

### plot_kcl.m

This MATLAB function is the specific plot function used to plot fluorescent intensity with different KCl concentration and do linear regression.



