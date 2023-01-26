class subscription:
	var list : Array
	func _init():
		list = []
	func subscribe(a):
		if !list.has(a):
			list.append(a)
	func unsubscribe(a):
		if list.has(a):
			list.erase(a)
	func is_empty():
		return list.is_empty()
	func clear():
		list = []
