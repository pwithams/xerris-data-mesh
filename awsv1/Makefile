#--- extract shared variables from [dev,qa,prod].tfvars ---#

LAMBDA_CONTAINER_NAME := `cat $$TERRAFORM_VAR_FILE | grep lambda_container_full_name | sed 's/.*"\(.*\)"$$/\1/g'`
STAGE := `cat $$TERRAFORM_VAR_FILE | grep stage | sed 's/.*"\(.*\)"$$/\1/g'`

GIT_DIGEST := `git rev-parse --short HEAD`

check-build-vars:
	[[ $$TERRAFORM_VAR_FILE ]] || (echo "TERRAFORM_VAR_FILE environment variable not set" && false)


build-lambda-container:
	make check-build-vars
	@echo "Building container..."
	IMAGE_NAME="$(LAMBDA_CONTAINER_NAME):$(GIT_DIGEST)"; cd lambdas && docker build . -t $$IMAGE_NAME

push-lambda-container:
	make build-lambda-container
	bash lambdas/push_image.sh $(LAMBDA_CONTAINER_NAME) $(GIT_DIGEST)

test-lambda-container:
	@echo "Building image..."
	make build-lambda-container
	@echo "Running lambda container as daemon..."
	docker run --rm -d -p 8080:8080 --name test-lambda $(LAMBDA_CONTAINER_NAME):$(GIT_DIGEST)
	@echo "Waiting for container startup..."
	@sleep 2
	@echo "Posting data to lambda container, stop the container, and check result..."
	@echo "Response:"
	@curl -XPOST "http://localhost:8080/2015-03-31/functions/function/invocations" -d '{"data": {"test": 12}}'
	@echo ""
	@docker stop test-lambda 2>&1 > /dev/null
