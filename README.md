This simple utility utilizes the Airflow REST API to trigger a DAG workflow and polls it until it returns as either `success` or `failed`. This is useful for workflows that depend on Airflow DAGs to run to completion rather than just be queued - for example, a CI/CD pipeline.

I don't know if this will be useful to the open source community in general, or in this particular form factor, but please feel free to use this, extend this, etc.

### Sample Job

An example of how the poller can be utilized in the context of a Kubernetes job is included as `sample-job.yaml`. This poller will work in other contexts too, including as a standalone script.

### Support for following Airflow log output

When the variable `TAIL_TASK_ID` is set, at polling time the poller will also return log output for this provided Airflow task ID. This allows tracking progress of the DagRun. In the future support may be added for following output for all active tasks, but feel free to contribute this feature!
