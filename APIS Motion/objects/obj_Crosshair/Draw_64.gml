draw_set_color(c_orange);
draw_set_alpha(1);

draw_set_font(fnt_Demo);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_text(20, 20, $"Last click: {click_position.get_x()},{click_position.get_y()}");

draw_set_color(c_white);
draw_set_alpha(1);
