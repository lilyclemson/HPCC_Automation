let path = require('path');
let schedule = require('node-schedule');
let git = require('simple-git')('./covid-19-data');
let fs = require('fs');
let request = require('request-promise');
require('dotenv').config();


hostname = process.env.DB_HOSTNAME_NEWAZURE;
lzip = process.env.DB_LZIP_NEWAZURE;


 
// let REPO = 'https://github.com/CSSEGISandData/COVID-19.git';
// gitP().silent(true)
//   .clone(REPO)
//   .then(() => console.log('finished'))
//   .catch((err) => console.error('failed: ', err));

// let j = schedule.scheduleJob('59 0-23/2 * * *', function(){
let j = schedule.scheduleJob('* * * * *', function(){
  let today = new Date();
  let date = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
  let time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
  let datetime = date + ' ' + time;
  console.log('Scheduler Start at ' + datetime);

let fileList = [];
git
  .exec(() => console.log('Starting pull...'))
  .pull('origin', 'master' ,(err, update) => {
      console.log(update);
      if(update && update.summary.changes) {
        fileList = update.files;
        console.log(fileList);
      }
   })
  .exec(() => {
    console.log('Pull Finished\n');
    fileList.forEach( async (item) => {
      console.log(typeof(item));
      if(item.search('vaccinations/vaccinations.csv') != -1
         || item.search('vaccinations/us_state_vaccinations.csv') != -1){
          dirList = item.split('/');
          //  console.log(dirList);
          dir0 = 'public/data/vaccinations/';
          dir1 = dirList[dirList.length - 1];
          newName =  dir0 + '' + dir1 ;
          console.log(newName);
        let uploadResponse = await upload(newName);
      }
    });
  });


let upload = (filename) => {
  let todaysFileName = filename;
  let todaysFilePath = path.join(__dirname, 'covid-19-data/' + todaysFileName);
  return new Promise((resolve, reject) => {
    if (fs.existsSync(todaysFilePath)) {
      let _clusterAddrAndPort = hostname;
      let _ClusterIP = lzip;
      let _mimetype = 'text/csv';
      let _fileStream = fs.createReadStream(todaysFilePath);
      let _clusterFilename = path.basename(todaysFileName);
        request({
          method: 'POST',
          uri: _clusterAddrAndPort + '/Filespray/UploadFile.json?upload_' +
            '&NetAddress=' + _ClusterIP + '&rawxml_=1&OS=2&' +
            'Path=/var/lib/HPCCSystems/mydropzone/hpccsystems/covid19/file/raw/',
          formData: {
            'UploadedFiles[]': {
              value: _fileStream,
              options: {
                filename: _clusterFilename,
                contentType: _mimetype
              }
            },
          },
          resolveWithFullResponse: true
        }).then((response) => {
          console.log(response.body);
          console.log('Upload Finished\n');
          resolve(response);
        }).catch((err) => {
          console.log(err);
          reject(err);
        })
      }else {console.log(todaysFilePath + ' !')}
    } 
  )}
});