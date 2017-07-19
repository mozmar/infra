## Snippets provisioning

1. you'll need to provision snippets infra by using the Terraform in the
`./infra` directory.

2. Install the application 
    1. Ensure your Kubernetes and Deis Workflow environments are set correctly!
    2. run `./setup.sh`
    3. follow the "Additional app installation steps" section below 
    4. run `./scale.sh`

3. Until we automate the IAM roles for snippets, add the appropriate values to
the following role:

```
arn:aws:iam::236517346949:user/snippets_prod 
```

4. [Create an ELB](https://github.com/mozmar/infra/tree/master/elbs) for the app in the new region.

5. IT owns the cloudfront CDN so we need to add a new origin there

    - See [this bug](https://bugzilla.mozilla.org/show_bug.cgi?id=1382211) for more info.

> Note: if the application is reinstalled via Deis Workflow, the snippets ELB **must** be recreated as the port #'s have changed.

### How to apply Terraform in a given region

```shell
# set your K8s/WF/config.sh appropriately
cd ./infra/<some_region>
./provision.sh
```

### Additional app installation steps


#### MySQL read replica

- until we automate this part, create an RDS read replica using params from similar read replicas in other regions.

- The username/password will remain the same, but the host part of the `DATABASE_URL` value will change.

#### Environment setup

In additional to the standard set of app variables (which can be found in our private
repo), set the following values:

- `AWS_S3_HOST`
    - ex: `s3-eu-central-1.amazonaws.com`
- `AWS_STORAGE_BUCKET_NAME`
- `CACHE_URL`
- `DATABASE_URL`
- `DEIS_DOMAIN`
- `MEDIA_BUNDLES_URL`
    - This is in the form `<regionname>/bundles/`
    - ex: `frankfurt/bundles/`
- `NEW_RELIC_APP_NAME`
- `SITE_URL`
- `STATSD_PREFIX`

Once you have a config file ready with the correct values, use a command similar to the following to load the new values:

```
deis config:push -p ./foo.cfg -a snippets-prod
```

**Note:** The pods will most likely be in an `Error` state until you create the database and set the environment.

### Project Source

https://github.com/mozmar/snippets-service/

