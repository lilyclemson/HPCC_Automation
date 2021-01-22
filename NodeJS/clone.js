let git = require('simple-git');

let REPO = 'https://github.com/CSSEGISandData/COVID-19.git';
git().silent(true)
  .clone(REPO)
  .then(() => console.log('finished'))