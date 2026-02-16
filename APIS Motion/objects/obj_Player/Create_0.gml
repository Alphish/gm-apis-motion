position = new ApisMotionInstanceRoundedPosition(id);

ru_corner = instance_create_layer(x, y, layer, obj_FollowCorner, { sprite_index: msk_PlayerCorner, image_index: 0 });
ul_corner = instance_create_layer(x, y, layer, obj_FollowCorner, { sprite_index: msk_PlayerCorner, image_index: 1 });
ld_corner = instance_create_layer(x, y, layer, obj_FollowCorner, { sprite_index: msk_PlayerCorner, image_index: 2 });
dr_corner = instance_create_layer(x, y, layer, obj_FollowCorner, { sprite_index: msk_PlayerCorner, image_index: 3 });

motion_mechanic = new ApisMotionCornerSlideMechanic(
    id, position, 6, obj_Obstacle,
    ru_corner, ul_corner, ld_corner, dr_corner
    );
