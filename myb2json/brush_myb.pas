{
  https://github.com/yapcheahshen/brushlib.js
}

unit brush_myb;

interface
uses classes,sysutils,brush_mapping;
const
   BRUSH_UNKNOWN=-1;
   BRUSH_OPAQUE=0;
   BRUSH_opaque_multiply=1;
   BRUSH_opaque_linearize=2;
   BRUSH_radius_logarithmic=3;
   BRUSH_hardness=4;
   BRUSH_dabs_per_basic_radius=5;
   BRUSH_dabs_per_actual_radius=6;
   BRUSH_dabs_per_second=7;
   BRUSH_radius_by_random=8;
   BRUSH_speed1_slowness=9;
   BRUSH_speed2_slowness=10;
   BRUSH_speed1_gamma=11;
   BRUSH_speed2_gamma=12;
   BRUSH_offset_by_random=13;
   BRUSH_offset_by_speed=14;
   BRUSH_offset_by_speed_slowness=15;
   BRUSH_slow_tracking=16;
   BRUSH_slow_tracking_per_dab=17;
   BRUSH_tracking_noise=18;
   BRUSH_color_h=19;
   BRUSH_color_s=20;
   BRUSH_color_v=21;
   BRUSH_change_color_h=22;
   BRUSH_change_color_l=23;
   BRUSH_change_color_hsl_s=24;

   BRUSH_change_color_v=25;
   BRUSH_change_color_hsv_s=26;
   BRUSH_smudge=27;
   BRUSH_smudge_length=28;
   BRUSH_smudge_radius_log=29;
   BRUSH_eraser=30;

   BRUSH_stroke_threshold=31;
   BRUSH_stroke_duration_logarithmic=32;
   BRUSH_stroke_holdtime=33;
   BRUSH_custom_input=34;
   BRUSH_custom_input_slowness=35;
   BRUSH_elliptical_dab_ratio=36;
   BRUSH_elliptical_dab_angle=37;
   BRUSH_direction_filter=38;

   BRUSH_version = 39;

   BRUSH_SETTINGS_COUNT=40;

   BRUSH_adapt_color_from_image = 1000;
   BRUSH_change_radius = 1001;
   BRUSH_group = 1002;


  (*
    ['opaque', _('Opacity'), False, 0.0, 1.0, 2.0, _("0 means brush is transparent, 1 fully visible\n(also known als alpha or opacity)")],
    ['opaque_multiply', _('Opacity multiply'), False, 0.0, 0.0, 2.0, _("This gets multiplied with opaque. You should only change the pressure input of this setting. Use 'opaque' instead to make opacity depend on speed.\nThis setting is responsible to stop painting when there is zero pressure. This is just a convention, the behaviour is identical to 'opaque'.")],
    ['opaque_linearize', _('Opacity linearize'), True, 0.0, 0.9, 2.0, _("Correct the nonlinearity introduced by blending multiple dabs on top of each other. This correction should get you a linear (\"natural\") pressure response when pressure is mapped to opaque_multiply, as it is usually done. 0.9 is good for standard strokes, set it smaller if your brush scatters a lot, or higher if you use dabs_per_second.\n0.0 the opaque value above is for the individual dabs\n1.0 the opaque value above is for the final brush stroke, assuming each pixel gets (dabs_per_radius*2) brushdabs on average during a stroke")],
    ['radius_logarithmic', _('Radius'), False, -2.0, 2.0, 5.0, _("basic brush radius (logarithmic)\n 0.7 means 2 pixels\n 3.0 means 20 pixels")],
    ['hardness', _('Hardness'), False, 0.0, 0.8, 1.0, _("hard brush-circle borders (setting to zero will draw nothing)")],
    ['dabs_per_basic_radius', _('Dabs per basic radius'), True, 0.0, 0.0, 6.0, _("how many dabs to draw while the pointer moves a distance of one brush radius (more precise: the base value of the radius)")],
    ['dabs_per_actual_radius', _('Dabs per actual radius'), True, 0.0, 2.0, 6.0, _("same as above, but the radius actually drawn is used, which can change dynamically")],
    ['dabs_per_second', _('Dabs per second'), True, 0.0, 0.0, 80.0, _("dabs to draw each second, no matter how far the pointer moves")],
    ['radius_by_random', _('Radius by random'), False, 0.0, 0.0, 1.5, _("Alter the radius randomly each dab. You can also do this with the by_random input on the radius setting. If you do it here, there are two differences:\n1) the opaque value will be corrected such that a big-radius dabs is more transparent\n2) it will not change the actual radius seen by dabs_per_actual_radius")],
    ['speed1_slowness', _('Fine speed filter'), False, 0.0, 0.04, 0.2, _("how slow the input fine speed is following the real speed\n0.0 change immediately as your speed changes (not recommended, but try it)")],
    ['speed2_slowness', _('Gross speed filter'), False, 0.0, 0.8, 3.0, _("same as 'fine speed filter', but note that the range is different")],
    ['speed1_gamma', _('Fine speed gamma'), True, -8.0, 4.0, 8.0, _("This changes the reaction of the 'fine speed' input to extreme physical speed. You will see the difference best if 'fine speed' is mapped to the radius.\n-8.0 very fast speed does not increase 'fine speed' much more\n+8.0 very fast speed increases 'fine speed' a lot\nFor very slow speed the opposite happens.")],
    ['speed2_gamma', _('Gross speed gamma'), True, -8.0, 4.0, 8.0, _("same as 'fine speed gamma' for gross speed")],
    ['offset_by_random', _('Jitter'), False, 0.0, 0.0, 2.0, _("add a random offset to the position where each dab is drawn\n 0.0 disabled\n 1.0 standard deviation is one basic radius away\n<0.0 negative values produce no jitter")],
    ['offset_by_speed', _('Offset by speed'), False, -3.0, 0.0, 3.0, _("change position depending on pointer speed\n= 0 disable\n> 0 draw where the pointer moves to\n< 0 draw where the pointer comes from")],
    ['offset_by_speed_slowness', _('Offset by speed filter'), False, 0.0, 1.0, 15.0, _("how slow the offset goes back to zero when the cursor stops moving")],
    ['slow_tracking', _('Slow position tracking'), True, 0.0, 0.0, 10.0, _("Slowdown pointer tracking speed. 0 disables it, higher values remove more jitter in cursor movements. Useful for drawing smooth, comic-like outlines.")],
    ['slow_tracking_per_dab', _('Slow tracking per dab'), False, 0.0, 0.0, 10.0, _("Similar as above but at brushdab level (ignoring how much time has past, if brushdabs do not depend on time)")],
    ['tracking_noise', _('Tracking noise'), True, 0.0, 0.0, 12.0, _("add randomness to the mouse pointer; this usually generates many small lines in random directions; maybe try this together with 'slow tracking'")],

    ['color_h', _('Color hue'), True, 0.0, 0.0, 1.0, _("color hue")],
    ['color_s', _('Color saturation'), True, -0.5, 0.0, 1.5, _("color saturation")],
    ['color_v', _('Color value'), True, -0.5, 0.0, 1.5, _("color value (brightness, intensity)")],
    ['change_color_h', _('Change color hue'), False, -2.0, 0.0, 2.0, _("Change color hue.\n-0.1 small clockwise color hue shift\n 0.0 disable\n 0.5 counterclockwise hue shift by 180 degrees")],
    ['change_color_l', _('Change color lightness (HSL)'), False, -2.0, 0.0, 2.0, _("Change the color lightness (luminance) using the HSL color model.\n-1.0 blacker\n 0.0 disable\n 1.0 whiter")],
    ['change_color_hsl_s', _('Change color satur. (HSL)'), False, -2.0, 0.0, 2.0, _("Change the color saturation using the HSL color model.\n-1.0 more grayish\n 0.0 disable\n 1.0 more saturated")],
    ['change_color_v', _('Change color value (HSV)'), False, -2.0, 0.0, 2.0, _("Change the color value (brightness, intensity) using the HSV color model. HSV changes are applied before HSL.\n-1.0 darker\n 0.0 disable\n 1.0 brigher")],
    ['change_color_hsv_s', _('Change color satur. (HSV)'), False, -2.0, 0.0, 2.0, _("Change the color saturation using the HSV color model. HSV changes are applied before HSL.\n-1.0 more grayish\n 0.0 disable\n 1.0 more saturated")],
    ['smudge', _('Smudge'), False, 0.0, 0.0, 1.0, _("Paint with the smudge color instead of the brush color. The smudge color is slowly changed to the color you are painting on.\n 0.0 do not use the smudge color\n 0.5 mix the smudge color with the brush color\n 1.0 use only the smudge color")],
    ['smudge_length', _('Smudge length'), False, 0.0, 0.5, 1.0, _("This controls how fast the smudge color becomes the color you are painting on.\n0.0 immediately change the smudge color\n1.0 never change the smudge color")],
    ['smudge_radius_log', _('Smudge radius'), False, -1.6, 0.0, 1.6, _("This modifies the radius of the circle where color is picked up for smudging.\n 0.0 use the brush radius \n-0.7 half the brush radius\n+0.7 twice the brush radius\n+1.6 five times the brush radius (slow)")],
    ['eraser', _('Eraser'), False, 0.0, 0.0, 1.0, _("how much this tool behaves like an eraser\n 0.0 normal painting\n 1.0 standard eraser\n 0.5 pixels go towards 50% transparency")],

    ['stroke_threshold', _('Stroke threshold'), True, 0.0, 0.0, 0.5, _("How much pressure is needed to start a stroke. This affects the stroke input only. Mypaint does not need a minimal pressure to start drawing.")],
    ['stroke_duration_logarithmic', _('Stroke duration'), False, -1.0, 4.0, 7.0, _("How far you have to move until the stroke input reaches 1.0. This value is logarithmic (negative values will not inverse the process).")],
    ['stroke_holdtime', _('Stroke hold time'), False, 0.0, 0.0, 10.0, _("This defines how long the stroke input stays at 1.0. After that it will reset to 0.0 and start growing again, even if the stroke is not yet finished.\n2.0 means twice as long as it takes to go from 0.0 to 1.0\n9.9 and bigger stands for infinite")],
    ['custom_input', _('Custom input'), False, -5.0, 0.0, 5.0, _("Set the custom input to this value. If it is slowed down, move it towards this value (see below). The idea is that you make this input depend on a mixture of pressure/speed/whatever, and then make other settings depend on this 'custom input' instead of repeating this combination everywhere you need it.\nIf you make it change 'by random' you can generate a slow (smooth) random input.")],
    ['custom_input_slowness', _('Custom input filter'), False, 0.0, 0.0, 10.0, _("How slow the custom input actually follows the desired value (the one above). This happens at brushdab level (ignoring how much time has past, if brushdabs do not depend on time).\n0.0 no slowdown (changes apply instantly)")],

    ['elliptical_dab_ratio', _('Elliptical dab: ratio'), False, 1.0, 1.0, 10.0, _("aspect ratio of the dabs; must be >= 1.0, where 1.0 means a perfectly round dab. TODO: linearize? start at 0.0 maybe, or log?")],
    ['elliptical_dab_angle', _('Elliptical dab: angle'), False, 0.0, 90.0, 180.0, _("this defines the angle by which eliptical dabs are tilted\n 0.0 horizontal dabs\n 45.0 45 degrees, turned clockwise\n 180.0 horizontal again")],
    ['direction_filter', _('Direction filter'), False, 0.0, 2.0, 10.0, _("a low value will make the direction input adapt more quickly, a high value will make it smoother")],
*)

   STATE_X=0;
   STATE_Y=1;
   STATE_PRESSURE=2;
   STATE_dist=3;
   STATE_actual_radius=4;
   STATE_smudge_ra=5;
   STATE_smudge_ga=6;
   STATE_smudge_ba=7;
   STATE_smudge_a=8;
   STATE_actual_x=9;
   STATE_actual_y=10;
   STATE_norm_dx_slow=11;
   STATE_norm_dy_slow=12;
   STATE_norm_speed1_slow=13;
   STATE_norm_speed2_slow=14;
   STATE_stroke=15;
   STATE_stroke_started=16;
   STATE_custom_input=17;
   STATE_rng_seed=18;
   STATE_actual_elliptical_dab_ratio=19;
   STATE_actual_elliptical_dab_angle=20;
   STATE_direction_dx=21;
   STATE_direction_dy=22;
   STATE_declination=23;
   STATE_ascension=24;

  BRUSH_STATE_COUNT = 25;



   INPUT_UNKNOWN=-1;
   INPUT_pressure=0;
   INPUT_speed1=1;
   INPUT_speed2=2;
   INPUT_random=3;
   INPUT_stroke=4;
   INPUT_direction=5;
   INPUT_tilt_declination=6;
   INPUT_tilt_ascension=7;
   INPUT_custom=8;
   BRUSH_INPUT_COUNT=9;

(*
    ['pressure', 0.0,  0.0,  0.4,  1.0, 1.0,  _("Pressure"), _("The pressure reported by the tablet, between 0.0 and 1.0. If you use the mouse, it will be 0.5 when a button is pressed and 0.0 otherwise.")],
    ['speed1',   None, 0.0,  0.5,  4.0, None, _("Fine speed"), _("How fast you currently move. This can change very quickly. Try 'print input values' from the 'help' menu to get a feeling for the range; negative values are rare but possible for very low speed.")],
    ['speed2',   None, 0.0,  0.5,  4.0, None, _("Gross speed"), _("Same as fine speed, but changes slower. Also look at the 'gross speed filter' setting.")],
    ['random',   0.0,  0.0,  0.5,  1.0, 1.0, _("Random"), _("Fast random noise, changing at each evaluation. Evenly distributed between 0 and 1.")],
    ['stroke',   0.0,  0.0,  0.5,  1.0, 1.0, _("Stroke"), _("This input slowly goes from zero to one while you draw a stroke. It can also be configured to jump back to zero periodically while you move. Look at the 'stroke duration' and 'stroke hold time' settings.")],
    ['direction',0.0,  0.0,  0.0,  180.0, 180.0, _("Direction"), _("The angle of the stroke, in degrees. The value will stay between 0.0 and 180.0, effectively ignoring turns of 180 degrees.")],
    ['tilt_declination',0.0,  0.0,  0.0,  90.0, 90.0,  _("Declination"), _("Declination of stylus tilt. 0 when stylus is parallel to tablet and 90.0 when it's perpendicular to tablet.")],
    ['tilt_ascension',-180.0,  -180.0,  0.0,  180.0, 180.0, _("Ascension"),  _("Right ascension of stylus tilt. 0 when stylus working end points to you, +90 when rotated 90 degrees clockwise, -90 when rotated 90 degrees counterclockwise.")],
    #['motion_strength',0.0,0.0,  0.0,  1.0, 1.0,  "[EXPERIMENTAL] Same as angle, but wraps at 180 degrees. The dynamics are shared with BRUSH_OFFSET_BY_SPEED_FILTER (FIXME: which is a bad thing)."],
    ['custom',   None,-2.0,  0.0, +2.0, None, _("Custom"), _("This is a user defined input. Look at the 'custom input' setting for details.")],
    ]
*)

procedure readmyb( myb:TStrings; var mapping:array  of TMyBrushmapping);
procedure defaultvalues(var mapping:array  of TMyBrushmapping);
function name2setting(name:string):integer;
function setting2name(s:integer):string;
function name2input(name:string):integer;
function input2name(i:integer):string;

(*
    ['opaque', _('Opacity'), False, 0.0, 1.0, 2.0, _("0 means brush is transparent, 1 fully visible\n(also known als alpha or opacity)")],
    ['opaque_multiply', _('Opacity multiply'), False, 0.0, 0.0, 2.0, _("This gets multiplied with opaque. You should only change the pressure input of this setting. Use 'opaque' instead to make opacity depend on speed.\nThis setting is responsible to stop painting when there is zero pressure. This is just a convention, the behaviour is identical to 'opaque'.")],
    ['opaque_linearize', _('Opacity linearize'), True, 0.0, 0.9, 2.0, _("Correct the nonlinearity introduced by blending multiple dabs on top of each other. This correction should get you a linear (\"natural\") pressure response when pressure is mapped to opaque_multiply, as it is usually done. 0.9 is good for standard strokes, set it smaller if your brush scatters a lot, or higher if you use dabs_per_second.\n0.0 the opaque value above is for the individual dabs\n1.0 the opaque value above is for the final brush stroke, assuming each pixel gets (dabs_per_radius*2) brushdabs on average during a stroke")],
    ['radius_logarithmic', _('Radius'), False, -2.0, 2.0, 5.0, _("basic brush radius (logarithmic)\n 0.7 means 2 pixels\n 3.0 means 20 pixels")],
    ['hardness', _('Hardness'), False, 0.0, 0.8, 1.0, _("hard brush-circle borders (setting to zero will draw nothing)")],
    ['dabs_per_basic_radius', _('Dabs per basic radius'), True, 0.0, 0.0, 6.0, _("how many dabs to draw while the pointer moves a distance of one brush radius (more precise: the base value of the radius)")],
    ['dabs_per_actual_radius', _('Dabs per actual radius'), True, 0.0, 2.0, 6.0, _("same as above, but the radius actually drawn is used, which can change dynamically")],
    ['dabs_per_second', _('Dabs per second'), True, 0.0, 0.0, 80.0, _("dabs to draw each second, no matter how far the pointer moves")],
    ['radius_by_random', _('Radius by random'), False, 0.0, 0.0, 1.5, _("Alter the radius randomly each dab. You can also do this with the by_random input on the radius setting. If you do it here, there are two differences:\n1) the opaque value will be corrected such that a big-radius dabs is more transparent\n2) it will not change the actual radius seen by dabs_per_actual_radius")],
    ['speed1_slowness', _('Fine speed filter'), False, 0.0, 0.04, 0.2, _("how slow the input fine speed is following the real speed\n0.0 change immediately as your speed changes (not recommended, but try it)")],
    ['speed2_slowness', _('Gross speed filter'), False, 0.0, 0.8, 3.0, _("same as 'fine speed filter', but note that the range is different")],
    ['speed1_gamma', _('Fine speed gamma'), True, -8.0, 4.0, 8.0, _("This changes the reaction of the 'fine speed' input to extreme physical speed. You will see the difference best if 'fine speed' is mapped to the radius.\n-8.0 very fast speed does not increase 'fine speed' much more\n+8.0 very fast speed increases 'fine speed' a lot\nFor very slow speed the opposite happens.")],
    ['speed2_gamma', _('Gross speed gamma'), True, -8.0, 4.0, 8.0, _("same as 'fine speed gamma' for gross speed")],
    ['offset_by_random', _('Jitter'), False, 0.0, 0.0, 2.0, _("add a random offset to the position where each dab is drawn\n 0.0 disabled\n 1.0 standard deviation is one basic radius away\n<0.0 negative values produce no jitter")],
    ['offset_by_speed', _('Offset by speed'), False, -3.0, 0.0, 3.0, _("change position depending on pointer speed\n= 0 disable\n> 0 draw where the pointer moves to\n< 0 draw where the pointer comes from")],
    ['offset_by_speed_slowness', _('Offset by speed filter'), False, 0.0, 1.0, 15.0, _("how slow the offset goes back to zero when the cursor stops moving")],
    ['slow_tracking', _('Slow position tracking'), True, 0.0, 0.0, 10.0, _("Slowdown pointer tracking speed. 0 disables it, higher values remove more jitter in cursor movements. Useful for drawing smooth, comic-like outlines.")],
    ['slow_tracking_per_dab', _('Slow tracking per dab'), False, 0.0, 0.0, 10.0, _("Similar as above but at brushdab level (ignoring how much time has past, if brushdabs do not depend on time)")],
    ['tracking_noise', _('Tracking noise'), True, 0.0, 0.0, 12.0, _("add randomness to the mouse pointer; this usually generates many small lines in random directions; maybe try this together with 'slow tracking'")],

    ['color_h', _('Color hue'), True, 0.0, 0.0, 1.0, _("color hue")],
    ['color_s', _('Color saturation'), True, -0.5, 0.0, 1.5, _("color saturation")],
    ['color_v', _('Color value'), True, -0.5, 0.0, 1.5, _("color value (brightness, intensity)")],
    ['change_color_h', _('Change color hue'), False, -2.0, 0.0, 2.0, _("Change color hue.\n-0.1 small clockwise color hue shift\n 0.0 disable\n 0.5 counterclockwise hue shift by 180 degrees")],
    ['change_color_l', _('Change color lightness (HSL)'), False, -2.0, 0.0, 2.0, _("Change the color lightness (luminance) using the HSL color model.\n-1.0 blacker\n 0.0 disable\n 1.0 whiter")],
    ['change_color_hsl_s', _('Change color satur. (HSL)'), False, -2.0, 0.0, 2.0, _("Change the color saturation using the HSL color model.\n-1.0 more grayish\n 0.0 disable\n 1.0 more saturated")],
    ['change_color_v', _('Change color value (HSV)'), False, -2.0, 0.0, 2.0, _("Change the color value (brightness, intensity) using the HSV color model. HSV changes are applied before HSL.\n-1.0 darker\n 0.0 disable\n 1.0 brigher")],
    ['change_color_hsv_s', _('Change color satur. (HSV)'), False, -2.0, 0.0, 2.0, _("Change the color saturation using the HSV color model. HSV changes are applied before HSL.\n-1.0 more grayish\n 0.0 disable\n 1.0 more saturated")],
    ['smudge', _('Smudge'), False, 0.0, 0.0, 1.0, _("Paint with the smudge color instead of the brush color. The smudge color is slowly changed to the color you are painting on.\n 0.0 do not use the smudge color\n 0.5 mix the smudge color with the brush color\n 1.0 use only the smudge color")],
    ['smudge_length', _('Smudge length'), False, 0.0, 0.5, 1.0, _("This controls how fast the smudge color becomes the color you are painting on.\n0.0 immediately change the smudge color\n1.0 never change the smudge color")],
    ['smudge_radius_log', _('Smudge radius'), False, -1.6, 0.0, 1.6, _("This modifies the radius of the circle where color is picked up for smudging.\n 0.0 use the brush radius \n-0.7 half the brush radius\n+0.7 twice the brush radius\n+1.6 five times the brush radius (slow)")],
    ['eraser', _('Eraser'), False, 0.0, 0.0, 1.0, _("how much this tool behaves like an eraser\n 0.0 normal painting\n 1.0 standard eraser\n 0.5 pixels go towards 50% transparency")],

    ['stroke_threshold', _('Stroke threshold'), True, 0.0, 0.0, 0.5, _("How much pressure is needed to start a stroke. This affects the stroke input only. Mypaint does not need a minimal pressure to start drawing.")],
    ['stroke_duration_logarithmic', _('Stroke duration'), False, -1.0, 4.0, 7.0, _("How far you have to move until the stroke input reaches 1.0. This value is logarithmic (negative values will not inverse the process).")],
    ['stroke_holdtime', _('Stroke hold time'), False, 0.0, 0.0, 10.0, _("This defines how long the stroke input stays at 1.0. After that it will reset to 0.0 and start growing again, even if the stroke is not yet finished.\n2.0 means twice as long as it takes to go from 0.0 to 1.0\n9.9 and bigger stands for infinite")],
    ['custom_input', _('Custom input'), False, -5.0, 0.0, 5.0, _("Set the custom input to this value. If it is slowed down, move it towards this value (see below). The idea is that you make this input depend on a mixture of pressure/speed/whatever, and then make other settings depend on this 'custom input' instead of repeating this combination everywhere you need it.\nIf you make it change 'by random' you can generate a slow (smooth) random input.")],
    ['custom_input_slowness', _('Custom input filter'), False, 0.0, 0.0, 10.0, _("How slow the custom input actually follows the desired value (the one above). This happens at brushdab level (ignoring how much time has past, if brushdabs do not depend on time).\n0.0 no slowdown (changes apply instantly)")],

    ['elliptical_dab_ratio', _('Elliptical dab: ratio'), False, 1.0, 1.0, 10.0, _("aspect ratio of the dabs; must be >= 1.0, where 1.0 means a perfectly round dab. TODO: linearize? start at 0.0 maybe, or log?")],
    ['elliptical_dab_angle', _('Elliptical dab: angle'), False, 0.0, 90.0, 180.0, _("this defines the angle by which eliptical dabs are tilted\n 0.0 horizontal dabs\n 45.0 45 degrees, turned clockwise\n 180.0 horizontal again")],
    ['direction_filter', _('Direction filter'), False, 0.0, 2.0, 10.0, _("a low value will make the direction input adapt more quickly, a high value will make it smoother")],
    ]
*)
implementation

// name is seperated by space, return name and the remaining
function fetchname(const s:string;var token:string):string;
var
  p:integer;
begin
  result:=trim(s);
  p:=pos(' ',result);
  if p>0 then begin
    token:=copy(result,1,p-1);
    result:=copy(result,p+1,length(result));
  end else begin
    token:=result;
    result:='';
  end;
end;

procedure stringlist_splitby(sl:tstringlist;c:char;input:string);
var
  s:string;
  p:pchar;
begin
  sl.clear;
  p:=pchar(input);
  s:='';
  while p^<>#0 do begin
    if p^=c then begin
      sl.add(s);
      s:='';
    end else begin
      s:=s+p^;
    end;
    inc(p);
  end;
  sl.add(s);

end;

procedure readmyb_controlpoints(st:string; pmapping: PMybrushmapping);
var
  sl, sl2:tstringlist;
  i,j,ip,p:integer;
  name,s,s2:string;
  x,y:single;
begin
  sl:=tstringlist.create;
  stringlist_splitby(sl,'|',st);
  sl2:=tstringlist.create;

  for i:=0 to sl.count-1 do begin
    s:=sl[i];
    s:=fetchname(s,name);
    stringlist_splitby(sl2,',',s);
    ip:=name2input(name);
    if ip=INPUT_UNKNOWN then exception.create('unknown brush input'+name);

    if sl2.count>1 then begin
      pmapping.set_n(ip,sl2.count);
      for j:=0 to sl2.count-1 do begin
        s2:=trim(sl2[j]);
        s2:=copy(s2,2,length(s2)-2);//remove ()
        p:=pos(' ',s2);
        x:=strtofloatdef( copy(s2,1,p),0);
        y:=strtofloatdef( copy(s2,p+1,length(s2)),0);

        pmapping.set_point(ip,j,x,y);
      end;
    end else begin // old format
      pmapping.set_n(ip,5); //maximum 5 points
      
      stringlist_splitby(sl2,' ',s);  //split by space, not ','
      pmapping.set_point(ip,0,0,0); //auto insert first point

      for j:=0 to sl2.count div 2 -1 do begin
        x:=strtofloatdef(sl2[j*2],0);
        y:=strtofloatdef(sl2[j*2+1],0);
        if (x=0) and (y=0) then break;

        pmapping.set_point(ip,j+1,x,y);
      end;

      pmapping.set_n(ip,j+1);

    end;
    pmapping.updated;

  end;
  sl2.free;
  sl.free;
end;
procedure readmyb_line(s:string; var mapping: array  of TMyBrushmapping);
var
  p:integer;
  name:string;
  setting:integer;
  pmapping:PMybrushmapping;
  base_v:string;
begin
  s:=fetchname(s,name);
  
  setting:=name2setting(name);
  if setting=BRUSH_ADAPT_COLOR_FROM_IMAGE then exit; //obsolute
  if setting=BRUSH_CHANGE_RADIUS then exit;
  if setting=BRUSH_group then exit;

  if setting=BRUSH_UNKNOWN then raise exception.create('unknown brush setting '+name);
  pmapping:=@mapping[setting];

  p:=pos('|',s);
  if p>0 then begin
    base_v:=copy(s,1,p-1);
    s:=copy(s,p+1,length(s));
    readmyb_controlpoints(s,pmapping);
  end else begin
    base_v:=trim(s);
  end;

  pmapping.base_value:= strtofloatdef(base_v ,0);
end;

procedure readmyb( myb:TStrings; var mapping: array  of TMyBrushmapping);
var
  i,j:integer;
  s:string;
begin
  defaultvalues(mapping);
  for i:=0 to myb.count-1 do begin
    s:=trim(myb[i]);
    if copy(s,1,1)='#' then continue; //ignore comment
    readmyb_line(s,mapping);
  end;
end;

procedure defaultvalues(var mapping:array  of TMyBrushmapping);
var
  i,j,k:integer;
begin
  mapping[BRUSH_opaque].base_value:=1.0;
  mapping[BRUSH_opaque_multiply].base_value:=0.0;
  mapping[BRUSH_opaque_linearize].base_value:=0.9;
  mapping[BRUSH_radius_logarithmic].base_value:=2.0;
  mapping[BRUSH_hardness].base_value:=0.8;
  mapping[BRUSH_dabs_per_basic_radius].base_value:=0.0;
  mapping[BRUSH_dabs_per_actual_radius].base_value:=2.0;
  mapping[BRUSH_dabs_per_second].base_value:=0.0;
  mapping[BRUSH_radius_by_random].base_value:=0.0;
  mapping[BRUSH_speed1_slowness].base_value:=0.04;
  mapping[BRUSH_speed2_slowness].base_value:=0.8;

  mapping[BRUSH_speed1_gamma].base_value:=4.0;
  mapping[BRUSH_speed2_gamma].base_value:=4.0;

  mapping[BRUSH_offset_by_random].base_value:=0.0;
  mapping[BRUSH_offset_by_speed].base_value:=0.0;
  mapping[BRUSH_offset_by_speed_slowness].base_value:=1.0;

  mapping[BRUSH_slow_tracking].base_value:=0.0;
  mapping[BRUSH_slow_tracking_per_dab].base_value:=0.0;
  mapping[BRUSH_tracking_noise].base_value:=0.0;
  mapping[BRUSH_color_h].base_value:=0.0;
  mapping[BRUSH_color_s].base_value:=0.0;
  mapping[BRUSH_color_v].base_value:=0.0;
  mapping[BRUSH_change_color_h].base_value:=0.0;
  mapping[BRUSH_change_color_l].base_value:=0.0;
  mapping[BRUSH_change_color_hsl_s].base_value:=0.0;
  mapping[BRUSH_change_color_v].base_value:=0.0;
  mapping[BRUSH_smudge].base_value:=0.0;
  mapping[BRUSH_smudge_length].base_value:=0.5;
  mapping[BRUSH_smudge_radius_log].base_value:=0.0;
  mapping[BRUSH_eraser].base_value:=0.0;
  mapping[BRUSH_stroke_threshold].base_value:=0.0;
  mapping[BRUSH_stroke_duration_logarithmic].base_value:=4.0;
  mapping[BRUSH_stroke_holdtime].base_value:=0.0;
  mapping[BRUSH_custom_input].base_value:=0.0;
  mapping[BRUSH_custom_input_slowness].base_value:=0.0;
  mapping[BRUSH_elliptical_dab_ratio].base_value:=1.0;
  mapping[BRUSH_elliptical_dab_angle].base_value:=90.0;

  mapping[BRUSH_direction_filter].base_value:=2.0;
  mapping[BRUSH_version].base_value:=2.0;

  for i:=0 to BRUSH_SETTINGS_COUNT-1 do begin
    for j:=0 to BRUSH_INPUT_COUNT-1 do begin
      mapping[i].pointsList[j].n:=0;
      for k:=0 to high(mapping[i].pointsList[j].xvalues) do begin
        mapping[i].pointsList[j].xvalues[k]:=0;
        mapping[i].pointsList[j].yvalues[k]:=0;        
      end;
    end;
  end;
end;
function name2setting(name:string):integer;
begin
 result:=BRUSH_UNKNOWN;
 name:=lowercase(name);
 if name='opaque' then result:=BRUSH_opaque
 else if name='opaque_multiply' then result:=BRUSH_opaque_multiply
 else if name='opaque_linearize'then result:=  BRUSH_opaque_linearize
 else if name='radius_logarithmic'then result:=  BRUSH_radius_logarithmic
 else if name='hardness'then result:=  BRUSH_hardness
 else if name='dabs_per_basic_radius'then result:=  BRUSH_dabs_per_basic_radius
 else if name='dabs_per_actual_radius'then result:=  BRUSH_dabs_per_actual_radius
 else if name='dabs_per_second'then result:=  BRUSH_dabs_per_second
 else if name='radius_by_random'then result:=  BRUSH_radius_by_random
 else if name='speed1_slowness'then result:=  BRUSH_speed1_slowness
 else if name='speed2_slowness'then result:=  BRUSH_speed2_slowness
 else if name='speed1_gamma'then result:=  BRUSH_speed1_gamma
 else if name='speed2_gamma'then result:=  BRUSH_speed2_gamma
 else if name='offset_by_random'then result:=  BRUSH_offset_by_random
 else if name='offset_by_speed'then result:=  BRUSH_offset_by_speed
 else if name='offset_by_speed_slowness'then result:=  BRUSH_offset_by_speed_slowness
 else if name='slow_tracking'then result:=  BRUSH_slow_tracking
 else if name='slow_tracking_per_dab'then result:=  BRUSH_slow_tracking_per_dab
 else if name='tracking_noise'then result:=  BRUSH_tracking_noise
 else if name='color_h'then result:=  BRUSH_color_h
 else if name='color_hue'then result:=  BRUSH_color_h  // oldname
 else if name='color_s'then result:=  BRUSH_color_s
 else if name='color_saturation'then result:=  BRUSH_color_s //oldname
 else if name='color_v'then result:=  BRUSH_color_v
 else if name='color_value'then result:=  BRUSH_color_v //oldname
 else if name='change_color_h'then result:=  BRUSH_change_color_h
 else if name='change_color_l'then result:=  BRUSH_change_color_l
 else if name='change_color_hsl_s'then result:=  BRUSH_change_color_hsl_s
 else if name='change_color_v'then result:=  BRUSH_change_color_v
 else if name='change_color_hsv_s'then result:=  BRUSH_change_color_hsv_s
 else if name='smudge'then result:=  BRUSH_smudge
 else if name='smudge_length'then result:=  BRUSH_smudge_length
 else if name='smudge_radius_log'then result:=  BRUSH_smudge_radius_log
 else if name='eraser'then result:=  BRUSH_eraser
 else if name='stroke_threshold'then result:=  BRUSH_stroke_threshold
 else if name='stroke_treshold'then result:=  BRUSH_stroke_threshold //miss spelling
 else if name='stroke_duration_logarithmic'then result:=  BRUSH_stroke_duration_logarithmic
 else if name='stroke_holdtime'then result:=  BRUSH_stroke_holdtime
 else if name='custom_input'then result:=  BRUSH_custom_input
 else if name='custom_input_slowness'then result:=  BRUSH_custom_input_slowness
 else if name='elliptical_dab_ratio'then result:=  BRUSH_elliptical_dab_ratio
 else if name='elliptical_dab_angle'then result:=  BRUSH_elliptical_dab_angle
 else if name='direction_filter'then result:=  BRUSH_direction_filter
 else if name='version' then result:=  BRUSH_version
 //obsolute
 else if name='adapt_color_from_image' then result:=  BRUSH_adapt_color_from_image
 else if name='change_radius' then result:=  BRUSH_change_radius
 else if name='group' then result:=  BRUSH_group;
end;

function name2input(name:string):integer;
begin
 result:=INPUT_UNKNOWN;
 name:=lowercase(name);
 if name='pressure' then result:=INPUT_pressure
 else if name='speed1' then result:=INPUT_speed1
 else if name='speed2' then result:=INPUT_speed2
 else if name='random' then result:=INPUT_random
 else if name='stroke' then result:=INPUT_stroke
 else if name='direction' then result:=INPUT_direction
 else if name='tilt_declination' then result:=INPUT_tilt_declination
 else if name='tilt_ascension' then result:=INPUT_tilt_ascension
 else if name='custom' then result:=INPUT_custom;


end;

function setting2name(s:integer):string;
var
  name:string;
begin
  name:='';
  case s of
    BRUSH_opaque: name:='opaque';
    BRUSH_opaque_multiply: name:='opaque_multiply';
    BRUSH_opaque_linearize: name:='opaque_linearize';
    BRUSH_radius_logarithmic: name:='radius_logarithmic';
    BRUSH_hardness: name:='hardness';
    BRUSH_dabs_per_basic_radius: name:='dabs_per_basic_radius';
    BRUSH_dabs_per_actual_radius: name:='dabs_per_actual_radius';
    BRUSH_dabs_per_second: name:='dabs_per_second';
    BRUSH_radius_by_random: name:='radius_by_random';
    BRUSH_speed1_slowness: name:='speed1_slowness';
    BRUSH_speed2_slowness: name:='speed2_slowness';
    BRUSH_speed1_gamma: name:='speed1_gamma';
    BRUSH_speed2_gamma: name:='speed2_gamma';
    BRUSH_offset_by_random: name:='offset_by_random';
    BRUSH_offset_by_speed:name:='offset_by_speed';
    BRUSH_offset_by_speed_slowness:name:='offset_by_speed_slowness';
    BRUSH_slow_tracking:name:='slow_tracking';
    BRUSH_slow_tracking_per_dab:name:='slow_tracking_per_dab';
    BRUSH_tracking_noise:name:='tracking_noise';
    BRUSH_color_h:name:='color_h';
    BRUSH_color_s :name:='color_s';
    BRUSH_color_v:name:='color_v';
    BRUSH_change_color_h:name:='change_color_h';
    BRUSH_change_color_l:name:='change_color_l';
    BRUSH_change_color_hsl_s :name:='change_color_hsl_s';
    BRUSH_change_color_v :name:='change_color_v';
    BRUSH_change_color_hsv_s :name:='change_color_hsv_s';
    BRUSH_smudge :name:='smudge';
    BRUSH_smudge_length :name:='smudge_length';
    BRUSH_smudge_radius_log :name:='smudge_radius_log';
    BRUSH_eraser :name:='eraser';
    BRUSH_stroke_threshold :name:='stroke_threshold';
    BRUSH_stroke_duration_logarithmic :name:='stroke_duration_logarithmic';
    BRUSH_stroke_holdtime :name:='stroke_holdtime';
    BRUSH_custom_input :name:='custom_input';
    BRUSH_custom_input_slowness :name:='custom_input_slowness';
    BRUSH_elliptical_dab_ratio :name:='elliptical_dab_ratio';
    BRUSH_elliptical_dab_angle :name:='elliptical_dab_angle';
    BRUSH_direction_filter :name:='direction_filter';
    BRUSH_version :name:='version';
  end;
  result:=name;
end;
function input2name(i:integer):string;
var
  name:string;
begin
  case i of
   INPUT_pressure:name:='pressure';
   INPUT_speed1 :name:='speed1';
   INPUT_speed2 :name:='speed2';
   INPUT_random :name:='random';
   INPUT_stroke :name:='stroke';
   INPUT_direction :name:='direction';
   INPUT_tilt_declination :name:='tilt_declination';
   INPUT_tilt_ascension :name:='tilt_ascension';
   INPUT_custom :name:='custom';
 end;
 result:=name;
end;


end.
