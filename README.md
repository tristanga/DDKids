docker build -t DDKids .

docker run --rm --name app -p 8050:8050 DDKids

docker kill app
