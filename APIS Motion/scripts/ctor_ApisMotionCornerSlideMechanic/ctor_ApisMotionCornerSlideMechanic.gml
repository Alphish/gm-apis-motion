function ApisMotionCornerSlideMechanic(_instance, _position, _speed, _obstacles, _ru, _ul, _ld, _dr) : ApisMotionMechanic() constructor {
    position = _position;
    target_x = position.get_x();
    target_y = position.get_y();
    speed = _speed;
    
    obstacles = _obstacles;
    instance = _instance;
    max_xgap = (instance.bbox_right - instance.bbox_left) div 2;
    max_ygap = (instance.bbox_bottom - instance.bbox_top) div 2;
    cardinal_direction_range = 30;
    
    ru_corner = _ru;
    ul_corner = _ul;
    ld_corner = _ld;
    dr_corner = _dr;
    
    // -----
    // Setup
    // -----
    
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
    
    // ----------
    // Processing
    // ----------
    
    static process = function() {
        var _current_x = position.get_x();
        var _current_y = position.get_y();
        if (_current_x == target_x && _current_y == target_y)
            return;
        
        var _xdiff, _ydiff;
        var _step_x, _step_y;
        var _direction = point_direction(_current_x, _current_y, target_x, target_y);
        if (sqr(_current_x - target_x) + sqr(_current_y - target_y) <= sqr(speed)) {
            _step_x = target_x;
            _step_y = target_y;
            _xdiff = _step_x - _current_x;
            _ydiff = _step_y - _current_y;
        } else {
            _xdiff = lengthdir_x(speed, _direction);
            _ydiff = lengthdir_y(speed, _direction);
            _step_x = _current_x + _xdiff;
            _step_y = _current_y + _ydiff;
        }
        
        if (obstacle_free(instance, _step_x, _step_y)) {
            position.set_position(_step_x, _step_y);
            return;
        }
        
        var _step_ix = get_integer_coordinate(_step_x, _xdiff);
        var _step_iy = get_integer_coordinate(_step_y, _ydiff);
        if (obstacle_free(instance, _step_ix, _step_iy)) {
            position.set_position(_step_ix, _step_iy);
            return;
        }
        
        var _cardinal_angle = (round(_direction / 90) * 90) mod 360;
        if (abs(angle_difference(_cardinal_angle, _direction)) > cardinal_direction_range / 2) {
            try_step_diagonal(_step_ix, _step_iy);
            return;
        }
        
        switch (_cardinal_angle) {
            case 0:
                try_step_horizontal(_step_ix, _step_iy, ru_corner, dr_corner);
                break;
            case 90:
                try_step_vertical(_step_ix, _step_iy, ul_corner, ru_corner);
                break;
            case 180:
                try_step_horizontal(_step_ix, _step_iy, ul_corner, ld_corner);
                break;
            case 270:
                try_step_vertical(_step_ix, _step_iy, ld_corner, dr_corner);
                break;
        }
    }
    
    static try_step_horizontal = function(_dest_ix, _dest_iy, _top_corner, _bottom_corner) {
        var _current_ix = instance.x;
        var _current_iy = instance.y;
        
        var _xsign = sign(_dest_ix - _current_ix);
        var _step_ix = _current_ix;
        var _step_iy = _current_iy;
        
        // preliminary broad stepping towards target coordinates
        _step_ix += get_x_leeway(instance, _step_ix, _step_iy, _dest_ix - _step_ix);
        _step_iy += get_y_leeway(instance, _step_ix, _step_iy, _dest_iy - _step_iy);
        
        if (_step_ix == _dest_ix)
            _dest_ix += _xsign;
        
        // crawl forward, while sliding around corners
        var _sqdist = sqr(speed);
        var _wall_reached = false;
        while (!_wall_reached) {
            var _x_leeway = get_x_leeway(instance, _step_ix, _step_iy, _dest_ix - _step_ix);
            var _actual_leeway = contain_xshift(_current_ix, _current_iy, _step_ix, _step_iy, _sqdist, _x_leeway);
            _step_ix += _actual_leeway;
            if (_x_leeway != _actual_leeway)
                break;
            
            if (_step_ix == _dest_ix) {
                _dest_ix += _xsign;
                continue;
            }
            
            var _top_sideshift = get_y_sideshift(instance, _top_corner, _step_ix + _xsign, _step_iy, -1);
            var _actual_top = contain_yshift(_current_ix, _current_iy, _step_ix, _step_iy, _sqdist, _top_sideshift);
            _step_iy += _actual_top;
            if (_top_sideshift != _actual_top)
                break;
                
            if (_top_sideshift != 0)
                continue;
            
            var _bottom_sideshift = get_y_sideshift(instance, _bottom_corner, _step_ix + _xsign, _step_iy, 1);
            var _actual_bottom = contain_yshift(_current_ix, _current_iy, _step_ix, _step_iy, _sqdist, _bottom_sideshift);
            _step_iy += _actual_bottom;
            if (_bottom_sideshift != _actual_bottom)
                break;
            
            if (_bottom_sideshift != 0)
                continue;
            
            _wall_reached = true;
        }
        
        // when hitting a literal wall, move towards target sideway coordinate
        if (_wall_reached) {
            var _target_yshift = contain_yshift(_current_ix, _current_iy, _step_ix, _step_iy, _sqdist, target_y - _step_iy);
            _step_iy += get_y_leeway(instance, _step_ix, _step_iy, _target_yshift);
        }
        
        position.set_position(_step_ix, _step_iy);
    }
    
    static try_step_vertical = function(_dest_ix, _dest_iy, _left_corner, _right_corner) {
        var _current_ix = instance.x;
        var _current_iy = instance.y;
        
        var _ysign = sign(_dest_iy - _current_iy);
        var _step_ix = _current_ix;
        var _step_iy = _current_iy;
        
        // preliminary broad stepping towards target coordinates
        _step_iy += get_y_leeway(instance, _step_ix, _step_iy, _dest_iy - _step_iy);
        _step_ix += get_x_leeway(instance, _step_ix, _step_iy, _dest_ix - _step_ix);
        
        if (_step_iy == _dest_iy)
            _dest_iy += _ysign;
        
        // crawl forward, while sliding around corners
        var _sqdist = sqr(speed);
        var _wall_reached = false;
        while (!_wall_reached) {
            var _y_leeway = get_y_leeway(instance, _step_ix, _step_iy, _dest_iy - _step_iy);
            var _actual_leeway = contain_yshift(_current_ix, _current_iy, _step_ix, _step_iy, _sqdist, _y_leeway);
            _step_iy += _actual_leeway;
            if (_y_leeway != _actual_leeway)
                break;
            
            if (_step_iy == _dest_iy) {
                _dest_iy += _ysign;
                continue;
            }
            
            var _left_sideshift = get_x_sideshift(instance, _left_corner, _step_ix, _step_iy + _ysign, -1);
            var _actual_left = contain_xshift(_current_ix, _current_iy, _step_ix, _step_iy, _sqdist, _left_sideshift);
            _step_ix += _actual_left;
            if (_left_sideshift != _actual_left)
                break;
                
            if (_left_sideshift != 0)
                continue;
            
            var _right_sideshift = get_x_sideshift(instance, _right_corner, _step_ix, _step_iy + _ysign, 1);
            var _actual_right = contain_xshift(_current_ix, _current_iy, _step_ix, _step_iy, _sqdist, _right_sideshift);
            _step_ix += _actual_right;
            if (_right_sideshift != _actual_right)
                break;
            
            if (_right_sideshift != 0)
                continue;
            
            _wall_reached = true;
        }
        
        // when hitting a literal wall, move towards target sideway coordinate
        if (_wall_reached) {
            var _target_xshift = contain_xshift(_current_ix, _current_iy, _step_ix, _step_iy, _sqdist, target_x - _step_ix);
            _step_ix += get_x_leeway(instance, _step_ix, _step_iy, _target_xshift);
        }
        
        position.set_position(_step_ix, _step_iy);
    }
    
    static try_step_diagonal = function(_dest_ix, _dest_iy) {
        var _current_ix = instance.x;
        var _current_iy = instance.y;
        
        var _ixdiff = _dest_ix - _current_ix;
        var _iydiff = _dest_iy - _current_iy;
        var _xsign = sign(_ixdiff);
        var _ysign = sign(_iydiff);
        
        // preliminary stepping towards the destination
        var _mindist = 0;
        var _refdist = max(abs(_ixdiff), abs(_iydiff));
        var _maxdist = _refdist - 1;
        var _xtest = 0;
        var _ytest = 0;
        if (obstacle_free(instance, _current_ix + _xsign, _current_iy + _ysign))
            _mindist = 1;
        else
            _maxdist = 0;
        
        while (_mindist < _maxdist) {
            var _testdist = (_mindist + _maxdist) div 2 + 1;
            _xtest = round(_ixdiff * _testdist / _refdist);
            _ytest = round(_iydiff * _testdist / _refdist);
            if (obstacle_free(instance, _current_ix + _xtest, _current_iy + _ytest))
                _mindist = _testdist;
            else
                _maxdist = _testdist - 1;
        }
        
        _xtest = round(_ixdiff * _mindist / _refdist);
        _ytest = round(_iydiff * _mindist / _refdist);
        var _step_ix = _current_ix + _xtest;
        var _step_iy = _current_iy + _ytest;
        
        // slide around to the most promising point
        
        var _sqdist = sqr(speed);
        var _distance_reached = false;
        while (!_distance_reached) {
            // try move directly towards the target
            var _can_hor = obstacle_free(instance, _step_ix + _xsign, _step_iy) && sign(target_x - _step_ix) == _xsign;
            var _hor_approach = get_approach(_step_ix + _xsign, _step_iy);
            var _can_ver = obstacle_free(instance, _step_ix, _step_iy + _ysign) && sign(target_y - _step_iy) == _ysign;
            var _ver_approach = get_approach(_step_ix, _step_iy + _ysign);
            if (_can_hor || _can_ver) {
                if (_can_ver && (!_can_hor || _ver_approach < _hor_approach)) {
                    _distance_reached = sqr(_step_ix - _current_ix) + sqr((_step_iy + _ysign) - _current_iy) > _sqdist;
                    _step_iy += _distance_reached ? 0 : _ysign;
                } else {
                    _distance_reached = sqr((_step_ix + _xsign) - _current_ix) + sqr(_step_iy - _current_iy) > _sqdist;
                    _step_ix += _distance_reached ? 0 : _xsign;
                }
                continue;
            }
            
            // try slide by 1 pixel
            var _current_approach = get_approach(_step_ix, _step_iy);
            var _close_hor_leeway = get_x_leeway(instance, _step_ix, _step_iy - _ysign, min(abs(target_x - _step_ix), speed) * _xsign);
            _hor_approach = get_approach(_step_ix + _close_hor_leeway, _step_iy - _ysign);
            var _close_ver_leeway = get_y_leeway(instance, _step_ix - _xsign, _step_iy, min(abs(target_y - _step_iy), speed) * _ysign);
            _ver_approach = get_approach(_step_ix - _xsign, _step_iy + _close_ver_leeway);
            
            if (_hor_approach < _current_approach || _ver_approach < _current_approach) {
                if (_hor_approach <= _ver_approach) {
                    _step_iy -= _ysign;
                    var _shift = contain_xshift(_current_ix, _current_iy, _step_ix, _step_iy, _sqdist, _close_hor_leeway);
                    _distance_reached = _shift != _close_hor_leeway;
                    _step_ix += min(2, abs(_shift)) * _xsign;
                } else {
                    _step_ix -= _xsign;
                    var _shift = contain_yshift(_current_ix, _current_iy, _step_ix, _step_iy, _sqdist, _close_ver_leeway);
                    _distance_reached = _shift != _close_ver_leeway;
                    _step_iy += min(2, abs(_shift)) * _ysign;
                }
                continue;
            }
            
            // try slide by 2 pixels
            _close_hor_leeway = get_x_leeway(instance, _step_ix, _step_iy - 2 * _ysign, min(abs(target_x - _step_ix), speed) * _xsign);
            _hor_approach = get_approach(_step_ix + _close_hor_leeway, _step_iy - 2 * _ysign);
            _close_ver_leeway = get_y_leeway(instance, _step_ix - 2 * _xsign, _step_iy, min(abs(target_y - _step_iy), speed) * _ysign);
            _ver_approach = get_approach(_step_ix - 2 * _xsign, _step_iy + _close_ver_leeway);
            
            if (_hor_approach < _current_approach || _ver_approach < _current_approach) {
                if (_hor_approach <= _ver_approach) {
                    _step_iy -= 2 * _ysign;
                    var _shift = contain_xshift(_current_ix, _current_iy, _step_ix, _step_iy, _sqdist, _close_hor_leeway);
                    _distance_reached = _shift != _close_hor_leeway;
                    _step_ix += min(2, abs(_shift)) * _xsign;
                } else {
                    _step_ix -= 2 * _xsign;
                    var _shift = contain_yshift(_current_ix, _current_iy, _step_ix, _step_iy, _sqdist, _close_ver_leeway);
                    _distance_reached = _shift != _close_ver_leeway;
                    _step_iy += min(2, abs(_shift)) * _ysign;
                }
                continue;
            }
            
            // ran out of options, stop
            break;
        }
        
        position.set_position(_step_ix, _step_iy);
    }
    
    // -------
    // Helpers
    // -------
    
    static get_integer_coordinate = function(_coord, _diff) {
        if (_diff < 0)
            return floor(_coord);
        else if (_diff > 0)
            return ceil(_coord);
        else
            return _coord;
    }
    
    static obstacle_free = function(_inst, _x, _y) {
        with (_inst) {
            return !place_meeting(_x, _y, other.obstacles);
        }
    }
    
    static obstacle_meeting = function(_inst, _x, _y) {
        with (_inst) {
            return place_meeting(_x, _y, other.obstacles);
        }
    }
    
    static get_x_leeway = function(_inst, _x, _y, _xshift) {
        with (_inst) {
            var _xsign = sign(_xshift);
            var _mindist = 0;
            var _maxdist = abs(_xshift);
            var _gap_mindist = _mindist + other.max_xgap;
            while (_gap_mindist < _maxdist) {
                if (!place_meeting(_x + _xsign * _gap_mindist, _y, other.obstacles)) {
                    _mindist = _gap_mindist;
                    _gap_mindist = _mindist;
                } else {
                    _maxdist = _gap_mindist - 1;
                }
            }
            
            if (!place_meeting(_x + _xsign * _maxdist, _y, other.obstacles))
                return _xsign * _maxdist;
            
            if (place_meeting(_x + _xsign * (_mindist + 1), _y, other.obstacles))
                return _xsign * _mindist;
            
            _maxdist -= 1;
            _mindist += 1;
            while (_mindist < _maxdist) {
                var _testdist = (_mindist + _maxdist) div 2 + 1;
                if (place_meeting(_x + _xsign * _testdist, _y, other.obstacles))
                    _maxdist = _testdist - 1;
                else
                    _mindist = _testdist;
            }
            return _xsign * _mindist;
        }
    }
    
    static get_y_leeway = function(_inst, _x, _y, _yshift) {
        with (_inst) {
            var _ysign = sign(_yshift);
            var _mindist = 0;
            var _maxdist = abs(_yshift);
            var _gap_mindist = _mindist + other.max_xgap;
            while (_gap_mindist < _maxdist) {
                if (!place_meeting(_x, _y + _ysign * _gap_mindist, other.obstacles)) {
                    _mindist = _gap_mindist;
                    _gap_mindist = _mindist;
                } else {
                    _maxdist = _gap_mindist - 1;
                }
            }
            
            if (!place_meeting(_x, _y + _ysign * _maxdist, other.obstacles))
                return _ysign * _maxdist;
            
            if (place_meeting(_x, _y + _ysign * (_mindist + 1), other.obstacles))
                return _ysign * _mindist;
            
            _maxdist -= 1;
            _mindist += 1;
            while (_mindist < _maxdist) {
                var _testdist = (_mindist + _maxdist) div 2 + 1;
                if (place_meeting(_x, _y + _ysign * _testdist, other.obstacles))
                    _maxdist = _testdist - 1;
                else
                    _mindist = _testdist;
            }
            return _ysign * _mindist;
        }
    }
    
    static get_x_sideshift = function(_inst, _corner, _x, _y, _xsign) {
        var _result = _xsign;
        while (obstacle_free(_corner, _x + _result, _y)) {
            if (obstacle_free(_inst, _x + _result, _y))
                return _result;
            
            _result += _xsign;
        }
        return 0;
    }
    
    static get_y_sideshift = function(_inst, _corner, _x, _y, _ysign) {
        var _result = 0;
        while (obstacle_free(_corner, _x, _y + _result)) {
            if (obstacle_free(_inst, _x, _y + _result))
                return _result;
            
            _result += _ysign;
        }
        return 0;
    }
    
    static contain_xshift = function(_origx, _origy, _x, _y, _sqdist, _xshift) {
        var _sqy = sqr(_y - _origy);
        if (_sqy >= _sqdist)
            return 0;
        
        if (sqr(_x + _xshift - _origx) + _sqy <= _sqdist)
            return _xshift;
        
        var _maxtarget = _origx + sign(_xshift) * floor(sqrt(_sqdist - _sqy));
        return _maxtarget - _x;
    }
    
    static contain_yshift = function(_origx, _origy, _x, _y, _sqdist, _yshift) {
        var _sqx = sqr(_x - _origx);
        if (_sqx >= _sqdist)
            return 0;
        
        if (_sqx + sqr(_y + _yshift - _origy) <= _sqdist)
            return _yshift;
        
        var _maxtarget = _origy + sign(_yshift) * floor(sqrt(_sqdist - _sqx));
        return _maxtarget - _y;
    }
    
    static get_approach = function(_x, _y) {
        return sqr(target_x - _x) + sqr(target_y - _y);
    }
}
