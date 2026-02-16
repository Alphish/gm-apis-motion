if (mouse_check_button(mb_left)) {
    motion_mechanic.set_target(obj_Crosshair.x, obj_Crosshair.y);
} else {
    var _hor = keyboard_check(vk_right) - keyboard_check(vk_left);
    var _ver = keyboard_check(vk_down) - keyboard_check(vk_up);
    if (_hor == 0 && _ver == 0)
        motion_mechanic.stop();
    else
        motion_mechanic.set_target(x + 16 * _hor, y + 16 * _ver);
}
motion_mechanic.process();
