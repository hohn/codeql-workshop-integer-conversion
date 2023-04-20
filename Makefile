all: linux-5.12-db.zip

.docker-build: Dockerfile
	docker build -t codeql-workshop-integer-conversion .
	touch .docker-build

linux-5.12-db.zip: .docker-build
	docker run -v "$(PWD):/data" codeql-workshop-integer-conversion database create --overwrite -l cpp -s linux --command=make /data/linux-5.12-db
	codeql database bundle -o linux-5.12-db.zip linux-5.12-db
	rm -rf linux-5.12-db

.PHONY: clean
clean:
	-rm -r linux-5.12-db.zip
	-docker rmi -f codeql-workshop-integer-conversion
	-rm .docker-build