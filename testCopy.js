const gitP = require('simple-git/promise');
const REPO = 'https://github.com/CSSEGISandData/COVID-19.git';
var path = require('path');

// gitP().silent(true)
//   .clone(REPO)
//   .then(() => console.log('finished'))
//   .catch((err) => console.error('failed: ', err));

const git = require('simple-git')('./COVID-19');
const fs = require('fs');
let request = require('request-promise');


let fileList = [];
let todaysFileName = '' ;
git
  .exec(() => console.log('Starting pull...'))
  .pull('origin', 'master',(err, update) => {
      console.log(update);
      if(update && update.summary.changes) {
        fileList = update.files;
        console.log(fileList);
      }
   })
  .exec(() => {
    fileList.forEach((item) => {
      console.log(item);
      todaysFileName = item
      upload();
    });
  });


let upload = () => {
  let todaysFilePath = path.join(__dirname, 'COVID-19/' + todaysFileName);
  if (fs.existsSync(todaysFilePath)) {
    let fileLocation;
    let _destPath = '.';
    let _clusterAddrAndPort = 'http://10.173.147.1:8010';
    let _ClusterIP = '10.173.147.1';
    let _filename = todaysFileName,
      _mimetype = 'text/csv',
      _fileStream = fs.createReadStream(todaysFilePath),
      _clusterFilename = path.basename(todaysFileName);

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
        console.log(response.body)
        console.log('End of upload')
      }).catch((err) => {
        console.log(err);
      })
    }
}




