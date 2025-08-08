extends CanvasLayer

@onready var oxigen_amount: Label = $Oxigen/Amount
@onready var o_2_timer: Timer = $Oxigen/O2Timer

var max_oxigen:= 100
var current_oxigen := 0

func _ready() -> void:
	GameManager.is_in_water.connect(manage_oxigen)
	GameManager.is_damaged.connect(reduce_oxigen)
	current_oxigen = max_oxigen
	oxigen_amount.text = str(current_oxigen)


	
func manage_oxigen(in_water):
	if in_water:		
		o_2_timer.start()
	else:
		current_oxigen = max_oxigen
		o_2_timer.stop()
		oxigen_amount.text = str(current_oxigen)

func reduce_oxigen(amount):
	if current_oxigen>0:
		current_oxigen -= amount
		oxigen_amount.text = str(current_oxigen)
	

func _on_o_2_timer_timeout() -> void:
	reduce_oxigen(1)
