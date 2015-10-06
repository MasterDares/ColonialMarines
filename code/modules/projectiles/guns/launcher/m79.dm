/obj/item/weapon/gun/launcher/m79
	var/projectile
	name = "M79 Grenade Launcher"
	desc = "M79 Grenade Launcher. Nice weapon for tanks."
	icon = 'icons/obj/gun.dmi'
	icon_state = "M79closed"
	item_state = "M79"
	w_class = 3.0
	throw_speed = 2
	throw_range = 10
	force = 5.0
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY
	slot_flags = SLOT_BELT | SLOT_BACK
	origin_tech = "combat=8;materials=5"
	projectile = /obj/item/mgrenade
	var/mgrenade_speed = 2
	var/mgrenade_range = 30
	var/max_mmgrenades = 1
	var/list/mmgrenades = new/list()
	var/cover_open = 0
	var/mmgrenade_inserted = 0

/obj/item/weapon/gun/launcher/m79/examine()
	set src in view()
	..()
	if (!(usr in view(2)) && usr!=src.loc) return
	usr << "\blue [mmgrenades.len] / [max_mmgrenades] grenades."

/obj/item/weapon/gun/launcher/m79/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/ammo_casing/mmgrenade))
		if(mmgrenades.len < max_mmgrenades)
			user.drop_item()
			I.loc = src
			mmgrenades += I
			user << "\blue You put the grenade in [src]."
			user << "\blue [mmgrenades.len] / [max_mmgrenades] grenades."
		else
			usr << "\red [src] cannot hold more grenades."

/obj/item/weapon/gun/launcher/m79/can_fire()
	return mmgrenades.len

/obj/item/weapon/gun/launcher/m79/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0)
	if(mmgrenades.len)
		var/obj/item/ammo_casing/mmgrenade/I = mmgrenades[1]
		var/obj/item/mgrenade/M = new projectile(user.loc)
		playsound(user.loc, 'sound/weapons/M79(fire).ogg', 80, 1)
		M.primed = 1
		M.throw_at(target, mgrenade_range, mgrenade_speed)
		message_admins("[key_name_admin(user)] fired a grenade from a M79 ([src.name]).")
		log_game("[key_name_admin(user)] used a M79 ([src.name]).")
		mmgrenades -= I
		mmgrenade_inserted = 0
		del(I)
		return
	else
		usr << "\red [src] is empty."

/obj/item/weapon/gun/launcher/m79/consume_next_projectile()
	if(mmgrenades.len)
		var/obj/item/ammo_casing/mmgrenade/I = mmgrenades[1]
		var/obj/item/mgrenade/M = new (src)
		M.primed = 1
		mmgrenades -= I
		return M
	return null

/obj/item/weapon/gun/launcher/m79/attack_self(mob/user as mob)
	cover_open = !cover_open
	user << "<span class='notice'>You [cover_open ? "open" : "close"] [src]'s cover.</span>"
	playsound(user.loc, 'sound/weapons/M79(close).ogg', 70, 1)
	update_icon()

/obj/item/weapon/gun/launcher/m79/update_icon()
	icon_state = "M79[cover_open ? "open" : "closed"]"

/obj/item/weapon/gun/launcher/m79/afterattack(atom/target as mob|obj|turf, mob/living/user as mob|obj, flag, params) //what I tried to do here is just add a check to see if the cover is open or not and add an icon_state change because I can't figure out how c-20rs do it with overlays
	if(cover_open)
		user << "<span class='notice'>[src]'s cover is open! Close it before firing!</span>"
	else
		..()
		update_icon()


/obj/item/weapon/gun/launcher/m79/attack_hand(mob/user as mob)
	if(loc != user)
		..()
		return	//let them pick it up
	if(!cover_open || (cover_open && !mmgrenade_inserted))
		..()
	else if(cover_open && mmgrenade_inserted)
		var/obj/item/ammo_casing/mmgrenade/I = mmgrenades[1]
		mmgrenades -= I
		mmgrenade_inserted = 0
		I.loc = get_turf(src.loc)
		update_icon()
		user << "<span class='notice'>You remove the grenade from [src].</span>"
		playsound(user.loc, 'sound/weapons/M79(load).ogg', 70, 1)


/obj/item/weapon/gun/launcher/m79/attackby(var/obj/item/A as obj, mob/user as mob)
	if(istype(A,/obj/item/ammo_casing/mmgrenade))
		if(!cover_open)
			user << "<span class='notice'>[src]'s cover is closed! You can't insert a grenade!</span>"
			return
		else if(cover_open && mmgrenade_inserted)
			user << "<span class='notice'>[src] already has a grenade inserted!</span>"
			return
		else if(cover_open && !mmgrenade_inserted)
			mmgrenade_inserted = 1
			user << "<span class='notice'>You insert the grenade!</span>"
			playsound(user.loc, 'sound/weapons/M79(load).ogg', 70, 1)
			update_icon()
	..()