/obj/machinery/monkey_recycler
	name = "Monkey Recycler"
	desc = "A machine used for recycling dead monkeys into monkey cubes."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "grinder"
	layer = 2.9
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 50
	var/grinded = 0
	var/required_grind = 5
	var/cube_production = 1

/obj/machinery/monkey_recycler/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/monkey_recycler(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	RefreshParts()

/obj/machinery/monkey_recycler/RefreshParts()
	var/req_grind = 5
	var/cubes_made = 1
	for(var/obj/item/weapon/stock_parts/manipulator/B in component_parts)
		req_grind -= B.rating
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		cubes_made = M.rating
	cube_production = cubes_made
	required_grind = req_grind

/obj/machinery/monkey_recycler/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if(default_deconstruction_screwdriver(user, "grinder_open", "grinder", O))
		return

	if(exchange_parts(user, O))
		return

	if(default_unfasten_wrench(user, O))
		power_change()
		return

	default_deconstruction_crowbar(O)

	if (src.stat != 0) //NOPOWER etc
		return
	if (istype(O, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = O
		var/grabbed = G.affecting
		if(istype(grabbed, /mob/living/carbon/human))
			var/mob/living/carbon/human/target = grabbed
			if(issmall(target))
				if(target.stat == 0)
					user << "\red The monkey is struggling far too much to put it in the recycler."
				else
					user.drop_item()
					qdel(target)
					user << "\blue You stuff the monkey in the machine."
					playsound(src.loc, 'sound/machines/juicer.ogg', 50, 1)
					var/offset = prob(50) ? -2 : 2
					animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = 200) //start shaking
					use_power(500)
					src.grinded++
					sleep(50)
					pixel_x = initial(pixel_x)
					user << "\blue The machine now has [grinded] monkeys worth of material stored."
			else
				user << "\red The machine only accepts monkeys!"
		else
			user << "\red The machine only accepts monkeys!"
	return

/obj/machinery/monkey_recycler/attack_hand(var/mob/user as mob)
	if (src.stat != 0) //NOPOWER etc
		return
	if(grinded >= required_grind)
		user << "\blue The machine hisses loudly as it condenses the grinded monkey meat. After a moment, it dispenses a brand new monkey cube."
		playsound(src.loc, 'sound/machines/hiss.ogg', 50, 1)
		grinded -= 5
		new /obj/item/weapon/reagent_containers/food/snacks/monkeycube/wrapped(src.loc)
		user << "\blue The machine's display flashes that it has [grinded] monkeys worth of material left."
	else
		user << "\red The machine needs at least [required_grind] monkey\s worth of material to produce a monkey cube. It only has [grinded]."
	return
