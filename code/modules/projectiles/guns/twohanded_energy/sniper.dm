/obj/item/weapon/gun/twohanded/energy/sniperrifle
	name = "\improper L.W.A.P. sniper rifle"
	desc = "A high-power laser rifle fitted with a SMART aiming-system scope."
	icon_state = "sniper"
	item_state = "laser"
	fire_sound = 'sound/weapons/marauder.ogg'
	origin_tech = "combat=6;materials=5;powerstorage=4"
	projectile_type = /obj/item/projectile/beam/sniper
	slot_flags = SLOT_BACK
	charge_cost = 600
	fire_delay = 35
	force = 10
	w_class = 4.0
//	accuracy = -3 //shooting at the hip
//	scoped_accuracy = 0
	cell_type = "/obj/item/weapon/cell/sniper"

/obj/item/weapon/gun/twohanded/energy/sniperrifle/verb/scope()
	set category = "Object"
	set name = "Use Scope"
	set popup_menu = 1

	toggle_scope(2.0)