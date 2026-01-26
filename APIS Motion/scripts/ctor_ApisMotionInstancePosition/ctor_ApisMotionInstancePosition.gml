function ApisMotionInstancePosition(_instance) : ApisMotionPosition() constructor {
    instance = _instance;
    
    static get_x = function() {
        return instance.x;
    }
    
    static get_y = function() {
        return instance.y;
    }
    
    static set_position = function(_x, _y) {
        instance.x = _x;
        instance.y = _y;
    }
}
