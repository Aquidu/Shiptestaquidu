/// From base of /client/proc/change_view() (mob/source, new_size)
#define COMSIG_MOB_CLIENT_CHANGE_VIEW "mob_client_change_view"
/// From base of /mob/proc/reset_perspective() (mob/source)
#define COMSIG_MOB_RESET_PERSPECTIVE "mob_reset_perspective"
/// From /mob/proc/ghostize() Called when a mob sucessfully ghosts
#define COMSIG_MOB_GHOSTIZED "mob_ghostized"
///from /mob/living/proc/apply_damage(), works like above but after the damage is actually inflicted: (damage, damagetype, def_zone, blocked, wound_bonus, bare_wound_bonus, sharpness, attack_direction)
#define COMSIG_MOB_AFTER_APPLY_DAMAGE "mob_after_apply_damage"
