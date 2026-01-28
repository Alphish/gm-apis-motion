function ApisMotionMechanic() constructor {
    static process = function() {
        throw ApisMotionException.not_implemented(self, nameof(process));
    }
}
