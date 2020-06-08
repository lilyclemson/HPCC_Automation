let path = require('path');
let schedule = require('node-schedule');
let git = require('simple-git')('./COVID-19');
let fs = require('fs');
let request = require('request-promise');
require('dotenv').config();

username =  process.env.DB_USERNAME;
password = process.env.DB_PASSWORD;
hostname_aws = process.env.DB_HOSTNAME_AWS;
lzip_aws = process.env.DB_LZIP_AWS;
hostname_azure = process.env.DB_HOSTNAME_AZURE;
lzip_azure = process.env.DB_LZIP_AZURE;


// let git = require('simple-git');
// let REPO = 'https://github.com/CSSEGISandData/COVID-19.git';
// git().silent(true)
//   .clone(REPO)
//   .then(() => console.log('finished'))

let j = schedule.scheduleJob('* * 0-23/6 * * *', function(){
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
        // console.log(fileList);
      }
   })
  .exec(() => {
    console.log('Pull Finished\n');
    fileList.forEach( async (item) => {
      console.log(typeof(item));
      if(item.startsWith('csse_covid_19_data/csse_covid_19_daily_reports/') === true
         && item.search('.csv') != -1){
        let uploadResponseAzure = await upload2Azure(item);
        let uploadResponseAWS = await upload2AWS(item);
      }
    });
  });


let upload2Azure = (filename) => {
  let todaysFileName = filename;
  let todaysFilePath = path.join(__dirname, 'COVID-19/' + todaysFileName);
  return new Promise((resolve, reject) => {
    if (fs.existsSync(todaysFilePath)) {
      let _clusterAddrAndPort = hostname_azure;
      let _ClusterIP = lzip_azure;
      let _mimetype = 'text/csv';
      let _fileStream = fs.createReadStream(todaysFilePath);
      let _clusterFilename = path.basename(todaysFileName);
        request({
          method: 'POST',
          auth: {'user' : username, 'password' : password},
          uri: _clusterAddrAndPort + '/Filespray/UploadFile.json?upload_' +
            '&NetAddress=' + _ClusterIP + '&rawxml_=1&OS=2&' +
            'Path=/var/lib/HPCCSystems/mydropzone/hpccsystems/covid19/file/raw/JohnHopkins/V2/',
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
      }
    }
  )}


  let upload2AWS = (filename) => {
  let todaysFileName = filename;
  let todaysFilePath = path.join(__dirname, 'COVID-19/' + todaysFileName);
  return new Promise((resolve, reject) => {
    if (fs.existsSync(todaysFilePath)) {
      let _clusterAddrAndPort = hostname_aws;
      let _ClusterIP = lzip_aws;
      let _mimetype = 'text/csv';
      let _fileStream = fs.createReadStream(todaysFilePath);
      let _clusterFilename = path.basename(todaysFileName);
        request({
          method: 'POST',
          uri: _clusterAddrAndPort + '/Filespray/UploadFile.json?upload_' +
            '&NetAddress=' + _ClusterIP + '&rawxml_=1&OS=2&' +
            'Path=/var/lib/HPCCSystems/mydropzone/hpccsystems/covid19/file/raw/JohnHopkins/V2/',
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
      }
    }
  )}
});