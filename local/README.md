# Local Development

## Setup

1. Create a Lima VM. It *must* have the user-v2 kind of network. No other type of network works with Superset. I don't understand why. The symptom of a non-functional network is that the first request to the Superset container will succeed (such as visiting http://localhost:8088), but all requests thereafter will become stuck in "pending" state.
    ```
    limactl create --name=containerd --network lima:user-v2
    ```
1. Deploy the containers.
    ```
    limactl shell containerd nerdctl compose up --build --file ./local/container-compose.yaml
    ```
1. Go to http://localhost:8088.

## Cleanup

1. Delete the containers and the data volumes.
    ```
    limactl shell containerd nerdctl compose down --file ./local/container-compose.yaml --volumes
    ```
