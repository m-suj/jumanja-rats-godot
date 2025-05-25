extends Node
class_name labyrinth_pathfinding

@export var start_pos = Vector2i(1, 1)
@export var end_pos = Vector2i(1, 2)
var _labyrinth_text: Array[String]
var _rows: int
var _cols: int


func _ready() -> void:
	var file = FileAccess.open("res://assets/labyrinth.txt", FileAccess.READ)
	while !file.eof_reached():
		var line = file.get_line()
		_labyrinth_text.append(line)
	file.close()
	
	# _labyrinth_text = _labyrinth_text.slice(0, -1)
	_rows = len(_labyrinth_text)
	_cols = len(_labyrinth_text[0])
	
	var path = find_path(start_pos, end_pos)
	if path and len(path) > 0:
		for pos in path:
			print(pos)
	else:
		print("Brak ścieżki")


func find_path(start: Vector2i, end: Vector2i):
	if !_is_in_bounds(start) or !_is_in_bounds(end) or _is_wall(start) or _is_wall(end):
		return []
	
	var visited = []
	for i in range(_rows):
		visited.append([])
		for j in range(_cols):
			visited[i].append(false)
	
	var parent = []
	for i in range(_rows):
		parent.append([])
		for j in range(_cols):
			parent[i].append(null)
	
	var queue: Array[Vector2i] = []
	queue.push_back(start)
	visited[start.x][start.y] = true
	var directions: Array[Vector2] = [
		Vector2i(-1, 0),  # up
		Vector2i(1, 0),  # down
		Vector2i(0, -1),  # left
		Vector2i(0, 1)  # right
	]
	
	while len(queue) > 0:
		var current = queue.pop_front()
		if current == end:
			return _reconstruct_path(parent, end)
		
		for dir in directions:
			var next = Vector2i(current.x + dir.x, current.y + dir.y)
			if !_is_in_bounds(next) or _is_wall(next) or visited[next.x][next.y]: continue
			visited[next.x][next.y] = true
			parent[next.x][next.y] = current
			queue.push_back(next)
		
	return null


func _reconstruct_path(parent, end: Vector2i):
	var path: Array[Vector2i] = []
	var current = end
	
	while parent[current.x][current.y]:
		path.append(current)
		current = parent[current.x][current.y]
	
	path.append(current)
	path.reverse()
	return path


func _is_in_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < _rows and pos.y >= 0 and pos.y < _cols;

func _is_wall(pos: Vector2i) -> bool:
	return _labyrinth_text[pos.x][pos.y] == '#'
