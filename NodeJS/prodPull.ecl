let path = require('path');
let schedule = require('node-schedule');
let git = require('simple-git')('./COVID-19');
let fs = require('fs');
let request = require('request-promise');
require('dotenv').config();


hostname = process.env.DB_HOSTNAME_PROD;
lzip = process.env.DB_LZIP_PROD;




let j = schedule.scheduleJob('0 0-23/4 * * *', function(){
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
      // console.log(typeof(item));
      if(item.search('csse_covid_19_daily_reports/') != -1
         && item.search('.csv') != -1){
           console.log(item);
          //  console.log(item + ' is uploading to AWS');
        // let uploadResponseAzure = await upload2Azure(item);
        let uploadResponseAWS = await upload2PROD(item);
      }
    });
  });


  let upload2PROD = (filename) => {
  let todaysFileName = filename;
  let todaysFilePath = path.join(__dirname, 'COVID-19/' + todaysFileName);
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