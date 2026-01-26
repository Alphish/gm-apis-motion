function ApisMotionDirectPosition(_x = 0, _y = 0) : ApisMotionPosition() constructor {
    x = _x;
    y = _y;
    
    static get_x = function() {
        return x;
    }
    
    static get_y = function() {
        return y;
    }
    
    static set_position = function(_x, _y) {
        x = _x;
        y = _y;
    }
}
