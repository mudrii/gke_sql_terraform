# awscli

To run AWS CLI create aliase

```sh
alias aws='docker run --rm -tiv $HOME/.aws:/root/.aws -v $(pwd):/aws mudrii/aws-cli aws'
```