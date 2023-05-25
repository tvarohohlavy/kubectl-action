# Kubectl Action

> I archived this repository because I think there are now more appropriate options like helm and argocd

This action allows you to deploy to a kubernetes cluster.

Alternatives:

- [steebchen/kubectl](https://github.com/marketplace/actions/kubernetes-cli-kubectl)

## Inputs

### `kubeconfig`

Base64 encoded `.kube/config` file, to generate use:
```shell script
cat .kube/config | base64
```

## Outputs
### `output`

kubectl commands output


## Usage
## Kustomize a Deployment
```yaml
- name: Kustomize
  uses: danielr1996/kubectl-action@1.0.0
  with:
    args: kustomize deployment/overlays/replace > template.yaml
```

## Deploy a Deployment
```yaml
- uses: danielr1996/kubectl-action@1.0.0
  name: Deploy
  with:
    kubeconfig: ${{ secrets.KUBE_CONFIG }}
    args: apply -f deployment.yaml
```


## Multiple kubectl commands
```yaml
- uses: danielr1996/kubectl-action@1.0.0
  name: Deploy
  with:
    kubeconfig: ${{ secrets.KUBE_CONFIG }}
    args: |
      create namespace my-namespace
      delete secret -n my-namespace secret-credentials --ignore-not-found
      create secret -n my-namespace generic secret-credentials \
                    --from-literal=USERNAME=${{secrets.USERNAME}} \
                    --from-literal=PASSWORD=${{secrets.PASSWORD}}
      apply -f deployment.yaml
```



## Outputs usage

```yaml
  scale_down:
    runs-on: [ self-hosted ]
    outputs:
     replicas: ${{ steps.get_replicas.outputs.output }}
    steps:
    - name: get replicas count
      id: get_replicas
      uses: danielr1996/kubectl-action@1.0.0
      with:
        kubeconfig: ${{ secrets.KUBECONFIG }}
        args: |
          get deployments.apps app -o jsonpath='{.spec.replicas}'
    - name: scale down to 0 replicas
      uses: danielr1996/kubectl-action@1.0.0
      with:
        kubeconfig: ${{ secrets.KUBECONFIG }}
        args: |
          scale --replicas=0 deployment app

  scale_up:
    runs-on: [ self-hosted ]
    needs: [ scale_down ]
    steps:          
    - name: create environmental variable
      run: |
        echo "REPLICAS=${{ needs.scale_down.outputs.replicas }}" | tr -d "'" >> $GITHUB_ENV
        
    - name: scale up to original number of replicas
      uses: danielr1996/kubectl-action@1.0.0
      with:
        kubeconfig: ${{ secrets.KUBECONFIG }}
        args: |
          scale --replicas=${{ env.REPLICAS }} deployment app
```
