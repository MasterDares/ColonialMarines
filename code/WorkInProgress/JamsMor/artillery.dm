#define MAX_DAMAGE_ARTILLERY 25
#define MAX_EXPLOSION_DAMAGE 5
#define MAX_HUMANDAMAGE_CHANCE 4


/obj/item/weapon/artcaller
	name = "artillery caller"
	desc = "An artillery caller needs to explode the brains."
	icon = 'icons/obj/items.dmi'
	icon_state = "artcaller"
	var/status = 0 // 0 - nothing, 1 = already called
	var/ready = 1
	var/power = 1

/obj/item/weapon/artcaller/attack_self(mob/user as mob)
	if(!power)
		user << "<font color = 'red'>This number cannot be reached at the moment, please try again later.</font>" // kekeke
		return
	else src.init(user)

/obj/item/weapon/artcaller/proc/init(mob/user as mob)
	var/dat = "<html><head><title>Personal Artillery Caller</title></head><body bgcolor=\"#808000\"><style>a, a:link, a:visited, a:active, a:hover { color: #000000; }img {border-style:none;}</style>"
	dat += "<a href='byond://?src=\ref[src];artcall=Close'>Close</a>"
	dat += "<br>"
	dat += "<h2> PERSONAL ARTILLERY CALLER BY NANOTRASEN!</h2>"
	if(ready)
		dat += "<h4>An artillery caller ready to work!</h4>"
		dat += "<font color = 'red'><a href='byond://?src=\ref[src];artcall=Call'>CALL THE ARTILLERY!</a></font>"
		dat += "<br>"
	else
		dat += "<h4><font color = 'red'> An artillery caller not ready to work!</font></h4>"
		dat += "<br>"
	if(status)
		dat += "The artillery has been called!"
	dat += "</body> </html>"
	user << browse(dat, "window=artcaller;size=300x270;border=1;can_resize=1;can_close=0;can_minimize=0")
	onclose(user, "artcaller", src)

/obj/item/weapon/artcaller/Topic(href, href_list)
	..()
	var/mob/living/U = usr
	if (usr.stat == DEAD)
		return 0

	switch(href_list["artcall"])
		if("Close")
			U << browse(null, "window=artcaller")
			return
		if("Call")
			if(U.z == 6)
				U << "Nice try!"
				return
			src.callart(U)

/obj/item/weapon/artcaller/proc/callart(mob/user as mob)
	if(!src.ready) return
	if(!locate(/obj/machinery/computer/artillery) in world) return
	for(var/obj/machinery/computer/artillery/artconsole in world)
		if(artconsole.status)
			user << "Sorry, but the artillery already called."
			src.power = !src.power
			sleep(2100)
			src.power = !src.power
			return
		if(user.z == 6)
			user << "Nice try."
			return
		artconsole.send(user)
	src.ready = 0
	sleep(3000)
	src.ready = 1
	return

/obj/machinery/computer/artillery
	name = "Artillery Console"
	desc = "This can be used for kill a somebody."
	icon_state = "artillery"
	req_access = list(access_heads)
	circuit = "/obj/item/weapon/circuitboard/artillery"
	var/power = 1
	var/needx
	var/needy
	var/needz
	var/status = 0 // 0 - nothing, 1 - artcalls

/obj/machinery/computer/artillery/New()
	..()
	src.power = 0
	sleep(12000)
	src.power = 1

/obj/machinery/computer/artillery/attack_hand(var/mob/user as mob)
	if(..()) return
//	if(!src.power)
//		user << "Sorry, but the artillery is not currently working."
//		return
	user.set_machine(src)
	var/dat = "<html><head><title> ARTILLERY CONSOLE </title></head><body>"
	dat += "<h3> WELCOME TO THE 'ARTILLERY CONSOLE'! </h3><br>"
	if(!src.status)
		dat += "There are not calls in current time!"
		dat += "</body></html>"
		user << browse(dat, "window=artillerycomputer;size=400x500")
		onclose(user, "artillerycomputer")
		return
	dat += "<h5> YOU GOT A NEW CALL IN [needx], [needy]! </h5>"
	dat += "<br><a href = '?src=\ref[src];artconsole=shoot'> SHOOT! </a><br><a href = '?src=\ref[src];artconsole=cancel;user=[user]'>Cancel</a></body></html>"
	user << browse(dat, "window=artillerycomputer;size=400x500")
	onclose(user, "artillerycomputer")

/obj/machinery/computer/artillery/proc/send(mob/user as mob)
	if(!ishuman(user)) return
	var/mob/living/carbon/human/H = user
	needx = H.x
	needy = H.y
	needz = H.z
	message_admins("Artillery called by [H.name] ([H.key]) in [H.x], [H.y], [H.z] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[H.x];Y=[H.y];Z=[H.z]'>JMP</a>)")
	log_game("Artillery called by [H.name] ([H.key]) in [H.x], [H.y], [H.z]")
	status = 1
	return

/obj/machinery/computer/artillery/Topic(href, href_list)
	if(!href_list["artconsole"]) return
	switch(href_list["artconsole"])
		if("shoot")
			//if(src.status == 0) return
			src.status = 0
			var/mob/U = href_list["user"]
//			var/area/last = U.lastarea
//			command_alert("Warning! The artillery has been called in [last.name]. The artillery will be 30 secons.", "NMV Sulaco::Arillery Alert!")
			sleep(300)
//			command_alert("Warning! The artillery has been called in [last.name]. The artillery will be NOW.", "NMV Sulaco::Arillery Alert!")
			src.BoomToTarget(needx, needy, needz)
//			command_alert("Warning! The artillery ended.", "NMV Sulaco::Arillery Alert!")
			src.needx = null
			src.needy = null
			message_admins("Artillery approved by [U.name] ([U.key]) in [U.x], [U.y], [U.z] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[U.x];Y=[U.y];Z=[U.z]'>JMP</a>)")
			log_game("Artillery called by [U.name] ([U.key]) in [U.x], [U.y], [U.z]")
			src.needz = null
			src.power = 0
			sleep(15000)
			src.power = 1
		if("cancel")
			src.status = 0
			src.needx = null
			src.needy = null

/obj/machinery/computer/artillery/proc/Shoot(var/turf/center as turf)
	var/turf/epicenter = center
	explosion(epicenter, 0, 0, MAX_EXPLOSION_DAMAGE, MAX_EXPLOSION_DAMAGE, 1)
	for(var/mob/living/carbon/C in range(4, epicenter))
		if(prob(MAX_HUMANDAMAGE_CHANCE)) C.take_overall_damage(MAX_DAMAGE_ARTILLERY, 0)
	return

/obj/machinery/computer/artillery/proc/BoomToTarget(boomx, boomy, boomz)
	if(!get_turf(locate(boomx, boomy, boomz))) return
	var/turf/center = get_turf(locate(boomx, boomy, boomz))
	var/rockets = rand(10, 15)
	for(var/turf/T in range(15, center))
		if(!rockets) return
		if(prob(2))
			src.Shoot(T)
			rockets--
			sleep(50)
	return

/obj/item/weapon/circuitboard/artillery
	name = "Circuit board (Artillery  Console)"
	build_path = "/obj/machinery/computer/artillery"

/obj/structure/artillery
	name = "Artillery"
	desc = "A big artillery, used for... help...."
	icon = 'icons/obj/machines/artillery.dmi'
	icon_state = "none"
	anchored = 1
	density = 1