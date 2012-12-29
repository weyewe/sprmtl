$(function () {
	
var data = [
	{ label: "Store 1", data: Math.floor (Math.random() * 100 + 650) }, 
	{ label: "Store 2", data: Math.floor (Math.random() * 100 + 250) }, 
	{ label: "Store 3", data: Math.floor (Math.random() * 100 + 50) }
];
			
Charts.donut ('#donut-chart', data);
	
});