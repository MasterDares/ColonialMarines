/obj/structure/clockedset/firstaidcabinet
	name = "First-Aid Cabinet"
	desc = "Nadpis' pod shkafchikom: \"Golub' - huesos\"."
	var/obj/item/weapon/storage/firstaid/regular = new/obj/item/weapon/storage/firstaid/regular
	icon = 'icons/obj/closet.dmi'
	icon_state = "firstaidcabinet"
	anchored = 1
	density = 0
	var/opened = 1
	var/hitstaken = 0
	var/locked = 1
	var/smashed = 0

	attackby(var/obj/item/O as obj, var/mob/user as mob)
		if (isrobot(usr) || src.locked)
			if(istype(O, /obj/item/device/multitool))
				user << "\red Resetting circuitry..."
				playsound(user, 'sound/machines/lockreset.ogg', 50, 1)
				sleep(50) // Sleeping time~
				src.locked = 0
				user << "\blue You disable the lockedcking modules."
				return
			else if(istype(O, /obj/item/weapon))
				var/obj/item/weapon/W = O
				if(src.smashed || src.opened)
					if(opened)
						opened = 0
						icon_state = "firstaidcabinet"
						spawn(10) update_icon()
					return
				if(W.force < 4)
					user << "\blue The cabinet's protective glass glances off the hitstaken."
					playsound(user, 'sound/effects/Glasshit.ogg', 100, 1)
				else
					playsound(user, 'sound/effects/Glasshit.ogg', 100, 1)
					user << "\blue You hit the glass."
					src.hitstaken++
					if(src.hitstaken == 2)
						src.smashed = 1
						src.locked = 0
						src.opened = 1
						icon_state = "firstaidcabinet_1"
						playsound(src.loc, 'sound/effects/WOOP-WOOP.ogg', 100, 1)
						user << "\blue ti sromal fuckin steklo."
				update_icon()
			return

	attack_hand(mob/user as mob)

		if(src.locked)
			user <<"\red The cabinet won't budge!"
			return
		if(src.opened)
			if(regular)
				user.put_in_hands(regular)
				regular = null
				user << "\blue You take the first-aid kit from the [name]."
				src.add_fingerprint(user)
				icon_state = "firstaidcabinet_2"
				update_icon()

	attack_tk(mob/user as mob)
		if(opened && regular)
			regular.loc = loc
			user << "\blue You telekinetically remove the first-aid kit."
			regular = null
			update_icon()
			return
		attack_hand(user)

	verb/toggle_openness() //nice name, huh? HUH?! -Erro //YEAH -Agouri
		set name = "Open/Close"
		set category = "Object"

		if (isrobot(usr) || src.locked || src.smashed)
			if(src.locked)
				usr << "\red The cabinet won't budge!"
			else if(src.smashed)
				usr << "\blue The protective glass is broken!"
			return

		update_icon()

	attack_paw(mob/user as mob)
		attack_hand(user)
		return

	attack_ai(mob/user as mob)
		if(src.smashed)
			user << "\red The security of the cabinet is compromised."
			return
		else
			locked = !locked
			if(locked)
				user << "\red Cabinet locked."
			else
				user << "\blue Cabinet unlocked."
			return
