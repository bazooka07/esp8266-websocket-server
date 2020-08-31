(function() {
	'use strict'

	const $ = function(id) { return document.getElementById(id);}

	$('setTime').onclick = function(event) {
		const d = new Date();
		ws.send('setTime=' + d.getTime());
	};
	$('relayBtn').onclick = function(event) {
		ws.send('relay=1');
	};

	const ws = new WebSocket(window.location.href.replace(/^https?/, 'ws'))

	ws.onmessage = function(event) {
		console.log('message :')
		console.log(event.data)
		const values = JSON.parse(event.data);
		console.log(values);
		$('temp').textContent = values.am2320.t;
		$('humid').textContent = values.am2320.rh;
		['relay', 'led'].forEach(function(item) {
			if(values[item] == 0) {
				$(item).classList.remove('active');
			} else {
				$(item).classList.add('active');
			}
		});
		const dt = new Date(values.time)
		$('time').textContent = dt.toISOString();
	}

	ws.onerror= function(event) {
		console.error('Error')
		console.log(event)
	}

	ws.onopen = function(event) {
		console.log('Websocket connected to ', event.target.url)
		console.log(event)

		this.send('status')
	}

	ws.onclose = function(event) {
		console.log('Websocket closed')
		console.log(event)
	}

})()
