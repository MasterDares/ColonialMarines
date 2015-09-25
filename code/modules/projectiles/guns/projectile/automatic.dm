/obj/item/weapon/gun/projectile/automatic //Hopefully someone will find a way to make these fire in bursts or something. --Superxpdude
	name = "submachine gun"
	desc = "A lightweight, fast firing gun. Uses 9mm rounds."
	icon_state = "saber"	//ugly
	w_class = 3.0
	max_shells = 18
	caliber = "9mm"
	origin_tech = "combat=4;materials=2"
	ammo_type = "/obj/item/ammo_casing/c9mm"
	automatic = 1
//	var/burstfire = 0 //Whether or not the gun fires multiple bullets at once
//	var/burst_count = 3

	fire_delay = 0

	isHandgun()
		return 0


/obj/item/weapon/gun/projectile/automatic/mini_uzi
	name = "Uzi"
	desc = "A lightweight, fast firing gun, for when you want someone dead. Uses .45 rounds."
	icon_state = "mini-uzi"
	w_class = 3.0
	max_shells = 16
	caliber = ".45"
	origin_tech = "combat=5;materials=2;syndicate=8"
	ammo_type = "/obj/item/ammo_casing/c45"

	isHandgun()
		return 1

/*/obj/item/weapon/gun/projectile/automatic/verb/ToggleFire()
	set name = "Toggle Burstfire"
	set category = "Object"
	burstfire = !burstfire
	usr << "You toggle \the [src]'s firing setting to [burstfire ? "burst fire" : "single fire"]."

/obj/item/weapon/gun/projectile/automatic/Fire()
	if(burstfire == 1)
		if(ready_to_fire())
			fire_delay = 0
		else
			usr << "<span class='warning'>\The [src] is still cooling down!</span>"
			return
		var/shots_fired = 0 //haha, I'm so clever
		var/to_shoot = min(burst_count, getAmmo())
		for(var/i = 1; i <= to_shoot; i++)
			..()
			shots_fired++
		message_admins("[usr] just shot [shots_fired] burst fire bullets out of [getAmmo() + shots_fired] from their [src].")
		fire_delay = shots_fired * 7
	else
		..()*/

/obj/item/weapon/gun/projectile/automatic/c20r
	name = "\improper C-20r SMG"
	desc = "A lightweight, fast firing gun, for when you REALLY need someone dead. Uses 12mm rounds. Has a 'Scarborough Arms - Per falcis, per pravitas' buttstamp"
	icon_state = "c20r"
	item_state = "c20r"
	w_class = 3.0
	max_shells = 20
	caliber = "12mm"
	origin_tech = "combat=5;materials=2;syndicate=8"
	ammo_type = "/obj/item/ammo_casing/a12mm"
	fire_sound = 'sound/weapons/Gunshot_smg.ogg'

	load_method = 2


	New()
		..()
		empty_mag = new /obj/item/ammo_magazine/a12mm/empty(src)
		update_icon()
		return


	afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag)
		..()
		if(!loaded.len && empty_mag)
			empty_mag.loc = get_turf(src.loc)
			empty_mag = null
			playsound(user, 'sound/weapons/smg_empty_alarm.ogg', 40, 1)
			update_icon()
		return


	update_icon()
		..()
		if(empty_mag)
			icon_state = "c20r-[round(loaded.len,4)]"
		else
			icon_state = "c20r"
		return

/obj/item/weapon/gun/projectile/twohanded/automatic/l6_saw
	name = "\improper L6 SAW"
	desc = "A rather traditionally made light machine gun with a pleasantly lacquered wooden pistol grip. Has 'Aussec Armoury- 2531' engraved on the reciever"
	icon_state = "l6closed100"
	item_state = "l6closedmag"
	w_class = 4
	slot_flags = 0
	max_shells = 50
	caliber = "a762"
	origin_tech = "combat=5;materials=1;syndicate=2"
	ammo_type = "/obj/item/ammo_casing/a762"
	fire_sound = 'sound/weapons/Gunshot.ogg'
	load_method = 2
	var/cover_open = 0
	var/mag_inserted = 1


/obj/item/weapon/gun/projectile/twohanded/automatic/l6_saw/attack_self(mob/user as mob)
	cover_open = !cover_open
	user << "<span class='notice'>You [cover_open ? "open" : "close"] [src]'s cover.</span>"
	update_icon()


/obj/item/weapon/gun/projectile/twohanded/automatic/l6_saw/update_icon()
	icon_state = "l6[cover_open ? "open" : "closed"][mag_inserted ? round(loaded.len, 25) : "-empty"]"


/obj/item/weapon/gun/projectile/twohanded/automatic/l6_saw/afterattack(atom/target as mob|obj|turf, mob/living/user as mob|obj, flag, params) //what I tried to do here is just add a check to see if the cover is open or not and add an icon_state change because I can't figure out how c-20rs do it with overlays
	if(cover_open)
		user << "<span class='notice'>[src]'s cover is open! Close it before firing!</span>"
	else
		..()
		update_icon()


/obj/item/weapon/gun/projectile/twohanded/automatic/l6_saw/attack_hand(mob/user as mob)
	if(loc != user)
		..()
		return	//let them pick it up
	if(!cover_open || (cover_open && !mag_inserted))
		..()
	else if(cover_open && mag_inserted)
		//drop the mag
		empty_mag = new /obj/item/ammo_magazine/a762(src)
		empty_mag.stored_ammo = loaded
		empty_mag.icon_state = "a762-[round(loaded.len, 10)]"
		empty_mag.desc = "There are [loaded.len] shells left!"
		empty_mag.loc = get_turf(src.loc)
		user.put_in_hands(empty_mag)
		empty_mag = null
		mag_inserted = 0
		loaded = list()
		update_icon()
		user << "<span class='notice'>You remove the magazine from [src].</span>"


/obj/item/weapon/gun/projectile/twohanded/automatic/l6_saw/attackby(var/obj/item/A as obj, mob/user as mob)
	if(istype(A,/obj/item/ammo_magazine/a762))
		if(!cover_open)
			user << "<span class='notice'>[src]'s cover is closed! You can't insert a new mag!</span>"
			return
		else if(cover_open && mag_inserted)
			user << "<span class='notice'>[src] already has a magazine inserted!</span>"
			return
		else if(cover_open && !mag_inserted)
			mag_inserted = 1
			user << "<span class='notice'>You insert the magazine!</span>"
			update_icon()
	..()


/* The thing I found with guns in ss13 is that they don't seem to simulate the rounds in the magazine in the gun.
   Afaik, since projectile.dm features a revolver, this would make sense since the magazine is part of the gun.
   However, it looks like subsequent guns that use removable magazines don't take that into account and just get
   around simulating a removable magazine by adding the casings into the loaded list and spawning an empty magazine
   when the gun is out of rounds. Which means you can't eject magazines with rounds in them. The below is a very
   rough and poor attempt at making that happen. -Ausops */


//FLASHLIGHT CODE FOR M39 SMG APOPHIS775 - 31JAN2015
//Moved to guns/projectile.dm and twohanded_projectile

///obj/item/weapon/gun/projectile/automatic/Assault
//	//flashlight stuff
//	var/haslight = 0 //Is there a flashlight attached?
//	var/islighton = 0
//	var/gun_light = 5 //How bright will the light be?
//
//
///obj/item/weapon/gun/projectile/automatic/Assault/verb/toggle_light()
//	set name = "Toggle Flashlight"
//	set category = "Weapon"
//
//	if(haslight && !islighton) //Turns the light on
//		usr << "\blue You turn the flashlight on."
//		usr.SetLuminosity(gun_light)
//		islighton = 1
//	else if(haslight && islighton) //Turns the light off
//		usr << "\blue You turn the flashlight off."
//		usr.SetLuminosity(0)
//		islighton = 0
//	else if(!haslight) //Points out how stupid you are
//		usr << "\red You foolishly look at where the flashlight would be, if it was attached..."
//
///obj/item/weapon/gun/projectile/automatic/Assault/pickup(mob/user)//Transfers the lum to the user when picked up
//	if(islighton)
//		SetLuminosity(0)
//		usr.SetLuminosity(gun_light)

///obj/item/weapon/gun/projectile/automatic/Assault/dropped(mob/user)//Transfers the Lum back to the gun when dropped
//	if(islighton)
//		SetLuminosity(gun_light)
//		usr.SetLuminosity(0)

