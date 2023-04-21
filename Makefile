OSS_BUCKET=

.PHONY: build export zip upload publish clean

build:
	docker build -t dew/php82 -f php82/Dockerfile .

export: build
	CID=$$(docker create dew/php82) && docker cp $$CID:/opt/dew ./export/php82 && docker rm $$CID

zip: export/php82
	cd export/php82; zip -r ../php82.zip .

upload: export/php82.zip
	aliyun oss cp export/php82.zip oss://$(OSS_BUCKET)/php82.zip

publish:
	aliyun fc-open CreateLayerVersion --layerName php82 --body "{\"Code\":{\"ossBucketName\":\"$(OSS_BUCKET)\",\"ossObjectName\":\"php82.zip\"},\"compatibleRuntime\":[\"custom\"]}"

clean:
	rm -rf ./export/php82*