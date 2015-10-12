/obj/structure/closet/firstaidcabinet
	name = "First-Aid Cabinet"
	desc = "Nadpis' pod shkafchikon: \"Golub' - huesos\"."
	var/obj/item/weapon/storage/firstaid/regular = new/obj/item/weapon/storage/firstaid/regular
	icon_state = "firstaidcabinet1000"
	icon_closed = "firstaidcabinet1000"
	icon_opened = "firstaidcabinet1100"
	anchored = 1
	density = 0
	var/localopened = 0 //Setting this to keep it from behaviouring like a normal closet and obstructing movement in the map. -Agouri
	opened = 1
	var/hitstaken = 0
	var/locked = 1
	var/smashed = 0

	attackby(var/obj/item/O as obj, var/mob/user as mob)  //Marker -Agouri
		//..() //That's very useful, Erro

		var/haskit = 0       //gonna come in handy later~
		if(regular)
			haskit = 1

		if (isrobot(usr) || src.locked)
			if(istype(O, /obj/item/device/multitool))
				user << "\red Resetting circuitry..."
				playsound(user, 'sound/machines/lockreset.ogg', 50, 1)
				sleep(50) // Sleeping time~
				src.locked = 0
				user << "\blue You disable the locking modules."
				update_icon()
				return
			else if(istype(O, /obj/item/weapon))
				var/obj/item/weapon/W = O
				if(src.smashed || src.localopened)
					if(localopened)
						localopened = 0
						icon_state = text("firstaidcabinet[][][][]closing",haskit,src.localopened,src.hitstaken,src.smashed)
						spawn(10) update_icon()
					return
				if(W.force < 1)
					user << "\blue The cabinet's protective glass glances off the hit."
					playsound(user, 'sound/effects/Glasshit.ogg', 100, 1)
				else
					playsound(user, 'sound/effects/Glasshit.ogg', 100, 1)
					src.hitstaken++
					if(src.hitstaken == 2)
//						playsound(user, 'sound/effects/Glassbr3.ogg', 100, 1) //Break cabinet, receive goodies. Cabinet's fucked for life after that.
						src.smashed = 1
						src.locked = 0
						src.localopened = 1
						playsound(src.loc, 'sound/effects/WOOP-WOOP.ogg', 100, 1)
				update_icon()
			return
		if (istype(O, /obj/item/weapon/storage/firstaid/regular) && src.localopened)
			if(!regular)
				if(O:wielded)
					user << "\red Unwield the kit first."
					return
				regular = O
				user.drop_item(O)
				src.contents += O
				user << "\blue You place the first-aid kit back in the [src.name]."
				update_icon()
			else
				if(src.smashed)
					return
				else
					localopened = !localopened
					if(localopened)
						icon_state = text("firstaidcabinet[][][][]opening",haskit,src.localopened,src.hitstaken,src.smashed)
						spawn(10) update_icon()
					else
						icon_state = text("firstaidcabinet[][][][]closing",haskit,src.localopened,src.hitstaken,src.smashed)
						spawn(10) update_icon()
		else
			if(src.smashed)
				return
			if(istype(O, /obj/item/device/multitool))
				if(localopened)
					localopened = 0
					icon_state = text("firstaidcabinet[][][][]closing",haskit,src.localopened,src.hitstaken,src.smashed)
					spawn(10) update_icon()
					return
				else
					user << "\red Resetting circuitry..."
					sleep(50)
					src.locked = 1
					user << "\blue You re-enable the locking modules."
					playsound(user, 'sound/machines/lockenable.ogg', 50, 1)
					return
			else
				localopened = !localopened
				if(localopened)
					icon_state = text("firstaidcabinet[][][][]opening",haskit,src.localopened,src.hitstaken,src.smashed)
					spawn(10) update_icon()
				else
					icon_state = text("firstaidcabinet[][][][]closing",haskit,src.localopened,src.hitstaken,src.smashed)
					spawn(10) update_icon()




	attack_hand(mob/user as mob)

		var/haskit = 0
		if(regular)
			haskit = 1

		if(src.locked)
			user <<"\red The cabinet won't budge!"
			return
		if(localopened)
			if(regular)
				user.put_in_hands(regular)
				regular = null
				user << "\blue You take the kit from the [name]."
				src.add_fingerprint(user)
				update_icon()
			else
				if(src.smashed)
					return
				else
					localopened = !localopened
					if(localopened)
						src.icon_state = text("firstaidcabinet[][][][]opening",haskit,src.localopened,src.hitstaken,src.smashed)
						spawn(10) update_icon()
					else
						src.icon_state = text("firstaidcabinet[][][][]closing",haskit,src.localopened,src.hitstaken,src.smashed)
						spawn(10) update_icon()

		else
			localopened = !localopened //I'm pretty sure we don't need an if(src.smashed) in here. In case I'm wrong and it fucks up teh cabinet, **MARKER**. -Agouri
			if(localopened)
				src.icon_state = text("firstaidcabinet[][][][]opening",haskit,src.localopened,src.hitstaken,src.smashed)
				spawn(10) update_icon()
			else
				src.icon_state = text("firstaidcabinet[][][][]closing",haskit,src.localopened,src.hitstaken,src.smashed)
				spawn(10) update_icon()

	attack_tk(mob/user as mob)
		if(localopened && regular)
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

		localopened = !localopened
		update_icon()

	verb/remove_fire_axe()
		set name = "Remove First-Aid Kit"
		set category = "Object"

		if (isrobot(usr))
			return

		if (localopened)
			if(regular)
				usr.put_in_hands(regular)
				regular = null
				usr << "\blue You take the First-Aid Kit from the [name]."
			else
				usr << "\blue The [src.name] is empty."
		else
			usr << "\blue The [src.name] is closed."
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

	update_icon()
		var/haskit = 0
		if(regular)
			haskit = 1
		icon_state = text("firstaidcabinet[][][][]",haskit,src.localopened,src.hitstaken,src.smashed)

	open()
		return

	close()
		return