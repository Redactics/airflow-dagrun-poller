This simple utility utilizes the Airflow REST API to trigger a DAG workflow and polls it until it returns as either `success` or `failed`. This is useful for workflows that depend on Airflow DAGs to run to completion rather than just be queued - for example, a CI/CD pipeline.

I don't know if this will be useful to the open source community in general, or in this particular form factor, but please feel free to use this, extend this, etc.

### Sample Job

An example of how the poller can be utilized in the context of a Kubernetes job is included as `sample-job.yaml`. This poller will work in other contexts too, including as a standalone script.
