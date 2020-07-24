const core = require('@actions/core');
const exec = require('@actions/exec');
const glob = require('@actions/glob');
const io = require('@actions/io');
const fs = require('fs');
const path = require('path');
const axios = require('axios');
const { CloudFront } = require('aws-sdk');
const FormData = require('form-data');

/**
 * Take everything from the "build" directory and move it into S3.
 * Note that "index.html" should not be cached.
 * @param bucketName {string}
 * @param version {string}
 */
async function syncS3Bucket(bucketName, version) {
    console.log('Syncing the build directory to S3');

    const bucketPath = `${bucketName}/v${version}`;
    console.log('Destination S3 is located at: ', bucketPath);

    await exec.exec(`aws s3 sync build/ s3://${bucketPath} --delete --exclude index.html`);
    console.log('Files uploaded.');

    await exec.exec(`aws s3 cp build/index.html s3://${bucketPath}/index.html --metadata-directive REPLACE --cache-control max-age=0,no-cache,no-store,must-revalidate --content-type text/html`)
    console.log('Adding cache control to "index.html"');
}

async function run() {
    try {
        console.log('Starting deployment to S3');

        const s3BucketName = core.getInput('bucketName');

        console.log('Bucket name: ', s3BucketName);

        console.log('Reading version from "package.json"');
        const version = JSON.parse(fs.readFileSync('package.json', 'utf8')).version;
        console.log('Version: ', version);

        console.log('All done!');
    } catch (e) {
        core.setFailed(e.message);
    }
}

run();
