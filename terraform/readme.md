yandex container registry login
cat tf_key.json | docker login \
  --username json_key \
  --password-stdin \
  cr.yandex

docker push cr.yandex/crps6iajan0jje7v30hd/catgpt:myapp

docker build . -t cr.yandex/crps6iajan0jje7v30hd/catgpt:myapp

