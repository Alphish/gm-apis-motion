if (mouse_check_button(mb_left)) {
    motion_mechanic.set_target(mouse_x, mouse_y);
} else {
    motion_mechanic.stop();
}
motion_mechanic.process();
