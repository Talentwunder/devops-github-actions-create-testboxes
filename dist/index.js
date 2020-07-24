module.exports =
/******/ (function(modules, runtime) { // webpackBootstrap
/******/ 	"use strict";
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		var threw = true;
/******/ 		try {
/******/ 			modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/ 			threw = false;
/******/ 		} finally {
/******/ 			if(threw) delete installedModules[moduleId];
/******/ 		}
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	__webpack_require__.ab = __dirname + "/";
/******/
/******/ 	// the startup function
/******/ 	function startup() {
/******/ 		// Load entry module and return exports
/******/ 		return __webpack_require__(77);
/******/ 	};
/******/
/******/ 	// run startup
/******/ 	return startup();
/******/ })
/************************************************************************/
/******/ ({

/***/ 77:
/***/ (function(__unusedmodule, __unusedexports, __webpack_require__) {

const core = __webpack_require__(299);
const exec = __webpack_require__(773);
const glob = __webpack_require__(878);
const io = __webpack_require__(514);
const fs = __webpack_require__(747);
const path = __webpack_require__(622);
const axios = __webpack_require__(858);
const { CloudFront } = __webpack_require__(325);
const FormData = __webpack_require__(575);

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


/***/ }),

/***/ 299:
/***/ (function(module) {

module.exports = eval("require")("@actions/core");


/***/ }),

/***/ 325:
/***/ (function(module) {

module.exports = eval("require")("aws-sdk");


/***/ }),

/***/ 514:
/***/ (function(module) {

module.exports = eval("require")("@actions/io");


/***/ }),

/***/ 575:
/***/ (function(module) {

module.exports = eval("require")("form-data");


/***/ }),

/***/ 622:
/***/ (function(module) {

module.exports = require("path");

/***/ }),

/***/ 747:
/***/ (function(module) {

module.exports = require("fs");

/***/ }),

/***/ 773:
/***/ (function(module) {

module.exports = eval("require")("@actions/exec");


/***/ }),

/***/ 858:
/***/ (function(module) {

module.exports = eval("require")("axios");


/***/ }),

/***/ 878:
/***/ (function(module) {

module.exports = eval("require")("@actions/glob");


/***/ })

/******/ });