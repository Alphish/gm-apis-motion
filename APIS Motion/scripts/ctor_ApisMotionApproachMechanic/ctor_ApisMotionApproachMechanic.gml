function ApisMotionApproachMechanic(_position, _speed) : ApisMotionMechanic() constructor {
    position = _position;
    target_x = position.get_x();
    target_y = position.get_y();
    speed = _speed;
    
    static set_target = function(_x, _y) {
        target_x = _x;
        target_y = _y;
    }
    
    static stop = function() {
        target_x = position.get_x();
        target_y = position.get_y();
    }
    
    static set_speed = function(_speed) {
        speed = _speed;
    }
    
    static process = function() {
        var _current_x = position.get_x();
        var _current_y = position.get_y();
        if (sqr(_current_x - target_x) + sqr(_current_y - target_y) <= sqr(speed)) {
            position.set_position(target_x, target_y);
        } else {
            var _direction = point_direction(_current_x, _current_y, target_x, target_y);
            position.set_position(_current_x + lengthdir_x(speed, _direction), _current_y + lengthdir_y(speed, _direction));
        }
    }
}
