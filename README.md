# GitHub Action to Create a S3 Bucket and copy testbox static files to it

## Usage

### `workflow.yml` Example

Place in a `.yml` file such as this one in your `.github/workflows` folder. [Refer to the documentation on workflow YAML syntax here.](https://help.github.com/en/articles/workflow-syntax-for-github-actions)

#### The following example includes optimal defaults for a public static website:

- `--acl public-read` makes your files publicly readable (make sure your [bucket settings are also set to public](https://docs.aws.amazon.com/AmazonS3/latest/dev/WebsiteAccessPermissionsReqd.html)).
- `--follow-symlinks` won't hurt and fixes some weird symbolic link problems that may come up.
- Most importantly, `--delete` **permanently deletes** files in the S3 bucket that are **not** present in the latest version of your repository/build.
- **Optional tip:** If you're uploading the root of your repository, adding `--exclude '.git/*'` prevents your `.git` folder from syncing, which would expose your source code history if your project is closed-source. (To exclude more than one pattern, you must have one `--exclude` flag per exclusion. The single quotes are also important!)

```yaml
name: Upload static site to S3 bucket

on:
  push:
    branches-ignore:
      - master
        
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@master

      - uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID_TESTBOX }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY_TESTBOX }}
          aws-region: 'eu-central-1'

      - uses: Talentwunder/devops-github-actions-create-testboxes@v1
        with:
          args: --acl public-read --follow-symlinks --delete --exclude '.git/*'

```


### Configuration

The following settings must be passed as environment variables as shown in the example. Sensitive information, especially `AWS_ACCESS_KEY_ID_TEXTBOX` and `AWS_SECRET_ACCESS_KEY_TEXTBOX`, should be [set as encrypted secrets](https://help.github.com/en/articles/virtual-environments-for-github-actions#creating-and-using-secrets-encrypted-variables) — otherwise, they'll be public to anyone browsing your repository's source code and CI logs.

| Key | Value | Suggested Type | Required | Default |
| ------------- | ------------- | ------------- | ------------- | ------------- |
| `AWS_ACCESS_KEY_ID_TEXTBOX` | Your AWS Access Key. [More info here.](https://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html) | `secret env` | **Yes** | N/A |
| `AWS_SECRET_ACCESS_KEY_TEXTBOX` | Your AWS Secret Access Key. [More info here.](https://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html) | `secret env` | **Yes** | N/A |
| `AWS_REGION` | The region where you created your bucket. Set to `eu-central-1` by default. [Full list of regions here.](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-available-regions) | `env` | No | `eu-central-1` |
| `SOURCE_DIR` | The local directory (or file) you wish to sync/upload to S3. For example, `public`. Defaults to your entire repository. | `env` | No | `./` (root of cloned repository) |
