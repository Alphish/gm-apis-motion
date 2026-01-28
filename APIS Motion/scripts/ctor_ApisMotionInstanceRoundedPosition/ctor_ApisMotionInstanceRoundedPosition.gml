function ApisMotionInstanceRoundedPosition(_instance) : ApisMotionPosition() constructor {
    instance = _instance;
    xprecise = _instance.x;
    yprecise = _instance.y;
    
    static get_x = function() {
        return xprecise;
    }
    
    static get_y = function() {
        return yprecise;
    }
    
    static set_position = function(_x, _y) {
        xprecise = _x;
        instance.x = round(xprecise);
        yprecise = _y;
        instance.y = round(yprecise);
    }
}
