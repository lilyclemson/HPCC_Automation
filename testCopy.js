const gitP = require('simple-git/promise');
const REPO = 'https://github.com/CSSEGISandData/COVID-19.git';
var path = require('path');
// gitP().silent(true)
//   .clone(REPO)
//   .then(() => console.log('finished'))
//   .catch((err) => console.error('failed: ', err));

const git = require('simple-git');
const fs = require('fs');
let request = require('request-promise');


// fileList = git('./COVID-19')
//                 .fetch('upstream', 'master', console.log.bind(console))
//                 .diff(['master', 'upstream/master', '--name-only'] ,  console.log.bind(console));

git('./COVID-19')
  .exec(() => console.log('Starting pull...'))
  .pull((err, update) => {
      if(update && update.summary.changes) {
         
      }
   })
  .exec(() => {
    console.log('pull done.');
    upload();
  });


let upload = () => {
  let today = new Date();
  let todaysFileName = ("0" + (today.getMonth() + 1)).slice(-2) + '-' + ("0" + today.getDate()).slice(-2) + '-' + today.getFullYear()+'.csv';
  let todaysFilePath = path.join(__dirname, 'COVID-19/COVID-19/csse_covid_19_data/csse_covid_19_daily_reports/'+todaysFileName);
  if (fs.existsSync(todaysFilePath)) {
    let fileLocation;
    let _destPath = '.';
    let _clusterAddrAndPort = 'http://10.173.147.1:8010';
    let _ClusterIP = '10.173.147.1';
    let _filename = todaysFileName,
      _mimetype = 'text/csv',
      _fileStream = fs.createReadStream(todaysFilePath),
      _clusterFilename = todaysFileName.substr(todaysFileName.indexOf('_') + 1);

      request({
        method: 'POST',
        uri: _clusterAddrAndPort + '/Filespray/UploadFile.json?upload_' +
          '&NetAddress=' + _ClusterIP + '&rawxml_=1&OS=2&' +
          'Path=/var/lib/HPCCSystems/mydropzone/',
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
        console.log(response.body)
      }).catch((err) => {
        console.log(err);
      })
    }
}

let uploadToLZ = (todaysFilePath) => {
  let fileLocation;
  let _destPath = '.';
  let _clusterAddrAndPort = 'http://10.173.147.1:8010';
  let _ClusterIP = '10.173.147.1';
  let _filename = filename,
      _mimetype = 'text/csv',
      _fileStream = fs.createReadStream(_destPath + '/' + _filename),
      _clusterFilename = _filename.substr(_filename.indexOf('_') + 1);

      request({
        method: 'POST',
        uri: _clusterAddrAndPort + '/Filespray/UploadFile.json?upload_' +
          '&NetAddress=' + _ClusterIP + '&rawxml_=1&OS=2&' +
          'Path=/var/lib/HPCCSystems/mydropzone/',
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
      });
}

filename = 'simplegit.csv';
//uploadToLZ(filename);
console.log('File ' + filename + ' is uploaded!');

