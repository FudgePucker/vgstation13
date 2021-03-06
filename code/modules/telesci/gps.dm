var/list/GPS_list = list()
/obj/item/device/gps
	name = "global positioning system"
	desc = "Helping lost spacemen find their way through the planets since 2016."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "gps-c"
	w_class = 2.0
	flags = FPRINT
	slot_flags = SLOT_BELT
	origin_tech = "bluespace=2;magnets=2"
	var/gpstag = "COM0"
	var/emped = 0

/obj/item/device/gps/New()
	..()
	GPS_list.Add(src)
	name = "global positioning system ([gpstag])"
	overlays += "working"

/obj/item/device/gps/Destroy()
	GPS_list.Remove(src)
	..()

/obj/item/device/gps/emp_act(severity)
	emped = 1
	overlays -= "working"
	overlays += "emp"
	spawn(300)
		emped = 0
		overlays -= "emp"
		overlays += "working"

/obj/item/device/gps/attack_self(mob/user as mob)
	var/obj/item/device/gps/t = ""
	if(emped)
		t += "ERROR"
	else
		t += "<BR><A href='?src=\ref[src];tag=1'>Set Tag</A> "
		t += "<BR>Tag: [gpstag]"

		for(var/obj/item/device/gps/G in GPS_list)
			var/turf/pos = get_turf(G)
			var/area/gps_area = get_area(G)
			var/tracked_gpstag = G.gpstag
			if(G.emped == 1)
				t += "<BR>[tracked_gpstag]: ERROR"
			else
				t += "<BR>[tracked_gpstag]: [format_text(gps_area.name)] ([pos.x-WORLD_X_OFFSET], [pos.y-WORLD_Y_OFFSET], [pos.z])"

	var/datum/browser/popup = new(user, "GPS", name, 600, 450)
	popup.set_content(t)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/item/device/gps/examine(mob/user)
	if (Adjacent(user) || isobserver(user))
		src.attack_self(user)
	else
		..()

/obj/item/device/gps/Topic(href, href_list)
	..()
	if(href_list["tag"])
		if (isobserver(usr))
			usr << "No way."
			return
		if (usr.get_active_hand() != src || usr.stat) //no silicons allowed
			usr << "<span class = 'caution'>You need to have the GPS in your hand to do that!</span>"
			return

		var/a = input("Please enter desired tag.", name, gpstag) as text|null
		if (!a) //what a check
			return

		if (usr.get_active_hand() != src || usr.stat) //second check in case some chucklefuck drops the GPS while typing the tag
			usr << "<span class = 'caution'>The GPS needs to be kept in your active hand!</span>"
			return
		a = copytext(sanitize(a), 1, 20)
		if(length(a) != 4)
			usr << "<span class = 'caution'>The tag must be four letters long!</span>"
			return

		else
			gpstag = a
			name = "global positioning system ([gpstag])"
			return

/obj/item/device/gps/science
	icon_state = "gps-s"
	gpstag = "SCI0"

/obj/item/device/gps/engineering
	icon_state = "gps-e"
	gpstag = "ENG0"

/obj/item/device/gps/paramedic
	icon_state = "gps-p"
	gpstag = "PMD0"

/obj/item/device/gps/mining
	desc = "A more rugged looking GPS device. Useful for finding miners. Or their corpses."
	icon_state = "gps-m"
	gpstag = "MIN0"
