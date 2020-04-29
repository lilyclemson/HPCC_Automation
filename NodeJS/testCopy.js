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


// git('./COVID-19')
// git
//   .fetch('upstream', 'master', console.log.bind(console))
//   .diff(['master', 'upstream/master', '--name-only'] ,  console.log.bind(console));


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
  let today = new Date();
  let todaysFileName = filename;
  // let todaysFileName = ("0" + (today.getMonth() + 1)).slice(-2) + '-' + ("0" + today.getDate()).slice(-2) + '-' + today.getFullYear()+'.csv';
  // let todaysFilePath = path.join(__dirname, 'COVID-19/COVID-19/csse_covid_19_data/csse_covid_19_daily_reports/'+todaysFileName);
  let todaysFilePath = path.join(__dirname, 'COVID-19/' + todaysFileName);
  return new Promise((resolve, reject) => {
    if (fs.existsSync(todaysFilePath)) {
      let _destPath = '.';
      let _clusterAddrAndPort = 'http://40.71.7.106:8010';
      let _ClusterIP = '10.0.0.6';
      let _filename = todaysFileName,
        _mimetype = 'text/csv',
        _fileStream = fs.createReadStream(todaysFilePath),
        _clusterFilename = path.basename(todaysFileName);
7
        request({
          method: 'POST',
          uri: _clusterAddrAndPort + '/Filespray/UploadFile.json?upload_' +
            '&NetAddress=' + _ClusterIP + '&rawxml_=1&OS=2&' +
            'Path=/var/lib/HPCCSystems/mydropzone/hpccsystems/covid19/file/raw/johnhopkins/v2/',
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




