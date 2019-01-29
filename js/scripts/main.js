var dog = null;

function init() {
	dog = Asset.create(1, 'dog', 'gfx/dog.png', 0);
	Asset.loadAll();
}

function update(dt) {
}

function draw(w, h) {
	Draw.clear();
 	Draw.image(dog, 20, 20, 0, 0, 1.0, 1.0, 0, 0, 0);
	Draw.submit();
}