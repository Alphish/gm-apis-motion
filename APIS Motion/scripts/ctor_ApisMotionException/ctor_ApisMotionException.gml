/// @desc An exception to be thrown due to invalid APIS Motion usage.
/// @arg {String} code              The code of the exception to differentiate between different exception causes.
/// @arg {String} description       A detailed description explaining the exception.
function ApisMotionException(_code, _description) constructor {
    /// @desc The code of the exception to differentiate between different exception causes.
    /// @type {String}
    code = _code;
    
    /// @desc A detailed description explaining the exception.
    /// @type {String}
    description = _description;
    
    toString = function() {
        return $"ApisMotion.{code}: {description}";
    }
}

ApisMotionException.not_implemented = function(_context, _method) {
    return new ApisMotionException(
        nameof(not_implemented),
        $"{instanceof(_context)}.{_method} was not implemented."
        );
}
