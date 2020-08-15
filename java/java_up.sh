
RES=$(docker ps | grep java-workspace)

if [ "$?" == "1" ]
then
	docker run -d \
		--name java-workspace \
		-v $(pwd):/app \
		--net host \
		-w /app \
		openjdk:11 \
		tail -f /dev/null

fi

docker exec -it java-workspace bash
