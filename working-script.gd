extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -500.0
const MAX_JUMPS = 2

@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
var jump_count = 0

# JSON Input System
var input_state = {
	"left": false,
	"right": false,
	"jump": false,
	"button1": false,
	"button2": false,
	"button3": false,
	"button4": false
}
var prev_jump_state = false
var json_path = "input_data.json"  # Match Python script path

func _ready():
	# Set up JSON input polling
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.1  # 100ms update interval
	timer.timeout.connect(_update_input_state)
	timer.start()

func _update_input_state():
	# Read JSON file using FileAccess
	if FileAccess.file_exists(json_path):
		var file = FileAccess.open(json_path, FileAccess.READ)
		var json = JSON.new()  # Create an instance of JSON
		var result = json.parse(file.get_as_text())  # Parse the JSON data
		file.close()
		
		if result == OK:  # Check if parsing was successful
			input_state = json.get_data()  # Get the parsed data

func _physics_process(delta: float) -> void:
	# Animations
	if velocity.x != 0:
		sprite_2d.animation = "running"
	else:
		sprite_2d.animation = "default"
	
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
		sprite_2d.animation = "jumping"
	else:
		jump_count = 0

	# Jump handling (edge detection)
	var jump_just_pressed = input_state.jump && !prev_jump_state
	if jump_just_pressed and jump_count < MAX_JUMPS:
		velocity.y = JUMP_VELOCITY
		jump_count += 1
	prev_jump_state = input_state.jump

	# Movement from JSON input
	var direction = 0
	if input_state.left:
		direction -= 1
	if input_state.right:
		direction += 1
		
	velocity.x = direction * SPEED
	if direction == 0:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	sprite_2d.flip_h = velocity.x < 0 if velocity.x != 0 else sprite_2d.flip_h
