# TW S3 & CloudFront Deployment GitHub Action 

**Disclaimer**
If you want to update the code in `index.js`, make sure to commit the bundle as well after running `yarn package`.

This action syncs the `build` folder to S3

The version will be pulled from the `version` prop in `package.json`.

## Inputs

### `bucketName`

**Required** Bucket name where the application build should be synced to

```yaml
uses: Talentwunder/devops-github-actions-testboxes@master
with:
  bucketName: 'app.talentwunder.com'
env:
  AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
  AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```
Note that you need to make sure AWS credentials are available as environment variables.
