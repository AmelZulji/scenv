docker build -f dockerfiles/multiomems_paper1.0.Dockerfile -t amelzulji/multiomems_paper:1.0 .
docker login
docker push amelzulji/multiomems_paper:1.0