# Wasabi S3 Bucket File Transfer Guide

## Understanding the Problem

[Wasabi S3 API Official Docs](https://docs.wasabi.com/docs/operations-on-buckets)

[Stack Overflow Reference](https://stackoverflow.com/questions/68415772/the-aws-access-key-id-you-provided-does-not-exist-in-our-records-aws)

When attempting to transfer files to a Wasabi S3 bucket using the AWS CLI, you may encounter difficulties due to Wasabi's unique configuration. The main issue is that Wasabi requires a specific endpoint URL to be specified, which differs from standard AWS S3 buckets.

Wasabi is an S3-compatible cloud storage service, but it uses its own infrastructure separate from Amazon Web Services. This means that while you can use AWS CLI and SDKs to interact with Wasabi buckets, you need to explicitly tell these tools where to find the Wasabi servers.

## Using AWS CLI with Wasabi

### Authentication

First, you need to configure your AWS CLI with your Wasabi credentials. Run the following command and enter your Wasabi access key and secret key when prompted:

```sh
aws configure
```

Example (using fake credentials):
```
AWS Access Key ID: AKIAIOSFODNN7EXAMPLE
AWS Secret Access Key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
Default region name: us-west-1
Default output format: json
```

### Copying a Single File

To copy a single file to your Wasabi bucket, use the following command structure:

```sh
aws s3 cp <local-file> s3://<bucket-name> --endpoint-url=https://s3.<region>.wasabisys.com
```

### Syncing an Entire Directory

To sync an entire directory with your Wasabi bucket, use the `sync` command:

```sh
aws s3 sync <local-directory> s3://<bucket-name> --endpoint-url=https://s3.<region>.wasabisys.com
```

## Python Example

Here's a simple Python script that demonstrates file upload and directory sync using the boto3 library:

```python
import boto3
import os

# Wasabi credentials and configuration
access_key = 'YOUR_ACCESS_KEY'
secret_key = 'YOUR_SECRET_KEY'
endpoint_url = 'https://s3.us-west-1.wasabisys.com'
region = 'us-west-1'
bucket_name = '<bucket-name>'

# Create a session with Wasabi credentials
session = boto3.Session(
    aws_access_key_id=access_key,
    aws_secret_access_key=secret_key,
    region_name=region
)

# Create S3 client
s3 = session.client('s3', endpoint_url=endpoint_url)

# Upload a single file
def upload_file(file_path):
    file_name = os.path.basename(file_path)
    s3.upload_file(file_path, bucket_name, file_name)
    print(f"Uploaded {file_name} to {bucket_name}")

# Sync a directory
def sync_directory(directory_path):
    for root, dirs, files in os.walk(directory_path):
        for file in files:
            local_path = os.path.join(root, file)
            relative_path = os.path.relpath(local_path, directory_path)
            s3.upload_file(local_path, bucket_name, relative_path)
    print(f"Synced {directory_path} to {bucket_name}")

# Example usage
upload_file('myfile.txt')
sync_directory('./my-folder')
```

## Node.js Example

Here's a Node.js script that demonstrates the same functionality using the AWS SDK:

```javascript
const AWS = require('aws-sdk');
const fs = require('fs');
const path = require('path');

// Wasabi credentials and configuration
const accessKey = 'YOUR_ACCESS_KEY';
const secretKey = 'YOUR_SECRET_KEY';
const endpointUrl = 'https://s3.us-west-1.wasabisys.com';
const region = 'us-west-1';
const bucketName = '<bucket-name>';

// Configure AWS SDK
AWS.config.update({
  accessKeyId: accessKey,
  secretAccessKey: secretKey,
  region: region,
  endpoint: endpointUrl
});

const s3 = new AWS.S3();

// Upload a single file
function uploadFile(filePath) {
  const fileName = path.basename(filePath);
  const fileContent = fs.readFileSync(filePath);

  const params = {
    Bucket: bucketName,
    Key: fileName,
    Body: fileContent
  };

  s3.upload(params, (err, data) => {
    if (err) {
      console.error("Error", err);
    } else {
      console.log(`Uploaded ${fileName} to ${bucketName}`);
    }
  });
}

// Sync a directory
function syncDirectory(directoryPath) {
  fs.readdirSync(directoryPath, { withFileTypes: true }).forEach((dirent) => {
    const fullPath = path.join(directoryPath, dirent.name);
    if (dirent.isFile()) {
      const fileContent = fs.readFileSync(fullPath);
      const params = {
        Bucket: bucketName,
        Key: dirent.name,
        Body: fileContent
      };
      s3.upload(params, (err, data) => {
        if (err) {
          console.error("Error", err);
        } else {
          console.log(`Uploaded ${dirent.name} to ${bucketName}`);
        }
      });
    } else if (dirent.isDirectory()) {
      syncDirectory(fullPath);
    }
  });
}

// Example usage
uploadFile('myfile.txt');
syncDirectory('./my-folder');
```

Remember to replace 'YOUR_ACCESS_KEY' and 'YOUR_SECRET_KEY' with your actual Wasabi credentials in both the Python and Node.js examples.

By using these methods, you should be able to successfully transfer files to your Wasabi S3 bucket. The key difference when working with Wasabi is the need to specify the correct endpoint URL, which points to Wasabi's servers instead of AWS's. This allows the S3-compatible tools to communicate with Wasabi's infrastructure while using the familiar S3 protocols and commands.

I hope this guide helps you and your client navigate the nuances of working with Wasabi S3 buckets. If you have any further questions or need additional clarification, please don't hesitate to ask!