//Variables
var width = window.innerWidth * 0.7;
var height = window.innerHeight * 0.9;
var days = {0: 'Sunday', 1: 'Monday', 2: 'Tuesday', 3: 'Wednesday',
    4: 'Thursday', 5: 'Friday', 6: 'Saturday'};
var hour = 0;
var day = 0;
var max_weight = 1650;
//Functions
var day_text = function(text) {
    svg.selectAll('.day')
        .transition()
        .text(text);
};
var hour_text = function(text) {
    svg.selectAll('.hour')
        .transition()
        .text(text);
};
var ready = function(error, ivory, weights) {
    svg.append('g')
        .attr('class', 'counties')
        .selectAll('path')
        .data(ivory.features)
        .enter().append('path')
        .attr('d', path)
    day_text('Sunday');
    hour_text('12:00 AM');
    redraw(error, weights);
};
var redraw = function(error, weights) {
    var rateById = {};
    weights.forEach(function(d) { rateById[d.id] = +d.weight; });
    svg.selectAll('path')
        .transition()
        .duration(750)
        .attr('fill', function(d) { return color(rateById[d.id] || 1); });
};
function increase_day(current) {return (current != 6) ? Math.min(6, current + 1) : 0;}
function decrease_day(current) {return (current != 0) ? Math.max(0, current - 1) : 6;}
function increase_hour(current) {return (current != 23) ? Math.min(23, current + 1) : 0;}
function decrease_hour(current) {return (current != 0) ? Math.max(0, current - 1) : 23;}
var update = function() {
    adjusted_hour = (hour % 12 != 0) ? hour % 12 : 12;
    suffix = (hour / 12 != 1) ?  'AM': 'PM';
    hour_text(adjusted_hour + ':00 ' + suffix);
    day_text(days[day]);
    queue()
        .defer(d3.csv, 'data/weights' + day + '_' + hour + '.csv')
        .await(redraw);
}
//where the magic is!
var color = d3.scale.log()
    .range(['#BFD3E6', '#49006A'])
    .domain([1, max_weight])
    .clamp(true);
var projection = d3.geo.mercator()
    .center([7.1317, 5.5230])
    .translate([width / 2, 2 * height / 3])
    .rotate([9, -0.75])
    .scale(20000);
var path = d3.geo.path()
    .projection(projection);
var svg = d3.select('body').append('svg')
    .attr('width', width)
    .attr('height', height);
svg.append('text')
    .attr('class', 'hour')
    .attr('transform', 'translate(' + (width / 2) + ', ' + ((height / 2) + 60) + ')')
svg.append('text')
    .attr('class', 'day')
    .attr('transform', 'translate(' + (width / 2) + ', ' + height / 2 + ')')
queue()
    .defer(d3.json, 'data/ivory.geojson')
    .defer(d3.csv, 'data/weights0_0.csv')
    .await(ready);
window.focus();
d3.select(window).on('keydown', function() {
    switch (d3.event.keyCode) {
        case 37: hour = decrease_hour(hour); break;
        case 39: hour = increase_hour(hour); break;
        case 38: day = decrease_day(day); break;
        case 40: day = increase_day(day); break;
    }
    update();
});