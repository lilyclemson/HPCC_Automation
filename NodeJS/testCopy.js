const gitP = require('simple-git/promise');
const REPO = 'https://github.com/CSSEGISandData/COVID-19.git';
const path = require('path');

// gitP().silent(true)
//   .clone(REPO)
//   .then(() => console.log('finished'))
//   .catch((err) => console.error('failed: ', err));

const git = require('simple-git')('./COVID-19');
const fs = require('fs');
let request = require('request-promise');

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
    console.log('pull done.');
    fileList.forEach( async (item) => {
      console.log(typeof(item));
      if(item.startsWith('csse_covid_19_data/csse_covid_19_daily_reports/') === true
         && item.search('.csv') != -1){
        let uploadResponse = await upload(item);
      }
    });
  });


let upload = (filename) => {
  let todaysFileName = filename;
  let todaysFilePath = path.join(__dirname, 'COVID-19/' + todaysFileName);
  return new Promise((resolve, reject) => {
    if (fs.existsSync(todaysFilePath)) {
      let _destPath = '.';
      let _clusterAddrAndPort = 'http://40.71.7.106:8010/';
      let _ClusterIP = '10.0.0.6';
      let _filename = todaysFileName,
        _mimetype = 'text/csv',
        _fileStream = fs.createReadStream(todaysFilePath),
        _clusterFilename = path.basename(todaysFileName);
        request({
          method: 'POST',
          auth: {'user':'xulili01', 'password':'Q4dRtHRF'},
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
          console.log('End of upload');
          resolve(response);
        }).catch((err) => {
          console.log(err);
          reject(err);

        })
      }
    }
)}




