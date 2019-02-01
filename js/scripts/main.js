Duktape.errCreate = function (err) {
    try {
        if (typeof err === 'object' &&
            typeof err.message !== 'undefined' &&
            typeof err.lineNumber === 'number') {
            err.message = err.message + ' (line ' + err.lineNumber + ')';
        }
    } catch (e) {
        // ignore; for cases such as where "message" is not writable etc
    }
    return err;
}

var drawDog = require('dog');
var dog = null;

function init() {
	dog = Asset.create(1, 'dog', 'gfx/dog.png', 0);
	Asset.loadAll();
}

function update(dt) {
}

function draw(w, h) {
	Draw.clear();
 	// Draw.image(dog, 20, 20, 0, 0, 1.0, 1.0, 0, 0, 0);
 	drawDog(dog);
	Draw.submit();
}