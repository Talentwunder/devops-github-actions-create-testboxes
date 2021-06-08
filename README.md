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
name: Upload repo content to S3 bucket

on:
    push:
        branches-ignore:
            - 'master'
            - 'develop'
            - 'dependabot/**'
            - 'release/**'

jobs:
    deploy:
        runs-on: ubuntu-latest
        steps:
            - uses: actions/checkout@master
            - uses: actions/setup-node@v1
              with:
                  node-version: '12.x'
                  registry-url: 'https://registry.npmjs.org'

            - name: Get yarn cache
              id: yarn-cache
              run: echo "::set-output name=dir::$(yarn cache dir)"

            - uses: actions/cache@v1
              with:
                  path: ${{ steps.yarn-cache.outputs.dir }}
                  key: ${{ runner.os }}-yarn-${{ hashFiles('**/yarn.lock') }}
                  restore-keys: |
                      ${{ runner.os }}-yarn-

            - name: Install dependencies
              run: yarn install

            - name: Run unit tests
              run: yarn test:ci
              env:
                  CI: ${{ true }}

            - name: Build branch with dev environment
              run: yarn build:dev

            - uses: aws-actions/configure-aws-credentials@v1
              with:
                  aws-access-key-id: ${{ secrets.TESTBOX_AWS_ACCESS_KEY_ID }}
                  aws-secret-access-key: ${{ secrets.TESTBOX_AWS_SECRET_ACCESS_KEY }}
                  aws-region: 'eu-central-1'

            - uses: Talentwunder/devops-github-actions-create-testboxes@v7
              with:
                  args: --acl public-read --follow-symlinks --delete --exclude '.git/*'


```


### Configuration

It is required to configure the AWS credentials in a separate workflow step so that the action to create the testboxes can execute AWS CLI commands. The required action (`aws-actions/configure-aws-credentials`) and environment variables which need to be passed to it can be seen in the workflow example.

The `AWS_ACCOUNT_NUMBER_SAAS` must be passed as environment variable to the `Talentwunder/devops-github-actions-create-testboxes` as shown in the example. Sensitive information should be [set as encrypted secrets](https://docs.github.com/en/actions/reference/encrypted-secrets) — otherwise, they'll be public to anyone browsing your repository's source code and CI logs.

  

| Key | Value | Suggested Type | Required | Default |
| ------------- | ------------- | ------------- | ------------- | ------------- |
| `AWS_ACCOUNT_NUMBER_SAAS` | AWS account number that is associated with the Lambda function to list the testboxes. | `env` | **Yes** | N/A |
| `AWS_REGION` | The region where you created your bucket. Set to `eu-central-1` by default. [Full list of regions here.](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-available-regions) | `env` | No | `eu-central-1` |
| `SOURCE_DIR` | The local directory (or file) you wish to sync/upload to S3. For example, `public`. Defaults to your entire repository. | `env` | No | `./` (root of cloned repository) |