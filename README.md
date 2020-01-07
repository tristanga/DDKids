docker build -t appwithdash .

docker run --rm --name app -p 8050:8050 appwithdash

docker kill app
