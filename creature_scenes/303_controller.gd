extends Node
	
func _ready():
	OS.open_midi_inputs()
	print(OS.get_connected_midi_inputs())

func _input(input_event):
	
	if input_event is InputEventMIDI:
		var me:InputEventMIDI = input_event
		# _print_midi_info(me)
		# print(me.message)
		if me.message == 11:
			controller_change(input_event.channel, input_event.controller_number, input_event.controller_value)
			
		if me.message == 9:	
					
			# play_note(me)
			# _print_midi_info(me)
			pass
		if me.message == 8:
			print("note off")	
	
		
func _print_midi_info(midi_event):
	
	print(midi_event)
	print("Channel ", midi_event.channel)
	print("Message ", midi_event.message)
	print("Pitch ", midi_event.pitch)
	print("Velocity ", midi_event.velocity)
	print("Instrument ", midi_event.instrument)
	print("Pressure ", midi_event.pressure)
	print("Controller number: ", midi_event.controller_number)
	print("Controller value: ", midi_event.controller_value)



# --- FIELDS ---
@export var targetSpe: float = 0.0
@export var targetBas: float = 0.0
@export var targetMul: float = 0.0
@export var targetHue: float = 0.0
@export var bhu: int = 0
@export var matchingFiles: Array = []
@export var font = null
@export var bri: int = 1
@export var exp: bool = true
@export var con: int = 0
@export var cue: int = 0
@export var arts: Array = []
@export var targetSat: float = 0.0
@export var targetAld: float = 0.0
@export var targetAlp: float = 0.0
@export var targetCqz: float = 0.0
@export var targetYaw: float = 0.0
@export var targetRol: float = 0.0
@export var duration: float = 0.0
@export var targetCCo: float = 0.0
@export var targetPit: float = 0.0

var log_message:String

func console(message):
	log_message += (message + "\n")
	
	print(message)

var vars = Dictionary()
# var labels = Array()

func variables(key, val):
	vars[key] = val
	
func show_variables():
	var i = 0
	for s in vars.keys():
		var count = $variables/GridContainer.get_child_count()
		var lab
		if i == count:
			lab	= Label.new()
			lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			$variables/GridContainer.add_child(lab)
		else:
			lab = $variables/GridContainer.get_child(i)
		i = i + 1
		lab.text = s + ":%07.3f" % float(vars[s])
		
func display_variables():
	# vars.clear()
	variables("BAS", targetBas)
	variables("SPE", targetSpe)
	variables("MUL", targetMul)
	variables("HUE", targetHue)
	variables("SAT", targetSat)
	variables("ALD", targetAld)
	variables("ALP", targetAlp)
	variables("CQZ", targetCqz)
	variables("YAW", targetYaw)
	variables("ROL", targetRol)
	variables("DUR", duration)
	variables("CCO", targetCCo)
	variables("PIT", targetPit)

	variables("BHU", bhu)
	variables("BRI", bri)
	variables("EXP", exp)
	variables("CON", con)
	variables("CUE", cue)
	variables("ARTS", arts.size())
	
	show_variables()


func _process(delta: float) -> void:
	$scroll/console.text = log_message
	# Get the ScrollContainer node
	var scroll_container = $scroll

	# Scroll to the bottom
	scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value

	# Scroll to the right edge
	scroll_container.scroll_horizontal = scroll_container.get_h_scroll_bar().max_value

	# Or both at once
	scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value
	scroll_container.scroll_horizontal = scroll_container.get_h_scroll_bar().max_value

	display_variables()

# --- CONTROLLER CHANGE FUNCTION ---
func controller_change(channel: int, number: int, value: int) -> void:
	if exp:
		console("CH %s NUM %s VA %s" % [channel, number, value])
	var clock_wise = value < 100

	if number == 7:
		targetSpe = lerp(0.0, 3.58, float(value) / 127.0)
		if exp:
			console("Z80 %.2f MHZ" % targetSpe)

	if number == 10:
		targetBas = lerp(0.0, 20.0, float(value) / 127.0)
		if exp:
			console("SAB %.2f" % targetBas)

	if number == 114:
		targetMul = lerp(0.0, 2.0, float(value) / 127.0)
		if exp:
			console("LUM %.2f" % targetMul)

	if number == 74:
		targetHue = lerp(0.0, 255.0, float(value) / 127.0)
		if exp:
			console("EUH %.2f" % targetHue)

	if number == 73 and matchingFiles.size() > 0:
		var b = int(lerp(0.0, matchingFiles.size() - 1, float(value) / 127.0))
		if b != bhu:
			bhu = b
			if bhu < 0:
				bhu = matchingFiles.size()
			bhu = bhu % matchingFiles.size()
			var fnt = str(matchingFiles[bhu])
			# font = create_font(fnt, bri) # Implement create_font if needed
			# text_font(font) # Implement text_font if needed
			# myTMoveMusextarea.setFont(font) # Implement if needed
			if exp:
				console("BHU %d" % bhu)
				console("FNT: %s" % fnt)
				console("abcdefghijklmnopqrstuvwxyz ABCDDEFGHIJKLMNOPQRSTUVWXYZ0123456789 color auto goto list run")

	if number == 18:
		con = int(lerp(0.0, 255.0, float(value) / 127.0))
		if exp:
			console("CON %d" % con)
		targetSat = lerp(0.0, 255.0, float(value) / 127.0)
		if exp:
			console("TAS %.2f" % targetSat)

	if number == 79:
		bri = int(lerp(1.0, 100.0, float(value) / 127.0))
		if exp:
			console("BRI %d" % bri)
		if matchingFiles.size() > 0:
			var fnt = str(matchingFiles[bhu])
			# font = create_font(fnt, bri)
			# text_font(font, bri)
			# myTextarea.setFont(font)
			console("abcdefghijklmnopqrstuvwxyz ABCDDEFGHIJKLMNOPQRSTUVWXYZ0123456789 color auto goto list run")

	if number == 75 and arts.size() > 0:
		cue = int(lerp(0.0, arts.size() - 1, float(value) / 127.0))
		console("EUC: %d" % cue)
		var a = arts[cue]
		console("CUE ART: %s.art" % [str(a)])
		return

	if number == 76:
		targetAld = lerp(0.0, 50.0, float(value) / 127.0)
		if exp:
			console("DAL %.2f" % targetAld)

	if number == 19:
		targetAlp = lerp(0.0, 255.0, float(value) / 127.0)
		if exp:
			console("PLA %.2f" % targetAlp)
	if number == 79:
		bri = int(lerp(1.0, 100.0, float(value) / 127.0))
		if exp:
			console("BRI %d" % bri)
		if matchingFiles.size() > 0:
			var fnt = str(matchingFiles[bhu])
			# font = create_font(fnt, bri)
			# text_font(font, bri)
			# myTextarea.setFont(font)
			console("abcdefghijklmnopqrstuvwxyz ABCDDEFGHIJKLMNOPQRSTUVWXYZ0123456789 color auto goto list run")

	if number == 71:
		targetCqz = lerp(1.0, 255.0, float(value) / 127.0)
		if exp:
			console("cqz %.2f" % targetCqz)

	if number == 77:
		targetYaw = lerp(-PI, PI, float(value) / 127.0)
		if exp:
			console("WAY %.0f" % rad_to_deg(targetYaw))

	if number == 93:
		targetRol = lerp(-PI, PI, float(value) / 127.0)
		targetRol = wrapf(targetRol, -PI, PI)
		if exp:
			console("LOR %.0f" % rad_to_deg(targetRol))

	if number == 90:
		duration = lerp(0.0, 10.0, float(value) / 127.0)
		if exp:
			console("DUR %.2f" % duration)

	if number == 91:
		targetCCo = lerp(0.0, 255.0, float(value) / 127.0)
		if exp:
			console("OCC %.2f" % targetCCo)

	if number == 17:
		targetPit = lerp(-PI, PI, float(value) / 127.0)
		targetPit = wrapf(targetPit, -PI, PI)
		if exp:
			console("TIP %.0f" % rad_to_deg(targetPit))
	
