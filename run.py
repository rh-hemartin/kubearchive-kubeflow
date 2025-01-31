from kfp.client import Client

client = Client(host='http://localhost:8080', verify_ssl=False)
run = client.create_run_from_pipeline_package(
    'pipeline.yaml',
    arguments={
        'recipient': 'World',
    },
)


run = client.create_run_from_pipeline_package(
    'pipeline.yaml',
    arguments={
        'recipient': 'Hector',
    },
)
