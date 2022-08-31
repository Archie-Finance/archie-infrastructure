"use strict";

exports.handler = (event, _, callback) => {
  // Extract the request from the CloudFront event that is sent to Lambda@Edge
  let request = event.Records[0].cf.request;
  // Extract the URI from the request
  let oldUri = request.uri;
  
  console.log('OLDURI', oldUri)
  
  // If URI is a file
  const isFile = /\/[^/]+\.[^/]+$/.test(oldUri);
  // If not a file request and does not end with / redirect to /
  if (!isFile && !oldUri.endsWith("/")) {
    request.uri = `${oldUri}/index.html`;
    return callback(null, request);
    // return callback(null, {
    //   body: "",
    //   status: "301",
    //   statusDescription: "Moved Permanently",
    //   querystring: request.querystring,
    //   headers: {
    //     location: [
    //       {
    //         key: "Location",
    //         value: `${oldUri}/`,
    //       },
    //     ],
    //   },
    // });
  }
  // Match any '/' that occurs at the end of a URI. Replace it with a default index
  request.uri = oldUri.replace(/\/$/, "/index.html");
  // Return to CloudFront
  return callback(null, request);
};