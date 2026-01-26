function ApisMotionPosition() constructor {
    static get_x = function() {
        throw ApisMotionException.not_implemented(self, nameof(get_x));
    }
    
    static get_y = function() {
        throw ApisMotionException.not_implemented(self, nameof(get_y));
    }
    
    static set_position = function(_x, _y) {
        throw ApisMotionException.not_implemented(self, nameof(set_position));
    }
    
    static set_x = function(_x) {
        set_position(_x, get_y());
    }
    
    static set_y = function(_y) {
        set_position(get_x(), _y);
    }
}
