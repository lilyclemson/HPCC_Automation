var today = new Date();

var date = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();

console.log(date);

var today = new Date();

var time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
console.log(time);

datetime = date + ' ' + time;
console.log(datetime);