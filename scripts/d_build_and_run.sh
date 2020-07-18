docker build -t cfe-jupyter -f Dockerfile .

docker run --env PORT=8888 -it -p 8888:8888 cfe-jupyter
